Jim
===

> This is Vim's brain[1] on JavaScript[2]

  [1]: It's a smaller brain than Vim's. As Vim's younger brutha, Jim keeps learning new things...
  [2]: Well, JavaScript compiled from Coffeescript

Jim is an [Ace](https://github.com/ajaxorg/ace) plugin that aims to bring the
feel of Vim to the editor.  The idea is to layer Vim's normal mode on top of Ace,
have a visual mode that works harmoniously with regular Ace selections, and just
step out of the way when in insert mode.  Also, Jim's undo/redo keybindings
(u/ctrl-r) should behave consistently with its Vim counterparts while using the
same undo stack as Ace so that its Undo/Redo keybindings are left unchanged.

What works so far
-----------------
* modes: normal, visual (characterwise and linewise), insert, replace
* insert switches: `i`, `a`, `o`, `O`, `I`, `A`, and `C`
* commands: `D`, `gJ`, `J`, `p`, `P`, `r`, `s`, `x`, `X`, and `u`
* visual mode commands: `gJ`, `J`, `p` and `P`
* operators: `c`, `d`, `y`, `>`, and `<` in normal and visual modes (double
  operators work as linewise commands in normal mode, too)
* motions (can be used with counts and/or operators, and in visual mode)
  * `h`, `j`, `k`, `l`
  * `W`, `E`, `B`, `w`, `e`, `b`
  * `0`, `^`, `$`
  * `G`, `gg`
  * `H`, `M`, `L`
  * `/`, `?`, `n`, `N`
  * `f`, `F`, `t`, `T`
* default register (operations yank text in the the register for pasting)
* `u` works as it does in Vim (`Cmd-z` and `Cmd-y` still work as they do in Ace)

Next up
-------
* `.` command

If you have a feature request [create an issue](https://github.com/misfo/jim/issues/new)

Known issues
------------
Take a gander at the [issue tracker](https://github.com/misfo/jim/issues)

Hack
----
```
git clone git://github.com/misfo/jim.git
cd jim
git submodule update --init
```

Then just open index.html and you're good to go.

Chrome needs a special command line argument to allow XHRs to files:
`google-chrome --allow-file-access-from-files`

While developing, keep your CoffeeScript compiling in the background:
```
coffee --watch --output lib/ src/
```

Open test/test.html to run the tests

Chromeless (experimental)
-------------------------
Jim can be run as a [Chromeless](https://github.com/mozilla/chromeless)
app that has (very) basic Open/Save file capabilities.  Once you've
installed Chromeless just point it at Jim's directory:
```
~/code/chromless/chromeless ~/code/jim/
```

Chromeless is very experimental and the file capabilities
that Jim has are only kinda tested, so keep any files you're editing in
Git.  If it eats your file or slaps your grandma, don't say you weren't
warned...
