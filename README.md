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
Not a whole lot beyond basic movements and insert mode so far.  This will get
updated once it's in a more usable state.


TODO
----
* linewise visual mode
* `c`, `d`, `y`, `~`, `g~`, `gu`, `gU`, `>`, and `<` operators (for normal &
visual modes)
* registers (including explicit "x registers)
* more movements (including `w`, `W`, `b`, `B` that is consistent with Vim's
ideas of words and WORDs)
* `u`/`ctrl-r` (with a granularity matching Vim's)
* `.` command
