# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# -------------
# proxy setting
# -------------

# 代理端口配置（可在 ~/.user_env.sh 中覆盖）
export PROXY_PORT=${PROXY_PORT:-10808}
export PROXY_TYPE=${PROXY_TYPE:-http}

# 自动探测代理主机: macOS / 普通 Linux 用 127.0.0.1; WSL 取 Windows 宿主 IP
setup_proxy_host() {
    local os_type=$(uname -s)

    if [[ "$os_type" == "Darwin" ]]; then
        export PROXY_HOST="127.0.0.1"
    elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
        # WSL: 优先用默认网关, 失败则退回 resolv.conf
        local win_ip=""
        command -v ip >/dev/null 2>&1 && win_ip=$(ip route 2>/dev/null | awk '/default/{print $3; exit}')
        [[ -z "$win_ip" ]] && win_ip=$(grep -m1 nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}')
        if [[ -z "$win_ip" ]]; then
            echo "⚠️  无法自动获取 WSL 主机 IP，使用默认值 127.0.0.1" >&2
            win_ip="127.0.0.1"
        fi
        export PROXY_HOST="$win_ip"
    else
        export PROXY_HOST="127.0.0.1"
    fi
}

# 设置代理: 导出环境变量 + git 全局配置
setproxy() {
    setup_proxy_host

    local proxy_url="$PROXY_TYPE://$PROXY_HOST:$PROXY_PORT"
    local socks_url="socks5://$PROXY_HOST:$PROXY_PORT"

    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"
    export all_proxy="$socks_url"
    export ALL_PROXY="$socks_url"   # 大写兜底: Homebrew curl 清理 https_proxy 后走 SOCKS5, 避免大文件 HTTP CONNECT 中断
    export no_proxy="localhost,127.0.0.1,localaddress,.local"

    # git 也走代理，确保 brew update / omp update 等能连 GitHub
    git config --global http.proxy "$proxy_url"
    git config --global https.proxy "$proxy_url"

    echo "✅ 代理已启动: $proxy_url"
}

# 取消代理
unsetproxy() {
    unset http_proxy https_proxy all_proxy ALL_PROXY no_proxy
    git config --global --unset http.proxy 2>/dev/null
    git config --global --unset https.proxy 2>/dev/null
    echo "❌ 代理已关闭"
}

# 测试配置的代理是否可用 (直接探测 PROXY_HOST:PROXY_PORT, 不依赖已设置的 env)
# 交互直接调用看输出; 脚本中用返回值判断 (0 = 可用)
testproxy() {
    setup_proxy_host
    local proxy_url="$PROXY_TYPE://$PROXY_HOST:$PROXY_PORT"
    if curl -x "$proxy_url" -sI -m 5 --connect-timeout 3 https://www.google.com >/dev/null 2>&1; then
        echo "✅ 代理可用: $proxy_url"
        return 0
    else
        echo "❌ 代理不可用: $proxy_url"
        return 1
    fi
}

# 包裹一条命令: 代理可用则临时 setproxy, 执行完自动 unsetproxy (仅关闭本函数开启的代理)
# 对 `curl ... | sh` 这类管道下载, 用 `with_proxy sh -c '...'` 包裹整条命令,
# 否则管道右侧命令在子 shell 中拿不到代理环境变量.
# Usage: with_proxy <command> [args...]
with_proxy() {
    (( $# )) || { echo "with_proxy: 缺少命令" >&2; return 1; }
    local _enabled=0
    if testproxy >/dev/null 2>&1; then
        setproxy >/dev/null 2>&1
        _enabled=1
    fi
    "$@"
    local _rc=$?
    ((_enabled)) && unsetproxy >/dev/null 2>&1
    return $_rc
}
# 跨平台取文件 mtime(秒, lstat 不跟随软链)。
# macOS/BSD 与 Linux/GNU 的 stat 格式不同, 在此按平台一次性选定函数。
# ⚠️ 不要用 `stat -f %m X 2>/dev/null || stat -c %Y X` 兼容两端:
#    GNU stat 把 `-f` 解释成"显示文件系统状态"模式, 失败时仍会把文件系统信息打到 stdout,
#    污染命令替换结果 → 触发 `bad math expression: operand expected`(WSL 实测)。
# 文件不存在或 stat 失败时输出空串, 调用方用 [[ -n $v ]] 判断。
case "$(uname)" in
  Darwin) _stat_mtime() { stat -f %m "$1" 2>/dev/null; } ;;
  *)      _stat_mtime() { stat -c %Y "$1" 2>/dev/null; } ;;
esac

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    with_proxy curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && with_proxy wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# Fix: asciiship PS1 starts with \n, causing empty line before first prompt.
# Remove it from PS1 and use precmd to add newline between prompts instead.
PS1="${PS1#$'\n'}"
_prompt_newline_added=0
function _prompt_add_newline() {
  if (( _prompt_newline_added )); then
    print ''
  fi
  _prompt_newline_added=1
}
add-zsh-hook precmd _prompt_add_newline

