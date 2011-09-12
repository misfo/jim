**Jim** is a JavaScript library that adds a Vim mode to the excellent in-browser editor
[Ace](http://ajaxorg.github.com/ace/).  Github uses Ace for its editor, so you can use
the [Jim bookmarklet](http://misfo.github.com/jim) to Jimmy rig it with Vim-ness.

Try it out:
[misfo.github.com/jim](http://misfo.github.com/jim)

Jim can be easily plugged into Ace.  For an example, look at
[index.html](https://github.com/misfo/jim/blob/master/index.html)


What works so far
-----------------
* [modes](http://misfo.github.com/jim/docs/modes.html): normal, visual
  (characterwise and linewise), insert, replace
* [operators](http://misfo.github.com/jim/docs/operators.html): `c`, `d`,
  `y`, `>`, and `<` in normal and visual modes (double
  operators work as linewise commands in normal mode, too)
* [motions](http://misfo.github.com/jim/docs/motions.html) (can be used with
  counts and/or operators, and in visual mode)
  * `h`, `j`, `k`, `l`
  * `W`, `E`, `B`, `w`, `e`, `b`
  * `0`, `^`, `$`
  * `G`, `gg`
  * `H`, `M`, `L`
  * `/`, `?`, `n`, `N`, `*`, `#`
  * `f`, `F`, `t`, `T`
* other [commands](http://misfo.github.com/jim/docs/commands.html)
  * insert switches: `i`, `a`, `o`, `O`, `I`, `A`, and `C`
  * commands: `D`, `gJ`, `J`, `p`, `P`, `r`, `s`, `x`, `X`, `u`, and `.`
  * visual mode commands: `gJ`, `J`, `p` and `P`
* default register (operations yank text in the register for pasting)
* `u` works as it does in Vim (`Cmd-z` and `Cmd-y` still work as they do in Ace)

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

To keep the files in `build/` building while you develop, you'll need CoffeeScript and uglify.js:

```
npm install coffee-script
npm install uglify-js
```


Then build your files in the background:

```
cake build:ace:watch
```


Open test/test.html to run the tests


Thanks!
-------
Thanks to all [contributors](https://github.com/misfo/jim/contributors).
In other words: thanks [sourrust](https://github.com/sourrust).
