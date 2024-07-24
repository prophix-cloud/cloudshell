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
#Render colours correctly
export COLORTERM=truecolor

# stop aws cli from using less instead of outputting to stdout
export AWS_PAGER=""

alias ll="ls -lahF"
alias v="vim"
alias gap="git add -p"

if [[ -d $HOME/bin ]]; then
    export PATH=$PATH:$HOME/bin
fi

# Always set tf plugin cache since it always gets cleared out in cloudshell
export TF_PLUGIN_CACHE_DIR=/tmp/.terraform.d/plugin-cache
mkdir -p /tmp/.terraform.d/plugin-cache

function get-temp-aws-creds() {
    ~/cloudshell/get-temp-aws-creds.sh
}

eval $(ssh-agent -s)
ssh-add ~/.ssh/private_key

pushd ~/cloudshell
    ~/cloudshell/setup-cloudshell.sh
popd

function ops-terminal() {
    ~/cloudshell/ops-terminal.sh
}
