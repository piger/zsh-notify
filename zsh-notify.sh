# zsh-notify
zmodload zsh/regex

# notify if commands was running for more than TIME_THRESHOLD seconds:
TIME_THRESHOLD=60
RE_SKIP_COMMANDS="^(ssh|vim|tmux|tig)"
TERMINAL_BUNDLE="com.googlecode.iterm2"
SCRIPT_DIR="$(dirname $0:A)"


notify() {
    # $1 subtitle of the notification (the command that was executed)
    # $2 the message for the notification
    # $3 the icon for the notification popup
    terminal-notifier -title "Long running command" -subtitle "$1" -message "$2" -activate "$TERMINAL_BUNDLE" -sound default \
                      -appIcon "${SCRIPT_DIR}/$3"
}

notify-success() {
    notify "$1" "The command succeded after $2 seconds" success.jpg
}

notify-error() {
    notify "$1" "The command failed after $2 seconds with code: $3" error.png
}

notify-command-complete() {
    # we must catch $? as soon as possible.
    local last_status=$?

    local now
    local timediff
    now=$(date +%s)

    if [[ $_notify_start_time = "" ]]; then
        return
    fi

    timediff=$(( now - _notify_start_time ))

    if (( timediff > TIME_THRESHOLD )); then
        if [[ $last_status = 0 ]]; then
            notify-success $_notify_last_command $timediff
        else
            notify-error $_notify_last_command $timediff $last_status
        fi
    fi

    unset _notify_last_command
    unset _notify_start_time
}

store-command-stats() {
    if [[ $1 -regex-match $RE_SKIP_COMMANDS ]]; then
        return
    fi

    _notify_last_command="$1"
    _notify_start_time=$(date +%s)
}

# For this script to be able to get the exit status of the last executed command ($?)
# it must be loaded before any other script or function that adds a precmd hook.
# Only the first precmd hook access the original $?.
autoload -Uz add-zsh-hook
add-zsh-hook preexec store-command-stats
add-zsh-hook precmd notify-command-complete
