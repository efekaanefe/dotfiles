#!/usr/bin/env zsh

languages=$(echo "python cpp c" | tr ' ' '\n')
core_utils=$(echo "git find cp" | tr ' ' '\n')
selected=$(printf "%s\n%s" "$languages" "$core_utils" | fzf)

if [[ -z $selected ]]; then
    exit 0
fi

echo -n "Enter Query: "
read query

if echo "$languages" | grep -qs "$selected"; then
    query=$(echo $query | tr ' ' '+')
    tmux neww zsh -c "echo \"curl cht.sh/$selected/$query/\"; curl cht.sh/$selected/$query; while true; do sleep 1; done"
else
    tmux neww zsh -c "curl -s cht.sh/$selected~$query | less"
fi
