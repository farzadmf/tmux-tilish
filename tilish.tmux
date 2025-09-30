#!/bin/sh
# vim: foldmethod=marker

# Project: tmux-tilish
# Author:  Jabir Ali Ouassou <jabirali@switzerlandmail.ch>
# Licence: MIT licence
#
# This file contains the `tmux` plugin `tilish`, which implements keybindings
# that turns `tmux` into a more typical tiling window manger for your terminal.
# The keybindings are taken nearly directly from `i3wm` and `sway`, but with
# minor adaptation to fit better with `vim` and `tmux`. See also the README.

# shellcheck disable=SC2016
# shellcheck disable=SC2086
# shellcheck disable=SC2250

# Define core functionality {{{
bind_switch() {
	# Bind keys to switch between workspaces with toggle functionality.
	tmux $bind "$1" \
		run-shell "
			current=\$(tmux display-message -p '#I')
			target=$2
			prev=\$(tmux show-environment -g @_tilish_toggle_prev 2>/dev/null | cut -d= -f2 || echo '')
			curr_stored=\$(tmux show-environment -g @_tilish_toggle_curr 2>/dev/null | cut -d= -f2 || echo '')
			
			if [ \"\$current\" = \"\$target\" ] && [ -n \"\$prev\" ]; then
				# Already on target window, toggle to previous
				tmux select-window -t :\$prev 2>/dev/null || true
				# Swap the toggle state since we just toggled
				tmux set-environment -g @_tilish_toggle_prev \"\$curr_stored\"
				tmux set-environment -g @_tilish_toggle_curr \"\$prev\"
			elif tmux select-window -t :\$target 2>/dev/null; then
				# Switch succeeded, update toggle state
				tmux set-environment -g @_tilish_toggle_prev \"\$current\"
				tmux set-environment -g @_tilish_toggle_curr \"\$target\"
			else
				# Window doesn't exist, create it
				tmux new-window -t :\$target
				tmux set-environment -g @_tilish_toggle_prev \"\$current\"
				tmux set-environment -g @_tilish_toggle_curr \"\$target\"
			fi
		"
}

bind_move() {
	# Bind keys to move panes between workspaces.
	if [ -z "$legacy" ]; then
		tmux $bind "$1" \
			if-shell "tmux join-pane -t :$2" \
			"" \
			"new-window -dt :$2; join-pane -t :$2; select-pane -t top-left; kill-pane" \\\; select-layout \\\; select-layout -E
	else
		tmux $bind "$1" \
			if-shell "tmux new-window -dt :$2" \
			"join-pane -t :$2; select-pane -t top-left; kill-pane" \
			"send escape; join-pane -t :$2" \\\; select-layout
	fi
}

bind_layout() {
	if [ "$1" = '_' ]; then
		return
	fi

	# Bind keys to switch or refresh layouts.
	if [ "$2" = "zoom" ]; then
		# Invoke the zoom feature.
		tmux $bind "$1" \
			resize-pane -Z
	else
		# Actually switch layout.
		if [ -z "$legacy" ]; then
			tmux $bind "$1" \
				select-layout "$2" \\\; select-layout -E
		else
			tmux $bind "$1" \
				run-shell "tmux select-layout \"$2\"" \\\; send escape
		fi
	fi
}

char_at() {
	# Finding the character at a given position in
	# a string in a way compatible with POSIX sh.
	echo $1 | cut -c $2
}
# }}}

# Check input parameters {{{
# Whether we need to use legacy workarounds (required before tmux 2.7).
legacy="$(tmux -V | grep -E 'tmux (1\.|2\.[0-6])')"

# Read user options.
for opt in \
	default dmenu easymode prefix shiftnum \
	navigate navigator \
	smart_splits smart_splits_dirs smart_splits_dirs_large \
  smart_splits_large_dx smart_splits_large_dy \
	layout_keys \
	refresh rename \
	refresh_hooks \
	new_pane; do
	export "$opt"="$(tmux show-option -gv @tilish-"$opt" 2>/dev/null)"
done

# Default to US keyboard layout, unless something is configured.
if [ -z "$shiftnum" ]; then
	shiftnum='!@#$%^&*()'
fi
if [ -z "$layout_keys" ]; then
	layout_keys='sSvVtz'
fi

# Resize hooks are enabled by default
if [ -z "$refresh_hooks" ]; then
	# First one is the 'after-split-window' hook
	# Second one is the 'pane-exited' hook
	refresh_hooks='yy'
fi

if [ -z "$refresh" ]; then refresh="r"; fi
if [ -z "$easymode" ]; then easymode="nn"; fi

if [ -z "$rename" ]; then
	rename="n"
elif [ "$rename" = '---' ]; then rename=''; fi

if [ -z "$new_pane" ]; then
	new_pane="enter"
elif [ "$new_pane" = '---' ]; then new_pane=''; fi

left_arrow='left'
down_arrow='down'
up_arrow='up'
right_arrow='right'

# Determine "arrow types" for pane focus.
if [ "$(char_at $easymode 1)" = "y" ]; then
	# Simplified arrows.
	h='left'
	j='down'
	k='up'
	l='right'
else
	# Vim-style arrows.
	h='h'
	j='j'
	k='k'
	l='l'
fi
# Determine "arrow types" for pane movement.
if [ "$(char_at $easymode 2)" = "y" ]; then
	# Simplified arrows.
	H='S-left'
	J='S-down'
	K='S-up'
	L='S-right'
else
	# Vim-style arrows.
	H='H'
	J='J'
	K='K'
	L='L'
fi

# Determine modifier vs. prefix key.
if [ -z "${prefix:-}" ]; then
	bind='bind -n'
	mod='M-'
else
	bind='bind -rT tilish'
	mod=''
fi
# }}}

# Define keybindings {{{
# Define a prefix key.
if [ -n "$prefix" ]; then
	tmux bind -n "$prefix" switch-client -T tilish
fi

# Switch to workspace via Alt + #.
bind_switch "${mod}1" 1
bind_switch "${mod}2" 2
bind_switch "${mod}3" 3
bind_switch "${mod}4" 4
bind_switch "${mod}5" 5
bind_switch "${mod}6" 6
bind_switch "${mod}7" 7
bind_switch "${mod}8" 8
bind_switch "${mod}9" 9

# Move pane to workspace via Alt + Shift + #.
bind_move "${mod}$(char_at $shiftnum 1)" 1
bind_move "${mod}$(char_at $shiftnum 2)" 2
bind_move "${mod}$(char_at $shiftnum 3)" 3
bind_move "${mod}$(char_at $shiftnum 4)" 4
bind_move "${mod}$(char_at $shiftnum 5)" 5
bind_move "${mod}$(char_at $shiftnum 6)" 6
bind_move "${mod}$(char_at $shiftnum 7)" 7
bind_move "${mod}$(char_at $shiftnum 8)" 8
bind_move "${mod}$(char_at $shiftnum 9)" 9

# The mapping of Alt + 0 and Alt + Shift + 0 depends on `base-index`.
# It can either refer to workspace number 0 or workspace number 10.
if [ "$(tmux show-option -gv base-index)" = "1" ]; then
	bind_switch "${mod}0" 10
	bind_move "${mod}$(char_at "$shiftnum" 10)" 10
else
	bind_switch "${mod}0" 0
	bind_move "${mod}$(char_at "$shiftnum" 10)" 0
fi

# Switch layout with Alt + <mnemonic key>.
# The keys can be overridden, but the default mnemonics are
# `s` and `S` for layouts Vim would generate with `:split`, and `v` and `V` for `:vsplit`.
# The remaining mappings based on `z` and `t` should be quite obvious.
layout_key_1=$(char_at $layout_keys 1)
layout_key_2=$(char_at $layout_keys 2)
layout_key_3=$(char_at $layout_keys 3)
layout_key_4=$(char_at $layout_keys 4)
layout_key_5=$(char_at $layout_keys 5)
layout_key_6=$(char_at $layout_keys 6)

[ $layout_key_1 = '_' ] || bind_layout "${mod}$(char_at $layout_keys 1)" 'main-horizontal'
[ $layout_key_2 = '_' ] || bind_layout "${mod}$(char_at $layout_keys 2)" 'even-vertical'
[ $layout_key_3 = '_' ] || bind_layout "${mod}$(char_at $layout_keys 3)" 'main-vertical'
[ $layout_key_4 = '_' ] || bind_layout "${mod}$(char_at $layout_keys 4)" 'even-horizontal'
[ $layout_key_5 = '_' ] || bind_layout "${mod}$(char_at $layout_keys 5)" 'tiled'
[ $layout_key_6 = '_' ] || bind_layout "${mod}$(char_at $layout_keys 6)" 'zoom'

# Refresh the current layout (e.g. after deleting a pane).
if [ -z "$legacy" ]; then
	tmux $bind "${mod}${refresh}" select-layout -E
else
	tmux $bind "${mod}${refresh}" run-shell 'tmux select-layout'\\\; send escape
fi

# Always do arrows anyways since they're useful
# (specially for easymode where we can move panes)!
tmux $bind "${mod}${left_arrow}" select-pane -L
tmux $bind "${mod}${down_arrow}" select-pane -D
tmux $bind "${mod}${up_arrow}" select-pane -U
tmux $bind "${mod}${right_arrow}" select-pane -R

# Switch to pane via Alt + hjkl.
tmux $bind "${mod}${h}" select-pane -L
tmux $bind "${mod}${j}" select-pane -D
tmux $bind "${mod}${k}" select-pane -U
tmux $bind "${mod}${l}" select-pane -R

# Move a pane via Alt + Shift + hjkl.
if [ -z "$legacy" ]; then
	tmux $bind "${mod}${H}" swap-pane -s '{left-of}'
	tmux $bind "${mod}${J}" swap-pane -s '{down-of}'
	tmux $bind "${mod}${K}" swap-pane -s '{up-of}'
	tmux $bind "${mod}${L}" swap-pane -s '{right-of}'
else
	tmux $bind "${mod}${H}" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -L; tmux swap-pane -t $old'
	tmux $bind "${mod}${J}" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -D; tmux swap-pane -t $old'
	tmux $bind "${mod}${K}" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -U; tmux swap-pane -t $old'
	tmux $bind "${mod}${L}" run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -R; tmux swap-pane -t $old'
fi

# Open a terminal with Alt + <new_pane>
if [ -n "$new_pane" ]; then
	if [ -z "$legacy" ]; then
		tmux $bind "${mod}${new_pane}" \
			run-shell 'cwd="`tmux display -p \"#{pane_current_path}\"`"; tmux select-pane -t "bottom-right"; tmux split-pane -c "$cwd"'
	else
		tmux $bind "${mod}${new_pane}" \
			select-pane -t 'bottom-right' \\\; split-window \\\; run-shell 'tmux select-layout' \\\; send escape
	fi
fi

# Name a window with Alt + n (or the key set through the options)
# Will be disabled if set to '---'
if [ -n "$rename" ]; then
	tmux $bind "${mod}${rename}" \
		command-prompt -p 'Window name:' 'rename-window "%%"'
fi

# Close a window with Alt + Shift + q.
if [ -z "$legacy" ]; then
	tmux $bind "${mod}Q" \
		if-shell \
		'[ "$(tmux display-message -p "#{window_panes}")" -gt 1 ]' \
		'kill-pane; select-layout; select-layout -E' \
		'kill-pane'
else
	tmux $bind "${mod}Q" \
		kill-pane
fi

# Close a connection with Alt + Shift + e.
tmux $bind "${mod}E" \
	confirm-before -p "Detach from #H:#S? (y/n)" detach-client

# Reload configuration with Alt + Shift + c.
tmux $bind "${mod}C" \
	source-file ~/.tmux.conf \\\; display "Reloaded config"
# }}}

# Define hooks {{{
if [ -z "$legacy" ]; then
	# Autorefresh layout after deleting a pane.
	if [ "$(char_at $refresh_hooks 1)" = 'y' ]; then
		tmux set-hook -g after-split-window "select-layout; select-layout -E"
	fi

	if [ "$(char_at $refresh_hooks 2)" = 'y' ]; then
		tmux set-hook -g pane-exited "select-layout; select-layout -E"
	fi

	# Autoselect layout after creating new window.
	if [ -n "${default:-}" ]; then
		tmux set-hook -g window-linked "select-layout \"$default\"; select-layout -E"
		tmux select-layout "$default"
		tmux select-layout -E
	fi
fi
# }}}

# Integrate with Vim for transparent navigation {{{
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

if [ "${navigate:-}" = "on" ]; then
	# If `@tilish-navigate` is nonzero, integrate Mod + hjkl with `tmux-navigate`.
	tmux set -g '@navigate-left'  "-n ${mod}${h}"
	tmux set -g '@navigate-down'  "-n ${mod}${j}"
	tmux set -g '@navigate-up'    "-n ${mod}${k}"
	tmux set -g '@navigate-right' "-n ${mod}${l}"
elif [ "${navigator:-}" = "on" ]; then
	# If `@tilish-navigator` is nonzero, integrate Mod + hjkl with `vim-tmux-navigator`.
	# This assumes that your Vim/Neovim is setup to use Alt + hjkl bindings as well.

	tmux $bind "${mod}${h}" if-shell "$is_vim" "send ${mod}${h}" 'select-pane -L'
	tmux $bind "${mod}${j}" if-shell "$is_vim" "send ${mod}${j}" 'select-pane -D'
	tmux $bind "${mod}${k}" if-shell "$is_vim" "send ${mod}${k}" 'select-pane -U'
	tmux $bind "${mod}${l}" if-shell "$is_vim" "send ${mod}${l}" 'select-pane -R'

	if [ -z "$prefix" ]; then
		tmux bind -T copy-mode-vi "${mod}${h}" select-pane -L
		tmux bind -T copy-mode-vi "${mod}${j}" select-pane -D
		tmux bind -T copy-mode-vi "${mod}${k}" select-pane -U
		tmux bind -T copy-mode-vi "${mod}${l}" select-pane -R
	fi
fi

if [ "${smart_splits:-}" = "on" ]; then
	if [ -z "$smart_splits_dirs" ]; then
		smart_splits_dirs='fvtg' # left/down/up/right
	fi

	if [ -z "$smart_splits_dirs_large" ]; then
		smart_splits_dirs_large='sxed' # left/down/up/right
	fi

	left=$(char_at $smart_splits_dirs 1)
	down=$(char_at $smart_splits_dirs 2)
	up=$(char_at $smart_splits_dirs 3)
	right=$(char_at $smart_splits_dirs 4)

	tmux $bind "${mod}${left}"  if-shell "$is_vim" "send ${mod}${left}"  'resize-pane -L'
	tmux $bind "${mod}${down}"  if-shell "$is_vim" "send ${mod}${down}"  'resize-pane -D'
	tmux $bind "${mod}${up}"    if-shell "$is_vim" "send ${mod}${up}"    'resize-pane -U'
	tmux $bind "${mod}${right}" if-shell "$is_vim" "send ${mod}${right}" 'resize-pane -R'

	left_large=$(char_at $smart_splits_dirs_large 1)
	down_large=$(char_at $smart_splits_dirs_large 2)
	up_large=$(char_at $smart_splits_dirs_large 3)
	right_large=$(char_at $smart_splits_dirs_large 4)

  dx=${smart_splits_large_dx:-10}
  dy=${smart_splits_large_dy:-6}

	tmux $bind "${mod}${left_large}"  if-shell "$is_vim" "send ${mod}${left}"  "resize-pane -L $dx"
	tmux $bind "${mod}${down_large}"  if-shell "$is_vim" "send ${mod}${down}"  "resize-pane -D $dy"
	tmux $bind "${mod}${up_large}"    if-shell "$is_vim" "send ${mod}${up}"    "resize-pane -U $dy"
	tmux $bind "${mod}${right_large}" if-shell "$is_vim" "send ${mod}${right}" "resize-pane -R $dx"
fi
# }}}

# Integrate with `fzf` to approximate `dmenu` {{{
if [ -z "$legacy" ] && [ "${dmenu:-}" = "on" ]; then
	if [ -n "$(command -v fzf)" ]; then
		# The environment variables of your `default-shell` are used when running `fzf`.
		# This solution is about an order of magnitude faster than invoking `compgen`.
		# Based on: https://medium.com/njiuko/using-fzf-instead-of-dmenu-2780d184753f
		tmux $bind "${mod}d" \
			select-pane -t '{bottom-right}' \\\; split-pane 'sh -c "exec \$(echo \"\$PATH\" | tr \":\" \"\n\" | xargs -I{} -- find {} -maxdepth 1 -mindepth 1 -executable 2>/dev/null | sort -u | fzf)"'
	else
		tmux $bind "${mod}d" \
			display 'To enable this function, install `fzf` and restart `tmux`.'
	fi
fi
# }}}
