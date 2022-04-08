# wittionary does dotfiles
_Originally and shamelessly copied from [@holman](https://github.com/holman/dotfiles). Aberrations are my own._

Your dotfiles are how you personalize your system. These are mine.

Zach Holman has an interesting [post](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/) on dotfiles if you're new to them. (I sure am!).

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## what's inside

_Who knows?_
[Fork it](https://github.com/wittionary/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

## install

### quick zsh setup
```sh
# Overwrites existing .zshrc
mv ~/.zshrc ~/.zshrc.bak;curl -fsSL https://raw.githubusercontent.com/Wittionary/dotfiles/main/zsh/.zshrc --output ~/.zshrc;source ~/.zshrc
```

## thanks

I forked [Zach Holman](http://github.com/holman)'s excellent
[dotfiles](http://github.com/holman/dotfiles) for a couple weeks before deciding I needed a setup that was built from the ground up and totally custom to the way I work so I started over. I will definitely be referring to his work as a documentation of sorts to discern different approaches and solutions. A decent amount of the code in these dotfiles stem or are inspired from Holman's original project.
