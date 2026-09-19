#!/usr/bin/env bash

# Getting the source location in nix-store of shared-lib
ORIGIN="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${ORIGIN}/debug.sh"

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
