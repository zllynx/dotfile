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

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
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

# -------------
# proxy setting
# -------------

# 代理端口配置（可在 .user_env.sh 中覆盖）
export PROXY_PORT=${PROXY_PORT:-10808}
export PROXY_TYPE=${PROXY_TYPE:-http}

# 设置代理主机
setup_proxy_host() {
    local os_type=$(uname -s)

    if [[ "$os_type" == "Darwin" ]]; then
        # macOS 使用本地代理
        export PROXY_HOST="127.0.0.1"
    elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
        # WSL 环境，获取 Windows 主机 IP
        local win_ip=""

        # 方式1：通过默认网关获取（更可靠）
        if command -v ip >/dev/null 2>&1; then
            win_ip=$(ip route 2>/dev/null | grep default | awk '{print $3}')
        fi

        # 方式2：从 /etc/resolv.conf 获取（备选）
        if [[ -z "$win_ip" ]]; then
            win_ip=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')
        fi

        # 如果都失败了，使用默认值
        if [[ -z "$win_ip" ]]; then
            echo "⚠️  无法自动获取 WSL 主机 IP，使用默认值"
            win_ip="127.0.0.1"
        fi

        export PROXY_HOST="$win_ip"
    else
        # 普通 Linux 使用本地代理
        export PROXY_HOST="127.0.0.1"
    fi
}

# 设置代理
setproxy() {
    setup_proxy_host

    local proxy_url="$PROXY_TYPE://$PROXY_HOST:$PROXY_PORT"
    local socks_url="socks5://$PROXY_HOST:$PROXY_PORT"

    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"
    export all_proxy="$socks_url"
    export no_proxy="localhost,127.0.0.1,localaddress,.local"

    echo "✅ 代理已启动: $proxy_url"
    echo "测试连接: curl -I https://www.google.com"
}

# 取消代理
unsetproxy() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    unset no_proxy
    echo "❌ 代理已关闭"
}

# 测试代理
testproxy() {
    if [[ -n "$http_proxy" ]]; then
        echo "🔗 当前代理: $http_proxy"
        curl -I -s https://www.google.com | head -n 1
    else
        echo "❌ 代理未设置"
    fi
}

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

# 加载 fzf 设置
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse '
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
	git clone https://github.com/jimeh/tmuxifier.git ~/.tmux/plugins/tmuxifier
fi
eval "$(tmuxifier init -)"


# init zoxide (directory autojump tool)
if ! command -v zoxide &> /dev/null; then
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
eval "$(zoxide init zsh)"
 
