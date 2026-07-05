#!/bin/bash

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dotfiles"

echo "Symlinking dotfiles from $dotfiles"

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

for location in $(find home -name '.*'); do
  file="${location##*/}"
  file="${file%.sh}"
  link "$dotfiles/$location" "$HOME/$file"
done

# Warp reads themes from its own data directory, not $HOME directly.
mkdir -p "$HOME/.warp/themes"
for theme in "$dotfiles"/terminal/catppuccin-warp/*.yml; do
  link "$theme" "$HOME/.warp/themes/$(basename "$theme")"
done

