#!/usr/bin/env bash

set -euo pipefail

# install nodejs using nvm
if [[ ! -d  $HOME/.nvm/ ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install --lts
nvm install node
nvm ls

sudo apt install \
    shellcheck \
    bat \
    tree \
    fd-find \
    ripgrep \
    fzf

# Install terraform
# https://github.com/hashicorp/terraform/releases
TERRAFORM_VERSION="1.3.9"
if [[ ! -e $(which terraform) ]]; then
    curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
    unzip terraform.zip
    sudo mv $HOME/terraform /usr/local/bin
    rm terraform.zip
fi

mkdir -p $HOME/workspace/
pushd $HOME/workspace/
    if [[ ! -d $HOME/workspace/cloud-ops ]]; then
        git clone git@github.com:prophix-cloud/cloud-ops.git
    else
        echo "cloud-ops repo already cloned"
    fi

    if [[ ! -d $HOME/workspace/infrastructure ]]; then
        git clone git@github.com:prophix-cloud/infrastructure.git
    else
        echo "infrastructure repo already cloned"
    fi
popd
