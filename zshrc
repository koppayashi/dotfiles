# environments.
export LANG=ja_JP.UTF-8
export GOPATH=$HOME/go
export ZPLUG_HOME=/usr/local/opt/zplug
export XDG_CONFIG_HOME=~/.config
export CLICOLOR=1

# zplug.
source $ZPLUG_HOME/init.zsh
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
#zplug load --verbose
zplug load

# colors.
autoload -Uz colors && colors

# keybind.
bindkey -e

# history.
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# prompt.
PROMPT="%B%F{green}❯❯%1(v|%1v|)%f%b %B%F{cyan}%~%f%b
%B%F{green}❯%f%b "

# wordstyle.
autoload -Uz select-word-style
select-word-style default

zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# completion.
#autoload -Uz compinit
#compinit

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# vcs_info
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '!'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:*' formats ' %c%u(%s:%b)'
zstyle ':vcs_info:*' actionformats ' %c%u(%s:%b|%a)'

function _update_vcs_info_msg() {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
add-zsh-hook precmd _update_vcs_info_msg

function peco-history-selection() {
  BUFFER=`history -n 1 | tail -r | awk '!a[$0]++' | peco`
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection

# options.
setopt print_eight_bit
setopt no_beep
setopt no_flow_control
setopt ignore_eof
setopt interactive_comments
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt extended_glob

# keybinds.
#bindkey '^R' history-incremental-pattern-search-backward
bindkey '^R' peco-history-selection
bindkey '^S' history-incremental-pattern-search-forward

# aliases.
alias vi='nvim'
alias vim='nvim'
alias ls='ls -G -F'
alias la='ls -a'
alias ll='ls -l'
alias lr='ls -ltr'
alias lar='ls -ltra'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias sudo='sudo -E '
alias h='history'
alias drmi='docker system prune'
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
alias dbc='docker-compose run --rm app bin/rake db:create'
alias ridgepole='docker-compose run --rm app bin/rake ridgepole:apply'
alias rubocop='docker-compose run --rm app bundle exec rubocop -a'
alias routes='docker-compose run --rm app bin/rake routes'
alias drun='docker-compose run --rm app'
alias dup='docker-compose up'

# global aliases.
alias -g L='| less'
alias -g G='| grep'
alias -g X='| xargs'
alias -g C='| pbcopy'
alias -g P='| peco'

# setup.
eval "$(rbenv init -)"
eval "$(nodenv init -)"

#if [ -e /usr/local/share/zsh-completions ]; then
#  fpath=(/usr/local/share/zsh-completions $fpath)
#
#  autoload -U compinit
#  compinit -u
#fi
