# zsh-notify (OS X)

Sends a desktop notification (via `terminal-notifier`) after the command you executed finishes
running.

We live in frantic days.

## Usage

Source `zsh-notify.zsh` as soon as early as possible in your `.zshrc` file, before any other script
or function that manipulates the `precmd` array.

    source /path/to/zsh-notify/zsh.notify.zsh

You also need [terminal-notifier](https://github.com/julienXX/terminal-notifier):

    brew install terminal-notifier

### Antigen

Add the following line before any other bundle in your `.zshrc`:

    antigen bundle piger/zsh-notify

## Credits

Icons made by [Freepik](https://www.freepik.com/) from [Flaticon](https://www.flaticon.com/) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/).
