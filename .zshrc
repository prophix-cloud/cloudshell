#oh-my-zsh config
plugins=(terraform aws z git)
ZSH_THEME="xiong-chiamiov-plus"
DISABLE_UPDATE_PROMPT="true"

#init oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD
# enable tab completion for git
autoload -Uz compinit && compinit

export EDITOR='vim'
export VISUAL='vim'

alias ll="ls -lahF"
alias v="vim"
alias gap="git add -p"

if [[ -d $HOME/bin ]]; then
    export PATH=$PATH:$HOME/bin
fi

if [[ -e $(which terraform) ]]; then
    export TF_PLUGIN_CACHE_DIR=/tmp/.terraform.d/plugin-cache
    mkdir -p /tmp/.terraform.d/plugin-cache
fi

function get-temp-aws-creds() {
    ~/cloudshell/get-temp-aws-creds.sh
}

eval $(ssh-agent -s)
ssh-add ~/.ssh/private_key

pushd ~/cloudshell
    ~/cloudshell/setup-cloudshell.sh
popd
