# =============================================================================
# lichtar — widgets/magic_clean_screen.zsh
# Clean screen with CTRL+L
# =============================================================================
 
function magic-clear-screen() {
	printf "\033[H\033[2J\033[3J"
	_assemble_prompt
	[[ -o zle ]] && zle reset-prompt
}

zle -N magic-clear-screen
bindkey '^L' magic-clear-screen
