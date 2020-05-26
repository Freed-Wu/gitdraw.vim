gitdraw.vim
===========

Draw your git heat map, powered by the god of editor. [中文]

![edit]

![compile]

Features
--------

1.  No dependency of web browser. Use vim as UI.
2.  Support upload your gitdraw to your repository website.
3.  Cross platform. Not need unix shell like [GalaxyMimi/git-draw].

Dependent
---------

1.  A distribution of vim. Such as [vim/vim].
2.  [git/git].

Install
-------

### Package manager

Such as [Shougo/dein.vim], Add the following code to your vimrc.

``` {.vim}
call dein#add('Freed-Wu/gitdraw.vim')
```

Then type the code in the command line of vim:

``` {.vim}
call dein#install()
```

Or the following, need [wsdjeg/dein-ui.vim].

``` {.vim}
SPInstall
```

Or the following, need [haya14busa/dein-command.vim].

``` {.vim}
Dein install
```

### Manual

Download the package first.

``` {.zsh}
git clone https://github.com/Freed-Wu/gitdraw.vim /path/to/save/this/package
```

Add the following code to your vimrc.

``` {.vim}
set runtimepath+=/path/to/save/this/package
```

Customize
---------

See [doc/gitdraw.txt]

Or type the code in the command line of vim:

``` {.vim}
help gitdraw
```

Q & A
-----

See more at [Issues].

Todo
----

### Optimize the speed of compile.

The following code need [tpope/vim-scriptease].

``` {.vim}
Time Compile
```

### Add more hotkeys.

``` {.vim}
xmap <buffer> <C-a> <plug>gitdraw-add 
xmap <buffer> <C-x> <plug>gitdraw-delete
```

Welcome to [PR]!

Thanks
------

-  [GalaxyMimi/git-draw]

  [中文]: https://zhuanlan.zhihu.com/p/141065072
  [edit]: images/i_love_open_source.png
  [compile]: images/i_love_open_source-compile.png
  [vim/vim]: https://github.com/vim/vim
  [git/git]: https://github.com/git/git
  [Shougo/dein.vim]: https://github.com/Shougo/dein.vim
  [wsdjeg/dein-ui.vim]: https://github.com/wsdjeg/dein-ui.vim
  [haya14busa/dein-command.vim]: https://github.com/haya14busa/dein-command.vim
  [doc/gitdraw.txt]: doc/gitdraw.txt
  [Issues]: https://github.com/Freed-Wu/gitdraw.vim/issues
  [tpope/vim-scriptease]: https://github.com/tpope/vim-scriptease
  [PR]: https://github.com/Freed-Wu/gitdraw.vim/pulls
  [GalaxyMimi/git-draw]: https://github.com/GalaxyMimi/git-draw
