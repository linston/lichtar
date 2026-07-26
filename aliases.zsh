# =============================================================================
# lichtar — aliases.zsh
# Shell aliases
# =============================================================================

if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --icons --level=2'
fi

alias v='nvim'
alias c='clear'
alias gst='git status -sb'
alias glog='git log --oneline --graph --decorate -20'

if command -v ptpython &>/dev/null; then
    alias py='ptpython'
else
    alias py='python3'
fi
