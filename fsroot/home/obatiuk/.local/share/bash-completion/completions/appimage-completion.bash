_appimage_completions() {
    local cur cmd commands bin_dir installed_apps

    # The current word being typed
    cur="${COMP_WORDS[COMP_CWORD]}"
    cmd="${COMP_WORDS[1]}"

    # Available main commands (including aliases ls and rm)
    commands="install import list ls update update-all remove rm check"

    # AppImage directory
    bin_dir="${HOME}/.local/bin/appimage"

    # LEVEL 1: Complete the main command (first argument)
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )
        return 0
    fi

    # LEVEL 2: Complete the arguments based on the chosen command
    case "${cmd}" in
        update|remove|rm)
            # Dynamically generate a list of installed AppImages (ignoring the updater tool)
            if [[ -d "${bin_dir}" ]]; then
                installed_apps=$(find "${bin_dir}" -maxdepth 1 -type f -not -name "appimageupdatetool" -exec basename {} \;)
                COMPREPLY=( $(compgen -W "${installed_apps}" -- "${cur}") )
            fi
            ;;
        install)
            # If a URL is being typed, stop completion so it doesn't break on slashes/domains
            if [[ "${cur}" =~ ^(http|https):// ]]; then
                return 0
            fi

            # Delegate to standard bash file/path completion for local files
            compopt -o filenames
            COMPREPLY=( $(compgen -f -- "${cur}") )
            ;;
        import)
            # Delegate to standard bash directory completion
            compopt -o dirnames
            COMPREPLY=( $(compgen -d -- "${cur}") )
            ;;
        *)
            # 'list', 'ls', 'update-all', and 'check' do not take further arguments
            COMPREPLY=()
            ;;
    esac
    return 0
}

# Attach the completion function to your executable name "appimage".
complete -F _appimage_completions appimage
