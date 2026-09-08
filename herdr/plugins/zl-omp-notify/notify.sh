#!/bin/sh
# herdr 插件: pane.agent_status_changed → agent 进入 blocked 时发 omp 风格中文通知。
# 事件驱动, 取代 launchd 轮询版 (~/dotfile/launchd/omp-herdr-watch.sh, 已停用可回滚)。
# 抑制语义对齐 herdr 自带通知: pane 在聚焦 tab 且 Ghostty 前台 → 不打扰;
# 同一 blocked 周期只发一次, 状态离开 blocked 后自动重新武装。
set -u
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
STATE="${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/zl-omp-notify}"
mkdir -p "$STATE"
NOTIFIED="$STATE/notified"

# 事件载荷: {"data":{"agent_status":..., "pane_id":...}, ...} (见官方 agent-telegram-notify 示例)
status=$(printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-}" | jq -r '.data.agent_status // empty' 2>/dev/null)
[ "$status" = "blocked" ] || exit 0

pane=$(printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-}" | jq -r '.data.pane_id // empty' 2>/dev/null)
[ -n "$pane" ] || pane="${HERDR_PANE_ID:-}"
[ -n "$pane" ] || exit 0

snap=$("$HERDR_BIN_PATH" api snapshot 2>/dev/null) || exit 0
row=$(printf '%s' "$snap" | jq -r --arg pane "$pane" '
  .result.snapshot as $s |
  ($s.workspaces | map({(.workspace_id // ""): (.name // .workspace_id // "")}) | add // {}) as $wsn |
  [ $s.panes[] | select(.pane_id == $pane) ][0] as $p |
  select($p != null) |
  [ ($p.agent // $pane)
  , ($wsn[$p.workspace_id // ""] // $p.workspace_id // "?")
  , (if ($p.tab_id // "") == ($s.focused_tab_id // "") then "y" else "n" end) ]
  | @tsv' 2>/dev/null) || exit 0
[ -n "$row" ] || exit 0

agent=$(printf '%s' "$row" | cut -f1)
ws=$(printf '%s' "$row" | cut -f2)
in_focused=$(printf '%s' "$row" | cut -f3)

if [ "$in_focused" = "y" ]; then
  asn=$(lsappinfo front 2>/dev/null) || exit 0
  bid=$(lsappinfo info -only bundleid "$asn" 2>/dev/null) | sed -E 's/.*"([^"]+)".*/\1/'
  [ "$bid" = "com.mitchellh.ghostty" ] && exit 0   # 用户正盯着这个 herdr 窗口
fi

touch "$NOTIFIED"
grep -qxF "$pane" "$NOTIFIED" && exit 0
osascript -e "display notification \"${agent} 在「${ws}」需要你输入 (${pane})\" with title \"omp · 等待输入\" sound name \"default\""
printf '%s\n' "$pane" >> "$NOTIFIED"

# 清理已离开 blocked 的 pane, 解除武装 (重建当前仍 blocked 的集合)
printf '%s' "$snap" | jq -r '
  [ .result.snapshot.panes[] | select(.agent_status == "blocked") | .pane_id ] | .[]' \
  > "$NOTIFIED.new" 2>/dev/null && mv "$NOTIFIED.new" "$NOTIFIED"

exit 0
