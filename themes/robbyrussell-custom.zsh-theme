# local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
# PROMPT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

# ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
# ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
# ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

local ret_status="%(?:%{$fg_bold[yellow]%}➜:%{$fg_bold[red]%}➜)"
local end_status="%(?:%{$fg_bold[yellow]%}»:%{$fg_bold[red]%}»)"
PROMPT='${ret_status} %{$reset_color%}%c$(git_prompt_info) ${end_status} %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" git:(%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}) ✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%})"

