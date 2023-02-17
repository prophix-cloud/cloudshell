#!/usr/bin/env bash

set -euo pipefail

cd ~

# Install some base packages
sudo yum install -y xz gzip file

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
TERRAFORM_VERSION="1.3.8"
if [[ ! -e $(which terraform) ]]; then
    curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
    unzip terraform.zip
    mv ~/terraform ~/bin/
    rm terraform.zip
fi

# Install terraformer https://github.com/GoogleCloudPlatform/terraformer
if [[ ! -e $(which terraformer) ]]; then
    export PROVIDER={aws,datadog}
    curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-${PROVIDER}-linux-amd64
    chmod +x terraformer-${PROVIDER}-linux-amd64
    mv terraformer-${PROVIDER}-linux-amd64 ~/bin/terraformer
fi

# Install tmate
if [[ ! -e $(which tmate) ]]; then
    curl -L "https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz" -o tmate.tar.xz
    tar -xf tmate.tar.xz
    rm tmate.tar.xz
    mv ./tmate*/tmate ~/bin/
    rm -rf ./tmate*
fi

# install podman
PODMAN_VERSION="4.4.1"
if [[ ! -e $(which podman) ]]; then
    curl -OL "https://github.com/containers/podman/releases/download/v${PODMAN_VERSION}/podman-remote-static-linux_amd64.tar.gz"
    tar xzf podman-remote-static-linux_amd64.tar.gz
    mv ~/bin/podman-* ~/bin/podman
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

cp ~/cloudshell/.vimrc ~/
cp ~/cloudshell/.bashrc ~/
cp ~/cloudshell/.zshrc ~/

echo "===================================================="
echo "========================DONE========================"
echo "===================================================="
echo "Run the following commands to make git commands work:"
echo 'eval $(ssh-agent -s)'
echo 'ssh-add ~/.ssh/private_key'
