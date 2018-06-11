#!/bin/bash

<<<<<<< HEAD
dev="$HOME/Development"
dotfiles="$dev/dotfiles"
=======
dev="$HOME/Developer"
dotfiles="$dev/delta/dotfiles"
>>>>>>> 46f12ab (changing the default path to delta)

if [[ -d "$dotfiles" ]]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "$dotfiles does not exist"
  exit 1
fi

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

