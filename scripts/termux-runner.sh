#!/data/data/com.termux/files/usr/bin/bash

declare -a dir_paths
declare -a dir_names
declare -a script_paths
declare -a script_names

shortcuts_dir="/data/data/com.termux/files/home/.shortcuts"
start_dir="$shortcuts_dir/tasks"
nl=$'\n'

get_dirs () {
    if [[ "$1" != "$shortcuts_dir" ]] ; then
        dir_paths+=( "$1/.." )
        dir_names+=( ".." )
    fi
    readarray -t paths < <(find $1/* -maxdepth 0 -type d | sort )
    for path in "${paths[@]}"; do
        dir_paths+=( "$path" )
        dir_names+=( "$(basename "$path")" )
    done
}

find_scripts () {
    readarray -t paths < <(file $1/* | grep executable | sed 's/\(^.*\):.*/\1/')
    for path in "${paths[@]}"; do
        script_paths+=( "$path" )
        script_names+=( "$(basename "$path")" )
    done
}

show_dialog () {
    csv=""
    for name in "${dir_names[@]}"; do
        csv+="> $name,"
    done
    for name in "${script_names[@]}"; do
        csv+="$name,"
    done
    csv=${csv%?}
    read -r code index < <(termux-dialog radio -t "$1${nl}Choose script to run" -v "$csv" | jq -j '.code, " ", .index')
    [[ $code -ne -1 ]] && index=""
    echo "$index"
}

script_path="${0}"
self_sum=$(md5sum "$script_path" | cut -d " " -f 1 )

while true; do
    dir_paths=()
    dir_names=()
    script_paths=()
    script_names=()
    get_dirs "$start_dir"
    find_scripts "$start_dir"
    index=$(show_dialog "$start_dir")
    [[ -z $index ]] && exit
    if [[ $index -lt ${#dir_paths[@]} ]] ; then
        start_dir=$(realpath "${dir_paths[$index]}")
    else
        script_choice="${script_paths[(($index - ${#dir_paths[@]}))]}"
        script_sum=$(md5sum "${script_paths[(($index - ${#dir_paths[@]}))]}" | cut -d " " -f 1)

        if [[ "$script_sum" == "$self_sum" ]] ; then
            termux-toast -s -b#FF0000 "I'm already running"
        else
            break
        fi
    fi
done
"$script_choice"
