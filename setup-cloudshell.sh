#!/usr/bin/env bash

set -euo pipefail

read -r -p "Would you like to ensure all tools and repos are installed? 'No' will take you right to the prompt. [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing base packages..."
else
    echo "Not installing base packages. Can install them yourself by running the setup-cloudshell.sh script."
    exit 0
fi

cd ~

sudo yum install -y \
    xz \
    gzip \
    file \
    openssl \
    nano \
    yum-utils \
    golang \
    shadow-utils

# should install binaries in $HOME/bin
mkdir -p ~/bin

# Install 1pass cli
# https://app-updates.agilebits.com/product_history/CLI2
OP_VERSION="2.7.3"
if [[ ! -e $(which op) ]]; then
    curl -L "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_amd64_v${OP_VERSION}.zip" -o 1pass.zip
    unzip 1pass.zip
    mv ~/op ~/bin/
    rm 1pass.zip op.sig
fi

# Install terraform
# https://github.com/hashicorp/terraform/releases
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Install tmate
if [[ ! -e $(which tmate) ]]; then
    curl -L "https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz" -o tmate.tar.xz
    tar -xf tmate.tar.xz
    rm tmate.tar.xz
    mv ./tmate*/tmate ~/bin/
    rm -rf ./tmate*
fi

# get ssh key from 1pass
if [[ ! -e ~/.ssh/private_key ]]; then
    echo "=========================================="
    echo "NOTE: You are about to sign into 1Password. It will first prompt you for the address to log into."
    echo "Use the following signin address: prophix-it.1password.com"
    echo "Press ENTER to continue..."
    read
    eval $(op signin --account prophix-it.1password.com)

    mkdir -p ~/.ssh
    op item get ssh-key --vault Private --field notesPlain --format json | jq -r '.value' > ~/.ssh/private_key
else
    echo "ssh key already downloaded"
fi
chmod 600 ~/.ssh/private_key
eval $(ssh-agent -s)
ssh-add ~/.ssh/private_key

# clone other repo's: cloud-ops, infrastructure, etc.
if [[ ! -d ~/cloud-ops ]]; then
    git clone git@github.com:prophix-cloud/cloud-ops.git
else
    echo "cloud-ops repo already cloned"
fi

if [[ ! -d ~/infrastructure ]]; then
    git clone git@github.com:prophix-cloud/infrastructure.git
else
    echo "infrastructure repo already cloned"
fi

if [[ ! -d ~/.oh-my-zsh ]]; then
    export CHSH='no'
    export RUNZSH='no'
    export KEEP_ZSHRC='yes'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "oh-my-zsh already installed"
fi

# change remote url for this repo so user can update it
pushd ~/cloudshell
    git remote set-url origin git@github.com:prophix-cloud/cloudshell.git
popd

ln -sf ~/cloudshell/.vimrc ~/.vimrc
ln -sf ~/cloudshell/.bashrc ~/.bashrc
ln -sf ~/cloudshell/.zshrc ~/.zshrc
ln -sf ~/cloudshell/.gitconfig ~/.gitconfig

echo "Updating system packages..."
sudo yum update -y 2&> /dev/null

green=$(tput setaf 2)
reset=$(tput sgr0)
echo "${green}DONE${reset}"