# ------------------------------
# Post-init module configuration
# ------------------------------

#  fix [BUG] Completion failing on Ubuntu 20.04 (fzf version <= 0.20.0)
#  https://github.com/Aloxaf/fzf-tab/issues/391
zstyle ':fzf-tab:*' fzf-bindings-default 'tab:down,btab:up,change:top,ctrl-space:toggle,bspace:backward-delete-char,ctrl-h:backward-delete-char'

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

# -----
# alias
# -----

alias rm="rm -i"
alias n="nvim"
alias tn="tmux new-session -s"
alias ta="tmux attach-session -t"
alias rn="rmux new-session -s"
alias ra="rmux attach-session -t"
alias tf="tmuxifier"
alias c="clear"
alias lg="lazygit"
alias lzd="lazydocker"
alias vim="vim -c \"syntax on\""
alias ra="ranger"
alias rr="source ranger"
alias cld="claude"
alias oc="opencode"

# ---------
# git alias
# ---------

alias gs="git status"
alias gc="git checkout"
alias gb="git branch"
alias gl="git log"
alias glg="git log --oneline"

# ----
# Misc
# ----


# yazi shell wrapper.
# use `y` instead of yazi to start, and press q to quit,you'll see the CWD changed.Press Q to keep original directory.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# rp: realpath + copy to clipboard (cross-platform)
# Usage: rp <file>... | rp (fzf picker) | rp <TAB> (fzf completion)
_rp_clip() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    pbcopy
  elif command -v wl-copy &>/dev/null; then
    wl-copy
  elif command -v xclip &>/dev/null; then
    xclip -selection clipboard
  elif command -v xsel &>/dev/null; then
    xsel --clipboard --input
  else
    cat > /dev/null
  fi
}

_rp_one() {
  local resolved
  resolved=$(realpath "$1" 2>/dev/null) || { echo "rp: $1: not found" >&2; return 1; }
  echo "$resolved"
  if echo -n "$resolved" | _rp_clip; then
    echo "  → copied" >&2
  fi
}

# rp 共用的文件列表: 只搜当前目录第一层(不递归), 含隐藏文件(否则搜不到 .env 这类配置).
_rp_finder() {
  if command -v fd &>/dev/null; then
    fd --type f --hidden --max-depth 1
  else
    find . -maxdepth 1 -type f
  fi
}

