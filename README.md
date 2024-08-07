# Table of Contents

<details>
   <summary>Click to expand</summary>

- [Tmux Tilish](#tmux-tilish)
  - [Changes in this fork:](#changes-in-this-fork)
  - [Why?](#why)
  - [Quickstart](#quickstart)
  - [Keybindings](#keybindings)
    - [Auto-refresh hooks](#auto-refresh-hooks)
    - [Layout keys](#layout-keys)
  - [Easy mode](#easy-mode)
  - [Prefix mode](#prefix-mode)
  - [Application launcher](#application-launcher)
  - [Terminal compatibility](#terminal-compatibility)
  - [Usage inside i3wm](#usage-inside-i3wm)
  - [Integration with vim](#integration-with-vim)
    - [Navigate](#navigate)
    - [Navigator](#navigator)
- [Related projects](#related-projects)

</details>

# Tmux Tilish

## Changes in this fork:

- A lot of keybindings are configurable using `set -g @tilish-<option> "<val>"`

---

This is a plugin that makes [`tmux`][6] behave more like a typical
[dynamic window manager][7]. It is heavily inspired by [`i3wm`][8], and
most keybindings are taken [directly from there][1]. However, I have made
some adjustments to make these keybindings more consistent with `vim`:
using <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> instead of
<kbd>j</kbd><kbd>k</kbd><kbd>l</kbd><kbd>;</kbd> for directions, and
using `vim`'s definitions of "split" and "vsplit". There is also an
"easy mode" available for non-`vim` users, which uses arrow keys
instead of <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>.

The plugin has been verified to work on `tmux` v1.9, v2.6, v2.7, v2.9, and v3.0.
Some features are only available on newer versions of `tmux` (currently v2.7+),
but I hope to provide at least basic support for most `tmux` versions in active use.
If you encounter any problems, please file an issue and I'll try to look into it.

[1]: https://i3wm.org/docs/refcard.html
[6]: https://github.com/tmux/tmux/wiki/Getting-Started
[7]: https://en.wikipedia.org/wiki/Dynamic_window_manager
[8]: https://i3wm.org/docs/

## Why?

Okay, so who is this plugin for anyway? You may be interested in this if:

- You're using or interested in using `tmux`, but find the default keybindings
  a bit clunky. This lets you try out an alternative keybinding paradigm,
  which uses a modifier key (<kbd>Alt</kbd>) instead of a prefix key
  (<kbd>Ctrl</kbd> + <kbd>b</kbd>). The plugin also makes it easier to do
  automatic tiling via `tmux` layouts, as opposed to splitting panes manually.
- You use `i3wm`, but also do remote work over `ssh` + `tmux`. This lets
  you use similar keybindings in both contexts.
- You also use other platforms like Gnome, Mac, or WSL. You want to take
  your `i3wm` muscle memory with you via `tmux`.
- You're not really using `i3wm` anymore, but you did like how it handled
  terminals and workspaces. You'd like to keep working that way in terminals,
  without using `i3wm` or `sway` for your whole desktop.
- You use a window manager that is similar to `i3wm`, e.g. [`dwm`][9],
  and want to have that workflow in `tmux` too.

[9]: https://dwm.suckless.org/tutorial/

## Quickstart

The easiest way to install this plugin is via the [Tmux Plugin Manager][2].
Just add the following to `~/.tmux.conf`, then press <kbd>Ctrl</kbd> + <kbd>b</kbd>
followed by <kbd>Shift</kbd> + <kbd>i</kbd> to install it (assuming default prefix key):

    set -g @plugin 'farzadmf/tmux-tilish'

For `tmux` v2.7+, you can customize which layout is used as default for new workspaces.
To do so, add this to `~/.tmux.conf`:

    set -g @tilish-default 'main-vertical'

Just replace `main-vertical` with one of the layouts from the `tmux` `man` page:

| Description       | Name              |
| ----------------- | ----------------- |
| split then vsplit | `main-horizontal` |
| only split        | `even-vertical`   |
| vsplit then split | `main-vertical`   |
| only vsplit       | `even-horizontal` |
| fully tiled       | `tiled`           |

The words "split" and "vsplit" refer to the layouts you get in `vim` when
running `:split` and `:vsplit`, respectively. (Unfortunately, what is called
a "vertical" and "horizontal" split varies between programs.)
If you do not set this option, `tilish` will not autoselect any layout; you
can still choose layouts manually using the keybindings listed below.

After performing the steps above, you should read the [list of keybindings](#keybindings).
For further configuration options:

- If you use `nvim` or `vim`, consider [integrating it with `tilish`](#integration-with-vim).
- If you do not use `vim` or `kak`, consider activating [easy mode](#easy-mode).
- If you use `kak` or `emacs`, consider activating [prefix mode](#prefix-mode).
- If you use `tmux` within `i3wm` or `sway`, see [this section](#usage-inside-i3wm).
- If you like `dmenu`, check out the [application launcher](#application-launcher).
- If it doesn't work, check your [terminal settings](#terminal-compatibility).

It is also recommended that you add the following to the top of your `.tmux.conf`:

    set -s escape-time 0
    set -g base-index 1

The first line prevents e.g. <kbd>Esc</kbd> + <kbd>h</kbd> from triggering the
<kbd>Alt</kbd> + <kbd>h</kbd> keybinding, preventing common misbehavior when
using `vim` in `tmux`. This option is automatically set by [tmux-sensible][4], if
you use that. The second line makes workspace numbers go from 1-10 instead of 0-9,
which makes more sense on a keyboard where the number row starts at 1. However,
`tilish` explicitly checks this setting when mapping keys, and works fine without it.

[2]: https://github.com/tmux-plugins/tpm
[4]: https://github.com/tmux-plugins/tmux-sensible

## Keybindings

Finally, here is a list of the actual keybindings. Most are [taken from `i3wm`][1].
Below, a "workspace" is what `tmux` would call a "window" and `vim` would call a "tab",
while a "pane" is what `i3wm` would call a "window" and `vim` would call a "split".

NOTE: a bunch of the following keys can be overridden through the options (see below).

| Keybinding                                                                           | Description                                                          |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| <kbd>Alt</kbd> + <kbd>0</kbd>-<kbd>9</kbd>                                           | Switch to workspace number 0-9                                       |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd>-<kbd>9</kbd>                        | Move pane to workspace 0-9                                           |
| <kbd>Alt</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>                    | Move focus left/down/up/right                                        |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> | Move pane left/down/up/right (NOTE: the arrow keys are always bound) |
| <kbd>Alt</kbd> + <kbd>Enter</kbd>                                                    | Create a new pane at "the end" of the current layout                 |
| <kbd>Alt</kbd> + <kbd>s</kbd>                                                        | Switch to layout: split then vsplit                                  |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>s</kbd>                                     | Switch to layout: only split                                         |
| <kbd>Alt</kbd> + <kbd>v</kbd>                                                        | Switch to layout: vsplit then split                                  |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>v</kbd>                                     | Switch to layout: only vsplit                                        |
| <kbd>Alt</kbd> + <kbd>t</kbd>                                                        | Switch to layout: fully tiled                                        |
| <kbd>Alt</kbd> + <kbd>z</kbd>                                                        | Switch to layout: zoom (fullscreen)                                  |
| <kbd>Alt</kbd> + <kbd>r</kbd>                                                        | Refresh current layout                                               |
| <kbd>Alt</kbd> + <kbd>n</kbd>                                                        | Name/rename current window                                           |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>q</kbd>                                     | Quit (close) pane                                                    |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>e</kbd>                                     | Exit (detach) tmux                                                   |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>c</kbd>                                     | Reload config                                                        |

The <kbd>Alt</kbd> + <kbd>0</kbd> and <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd>
bindings are "smart": depending on `base-index`, they either act on workspace 0 or 10.

The following options can be used to override some keys mentioned in the above table (if they're not
set, the default value will be used):

- `set -g @tilish-refresh "..."` (default <kbd>r</kbd>)
- `set -g @tilish-rename "..."` (default <kbd>n</kbd>)

The keybindings that move panes between workspaces assume a US keyboard layout.
However, you can configure `tilish` for international keyboards by providing a string
`@tilish-shiftnum` prepared by pressing <kbd>Shift</kbd> +
<kbd>1</kbd><kbd>2</kbd><kbd>3</kbd><kbd>4</kbd><kbd>5</kbd><kbd>6</kbd><kbd>7</kbd><kbd>8</kbd><kbd>9</kbd><kbd>0</kbd>.
For instance, for a UK keyboard, you would configure it as follows:

    set -g @tilish-shiftnum '!"£$%^&*()'

Your terminal must support sending keycodes like `M-£` for the above to work.
For instance, a UK keyboard layout works fine on `urxvt`, but does not work
by default on `kitty` or `alacritty`, which may require additional configuration.

### Bindings the can be disabled through options

- The `rename` option can be disabled if set to `---` like this:

  set -g @tilish-rename '---'

- The `new_pane` option, which defaults to `Enter` resulting in the combination of
  <kbd>Alt</kbd> + <kbd>Enter</kbd> to create a new pane,
  can be disabled if set to `---` like this:

  set -g @tilish-new_pane '---'

### Auto-refresh hooks

By default, we set hooks to auto-refresh the window layout when a pane is created/deleted. The setting can be controlled using
`@tilish-refresh_hooks`. It's a 2-character (default is `'yy'`):

- First character enables/disables auto-refreshing after a pane is created (`after-split-window`)
- Second character enables/disables auto-refreshing after a pane is deleted (`pane-exited`)

So, for example, to disable the hooks, we would do something like this:

    set -g @tilish-refresh_hooks 'nn'

### Layout keys

We use some keys to manipulate the window layout. The setting is controlled through the option `@tilish-layout_keys`,
where the default value is `sSvVtz`, representing the following:

- First character (<kbd>s</kbd>) is used to switch to layout `main-horizontal`
- Second character (<kbd>S</kbd>) is used to switch to layout `even-vertical`
- Third character (<kbd>v</kbd>) is used to switch to layout `main-vertical`
- Fourth character (<kbd>V</kbd>) is used to switch to layout `even-horizontal`
- Fifth character (<kbd>t</kbd>) is used to switch to layout `tiled`
- Sixth character (<kbd>z</kbd>) is used to switch to layout `zoom`

In order to override a key, you need to specify the complete string and only change the ones you desire. For example,
to use <kbd>i</kbd> and <kbd>I</kbd> instead of <kbd>v</kbd> and <kbd>V</kbd>, respectively, we would do something like this:

    set -g @tilish-layout_keys 'sSiItz'

To disable a key, you can set it to `_`; for example, to disable `mod-t` to switch to tiled layout, we can do:

    set -g @tilish-layout_keys 'sSiI_z'

## Easy mode

To make the plugin more accessible for people who do not use `vim` as well,
there is also an "easy mode" available, which uses arrow keys instead of
the `vim`-style <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> keys.

There's a setting called `tilish_easymode`, consisting of two characters that enables/disables
the "easy mode" for pane focus/movment.

The default value is `'nn'`, which means to use vim-style keybindings for both focus and movement:

- The first character corresponds to pane focus.
- The second character corresponds to pane movement.

For example, by doing this in `.tmux.conf`:

    set -g @tilish-easymode 'ny'

we can enable the "easy mode" only for pane movement, which means the revised keybindings for the pane movement then become:

| Keybinding                                                                                                   | Description                  |
| ------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>&#8592;</kbd><kbd>&#8595;</kbd><kbd>&#8593;</kbd><kbd>&#8594;</kbd> | Move pane left/down/up/right |

Or by doing this:

    set -g @tilish-easymode 'yn'

will enable arrows for pane focus. The revised keybindings for the pane focus then become:

| Keybinding                                                                                | Description                   |
| ----------------------------------------------------------------------------------------- | ----------------------------- |
| <kbd>Alt</kbd> + <kbd>&#8592;</kbd><kbd>&#8595;</kbd><kbd>&#8593;</kbd><kbd>&#8594;</kbd> | Move focus left/down/up/right |

## Prefix mode

Note that this feature is currently only available in `tmux` v2.4+.
The "prefix mode" uses a prefix key instead of <kbd>Alt</kbd>, and
may be particularly interesting for users of editors like `kak` and
`emacs` that use <kbd>Alt</kbd> key a lot. To activate this mode, you
define a prefix keybinding in your `tmux.conf`. For instance, to use
<kbd>Alt</kbd> + <kbd>Space</kbd> as your `tilish` prefix, add:

    set -g @tilish-prefix 'M-space'

Actions that would usually be done by <kbd>Alt</kbd> + <kbd>key</kbd>
are now accomplished by pressing the prefix and then <kbd>key</kbd>.
For example, opening a split is usually <kbd>Alt</kbd> + <kbd>Enter</kbd>,
but with the above prefix this becomes <kbd>Alt</kbd> + <kbd>Space</kbd>
then <kbd>Enter</kbd>. Note that the `tilish` prefix is different from
the `tmux` prefix, and should generally be bound to a different key.
For the prefix key, you can choose basically any keybinding that `tmux`
supports, e.g. `F12` or `C-s` or anything else you may prefer.

All these keybindings are `repeat`'able, so you do not have to press the
prefix key again if you type multiple commands fast enough. Thus, pressing
<kbd>Alt</kbd> + <kbd>Space</kbd> followed by <kbd>h</kbd><kbd>j</kbd> would
move to the left and then down, without requiring another prefix activation.
The `tmux` option `repeat-time` can be used to customize this timeout.
Personally, I find the default 500ms timeout somewhat short, and would
recommend that you increase this to at least a second if you use `tilish`:

    set -g repeat-time 1000

## Application launcher

In `i3wm`, the keybinding <kbd>Alt</kbd>+<kbd>d</kbd> is by default mapped to
the application launcher `dmenu`, which can be practical to quickly open apps.
If you have [`fzf`][5] available on your system, `tilish` can offer a similar
application launcher using the same keyboard shortcut. To enable this
functionality, add the following to your `~/.tmux.conf`:

    set -g @tilish-dmenu 'on'

Basically, pressing <kbd>Alt</kbd>+<kbd>d</kbd> will then pop up a split
that lets you fuzzy-search through all executables in your system `$PATH`.
Selecting an executable runs the command in that split. When you want
to start an interactive process, this can be more convenient than
using <kbd>Alt</kbd>+<kbd>Enter</kbd> and typing the command name.
This is currently only available in `tmux` v2.7+.

[5]: https://github.com/junegunn/fzf

## Terminal compatibility

Not all terminals support all keybindings. The plugin has been verified
to work well with: `iTerm2` and `Terminal.app` on macOS; `alacritty`, `kitty`,
`terminator`, `gnome-terminal`, and `urxvt` on Linux; `wsltty` and `alacritty`
on Windows. Some of these terminals bind <kbd>Alt</kbd>+<kbd>Enter</kbd> to
fullscreen, so you have to disable that for the `tilish` "new pane" binding to
work. Moreover, `gnome-terminal` steals the "switch workspace" keybindings
<kbd>Alt</kbd>+<kbd>0</kbd>-<kbd>9</kbd> _if_ you open multiple tabs. If you
use macOS, you likely want to configure the `Option` key to send either `Esc+`
(`iTerm2`) or `Meta` (`Terminal.app`) under the keyboard settings of the app.

If you use `xterm`, almost none of the <kbd>Alt</kbd> keys work by default.
That can be fixed by adding this to `~/.Xresources`:

    XTerm*eightBitControl: false
    XTerm*eightBitInput: false
    XTerm.omitTranslation: fullscreen
    XTerm*fullscreen: never

## Usage inside i3wm

If you use `tilish` inside `i3wm` or `sway`, keybindings like
<kbd>Alt</kbd>+<kbd>Enter</kbd> may spawn a new terminal in your window manager
instead of a new terminal pane inside `tmux`. The window manager always takes
priority — so if both `i3wm` and `tilish` define the same keybinding,
`i3wm` will intercept the keybinding before `tmux` sees it.

The best way to solve this is perhaps to change your window manager modifier key
to <kbd>Super</kbd>, also known as the "Windows key". As described
[in the `i3wm` user guide](https://i3wm.org/docs/userguide.html#_using_i3), this can
be done by changing `$mod` to `Mod4` in your `i3wm` config. That way, pressing e.g.
<kbd>Alt</kbd>+<kbd>Enter</kbd> opens a new terminal pane inside `tmux`, while
<kbd>Super</kbd>+<kbd>Enter</kbd> opens a new terminal in `i3wm`.

Alternatively, `tilish` also supports a [Prefix mode](#prefix-mode). This is in my opinion
less ergonomic than the default `tilish` keybindings. However, it does not require the use
of <kbd>Alt</kbd>, and is therefore compatible with the default `i3wm` keybindings.

## Integration with [neo]vim

There are plugins such as:

- [tmux-navigate][10]
- [vim-tmux-navigator][3]
- [smart-splits.nvim][4]
  which both allow seamless navigation/resizing between `vim` splits and `tmux` splits.
  The former has an advantage that it also works over `ssh` connections, and that
  it plays better with zooming (<kbd>Alt</kbd>+<kbd>z</kbd>). If you use either
  plugin, you can tell `tilish` to make it setup the keybindings for you. (If you
  don't, `tilish` will use fallback keybindings that don't integrate with `vim`.)

### Navigate

It is perhaps easiest to setup `tmux-navigate`. Just load `navigate` _after_ `tilish`
in your `tmux.conf`, and set the option `@tilish-navigate` to `on` to integrate them.
Thus a full working minimal example of a `tpm`-based `tmux.conf` would be:

    # List of plugins.
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'farzadmf/tmux-tilish'
    set -g @plugin 'sunaku/tmux-navigate'

    # Plugin options.
    set -g @tilish-navigate 'on'

    # Install `tpm` if needed.
    if "test ! -d ~/.tmux/plugins/tpm" \
       "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

    # Activate the plugins.
    run -b "~/.tmux/plugins/tpm/tpm"

No further setup is required; `tilish` sets up the keybindings, and `navigate`
handles seamless navigation of `vim`/`nvim` splits. However, if you also want
this seamless navigation over `ssh` connections, you should install
the accompanying `vim` plugin; see [their website for more information][10].

### Navigator

To install `vim-tmux-navigator`, you should first install the plugin for `vim`
or `nvim`, as described on [their website][3]. Then place this in your
`~/.config/nvim/init.vim` (`nvim`) or `~/.vimrc` (`vim`):

    noremap <silent> <m-h> :TmuxNavigateLeft<cr>
    noremap <silent> <m-j> :TmuxNavigateDown<cr>
    noremap <silent> <m-k> :TmuxNavigateUp<cr>
    noremap <silent> <m-l> :TmuxNavigateRight<cr>

You then just have to tell `tilish` that you want the integration:

    set -g @tilish-navigator 'on'

A minimal working example of a `~/.tmux.conf` with `tpm` would then be:

    # List of plugins.
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'jabirali/tmux-tilish'

    # Plugin options.
    set -g @tilish-navigator 'on'

    # Install `tpm` if needed.
    if "test ! -d ~/.tmux/plugins/tpm" \
       "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

    # Activate the plugins.
    run -b "~/.tmux/plugins/tpm/tpm"

### Smart-Splits

Although this plugin also provides navigation, as of now, we only support the resizing of splits.
The default directions used as up/down/left/right are `tvfg`. They might seem random, but on a
"normal" keyboard, you can see how they can represent the directions 😉.

You to setup the plugin in neovim (see their Website), and then tell `tilish` to enable
the integration:

    set -g @tilish-smart_splits 'on'

And you can customize the keys (the order is left/down/up/right); for example, the default is:

    set -g @tilish-smart_splits_dirs 'fvtg'

There's also the variable `@tilish-smart_splits_dirs_large`, which resizes the panes in larger
deltas. Different delta values for `x` and `y` directions can be specified using the
`@tilish-smart_splits_large_dx` and `@tilish-smart_splits_large_dy`.

Default values for the options mentioned above (there's no need for these lines in your config;
there are here for reference):

    set -g @tilish-smart_splits_dirs_large 'sxed'
    set -g @tilish-smart_splits_large_dx 10
    set -g @tilish-smart_splits_large_dx 6

[3]: https://github.com/christoomey/vim-tmux-navigator
[4]: https://github.com/mrjones2014/smart-splits.nvim
[10]: https://github.com/sunaku/tmux-navigate

# Related projects

- [3mux](https://github.com/aaronjanse/3mux)
- [tmux-navigate](https://github.com/sunaku/tmux-navigate)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [vim-i3wm-tmux-navigator](https://github.com/fogine/vim-i3wm-tmux-navigator)
