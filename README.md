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

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/wittionary/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## install

### quick zsh setup
```sh
# Overwrites existing .zshrc
mv "$(curl -fsSL https://raw.githubusercontent.com/Wittionary/dotfiles/main/zsh/.zshrc)" ~/.zshrc
```

## thanks

I forked [Zach Holman](http://github.com/holman)'s excellent
[dotfiles](http://github.com/holman/dotfiles) for a couple weeks before deciding I needed a setup that was built from the ground up and totally custom to the way I work so I started over. I will definitely be referring to his work as a documentation of sorts to discern different approaches and solutions. A decent amount of the code in these dotfiles stem or are inspired from Holman's original project.
