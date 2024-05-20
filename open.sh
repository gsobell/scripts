#!/bin/bash
o() {
    while true; do
    local files=(*.tex)
    local selected=0
    local num_files=${#files[@]}
    if [ $num_files -eq 0 ]; then
        echo "No .tex files found in the current directory."
        return 1
    fi

    while true; do
        clear
        echo "Select a .tex file using arrow keys:"
        local display=()
        for ((i=0; i<$num_files; i++)); do
            if [ $i -eq $selected ]; then
                display+=("> $((i+1)). ${files[i]}")
            else
                display+=("  $((i+1)). ${files[i]}")
            fi
        done
        printf "%s\n" "${display[@]}"
        read -rsn1 key
        case $key in
            "A") # up
                ((selected--))
                if [ $selected -lt 0 ]; then
                    selected=$((num_files - 1))
                fi
                ;;
            "B") # down
                ((selected++))
                if [ $selected -ge $num_files ]; then
                    selected=0
                fi
                ;;
            "") # enter
                vim "${files[selected]}"
                echo "You selected: ${files[selected]}"
                return 0
                ;;
        "q" | "Q") # exit
                    return 0
                    ;;
        esac
    done
done
}

o
