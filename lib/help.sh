# -*- shell-script -*-
# help.sh - Debugger Help Routines
#
#   Copyright (C) 2002-2008, 2010-2011, 2019
#   Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

# A place to put help command text
typeset -A _Dbg_command_help
export _Dbg_command_help

# List of debugger commands.
# FIXME: for now we are attaching this to _Dbg_help_add which
# is when this is here. After moving somewhere more appropriate, relocate
# the definition.
typeset -A _Dbg_debugger_commands

# Add help text $2 for command $1
function _Dbg_help_add {
    (($# < 2)) || (($# > 4))  && return 1
    typeset -i add_command; add_command=${3:-0}
    _Dbg_command_help[$1]="$2"
    (( add_command )) && _Dbg_debugger_commands[$1]="_Dbg_do_$1"
    # if (($# == 4)); then
    #   complete -F "$4" "$1"
    # fi
    return 0
}

# Add help text $3 for in subcommand $1 under key $2
function _Dbg_help_add_sub {
    add_command=${4:-1}
    (($# != 3)) && (($# != 4))  && return 1
    eval "_Dbg_command_help_$1[$2]=\"$3\""
    if (( add_command )) ; then
        eval "_Dbg_debugger_${1}_commands[$2]=\"_Dbg_do_${1}_${2}\""
    fi
    return 0
}

_Dbg_help_set() {

    typeset subcmd
    if (( $# == 0 )) ; then
        typeset list
        list="${!_Dbg_command_help_set[@]}"
        for subcmd in $list ; do
            _Dbg_help_set $subcmd 1
        done
        return 0
    fi

    subcmd="$1"
    typeset label="$2"

    if [[ -n "${_Dbg_command_help_set[$subcmd]}" ]] ; then
        if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_set[$subcmd]}"
            return 0
        else
            label=$(printf "set %-12s-- " $subcmd)
        fi
    fi

    # FIXME: DRY this
    case $subcmd in
        an | ann | anno | annot | annota | annotat | annotate )
            if [[ -z $label ]] ; then
                typeset post_label='
0 == normal;     1 == fullname (for use when running under emacs).'
            fi
            _Dbg_msg \
                "${label}Set annotation level.$post_label"
            return 0
            ;;
        ar | arg | args )
            _Dbg_msg \
                "${label}Set argument list to give program when it is restarted."
            ;;
        autoe | autoev | autoeva | autoeval )
            _Dbg_msg \
                "${label}auto evaluation of unrecognized commands is" $(_Dbg_onoff $_Dbg_set_autoeval)
            ;;
        autol | autoli | autolis | autolist )
	    typeset onoff="on."
	    [[ -z ${_Dbg_cmdloop_hooks["list"]} ]] && onoff='off.'
            _Dbg_msg \
                "${label}auto listing on debugger stop is ${onoff}"
            ;;
        b | ba | bas | base | basen | basena | basenam | basename )
            _Dbg_msg \
                "${label}short filenames (the basename) is" $(_Dbg_onoff $_Dbg_set_basename)
            ;;
        c | co | con | conf | confi | confir | confirm )
            _Dbg_msg \
                "${label}confirm dangerous operations" $(_Dbg_onoff $_Dbg_set_confirm)
            ;;
        de|deb|debu|debug )
            _Dbg_msg \
                "${label}debug the debugger is" $(_Dbg_onoff $_Dbg_set_debug)
            ;;
        di|dif|diff|diffe|differe|differen|different )
            typeset onoff=${1:-'on'}
            (( _Dbg_set_different )) && onoff='on.'
            _Dbg_msg \
                "${label}stop on different lines is" $(_Dbg_onoff $_Dbg_set_different)
            ;;
        e | ed | edi | edit | editi | editin | editing )
            _Dbg_msg_nocr \
                "${label}Set editing of command lines as they are typed is "
            if [[ -z $_Dbg_edit ]] ; then
                _Dbg_msg 'off.'
            else
                _Dbg_msg 'on.'
            fi
            return 0
            ;;
        high | highl | highlight )
            _Dbg_msg_nocr \
                "${label}Set syntax highlighting of source listings is "
            if [[ -z $_Dbg_edit ]] ; then
                _Dbg_msg 'off.'
            else
		_Dbg_msg "${_Dbg_set_highlight}"
            fi
            ;;
        his | hist | history )
            _Dbg_msg_nocr \
                "${label}Set record command history is "
            if [[ -z $_Dbg_set_edit ]] ; then
                _Dbg_msg 'off.'
            else
                _Dbg_msg 'on.'
            fi
            ;;
        inferior-tty )
            _Dbg_msg "${label} set tty for input and output"
            ;;
        lin | line | linet | linetr | linetra | linetrac | linetrace )
            typeset onoff='off.'
            (( _Dbg_set_linetrace )) && onoff='on.'
            _Dbg_msg \
                "${label}Set tracing execution of lines before executed is" $onoff
            if (( _Dbg_set_linetrace )) ; then
                _Dbg_msg \
                    "set linetrace delay -- delay before executing a line is" $_Dbg_linetrace_delay
            fi
            return 0
            ;;
        lis | list | lists | listsi | listsiz | listsize )
            _Dbg_msg "${label}Set number of lines in listings is ${_Dbg_set_listsize}"
	    ;;
        p | pr | pro | prom | promp | prompt )
            _Dbg_msg "${label}prompt string ${_Dbg_set_prompt}"
            ;;
        sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
            _Dbg_msg \
                "${label}Set showing the command to execute is $_Dbg_show_command."
            return 0
            ;;
        sty | style )
            _Dbg_msg_nocr \
                "${label}Set pygments highlighting style is "
            if [[ -z $_Dbg_set_style ]] ; then
                _Dbg_msg 'off.'
            else
		_Dbg_msg "${_Dbg_set_style}"
            fi
            ;;
        wi|wid|widt|width )
            _Dbg_msg \
                "${label}Set maximum width of lines is $_Dbg_set_linewidth."
            return 0
            ;;

        * )
            _Dbg_errmsg \
                "There is no \"set $subcmd\" command."
    esac
}

