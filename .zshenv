typeset -U path PATH

if [[ -d "$HOME/.local/share/bob/nvim-bin" ]]; then
  path=("$HOME/.local/share/bob/nvim-bin" $path)
fi

if [[ -d "$HOME/.local/bin" ]]; then
  path=("$HOME/.local/bin" $path)
fi

export PATH
