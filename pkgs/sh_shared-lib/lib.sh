#!/usr/bin/env bash
set -eo pipefail

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    ORIGIN="$(basename "$0")"
else
    ORIGIN="$(basename "${BASH_SOURCE[0]}")"
fi

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

check() {
    local type
    local items=()

    while (("$#")); do
        case $1 in
        --type)
            if [[ -z "$2" ]]; then
                print -e "Missing type argument"
                exit 1
            fi

            type="$2"
            shift 2
            ;;
        *)
            items+=("$1")
            shift
            ;;
        esac
    done

    case "$type" in
    "cmd")
        local missing=()
        for cmd in "${items[@]}"; do
            if ! command -v "$cmd" >/dev/null 2>&1; then
                missing+=("$cmd")
            fi
        done

        if ((${#missing[@]})); then
            print -e "Missing required commands: ${missing[*]}. See ${ORIGIN} --help."
            exit 1
        fi
        ;;

    "var")
        local missing=()
        for var in "${items[@]}"; do
            eval "val=\${$var}"
            if [[ -z "$val" ]]; then
                missing+=("$var")
            fi
        done

        if ((${#missing[@]})); then
            print -e "Missing required arguments: ${missing[*]}. See ${ORIGIN} --help."
            exit 1
        fi
        ;;
    *)
        print -e "Unknown check type: $type"
        exit 1
        ;;
    esac
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
