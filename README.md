# wittionary does dotfiles
_Originally and shamelessly copied from [@holman](https://github.com/holman/dotfiles). Aberrations are my own._

Your dotfiles are how you personalize your system. These are mine.

Zach Holman has an interesting [post](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/) on dotfiles if you're new to them.

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell.

## what's inside

_Who knows?_
[Fork it](https://github.com/wittionary/dotfiles/fork), remove what you don't
use, and build on what you do.

## install
- clone dotfiles repo
- ensure `$env:git` and `$GIT_PATH` are set

### quick zsh setup
- [ ] TODO: Update this. This is outdated. I think.
```sh
# Overwrites existing .zshrc
mv ~/.zshrc ~/.zshrc.bak;curl -fsSL https://raw.githubusercontent.com/Wittionary/dotfiles/main/zsh/.zshrc --output ~/.zshrc;source ~/.zshrc
```
### windows setup
- espanso/_setup.ps1
- git/_setup.ps1
- powershell/_setup.ps1
- windows-terminal/_setup.ps1
- Coming soon: run setup-windows.ps1

## thanks

I forked [Zach Holman](http://github.com/holman)'s excellent
[dotfiles](http://github.com/holman/dotfiles) for a couple weeks before deciding I needed a setup that was built from the ground up and totally custom to the way I work so I started over. I will definitely be referring to his work as a documentation of sorts to discern different approaches and solutions.
