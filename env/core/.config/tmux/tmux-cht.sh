#!/usr/bin/env bash


# check that the cht command is available
if ! command -v cht &> /dev/null; then
    echo "cht is not installed"
    exit 1
fi

# fzf cht history file location
export CHT_FZF_HISTORY=~/.config/tmux/.tmux-cht-fzf-history

opts="$(cht :list)"


# selected=`cat ~/.config/tmux/.tmux-cht-languages ~/.config/tmux/.tmux-cht-command | fzf`
languages=`cat ~/.config/tmux/.tmux-cht-languages`

tools=`cat ~/.config/tmux/.tmux-cht-command`

for tool in $tools; do
    opts=`echo "$opts" | sed "s/^$tool$//"`
    opts="$tool\n$opts"
done


# move the priority elements to the front of the list
# for element in $priority_elements; do
for language in $languages; do
    opts=`echo "$opts" | sed "s/^$language$//"`
    opts="$language\n$opts"
done


# get all the options in fzf
selected=`printf "$opts" | fzf --exact --print-query --scheme=history | tail -n 1`

# replace the space with a plus sign in selected
selected=`echo $selected | tr ' ' '+'`

# store the selected in the history file
echo $selected >> $CHT_FZF_HISTORY

# print the $selected and $query
echo "selected: $selected"


tmux neww bash -c "cht $selected | less -r"


# new with cht rather than curl

# # define the languages 
# languages=`echo "zsh golang bash cpp c lua rust python css html dart" | tr ' ' '\n'`
# # define the core utils
# core_utils=`echo "xargs find mv sed awk" | tr ' ' '\n'`
# 
# # check that the cht command is available
# if ! command -v cht &> /dev/null; then
#     echo "cht is not installed"
#     exit 1
# fi
# 
# 
# # change it so that it only takes one query associated with which it suggests in fzf
# 
# # select the language or core util
# selected=`printf "$languages\n$core_utils" | fzf`
# read -p "query: " query
# 
# # check if the selected language is in the languages list
# if printf "$languages" | grep -qs $selected; then
#     # echo "running command: cht $selected `echo $query | tr ' ' '+'`"
#     # tmux neww bash -c "cht $selected/`echo $query | tr ' ' '+'` & while [ : ]; do sleep 1; done"
#     # tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
#     tmux neww bash -c "echo \"cht $selected/$query/\" & cht $selected/$query & while [ : ]; do sleep 1; done"
#     # tmux neww bash -c "echo \"cht $selected/$query/\" & cht $selected/$query | less -r"
# else # if not, assume it is a core util
#     # echo "running command: cht $selected~$query"
#     # cht $selected~$query
#     # tmux neww bash -c "cht $selected~$query"
#     tmux neww bash -c "cht $selected~$query | less -r"
# fi


# autocomplete:
#
# _cht_complete()
# {
#     local cur prev opts
#     _get_comp_words_by_ref -n : cur
# 
#     COMPREPLY=()
#     cur="${COMP_WORDS[COMP_CWORD]}"
#     prev="${COMP_WORDS[COMP_CWORD-1]}"
#     # opts="$(curl -s cheat.sh/:list)"
#     opts="$(cht :list)"
# 
#     if [ ${COMP_CWORD} = 1 ]; then
# 	  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
# 	  __ltrim_colon_completions "$cur"
#     fi
#     return 0
# }
# complete -F _cht_complete cht


# old

# # selected=`cat ~/.tmux-cht-languages ~/.tmux-cht-command | fzf`
# # temp solution
# selected=`cat ~/.config/tmux/.tmux-cht-languages ~/.config/tmux/.tmux-cht-command | fzf`
# if [[ -z $selected ]]; then
#     exit 0
# fi
# 
# # read -p "Enter Query: " query
# # 
# # if grep -qs "$selected" ~/.config/tmux/.tmux-cht-languages; then
# #     query=`echo $query | tr ' ' '+'`
# #     tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
# # else
# #     tmux neww bash -c "curl -s cht.sh/$selected~$query | less"
# # fi
# # 
# # 
#
#
#
#
#
#
