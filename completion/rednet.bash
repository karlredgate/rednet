
_rednet()
{
    local CACHE PKIDIR SPOOL SHARE INTERFACE
    . /etc/sysconfig/rednet

    # The current word (string)
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # The previous word (string)
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # the index of the current word (0 is the command itself - never seen)
    local cword=$COMP_CWORD

    # the character index of the cursor in the command line
    local point=$COMP_POINT

    # the ascii character of the keypress that caused the completion event
    local point=$COMP_KEY

    # count of the words in the current command line
    local wordcount=${#COMP_WORDS[*]}

    # an array of the indices for the word array (0 1 2)
    local -a indices=( ${!COMP_WORDS[@]} )

    # All possible subcommands for rednet
    local commands=$( ls /usr/libexec/rednet/rednet-* | sed -e 's/.*rednet-//' )

    COMPREPLY=()

    case $cword in
    1)
        # fill out subcommands
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        ;;
    2)
        command=${COMP_WORDS[1]}

        case $command in
        mac|login|disconnect)
            local clients=$( ls $CACHE/*.rdf | sed -e "s|$CACHE/||" -e 's|.rdf||' )
            COMPREPLY=( $(compgen -W "$clients" -- "$cur") )
            ;;
        cp)
            COMPREPLY=( $(compgen -A file -- "$cur") )
            ;;
        clients)
            COMPREPLY=( probe )
            ;;
        esac
        ;;
    3)
        command=${COMP_WORDS[1]}

        case $command in
        cp)
            local clients=$( shopt -s nullglob ; ls $CACHE/*.llv6 | sed -e "s|$CACHE/||" -e 's|.llv6||' )
            COMPREPLY=( $(compgen -W "$clients" -- "$cur") )
            ;;
        esac
        ;;
    esac

} &&
complete -F _rednet rednet

# vim:autoindent expandtab sw=4
