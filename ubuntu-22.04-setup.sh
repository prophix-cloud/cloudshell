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

sudo apt install -y \
    shellcheck \
    bat \
    tree \
    fd-find \
    ripgrep \
    fzf \
    unzip \
    podman \
    skopeo \
    jq

# https://github.com/hashicorp/terraform/releases
TERRAFORM_VERSION="1.3.9"
if [[ ! -e $(which terraform) ]]; then
    curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
    unzip terraform.zip
    sudo mv ./terraform /usr/local/bin/
    rm terraform.zip
fi

# Install terraformer https://github.com/GoogleCloudPlatform/terraformer
if [[ ! -e $(which terraformer) ]]; then
    export PROVIDER=all
    curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-${PROVIDER}-linux-amd64
    chmod +x terraformer-${PROVIDER}-linux-amd64
    mv terraformer-${PROVIDER}-linux-amd64 ~/bin/terraformer
fi

if [[ ! -e $(which aws) ]]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf ./aws/
    rm awscliv2.zip
fi

PX_WORKSPACE_DIR="$HOME/workspace/prophix"
mkdir -p "$PX_WORKSPACE_DIR"

pushd $HOME/workspace/prophix
    if [[ ! -d "$PX_WORKSPACE_DIR/cloud-ops" ]]; then
        git clone git@github.com:prophix-cloud/cloud-ops.git
    else
        echo "cloud-ops repo already cloned"
    fi

    if [[ ! -d "$PX_WORKSPACE_DIR/infrastructure" ]]; then
        git clone git@github.com:prophix-cloud/infrastructure.git
    else
        echo "infrastructure repo already cloned"
    fi
popd
