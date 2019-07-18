#!/usr/bin/env zsh

fpath=("$HOME/.zsh/completions" /home/linuxbrew/.linuxbrew/share/zsh/site-functions $fpath)

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump* ]]; then
	compinit
else
	compinit -C
fi

source "$HOME/.asdf/completions/asdf.bash"

for completion in "$HOME"/.zsh/completions/*.zsh; do
	source "$completion"
done

compdef exa=ls
