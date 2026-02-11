#!/usr/bin/env bash
set -euo pipefail

read -r -p "Would you like to ensure all tools and repos are installed? 'No' will still setup repos/symlinks and take you right to the prompt. [y/N] " response
DO_INSTALL=0
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  DO_INSTALL=1
  echo "Installing base packages..."
else
  echo "Skipping package/tool installs; continuing with repo + config wiring..."
fi

cd ~

# Prefer /home (bigger ext4) over $HOME
WORKDIR_BASE="/home/workspace"
WORKDIR="${WORKDIR_BASE}/${USER:-cloudshell-user}"

sudo mkdir -p "$WORKDIR"
sudo chown "$(id -u)":"$(id -g)" "$WORKDIR"
chmod 775 "$WORKDIR"

echo "Using WORKDIR=$WORKDIR"
echo "Disk/inode status:"
df -hT /home || true
df -ih "$HOME" || true
echo

mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"

if [[ "$DO_INSTALL" -eq 1 ]]; then
  sudo yum install -y \
    xz gzip file openssl nano yum-utils golang shadow-utils jq unzip git

  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum -y install terraform

  if ! command -v tmate >/dev/null 2>&1; then
    tmpdir="$(mktemp -d)"
    curl -L "https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz" -o "${tmpdir}/tmate.tar.xz"
    tar -C "${tmpdir}" -xf "${tmpdir}/tmate.tar.xz"
    mv "${tmpdir}"/tmate*/tmate ~/bin/
    rm -rf "${tmpdir}"
  fi
fi

# SSH key (manual)
if [[ ! -f ~/.ssh/private_key ]]; then
  echo "=========================================="
  echo "~/.ssh/private_key was not found."
  echo
  echo "Create it manually, then re-run this script:"
  echo "  mkdir -p ~/.ssh"
  echo "  nano ~/.ssh/private_key"
  echo "  chmod 600 ~/.ssh/private_key"
  exit 1
fi
chmod 600 ~/.ssh/private_key

# Start agent + add key (always)
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
fi
ssh-add ~/.ssh/private_key >/dev/null

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

  # Symlink into ~ for convenience
  ln -sfn "$dest" "$HOME/$name"
}

clone_or_update "cloudshell" "git@github.com:prophix-cloud/cloudshell.git" "main"
clone_or_update "cloud-ops" "git@github.com:prophix-cloud/cloud-ops.git" "main"
clone_or_update "infrastructure" "git@github.com:prophix-cloud/infrastructure.git" "main"
clone_or_update "ops-terminal" "git@github.com:prophix-cloud/ops-terminal.git" "main"

# Oh My Zsh on WORKDIR, symlink into ~
OHMY_DIR="$WORKDIR/oh-my-zsh"
if [[ ! -d "$OHMY_DIR/.git" ]]; then
  echo "Cloning oh-my-zsh into $OHMY_DIR..."
  rm -rf "$OHMY_DIR"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OHMY_DIR"
else
  echo "oh-my-zsh already present in workspace"
fi
ln -sfn "$OHMY_DIR" "$HOME/.oh-my-zsh"

# Dotfiles: link from WORKDIR/cloudshell
ln -sf "$HOME/cloudshell/.vimrc" "$HOME/.vimrc"
ln -sf "$HOME/cloudshell/.bashrc" "$HOME/.bashrc"
ln -sf "$HOME/cloudshell/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/cloudshell/.gitconfig" "$HOME/.gitconfig"
ln -sf "$HOME/ops-terminal/ops-terminal.yml" "$HOME/ops-terminal.yml"

# Ensure ops-terminal always finds its config (even if invoked from elsewhere)
cat > "$HOME/bin/ops-terminal" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$HOME"
exec "$HOME/ops-terminal/ops-terminal" "$@"
EOF
chmod +x "$HOME/bin/ops-terminal"

if [[ "$DO_INSTALL" -eq 1 ]]; then
  echo "Updating system packages..."
  sudo yum update -y &> /dev/null || true
fi

echo
echo "Done."
echo "Workspace: $WORKDIR"
echo "If anything still errors with 'No space left on device', run: df -ih \$HOME"
