# Catppuccin Mocha — fzf theme
# Aligned with yazi flavor.toml color logic
#
# Palette:
#   base       #1e1e2e   surface0   #313244   surface1   #45475a   surface2   #585b70
#   overlay0   #6c7086   overlay1   #7f849c   overlay2   #9399b2   subtext0   #a6adc8
#   text       #cdd6f4   blue       #89b4fa   teal       #94e2d5   green      #a6e3a1
#   yellow     #f9e2af   peach      #fab387   red        #f38ba8   mauve      #cba6f7
#   pink       #f5c2e7   sky        #89dceb   mantle     #181825   crust      #11111b

export FZF_DEFAULT_OPTS="
  --color=dark
  --highlight-line
  --color=bg:#0a0a0f           # main background — near black
  --color=bg+:#313244          # current line background — slightly lighter
  --color=alt-bg:#111119       # alternating row background — between bg and bg+
  --color=gutter:#0a0a0f       # left gutter — blends with background
  --color=input-bg:#0a0a0f     # input line background
  --color=preview-bg:#0a0a0f   # preview window background
  --color=fg:#cdd6f4           # main text
  --color=fg+:#cdd6f4          # current line text
  --color=selected-fg:#cdd6f4  # selected items text
  --color=preview-fg:#cdd6f4   # preview window text
  --color=query:#cdd6f4        # query text in input line
  --color=ghost:#585b70        # placeholder text (hint)
  --color=disabled:#585b70     # query text when search is disabled
  --color=hl:#f38ba8           # matched characters in list
  --color=hl+:#f38ba8          # matched characters in current line
  --color=selected-hl:#f38ba8  # matched characters in selected lines
  --color=selected-bg:#1e1e2e  # selected (multi-select) lines background
  --color=prompt:#89b4fa       # prompt symbol ('>') before query
  --color=pointer:#94e2d5      # pointer to current line
  --color=marker:#f5c2e7       # multi-select marker (Tab)
  --color=spinner:#94e2d5      # loading spinner
  --color=info:#9399b2         # info line (match count)
  --color=separator:#313244    # horizontal separator of info line
  --color=scrollbar:#45475a    # scrollbar
  --color=border:#708880       # border around the whole window
  --color=label:#89b4fa        # border label (--border-label)
  --color=list-border:#6c7086  # border around the list
  --color=input-border:#6c7086 # border around the input line
  --color=preview-border:#6c7086       # preview window border
  --color=preview-scrollbar:#45475a    # preview window scrollbar
  --color=preview-label:#94e2d5        # preview window border label
  --color=header:#a6e3a1       # header line (--header)
  --color=footer:#9399b2       # footer line (--footer)"