rp() {
  if [[ $# -gt 0 ]]; then
    local f
    for f in "$@"; do _rp_one "$f"; done
  else
    local files
    files=$(_rp_finder 2>/dev/null | fzf -m \
      --preview 'bat --color=always --style=numbers {} 2>/dev/null || head -80 {}' < /dev/tty)
    [[ -n "$files" ]] || return 1
    while IFS= read -r f; do _rp_one "$f"; done <<< "$files"
  fi
}

# rp 补全: 原生 zsh 菜单(和 rm/cd 一致). 不要在补全里嵌套 fzf ——
# 它和 ZLE 抢终端, 会卡死且 ESC 退不出; fzf 体验用裸 `rp` 选择器就有.
if (( ${+functions[compdef]} )); then
  _rp() {
    local -a files
    files=(${(f)"$(_rp_finder 2>/dev/null)"})
    (( ${#files} )) && compadd -- $files
  }
  compdef _rp rp
fi

# shell working directory reporting. 
# https://github.com/Eugeny/tabby/wiki/Shell-working-directory-reporting
precmd () { echo -n "\x1b]1337;CurrentDir=$(pwd)\x07" }

os=$(uname -s)

# set bat theme
export BAT_THEME="gruvbox-dark"
if [ $os != "Darwin" ] && [ ! -e ~/.local/bin/bat ] && [ ! -e /usr/bin/bat ] && [ -e /usr/bin/batcat ];then
  # installed from apt, binary name is batcat, from release, binary name is bat
  # create the link when:
  # 1. not in macos
  # 2. not installed bat from realease
  # 3. not link bat to batcat already
   ln -s /usr/bin/batcat ~/.local/bin/bat
fi

if [ -e ~/local/bin/bat ];then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'" # man with bat
fi

# 加载 fzf 设置.
# 裸 fzf/fzfp 无输入时走内置 walker, 默认 hidden+follow 在家目录会扫 12w+ 文件卡死.
# 限制为可见文件, 并跳过依赖/构建目录.
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --walker file --walker-skip .git,node_modules,target,dist,build,__pycache__'
alias fzfp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# 关闭 homebrew 自动更新
export HOMEBREW_NO_AUTO_UPDATE=true

# set default editor
export EDITOR=nvim

# 加载本机个人设置
[ -f ~/.user_env.sh ] && source ~/.user_env.sh 
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Not display the timestap when CtrlR search the history
export ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=0

#! SHLVL 表示当前shell的嵌套程度. 在tmux中,shlvl会是2,在asciiship这个prompt中会一直显示,这里只是为了让它不显示.
# 如果出了问题,再删除
export SHLVL=1


# set TERM variable
if [[ $TERM == xterm ]]; then TERM=xterm-256color; fi
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    export TERM=xterm-256color
fi

# 有个插件的alias 覆盖了我 ls 设置,所以把自己的放到最后,避免覆盖
if command -v lsd &> /dev/null; then # In unix , exit code 0 is true.
  alias ls='lsd'
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
else
  alias ll='ls -lF'
  alias lla='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi

# some universal path
export PATH=$PATH:$HOME/.local/bin 
export PATH=$PATH:$HOME/.tmux/plugins/tmuxifier/bin

# set hugging face mirror site
export HF_ENDPOINT=https://hf-mirror.com

# init tmuxifier
# tmuxifier layout file is placed in $TMUXIFIER_LAYOUT_PATH
# $TMUXIFIER_LAYOUT_PATH default is where the tmuxifier installed.
# $HOME/.tmux/plugins/tmuxifier/layouts/

# auto-install tmuxifier if not exists
if [ ! -d "$HOME/.tmux/plugins/tmuxifier" ]; then
	with_proxy git clone https://github.com/jimeh/tmuxifier.git ~/.tmux/plugins/tmuxifier
fi
# ---------------------------------------------------------------------------
# Shell init 缓存设计 (tmuxifier / zoxide / omp 共用此模式)
#
# 目的: 把 `xxx init/completions zsh` 的输出缓存到文件，开 shell 直接 source，
#       仅当工具二进制变化时才重新生成，加速启动。
#
# 为什么不用 `[[ "$_cache" -nt "$_bin" ]]`?
#   command -v <tool> 对 brew 安装的工具是符号链接(/opt/homebrew/bin/xxx)，
#   而 zsh 的 -nt 会【跟随符号链接】, 比的是 Cellar 里真实二进制的 mtime。
#   Homebrew 倒 bottle 时保留了【构建时】的 mtime(比缓存还旧), 导致 -nt 恒为真
#   → 缓存永不重生 → 升级工具后补全仍是旧版。(实测 omp 16.2.13→16.3.0 即如此)
#
# 正确做法: 用 stat 取【符号链接本体】的 lstat mtime 做数值比较。
#   - macOS `stat -f %m` 默认就是 lstat(不跟随); Linux 用 `stat -c %Y`。
#   - brew upgrade 会 relink(删旧 symlink、建新 symlink) → symlink 本体 mtime 刷新 → 缓存失效 ✓
#   - 脚本覆盖安装(原地覆盖二进制) → 文件 mtime 刷新 → 同样失效 ✓
# ---------------------------------------------------------------------------
if command -v tmuxifier &> /dev/null; then
  local _cache="$HOME/.cache/zsh/tmuxifier_init.zsh" _bin="$(command -v tmuxifier)"
  local _bin_mtime=$(_stat_mtime "$_bin")
  local _cache_mtime=$(_stat_mtime "$_cache")
  if [[ -n "$_bin_mtime" && -n "$_cache_mtime" && "$_cache_mtime" -gt "$_bin_mtime" ]]; then
    source "$_cache"
  else
    mkdir -p "$HOME/.cache/zsh"
    tmuxifier init - >| "$_cache" 2>/dev/null && source "$_cache"
  fi
fi


# init zoxide (directory autojump tool)
if ! command -v zoxide &> /dev/null; then
	with_proxy sh -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'
fi
if command -v zoxide &> /dev/null; then
  local _cache="$HOME/.cache/zsh/zoxide_init.zsh" _bin="$(command -v zoxide)"
  local _bin_mtime=$(_stat_mtime "$_bin")
  local _cache_mtime=$(_stat_mtime "$_cache")
  if [[ -n "$_bin_mtime" && -n "$_cache_mtime" && "$_cache_mtime" -gt "$_bin_mtime" ]]; then
    source "$_cache"
  else
    mkdir -p "$HOME/.cache/zsh"
    zoxide init zsh >| "$_cache" 2>/dev/null && source "$_cache"
  fi
fi


# init oh-my-pi (coding assistant)
if ! command -v omp &> /dev/null; then
  with_proxy sh -c 'curl -fsSL https://omp.sh/install | sh'
fi
if command -v omp &> /dev/null; then
  local _cache="$HOME/.cache/omp_completions.zsh" _bin="$(command -v omp)"
  local _bin_mtime=$(_stat_mtime "$_bin")
  local _cache_mtime=$(_stat_mtime "$_cache")
  if [[ -n "$_bin_mtime" && -n "$_cache_mtime" && "$_cache_mtime" -gt "$_bin_mtime" ]]; then
    source "$_cache"
  else
    mkdir -p "$HOME/.cache"
    omp completions zsh >| "$_cache" 2>/dev/null && source "$_cache"
  fi
fi


# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<
# init starship (prompt)
if ! command -v starship &> /dev/null; then
  with_proxy sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin -y'
fi
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# 通知: bell=终端铃声(BEL), toast=Windows 系统弹窗 (脚本在 ~/.local/bin/omp-done)
alias bell="printf '\\a'"
alias toast="$HOME/.local/bin/omp-done"
