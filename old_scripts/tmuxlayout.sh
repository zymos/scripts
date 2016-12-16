#!/bin/bash
tmux new-session -d -n WindowName Command
tmux new-window -n NewWindowName
tmux split-window -v
tmux selectp -t 1
tmux resize-pane -x 2
tmux split-window -v
tmux selectw -t 1

tmux -2 attach-session -d
