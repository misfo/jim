Jim
===

Jim is an [Ace](https://github.com/ajaxorg/ace) plugin that aims to bring the
feel of Vim to the editor.  The idea is to layer Vim's normal mode on top of Ace,
have a visual mode that works harmoniously with regular Ace selections, and just
step out of the way when in insert mode.  Also, Jim's undo/redo keybindings
(u/ctrl-r) should behave consistently with its Vim counterparts while using the
same undo stack as Ace so that its Undo/Redo keybindings are left unchanged.

What works so far
-----------------
* modes: normal, visual, insert
* insert switches: `i`, `a`, `o`, `O`, `I`, `A`, and `C`
* commands: `D`, `p`, `P`, `s`, `x`, `X`, and `u`
* operators: `c`, `d`, and `y` in normal and visual modes (double operators work
  as linewise commands in normal mode, too)
* motions: `h`, `j`, `k`, `l`, `W`, `E`, `B`, `w`, `e`, `b`, `0`, `^`, `$`, `G`,
  `gg`, `/`, `n`, `N`, `f`, `F`, `t`, and `T` (`/`, `n`, and `N` don't work with
  operators yet)
* default register (operations yank text in the the register for pasting)
* `u` works as it does in Vim (`Cmd-z` and `Cmd-y` still work as they do in Ace)

TODO for first "version"
------------------------
* `p` from visual mode
* `>`, `<` operators
* `;`
* `r`, `R`
* `J`, `gJ`
* `*`, `#`
* `ctrl-r`
* `.` command for non-insert command (inserts are a bit more complicated to
  implement)
* fully docco'ed source

Known issues
------------
* linewise visual mode's selection can disappear when selecting only one line
* Jim can get in a weird state when clicking/highlighting (i.e. highlighting
  something with the mouse should switch Jim to visual mode)
