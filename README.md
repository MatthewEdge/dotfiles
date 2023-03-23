# Dotfiles

## Neovim

Neovim is now built from source with the alternate path prefix assumed
to be `$HOME/neovim`:

```
rm -r build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
export PATH="$HOME/neovim/bin:$PATH"
```

Check https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source
for up-to-date build instructions

### Sync Neovim Conf

```sh
rsync -r --delete -v ./nvim/* ~/.config/nvim/
```
