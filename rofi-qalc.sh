#!/usr/bin/env bash


# Vars
historyfile="$HOME/.config/rofi/rofi-qalc-history" #place it wherever you like
# Determine last line
row=$(($(wc -l < $historyfile)-1))
if [ "$1" != "" ]
then
	if [[ "$1" =~ "= " ]]
	then
		echo "0" > /dev/null #tricks
	else
		row=$(($(wc -l < $historyfile)+1))
	fi
fi
# Rofi & args, customize to your likings
menu="/usr/bin/rofi -no-cycle -dmenu -matching fuzzy -no-auto-select -lines 10 -selected-row $row"


# Grab the answer & Make sure the querry sent by the user is correct
if [ "$1" != "" ]
then
	answer=$(qalc -novariables -nocurrencies -nodatasets +u8 -t "$1") #compute
	if [[ "$1" =~ " = " ]]
	then
		echo "0" > /dev/null
	else
		case "$1" in
  			*--dmenu*) ;; #issue with clear passing "--dmenu.*" as $1
			*=) ;; #with qalc, = symbolize an equation; but " = .*" is just an empty querry
			*) echo "$1" >> "$historyfile" && echo " = $answer" >> "$historyfile" #save to history file
		esac
	fi
fi

# Determine args to pass to dmenu/rofi
while [[ $# -gt 0 && $1 != "--" ]]; do
    shift
done
[[ $1 == "--" ]] && shift

action=$(cat $historyfile | $menu "$@" -p " > ")

case $action in
    "clear") rm "$historyfile" && $0 "--dmenu=$menu" ;;
    "close") ;;
    "") ;;
    *) $0 "$action" "--dmenu=$menu" "--" "$@" ;;
esac
