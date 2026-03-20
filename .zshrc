export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"
plugins=(
  git
  bundler
  dotenv
  macos
  rake
  rbenv
)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Keep agnoster's styling but hide the user@host context segment.
prompt_context() {}
