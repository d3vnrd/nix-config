print() {
    local color="" text="" format="" type="" newline=true

    while (("$#")); do
        case $1 in
        -n) newline=false ;;
        -e)
            color="31"
            type="ERROR"
            ;;
        -d)
            color="32"
            type="✓"
            ;;
        -w)
            color="33"
            type="WARN"
            ;;
        -i)
            color="34"
            type="INFO"
            ;;
        -c)
            color="35"
            type="CONFIRM"
            ;;
        *) text="$1" ;;
        esac
        shift
    done

    [[ -n "$color" ]] && format="$color"

    local output="\033[${format}m[${type}] ${text}\033[0m"
    if $newline; then
        echo -e "$output"
    else
        echo -ne "$output"
    fi
}

confirm() {
    local mess="$1"
    local default="${2:-n}"
    local input

    while true; do
        if [[ "$default" == "y" ]]; then
            print -c -n "$mess (Y/n): "
            read -r input
            [[ -z "$input" ]] && input="y"
        else
            print -c -n "$mess (y/N): "
            read -r input
            [[ -z "$input" ]] && input="n"
        fi

        case "$input" in
        [Yy] | [Yy][Ee][Ss]) return 0 ;;
        [Nn] | [Nn][Oo]) return 1 ;;
        *)
            print -w "Please answer yes or no."
            continue
            ;;
        esac
    done
}
