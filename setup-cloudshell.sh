#!/usr/bin/env bash

set -euo pipefail

cd ~

# should install binaries in $HOME/bin
mkdir -p ~/bin

# Install 1pass cli
curl -L https://cache.agilebits.com/dist/1P/op2/pkg/v2.7.3/op_linux_amd64_v2.7.3.zip -o 1pass.zip
unzip 1pass.zip
mv ~/op ~/bin/
rm 1pass.zip op.sig

echo "NOTE: You are about to sign into 1Password. It will first prompt you for the address to log into."
echo "Use the following signin address: prophix-it.1password.com"
echo "Press ENTER to continue..."
read
eval $(op signin --account prophix-it.1password.com)

# get ssh key from 1pass
mkdir -p ~/.ssh
op item get ssh-key --vault Private --field notesPlain --format json | jq -r '.value' > ~/.ssh/private_key
chmod 644 ~/.ssh/private_key
eval $(ssh-agent -s)
ssh-add ~/.ssh/private_key

# clone other repo's: cloud-ops, infrastrucutre
if [[ ! -d ~/cloud-ops ]]; then
    git clone git@github.com:prophix-cloud/cloud-ops.git
fi

if [[ ! -d ~/infrastrucutre ]]; then
    git clone git@github.com:prophix-cloud/infrastrucutre.git
fi


#install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim