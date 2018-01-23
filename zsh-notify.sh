# zsh-notify
zmodload zsh/regex

# notify if commands was running for more than TIME_THRESHOLD seconds:
TIME_THRESHOLD=60
RE_SKIP_COMMANDS="^(ssh|vim)"

notify() {
    terminal-notifier -title "⌛ zsh long running job"  -subtitle "$1" -message "$2"
}

notify-success() {
    notify "execution finished" \
           "Command $1 succeded after $2 seconds"
}

notify-error() {
    notify "⚠ execution finished" \
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
    if [[ ! $1 -regex-match $RE_SKIP_COMMANDS ]]; then
        _notify_last_command=${(qqq)1}
        _notify_start_time=$(date +%s)
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec store-command-stats
add-zsh-hook precmd notify-command-complete
