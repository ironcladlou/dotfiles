#!/bin/bash
name=$1
pane="$(tmux display -p "#D" | tr -d %)"

var="TMUX_${name}_${pane}"
tmux showenv -g $var | sed 's/^.*=//'
#printf '%s' "${!1}"