_Dbg_help_show() {
    if (( $# == 0 )) ; then
        typeset list
        list="${!_Dbg_command_help_show[@]}"
        typeset subcmd
        for subcmd in $list; do
            _Dbg_help_show $subcmd 1
        done
        return 0
    fi

    typeset subcmd=$1
    typeset label="$2"

    if [[ -n "${_Dbg_command_help_show[$subcmd]}" ]] ; then
        if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_show[$subcmd]}"
            return 0
        else
            label=$(printf "show %-12s-- " $subcmd)
        fi
    fi

    case $subcmd in
        al | ali | alia | alias | aliase | aliases )
            _Dbg_msg \
                "${label}Show list of aliases currently in effect."
            return 0
            ;;
        ar | arg | args )
            _Dbg_msg \
                "${label}Show argument list to give program on restart."
            return 0
            ;;
        an | ann | anno | annot | annota | annotat | annotate )
            _Dbg_msg \
                "${label}Show annotation_level"
            return 0
            ;;
        autoe | autoev | autoeva | autoeval )
            _Dbg_msg \
                "${label}Show if we evaluate unrecognized commands."
            return 0
            ;;
        autol | autoli | autolis | autolist )
            _Dbg_msg \
                "${label}Run list before command loop?"
            return 0
            ;;
        b | ba | bas | base | basen | basena | basenam | basename )
            _Dbg_msg \
                "${label}Show if we are are to show short or long filenames."
            return 0
            ;;
        c | co | con | conf | confi | confir | confirm )
            _Dbg_msg \
                "${label}confirm dangerous operations" $(_Dbg_onoff $_Dbg_set_confirm)
            ;;
        com | comm | comma | comman | command | commands )
            _Dbg_msg \
                "${label}Show the history of commands you typed."
            ;;
        cop | copy| copyi | copyin | copying )
            _Dbg_msg \
                "${label}Conditions for redistributing copies of debugger."
            ;;
        d|de|deb|debu|debug|debugg|debugger|debuggi|debuggin|debugging )
            _Dbg_msg \
                "${label}Show if we are set to debug the debugger."
            return 0
            ;;
        different | force)
            _Dbg_msg \
                "${label}Show if debugger stops at a different line."
            return 0
            ;;
        dir|dire|direc|direct|directo|director|directori|directorie|directories)
            _Dbg_msg \
                "${label}Show file directories searched for listing source."
            ;;
        editing )
            _Dbg_msg \
                "${label}Show editing of command lines and edit style."
            ;;
        highlight )
            _Dbg_msg \
                "${label}Show if we syntax highlight source listings."
            return 0
            ;;
        history )
            _Dbg_msg \
                "${label}Show if we are recording command history."
            return 0
            ;;
        lin | line | linet | linetr | linetra | linetrac | linetrace )
            _Dbg_msg \
                "${label}Show whether to trace lines before execution."
            ;;
        lis | list | lists | listsi | listsiz | listsize )
            _Dbg_msg \
                "${label}Show number of source lines debugger will list by default."
            ;;
        p | pr | pro | prom | promp | prompt )
            _Dbg_msg \
                "${label}Show debugger prompt."
            return 0
            ;;
        sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
            [[ -n $label ]] && label='set showcommand -- '
            _Dbg_msg \
                "${label}Set showing the command to execute is $_Dbg_set_show_command."
            return 0
            ;;
        t|tr|tra|trac|trace|trace-|trace-c|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
            _Dbg_msg \
                'show trace-commands -- Show if we are echoing debugger commands'
            return 0
            ;;
        wa | war | warr | warra | warran | warrant | warranty )
            _Dbg_msg \
                "${label}Various kinds of warranty you do not have."
            return 0
            ;;
        width )
            _Dbg_msg \
                "${label}maximum width of a line."
            return 0
            ;;
	"style" | "version" )
	    # Not done yet
	    ;;

        * )
            _Dbg_msg \
                "Undefined show command: \"$subcmd\".  Try \"help show\"."
    esac
}

_Dbg_help_info() {

    typeset subcmd
    if (( $# == 0 )) ; then
        typeset -a list
        list=(${(ki)_Dbg_command_help_info[@]})
        sort_list 0 ${#list[@]}-1
        for subcmd in ${list[@]}; do
            _Dbg_help_info $subcmd 1
        done
        return 0
    fi

    subcmd="$1"
    typeset label="$2"

    if [[ -n "${_Dbg_command_help_info[$subcmd]}" ]] ; then
        if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_info[$subcmd]}"
            return 0
        else
            label=$(builtin printf "info %-12s-- " $subcmd)
        fi
    fi

    _Dbg_info_help $subcmd $label
}
