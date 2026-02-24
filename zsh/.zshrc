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

alias setproxy="export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890"
alias unsetproxy="unset https_proxy http_proxy all_proxy"

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
eval "$(tmuxifier init -)"


# init zoxide (directory autojump tool)
if ! command -v zoxide &> /dev/null; then
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
eval "$(zoxide init zsh)"
 
