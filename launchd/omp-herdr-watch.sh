#!/bin/sh
# omp-herdr-watch: 轮询 herdr 快照, agent 进入 blocked(需要输入)时发 omp 风格中文通知。
# 补 omp-done 盲区(它只在收工时跑); herdr 状态机检测, 不依赖 agent 自觉。
# 由 launchd 常驻: ~/Library/LaunchAgents/com.zllynx.omp-herdr-watch.plist
# 抑制语义对齐 herdr 自带通知: pane 在聚焦 tab 且 Ghostty 前台 → 不打扰;
# 用户切走后同一 blocked 事件也不再补发(已在"看着"的时候交付过状态)。
set -u

INTERVAL=${OMPHW_INTERVAL:-3}
ONESHOT=0
[ "${1:-}" = "once" ] && ONESHOT=1
RUNDIR="${TMPDIR:-/tmp}/omp-herdr-watch"
mkdir -p "$RUNDIR"
CAND="$RUNDIR/candidates"
NOTIFIED="$RUNDIR/notified"
NEXT="$RUNDIR/notified.next"
: > "$CAND"

GHOSTTY_BUNDLE="com.mitchellh.ghostty"

frontmost_bundle() {
  local asn bid
  asn=$(lsappinfo front 2>/dev/null) || return 1
  bid=$(lsappinfo info -only bundleid "$asn" 2>/dev/null) || return 1
  printf '%s' "$bid" | sed -E 's/.*"([^"]+)".*/\1/'
}

while :; do
  snap=$(herdr api snapshot 2>/dev/null) || { [ "$ONESHOT" = 1 ] && exit 0; sleep 5; continue; }

  printf '%s' "$snap" | jq -r '
    .result.snapshot as $s |
    ($s.workspaces
     | map({(.workspace_id // ""): (.name // .workspace_id // "")})
     | add // {}) as $wsn |
    [ $s.panes[]
      | select(.agent_status == "blocked")
      | [ (.agent // .pane_id // "?")
        , .pane_id
        , ($wsn[.workspace_id // ""] // .workspace_id // "?")
        , (if (.tab_id // "") == ($s.focused_tab_id // "") then "y" else "n" end) ]
      | @tsv ][]' > "$CAND" 2>/dev/null || printf '' > "$CAND"

  : > "$NEXT"
  while IFS="	" read -r agent pane ws in_focused; do
    [ -n "${pane:-}" ] || continue
    if [ "$in_focused" = "y" ]; then
      # 聚焦 tab 上 blocked: 仅当 Ghostty 不是前台(用户根本没在看)才打扰
      [ "$(frontmost_bundle)" = "$GHOSTTY_BUNDLE" ] && { printf '%s\n' "$pane" >> "$NEXT"; continue; }
    fi
    if ! grep -qxF "$pane" "$NOTIFIED" 2>/dev/null; then
      osascript -e "display notification \"${agent} 在「${ws}」需要你输入 (${pane})\" with title \"omp · 等待输入\" sound name \"default\""
    fi
    printf '%s\n' "$pane" >> "$NEXT"
  done < "$CAND"
  mv "$NEXT" "$NOTIFIED"

  [ "$ONESHOT" = 1 ] && exit 0
  sleep "$INTERVAL"
done
