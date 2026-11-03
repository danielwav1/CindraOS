case $- in
    *i*) ;;
    *) return ;;
esac

export EDITOR=${EDITOR:-nano}
export CINDRA_SHELL=1

HISTCONTROL=ignoredups:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend checkwinsize cmdhist

__cindra_ps1() {
    local rc=$?
    local status=""
    local mark='\$'
    if [ "$rc" -ne 0 ]; then
        status=" \[\e[31m\][$rc]\[\e[0m\]"
    fi
    if [ "$EUID" -eq 0 ]; then
        mark='\[\e[1;31m\]#\[\e[0m\]'
    fi
    PS1="\[\e[1;31m\]\u\[\e[0m\]@\[\e[1m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]${status} ${mark} "
}
PROMPT_COMMAND=__cindra_ps1

if [ -z "${NO_COLOR:-}" ] && [ "$TERM" != dumb ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias ip='ip -c'
    alias diff='diff --color=auto'
fi
alias ll='ls -alFh'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
alias free='free -h'
alias update='cindra update'
alias sysinfo='cindra info'

command_not_found_handle() {
    printf 'bash: %s: command not found\n' "$1" >&2
    printf "  Look through 'cindra help', or install it with: sudo apt install <package>\n" >&2
    return 127
}

if command -v cindra >/dev/null 2>&1; then
    complete -W "help version info sys checkup desktop update clean repair logs network theme about report banner" cindra
    if [ -z "${CINDRA_GREETED:-}" ] && [ -t 1 ]; then
        export CINDRA_GREETED=1
        cindra banner
    fi
fi
