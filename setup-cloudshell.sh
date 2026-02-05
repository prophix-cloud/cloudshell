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

# -------------------------
# Workspace selection
# -------------------------
# In some CloudShell environments, $HOME is a small loop-mounted FS (~1G) and can run out of inodes fast.
# /home is usually the larger ext4 FS (e.g., 16G). Prefer placing repos under /home/workspace/<user>.
WORKDIR_BASE="/home/workspace"
WORKDIR="${WORKDIR_BASE}/${USER:-cloudshell-user}"

# Ensure it exists and is writable
sudo mkdir -p "$WORKDIR"
sudo chown "$(id -u)":"$(id -g)" "$WORKDIR"
chmod 775 "$WORKDIR"

echo "Using WORKDIR=$WORKDIR"

# -------------------------
# Base packages
# -------------------------
# Include jq/unzip because script uses them elsewhere
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
  unzip \
  git

# Install small binaries in $HOME/bin
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"

# -------------------------
# Terraform
# -------------------------
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# -------------------------
# tmate
# -------------------------
if ! command -v tmate >/dev/null 2>&1; then
  tmpdir="$(mktemp -d)"
  curl -L "https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz" -o "${tmpdir}/tmate.tar.xz"
  tar -C "${tmpdir}" -xf "${tmpdir}/tmate.tar.xz"
  mv "${tmpdir}"/tmate*/tmate ~/bin/
  rm -rf "${tmpdir}"
fi

# -------------------------
# SSH key (manual)
# -------------------------
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

# -------------------------
# Helpers
# -------------------------
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
    echo "$name repo already cloned in $dest"
    pushd "$dest" >/dev/null
      git fetch origin --prune
      git checkout -f "$branch"
      if git diff --quiet && git diff --cached --quiet; then
        git pull --rebase
      else
        echo "NOTE: $name has local changes; skipping pull --rebase"
      fi
    popd >/dev/null
  fi

  # Convenience symlink from ~ to the workspace location
  ln -sfn "$dest" "$HOME/$name"
}


clone_or_update "cloud-ops" "git@github.com:prophix-cloud/cloud-ops.git" "main"
clone_or_update "infrastructure" "git@github.com:prophix-cloud/infrastructure.git" "main"
clone_or_update "ops-terminal" "git@github.com:prophix-cloud/ops-terminal.git" "main"

# If ops-terminal clone succeeded but checkout failed previously, ensure working tree is repaired:
if [[ -d "$WORKDIR/ops-terminal/.git" ]]; then
  pushd "$WORKDIR/ops-terminal" >/dev/null
    # If checkout is in a bad state, this restores to HEAD.
    git status --porcelain >/dev/null 2>&1 || true
    git restore --source=HEAD :/ >/dev/null 2>&1 || true
  popd >/dev/null
fi

# -------------------------
# Oh My Zsh (keep in $HOME; it’s not that big compared to vendor)
# -------------------------
if [[ ! -d ~/.oh-my-zsh ]]; then
  export CHSH='no'
  export RUNZSH='no'
  export KEEP_ZSHRC='yes'
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
else
  echo "oh-my-zsh already installed"
fi

# -------------------------
# cloudshell repo remote + update
# -------------------------
pushd "$HOME/cloudshell" >/dev/null
  git remote set-url origin git@github.com:prophix-cloud/cloudshell.git
  if git diff --quiet && git diff --cached --quiet; then
    git pull --rebase || true
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
sudo yum update -y &> /dev/null || true

echo
echo "Done. Workspace is at: $WORKDIR"
echo "If you still see 'No space left on device', check inodes with: df -ih \$HOME"
