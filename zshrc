# environments.
export LANG=ja_JP.UTF-8
export GOPATH=$HOME/go
export ZPLUG_HOME=/usr/local/opt/zplug
export XDG_CONFIG_HOME=~/.config
export CLICOLOR=1
export WORDCHARS="*?_-.[]~=&;!#$%^(){}<"
export HOMEBREW_NO_INSTALL_CLEANUP=1 # for homebrew

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
setopt nonomatch

# keybinds.
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
alias reload="source ~/.zshrc"
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
alias dbc='docker-compose run --rm app bin/rake db:create'
alias ridgepole='docker-compose run --rm app bin/rake ridgepole:apply'
alias rubocop='docker-compose run --rm app bundle exec rubocop -a'
alias rspec='docker-compose run --rm -e "RAILS_ENV=test" app bundle exec rspec'
alias routes='docker-compose run --rm app bin/rake routes'
alias seed='docker-compose run --rm app bin/rake db:seed'
alias drun='docker-compose run --rm app'
alias dup='docker-compose up'
alias dkill='docker kill $(docker ps -q)'
alias drm='docker rm $(docker ps -a -q)'
alias dprune='docker system prune'
alias drmi='docker rmi $(docker images | peco | awk "{print \$3}")'
alias debug='docker-compose run --rm --service-ports app'
alias console='drun rails c'
alias sandbox='console -s'
alias -g DPS='docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}"'
alias de='docker exec -it `DPS | peco | cut -f 1` /bin/sh'

# global aliases.
alias -g L='| less'
alias -g G='| grep'
alias -g X='| xargs'
alias -g C='| pbcopy'
alias -g P='| peco'

alias preci="circleci local execute --job deploy-stg \
                                    -e GCLOUD_SERVICE_KEY='$(cat ~/.ssh/stg-creal.json)' \
                                    -e RAILS_MASTER_KEY=$(cat ~/.ghq/github.com/bridge-c-capital/creal/config/master.key)"

# Kubernetes
alias -g KP='$(kubectl get pods | peco | awk "{print \$1}")'
alias -g KD='$(kubectl get deploy | peco | awk "{print \$1}")'
alias -g KS='$(kubectl get svc | peco | awk "{print \$1}")'
alias -g KI='$(kubectl get ing | peco | awk "{print \$1}")'
alias -g KN='$(kubectl get nodes | peco | awk "{print \$1}")'
alias kc='kubectl'
alias kce='kubectl exec -it KP'
alias kcl='kubectl logs -f KP'
alias kcd='kubectl describe pod KP'
alias kcdn='kubectl describe node KN'
alias kt='kubectl top nodes'
if [ $commands[kubectl] ]; then source <(kubectl completion zsh); fi

# setup.
eval "$(rbenv init -)"
eval "$(nodenv init -)"

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'

export PATH="/usr/local/opt/gettext/bin:$PATH"

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

function cleanup {
  docker-compose stop && \
  docker container prune -f && \
  docker volume rm creal_redis-data && \
  rm -f tmp/pids/server.pid
}

function serve_debug {
  cleanup
  docker-compose run --rm --service-ports app
}

function serve {
  cleanup
  docker-compose up
}

function cluster {
  gcloud container clusters get-credentials -z $ZONE_NAME $CLUSTER_NAME
  gconfig
}

function gauth {
  gcloud auth activate-service-account $GOOGLE_SERVICE_ACCOUNT --key-file $GOOGLE_APPLICATION_CREDENTIALS --project=$GOOGLE_PROJECT_ID
}

# ansible-vault
function encrypt {
  tmpfile=$(mktemp)
  echo $VAULT_PASSWORD >> $tmpfile
  ansible-vault encrypt --vault-password-file=$tmpfile $@
  rm -f $tmpfile
}

function decrypt {
  tmpfile=$(mktemp)
  echo $VAULT_PASSWORD >> $tmpfile
  ansible-vault decrypt --vault-password-file=$tmpfile $@
  rm -f $tmpfile
}

function ipv4 {
  ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}

function gconfig {
  echo "Project     [$(gcloud config get-value project)]"
  echo "K8s Context [$(kubectl config current-context)]"
}

function gcluster {
  source $(find ~/.env/auth/{stg,prod}-* -type f | peco)
  gcloud auth activate-service-account $GOOGLE_SERVICE_ACCOUNT --key-file $GOOGLE_APPLICATION_CREDENTIALS --project=$GOOGLE_PROJECT_ID
  gcloud container clusters get-credentials --region $REGION_NAME $CLUSTER_NAME
  gconfig
}

function proxy {
  source $(find ~/.env/proxy/{stg,prod}-* -type f | peco)
  ~/cloud_sql_proxy -instances=$INSTANCE_CONNECTION_NAME=tcp:3306 \
                    -credential_file=$CLOUD_SQL_PROXY_CREDENTIALS
}

function gcr_clean {
  source $(find ~/.env/auth/{stg,prod}-* -type f | peco)
  gcloud auth activate-service-account $GOOGLE_SERVICE_ACCOUNT --key-file $GOOGLE_APPLICATION_CREDENTIALS --project=$GOOGLE_PROJECT_ID
  local date=`gdate '+%Y-%m-%d' -d '1 months ago'`
  local image="gcr.io/${GOOGLE_PROJECT_ID}/rails"
  for digest in $(gcloud container images list-tags $image --filter="timestamp.datetime < '${date}'" --format='get(digest)'); do
    gcloud container images delete -q --force-delete-tags "${image}@${digest}" 
  done
}

alias gls='gcloud config configurations list'
alias ctx='source $(find ~/.env/auth/{dev,stg,prod}-* -type f | peco); gauth'
