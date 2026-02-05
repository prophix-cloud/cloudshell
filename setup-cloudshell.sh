#!/usr/bin/env bash
set -euo pipefail

read -r -p "Would you like to ensure all tools and repos are installed? 'No' will take you right to the prompt. [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "Installing base packages..."
else
  echo "Not installing base packages. You can install them yourself by running the ./cloudshell/setup-cloudshell.sh script."
  exit 0
fi

cd ~

# Pick a big, persistent workspace
WORKDIR=""

for candidate in "/aws/mde/mde/workspace" "/aws/mde/workspace" "$HOME/workspace"; do
  if mkdir -p "$candidate" 2>/dev/null; then
    WORKDIR="$candidate"
    break
  fi
done

if [[ -z "$WORKDIR" ]]; then
  echo "ERROR: Could not create a workspace directory anywhere."
  echo "Tried: /aws/mde/mde/workspace, /aws/mde/workspace, $HOME/workspace"
  exit 1
fi

echo "Using WORKDIR=$WORKDIR"

# Base packages
sudo yum install -y \
  xz \
  gzip \
  file \
  openssl \
  nano \
  yum-utils \
  golang \
  shadow-utils \
  jq \
  unzip

# Install small binaries in $HOME/bin
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"

# Install terraform
# https://github.com/hashicorp/terraform/releases
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Install tmate
if ! command -v tmate >/dev/null 2>&1; then
  tmpdir="$(mktemp -d)"
  curl -L "https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz" -o "${tmpdir}/tmate.tar.xz"
  tar -C "${tmpdir}" -xf "${tmpdir}/tmate.tar.xz"
  mv "${tmpdir}"/tmate*/tmate ~/bin/
  rm -rf "${tmpdir}"
fi

# SSH key (manual)
if [[ ! -f ~/.ssh/private_key ]]; then
  echo "=========================================="
  echo "~/.ssh/private_key was not found."
  echo
  echo "Create it manually, then re-run this script:"
  echo
  echo "  mkdir -p ~/.ssh"
  echo "  nano ~/.ssh/private_key"
  echo "  chmod 600 ~/.ssh/private_key"
  echo
  exit 1
else
  echo "ssh key already exists at ~/.ssh/private_key"
  chmod 600 ~/.ssh/private_key
fi

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/private_key

clone_or_update() {
  local name="$1"
  local repo="$2"
  local branch="${3:-main}"
  local dest="$WORKDIR/$name"

  if [[ ! -d "$dest/.git" ]]; then
    echo "Cloning $name into $dest..."
    rm -rf "$dest"
    git clone "$repo" "$dest"
  else
    echo "$name repo already cloned"
    pushd "$dest" >/dev/null
      git fetch origin --prune
      git checkout -f "$branch"
      # Only pull if clean; otherwise avoid failing the whole script
      if git diff --quiet && git diff --cached --quiet; then
        git pull --rebase
      else
        echo "NOTE: $name has local changes; skipping pull --rebase"
      fi
    popd >/dev/null
  fi

  # Convenience symlink from ~ to workspace
  ln -sfn "$dest" "$HOME/$name"
}

# Clone repos into workspace and link into ~
clone_or_update "cloud-ops" "git@github.com:prophix-cloud/cloud-ops.git" "main"
clone_or_update "infrastructure" "git@github.com:prophix-cloud/infrastructure.git" "main"
clone_or_update "ops-terminal" "git@github.com:prophix-cloud/ops-terminal.git" "main"

# Install Oh My Zsh on workspace, symlink into ~
OHMY_DIR="$WORKDIR/oh-my-zsh"
if [[ ! -d "$OHMY_DIR/.git" ]]; then
  echo "Cloning oh-my-zsh into $OHMY_DIR..."
  rm -rf "$OHMY_DIR"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OHMY_DIR"
else
  echo "oh-my-zsh already present in workspace"
  pushd "$OHMY_DIR" >/dev/null
    git fetch origin --prune || true
    git checkout -f master || true
    if git diff --quiet && git diff --cached --quiet; then
      git pull --rebase || true
    fi
  popd >/dev/null
fi
ln -sfn "$OHMY_DIR" "$HOME/.oh-my-zsh"

# change remote url for this repo so user can update it
# NOTE: skip pull if you have local changes
pushd "$HOME/cloudshell" >/dev/null
  git remote set-url origin git@github.com:prophix-cloud/cloudshell.git
  if git diff --quiet && git diff --cached --quiet; then
    git pull --rebase
  else
    echo "NOTE: ~/cloudshell has local changes; skipping git pull --rebase"
  fi
popd >/dev/null

# Link dotfiles/config into home
ln -sf "$HOME/cloudshell/.vimrc" "$HOME/.vimrc"
ln -sf "$HOME/cloudshell/.bashrc" "$HOME/.bashrc"
ln -sf "$HOME/cloudshell/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/cloudshell/.gitconfig" "$HOME/.gitconfig"
ln -sf "$HOME/ops-terminal/ops-terminal.yml" "$HOME/ops-terminal.yml"

echo "Updating system packages..."
sudo yum update -y &> /dev/null
