#!/usr/bin/env zsh
#
# Bootstraps a brand-new Mac: Xcode Command Line Tools, Homebrew, this repo
# (cloned + symlinked), and everything declared in Brewfile.
#
#   sh bootstrap-new-system.sh          # personal machine: Brewfile only
#   sh bootstrap-new-system.sh --work   # office machine: + Brewfile.work
#
# Via curl: curl -fsSL .../bootstrap-new-system.sh | sh -s -- --work
set -e

work=false
[[ "$1" == "--work" ]] && work=true

if ! xcode-select -p >/dev/null 2>&1; then
  echo 'Installing Xcode Command Line Tools (follow the GUI prompt)...'
  xcode-select --install
  echo 'Re-run this script once that install finishes.'
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo 'Installing Homebrew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

dev="$HOME/Developer/delta"
dotfiles="$dev/dotfiles"
if [[ ! -d "$dotfiles" ]]; then
  echo 'Cloning dotfiles...'
  mkdir -p "$dev"
  git clone --recursive https://github.com/hari-tw/dotfiles.git "$dotfiles"
fi

echo 'Symlinking dotfiles...'
bash "$dotfiles/symlink-dotfiles.sh"

echo 'Installing packages from Brewfile (this takes a while)...'
brew bundle install --file="$dotfiles/Brewfile"

if $work; then
  # hashicorp/tap and isen-ng/dotnet-sdk-versions both ship untrusted by
  # default on a fresh Homebrew install - `brew bundle install` auto-taps
  # them (they're `tap` lines in Brewfile.work) but won't trust them, so
  # their formula/cask lines fail with "Refusing to load ... from untrusted
  # tap" and abort just those installs (the rest of the bundle still
  # proceeds). Tap and trust exactly what we use ahead of time so everything
  # installs cleanly in the same run.
  brew tap hashicorp/tap
  brew trust --formula hashicorp/tap/terraform

  brew tap isen-ng/dotnet-sdk-versions
  brew trust --cask isen-ng/dotnet-sdk-versions/dotnet-sdk8
  brew trust --cask isen-ng/dotnet-sdk-versions/dotnet-sdk8-0-400

  echo 'Installing office extras from Brewfile.work...'
  brew bundle install --file="$dotfiles/Brewfile.work"
fi

cat <<'EOF'

Bootstrap complete. Manual steps still needed:
  - Set your terminal font to the installed Nerd Font (JetBrainsMono Nerd Font)
  - Import terminal/catppuccin/catppuccin-mocha.itermcolors into iTerm2 and
    apply it to your profile (Settings > Profiles > Colors > Color Presets)
  - Restore SSH keys, home/.gitconfig-*, and shell history from your
    private backup (never stored in this repo)
  - Insert entries from etc/hosts into /etc/hosts if needed
  - Optionally review and run etc/osx.sh for macOS defaults tweaks (uses sudo)
EOF

if $work; then
  cat <<'EOF'
  - brew tap xero-internal/tap git@github.com:xero-internal/homebrew-tap.git
    && brew install aws-sso-tools (the explicit SSH URL is required - the
    bare one-argument form defaults to HTTPS and fails), then set up AWS
    SSO profiles and Kubernetes contexts from scratch
EOF
fi
