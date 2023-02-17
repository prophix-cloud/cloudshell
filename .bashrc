alias v="vim"
alias g="git"
alias gst="git status"
alias gap="git add -p"
alias gup="git pull"
alias ll="ls -lahF"

if [[ -d $HOME/bin ]]; then
    export PATH=$PATH:$HOME/bin
fi

if [[ -e $(which terraform) ]]; then
    export TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache
    mkdir -p $HOME/.terraform.d/plugin-cache
fi

echo "WARNING: You should use zsh, it has more tooling"
