# =============================================================================
# lichtar — widgets/keys.zsh
# Key bindings for physical keyboard
# =============================================================================

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[3~'   delete-char
bindkey '^H'      backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[^?'    backward-kill-word

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
