#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(terraform aws z git)

ZSH_THEME="xiong-chiamiov-plus"
DISABLE_UPDATE_PROMPT="true"

export EDITOR='vim'
export VISUAL='vim'

if [[ -d $HOME/bin ]]; then
    export PATH=$PATH:$HOME/bin
fi

if [[ -e $(which terraform) ]]; then
    export TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache
    mkdir -p $HOME/.terraform.d/plugin-cache
fi