#!/usr/bin/env zsh

autoload -U colors && colors

for dir in */; do
  [[ -d "$dir/.git" ]] || continue
  cd "$dir"
  line_count=$(git status --porcelain 2> /dev/null | wc -l)
  if [[ "$line_count" -ne "0" ]]; then
    echo "${fg[blue]}${dir%/}${reset_color}:"
    git status --short
    echo ""
  fi
  cd ..
done
