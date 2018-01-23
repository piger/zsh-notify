# zsh-notify

# notify if commands was running for more than TIME_THRESHOLD seconds:
TIME_THRESHOLD=1

notify() {
    terminal-notifier -title "$1" -subtitle "$2" -message "$3"
}

notify-success() {
    notify "⌛ zsh long running job" \
           "execution finished" \
           "Command $1 succeded after $2 seconds"
}

notify-error() {
    notify "⌛ zsh long running job" \
           "⚠ execution finished" \
           "Command $1 failed after $2 seconds: $3"
}

notify-command-complete() {
    local now
    local last_status=$?
    local timediff
    now=$(date +%s)

    if [[ $_notify_start_time != "" ]]; then
        timediff=$(( now - _notify_start_time ))

        if (( timediff > TIME_THRESHOLD )); then
            if [[ $last_status = 0 ]]; then
                notify-success $_notify_last_command $timediff
            else
                notify-error $_notify_last_command $timediff $last_status
            fi
        fi
    fi

    unset _notify_last_command
    unset _notify_start_time
}

store-command-stats() {
    _notify_last_command=${(qqq)1}
    _notify_start_time=$(date +%s)
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec store-command-stats
add-zsh-hook precmd notify-command-complete
