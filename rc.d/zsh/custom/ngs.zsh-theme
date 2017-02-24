PROMPT_SUCCESS_COLOR=$FG[149]
PROMPT_FAILURE_COLOR=$FG[131]
PROMPT_VCS_INFO_COLOR=$FG[242]
PROMPT_PROMPT=$FG[077]
GIT_DIRTY_COLOR=$FG[133]
GIT_CLEAN_COLOR=$FG[045]
GIT_PROMPT_INFO=$FG[012]
HOSTNAME_COLOR=$FG[247]

autoload -U add-zsh-hook
typeset -A host_repr

# local time, color coded by last return code
time_enabled="%(?.%{$PROMPT_SUCCESS_COLOR%}.%{$PROMPT_FAILURE_COLOR%})%*%{$reset_color%}"
time_disabled="%{$PROMPT_SUCCESS_COLOR%}%*%{$reset_color%}"
time=$time_enabled

# user part, color coded by privileges
local user="%(?.%{$PROMPT_SUCCESS_COLOR%}.%{$PROMPT_FAILURE_COLOR%})%n%{$reset_color%}"

# Hostname part.  compressed and colorcoded per host_repr array
# if not found, regular hostname in default color
local host="%{$HOSTNAME_COLOR%}@%m%{$reset_color%}"

# Compacted $PWD
local pwd="%{$fg[blue]%}%~%{$reset_color%}"

PROMPT='${user}${host} ${pwd} \$ '
RPS1='$(git_prompt_status) $(git_prompt_info)$(git_prompt_short_sha) %{$FG[246]%}rb:$(rbenv_prompt_info)/nd:$(nodenv_prompt_info)%{$reset_color%} ${time}${return_code}'

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[046]%}+%{$FG[196]%}-%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="${GIT_DIRTY_COLOR} ✘"
ZSH_THEME_GIT_PROMPT_CLEAN="${GIT_CLEAN_COLOR} ✔"

ZSH_THEME_GIT_PROMPT_ADDED=" %{$FG[082]%}A%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %{$FG[166]%}M%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED=" %{$FG[160]%}D%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_RENAMED=" %{$FG[220]%}R%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED=" %{$FG[082]%}U%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$FG[190]%}?%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=''

# elaborate exitcode on the right when >0
return_code_enabled=" %(?..%{$bg_bold[red]%}%{$fg_bold[black]%}%? ↵%{$reset_color%})"
return_code_disabled=
return_code=$return_code_enabled

function accept-line-or-clear-warning () {
	if [[ -z $BUFFER ]]; then
		time=$time_disabled
		return_code=$return_code_disabled
	else
		time=$time_enabled
		return_code=$return_code_enabled
	fi
	zle accept-line
}
zle -N accept-line-or-clear-warning
bindkey '^M' accept-line-or-clear-warning
