# zsh-notify
zmodload zsh/regex

# notify if commands was running for more than TIME_THRESHOLD seconds:
typeset -g _ZSH_NOTIFY_TIME_THRESHOLD=60
typeset -g _ZSH_NOTIFY_RE_SKIP_COMMANDS="^[^ ]*(ssh|vim|tmux|tig|man)"
typeset -g _ZSH_NOTIFY_TERMINAL_BUNDLE="com.googlecode.iterm2"
typeset -g _ZSH_NOTIFY_SCRIPT_DIR="$(dirname $0:A)"


_zsh_notify_popup() {
    # $1 subtitle of the notification (the command that was executed)
    # $2 the message for the notification
    # $3 the icon for the notification popup
    terminal-notifier -title "Long running command" -subtitle "$1" -message "$2" -activate "$_ZSH_NOTIFY_TERMINAL_BUNDLE" -sound default \
                      -appIcon "${_ZSH_NOTIFY_SCRIPT_DIR}/$3"
}

_zsh_notify_success() {
    _zsh_notify_popup "$1" "The command succeded after $2 seconds" success.jpg
}

_zsh_notify_error() {
    _zsh_notify_popup "$1" "The command failed after $2 seconds with code: $3" error.png
}

_zsh_notify_command_complete() {
    # we must catch $? as soon as possible.
    local last_status=$?

    local now
    local timediff
    now=$(date +%s)

    if [[ $_zsh_notify_start_time = "" ]]; then
        return
    fi

    timediff=$(( now - _zsh_notify_start_time ))

    if (( timediff > _ZSH_NOTIFY_TIME_THRESHOLD )); then
        if [[ $last_status = 0 ]]; then
            _zsh_notify_success $_zsh_notify_last_command $timediff
        else
            _zsh_notify_error $_zsh_notify_last_command $timediff $last_status
        fi
    fi

    unset _zsh_notify_last_command
    unset _zsh_notify_start_time
}

_zsh_notify_store_command_stats() {
    if [[ $1 -regex-match $_ZSH_NOTIFY_RE_SKIP_COMMANDS ]]; then
        return
    fi

    _zsh_notify_last_command="$1"
    _zsh_notify_start_time=$(date +%s)
}

# For this script to be able to get the exit status of the last executed command ($?)
# it must be loaded before any other script or function that adds a precmd hook.
# Only the first precmd hook access the original $?.
autoload -Uz add-zsh-hook
add-zsh-hook preexec _zsh_notify_store_command_stats
add-zsh-hook precmd _zsh_notify_command_complete
