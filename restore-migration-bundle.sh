#!/usr/bin/env bash
#
# Restores the private mac-migration bundle (Phase 3 Step 4 of
# MAC_MIGRATION.md) on a new machine. Expects the zip already extracted to
# ~/Downloads/mac-migration - run from anywhere, paths are absolute.
#
# Safe to re-run - every step is a plain copy/mkdir, nothing destructive.

set -e

BUNDLE="$HOME/Downloads/mac-migration"

if [[ ! -d "$BUNDLE" ]]; then
  echo "Error: $BUNDLE not found. Extract mac-migration.zip there first."
  exit 1
fi

echo "==> SSH keys"
cp "$BUNDLE/ssh/id_ed25519"                "$HOME/.ssh/"
cp "$BUNDLE/ssh/id_ed25519.pub"            "$HOME/.ssh/"
cp "$BUNDLE/ssh/id_ed25519_aisforapp"      "$HOME/.ssh/"
cp "$BUNDLE/ssh/id_ed25519_aisforapp.pub"  "$HOME/.ssh/"
cp "$BUNDLE/ssh/id_ed25519_hari-tw"        "$HOME/.ssh/"
cp "$BUNDLE/ssh/id_ed25519_hari-tw.pub"    "$HOME/.ssh/"
cp "$BUNDLE/ssh/config"                    "$HOME/.ssh/"

echo "==> Fixing SSH permissions"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519_aisforapp" "$HOME/.ssh/id_ed25519_hari-tw"
chmod 644 "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ed25519_aisforapp.pub" "$HOME/.ssh/id_ed25519_hari-tw.pub"
chmod 600 "$HOME/.ssh/config"

echo "==> Adding keys to macOS Keychain"
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519_aisforapp"
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519_hari-tw"

echo "==> Testing GitHub access for all three accounts"
echo "  (exit code 1 here is expected - GitHub SSH never grants shell access,"
echo "   only the greeting message below matters)"
set +e
ssh -T git@github.com          2>&1 | tail -1
ssh -T git@github.com-personal 2>&1 | tail -1
ssh -F /dev/null -i "$HOME/.ssh/id_ed25519_hari-tw" -o IdentitiesOnly=yes -T git@github.com 2>&1 | tail -1
set -e

echo "==> Git identity + SSH key overrides (Projects/SideGigs)"
cp "$BUNDLE/git/.gitconfig-work"      "$HOME/Developer/delta/dotfiles/home/.gitconfig-work"
cp "$BUNDLE/git/.gitconfig-sidegigs"  "$HOME/Developer/delta/dotfiles/home/.gitconfig-sidegigs"
bash "$HOME/Developer/delta/dotfiles/symlink-dotfiles.sh"

echo "==> Creating ~/Projects and ~/SideGigs"
mkdir -p "$HOME/Projects" "$HOME/SideGigs"

echo "==> Shell history"
cp "$BUNDLE/shell/zhistory"      "$HOME/.zhistory"
cp "$BUNDLE/shell/bash_history"  "$HOME/.bash_history"

echo "==> Claude profiles"
rsync -a "$BUNDLE/claude/claude/"          "$HOME/.claude/"
rsync -a "$BUNDLE/claude/claude-work/"     "$HOME/.claude-work/"
rsync -a "$BUNDLE/claude/claude-personal/" "$HOME/.claude-personal/"
mkdir -p "$HOME/Library/Application Support/Claude/"
cp "$BUNDLE/claude/claude_desktop_config.json" "$HOME/Library/Application Support/Claude/"
cp "$BUNDLE/claude/config.json"                "$HOME/Library/Application Support/Claude/"

echo "==> Cursor IDE settings"
mkdir -p "$HOME/Library/Application Support/Cursor/User/"
cp "$BUNDLE/cursor/settings.json"    "$HOME/Library/Application Support/Cursor/User/"
cp "$BUNDLE/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/"

echo "==> ngrok"
mkdir -p "$HOME/Library/Application Support/ngrok/"
cp "$BUNDLE/tools/ngrok.yml" "$HOME/Library/Application Support/ngrok/"

echo "==> gcloud configurations"
mkdir -p "$HOME/.config/gcloud/configurations"
cp -r "$BUNDLE/tools/gcloud-configurations/." "$HOME/.config/gcloud/configurations/"

echo "==> gh CLI config"
mkdir -p "$HOME/.config/gh"
cp "$BUNDLE/tools/gh-config.yml" "$HOME/.config/gh/config.yml"

cat <<'EOF'

==> Done. Manual steps still needed:
  - Sort the 53 repos from the old ~/Projects into ~/Projects (office/Xero)
    and ~/SideGigs (personal) - needs human judgment per repo, not automatable
  - gh auth login, once for each of the 3 GitHub accounts (Step 5)
  - AWS SSO profiles + Kubernetes contexts from scratch (Step 5a)
  - iTerm2 profile import (if you exported one in Phase 1b)
EOF
