# Dotfiles
Colourful & robust OS X configuration files and utilities.

Installation is done with simple command set:

```
curl --silent https://raw.githubusercontent.com/hari-tw/dotfiles/master/install.sh | sh
```

## Additional steps
* Install XCode & its Command Line Tools.
* Install trash command `brew install trash`
* Install a [Nerd Font](https://www.nerdfonts.com/) (`brew install --cask font-jetbrains-mono-nerd-font`) and set it in your terminal(s) — required for the prompt/`eza` icons. In font pickers, search for **`JetBrainsMono Nerd Font Mono`** (no space between "JetBrains" and "Mono" — that's the actual registered family name; "JetBrains Mono Nerd Font" finds nothing).
* **iTerm2:** import `terminal/catppuccin/catppuccin-mocha.itermcolors` (Settings → Profiles → Colors → Color Presets → Import) and apply it to your profile.
* **Warp:** the Catppuccin theme files are symlinked into `~/.warp/themes/` automatically by `symlink-dotfiles.sh` — select "Catppuccin Mocha" in Settings → Appearance → Themes. Then, **before** expecting Starship to show up: Settings → Appearance → Prompt → set Input type to `Shell Prompt (PS1)` — Warp defaults to its own built-in prompt, which silently replaces Starship's output entirely (not just missing icons).
* If git modules failed to download, run:
```
git submodule update --init --recursive
```

## For new computer
* On a completely fresh Mac (no Xcode CLT/Homebrew yet), run `sh bootstrap-new-system.sh` — it installs Xcode CLT and Homebrew if missing, clones this repo, symlinks it, and runs `brew bundle install`.
* If Homebrew's already set up, `curl --silent .../install.sh | sh` (see top of this README) + `brew bundle install --file=Brewfile` covers the same ground.
* Insert proper hosts from `etc/hosts` to system’s `/etc/hosts`.

## Features

![](https://cloud.githubusercontent.com/assets/574696/3210643/80f11554-eed7-11e3-8c8f-5509bc304fc7.png)

![](https://cloud.githubusercontent.com/assets/574696/3210642/7ecc9a00-eed7-11e3-9357-27c2a8576f80.png)

Shell (zsh):

* Catppuccin Mocha theme (iTerm2, Warp, and the Starship prompt, all matched) — other flavors in `terminal/catppuccin/` and `terminal/catppuccin-warp/`
* Modern CLI tooling: `ls`/`ll`/`la` → `eza`, `cat` → `bat`, `cd` → zoxide-enhanced, `fzf`-powered Ctrl+R/Ctrl+T (installed via `Brewfile`)
* Auto-completion
* Syntax highlighting
* Automatic setting up of terminal tab / window title to current dir
* `rm` moves file to the OS X trash
* A bunch of useful functions:
    * `ram safari` — show app RAM usage
    * `openfiles` — real-time disk usage monitoring with `dtrace`.
    * `loc py coffee js html css` — count lines of code
    in current dir in a colourful way.
    * `ff file-name-or-pattern` - fast recursive search for a file name in directories.
    * `curl http://site/v1/api.json | json` - pretty-print JSON
    * `aes-enc`, `aes-dec` - safely encrypt files.
* Neat git extras:
    * Opinionated `git log`, `git graph`
    * `gcp` for fast `git commit -m ... && git push`
    * `git pr <pull-req> [origin]` for fetching pull request branches
    * `git cleanup` — clean up merged git branches. Very useful if
    you’re doing github pull requests in topic branches.
    * `git summary` — outputs commit email statistics.
    * `git release` — save changes, tag commit. If used on node.js project, also push to npm.
    * `git url` - opens GitHub repo for current git repo.
    * `git-changelog`, `git-setup` etc.
* [homesick](https://github.com/technicalpickles/homesick) /
  [homeshick](https://github.com/andsens/homeshick)-compatible

## Prompt

Starship (`terminal/starship.toml`), `catppuccin-powerline` preset, Catppuccin Mocha palette. Left-to-right, one colored chip per segment:

| Segment | Color | Shows |
|---|---|---|
| user/host | red | Username, plus `@hostname` — but only during an SSH session (silent on local machines) |
| directory | peach | Current path, truncated to 3 levels |
| git | yellow | Branch name + status (`!` modified, `↑`/`↓` ahead/behind, etc.) — only inside a git repo |
| languages | green | Detected runtime version (Node, Python, Rust, Go, Java, Kotlin, Haskell, PHP, C) — only in a matching project |
| cloud/infra/claude | teal | `aws` (only when `AWS_PROFILE` is set), `kubernetes` (only in dirs with `Chart.yaml`/`kustomization.yaml`/`skaffold.yaml` or a `k8s`/`kubernetes`/`manifests` folder), `docker_context` (only with a Dockerfile/compose file present), `helm` (only with `Chart.yaml`/`helmfile.yaml`), `conda`, and Claude Code's `claude_model`/`claude_context`/`claude_cost` — all merged into one segment on purpose, see below |
| time | lavender | Current time, always shown |
| *(right edge)* | lavender | `cmd_duration` — only after a command that took a while |

`gcloud` exists in the config but is **disabled** — Starship can only gate it by environment variable (not by directory, unlike the others above), and gcloud CLI doesn't set one that means "actively doing GCP work." Left on, it would show on every single prompt forever after one `gcloud auth login`. Flip `disabled = false` in `[gcloud]` if you want it back anyway.

Why cloud/conda/claude share one segment instead of three: each segment's transition arrow prints unconditionally, regardless of whether the modules inside it have anything to show. Outside actual infra/Python/Claude work, all of those modules are simultaneously empty most of the time — three separate segments meant three consecutive "empty" arrows with nothing between them. One shared segment cuts that down to one arrow in, one arrow out. Starship doesn't support fully conditional inter-segment arrows without much more complex per-module format surgery, so this reduces the effect rather than eliminating it entirely.

`command_timeout` is bumped to 1000ms (Starship's default 500ms is too aggressive — `helm version` alone can exceed it and render blank).

## Structure
* `Brewfile` — everything installed via Homebrew; run `brew bundle install --file=Brewfile`
* `etc` — various stuff like osx text substitutions / hosts backup
* `git-extras` — useful git functions, defined in `home/gitconfig`. Don't forget to change your git author to a proper name.
* `home` — files that are symlinked to `$HOME` directory
* `terminal` — terminal theme & prompt: `catppuccin/` (iTerm2 color schemes), `catppuccin-warp/` (Warp themes, symlinked into `~/.warp/themes/`), `starship.toml` (prompt config), plus completion/syntax-highlighting submodules


## License

The MIT license.

Copyright (c) 2013 Paul Miller (http://paulmillr.com/)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
