# -*- shell-script -*-
# dbg-io.inc - Korn Shell Debugger Input/Output routines
#
#   Copyright (C) 2008 Rocky Bernstein rocky@gnu.org
#
#   Kshdb is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
#
#   Kshdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#   
#   You should have received a copy of the GNU General Public License along
#   with Kshdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

# ==================== VARIABLES =======================================

# _Dbg_source_mungedfilename is an array which contains source_lines for
#  filename
# _Dbg_read_mungedfilename is array which contains the value '1' if the
#  filename has been read in.

# ===================== FUNCTIONS =======================================

# Common funnel for "Undefined command" message
_Dbg_undefined_cmd() {
  _Dbg_msg "Undefined $1 command \"$2\""
}

# _Dbg_progess_show --- print the progress bar
# $1: prefix string
# $2: max value
# $3: current value
function _Dbg_progess_show {
    typeset title=$1
    typeset -i max_value=$2
    typeset -i current_value=$3
    typeset -i max_length=40
    typeset -i current_length

    if (( max_value == 0 )) ; then
	# Avoid dividing by 0.
	current_length=${max_length}
    else
	current_length=$(( ${max_length} * ${current_value} / ${max_value} ))
    fi
    
    _Dbg_progess_show_internal "$1" ${max_length} ${current_length}
    _Dbg_printf_nocr ' %3d%%' "$(( 100 * ${current_value} / ${max_value} ))"
}
# _Dbg_progess_show_internal --- internal function for _Dbg_progess_show
# $1: prefix string
# $2: max length
# $3: current length
function _Dbg_progess_show_internal {
    typeset -i i=0

    # Erase line
    if [[ t == $EMACS ]]; then
	_Dbg_msg_nocr "\r\b\n"	
    else
	_Dbg_msg_nocr "\r\b"
    fi
    
    _Dbg_msg_nocr "$1: ["
    for (( i=0; i < $3 ; i++ )); do
	_Dbg_msg_nocr "="
    done
    _Dbg_msg_nocr '>'

    for (( i=0; i < $2 - $3 ; i++ )); do
	_Dbg_msg_nocr ' '
    done
    _Dbg_msg_nocr ']'
}

# clean up progress bar
function _Dbg_progess_done {
    # Erase line
    if test "x$EMACS" = xt; then
	_Dbg_msg_nocr "\r\b\n"	
    else
	_Dbg_msg_nocr "\r\b"
    fi
    _Dbg_msg $1
}


# Return text for source line for line $1 of filename $2 in variable
# $source_line. The hope is that this has been declared "typeset" in the 
# caller.

# If $2 is omitted, # use .sh.file, if $1 is omitted use _curline.
function _Dbg_get_source_line {
  typeset lineno=${1:-$_curline}
  typeset filename=${2:-${.sh.file}}
  typeset is_read=$(_Dbg_get_assoc_scalar_entry "_Dbg_read_" $filevar)
  [[ $is_read ]] || _Dbg_readin $filename 
  
  source_line=`_Dbg_get_assoc_array_entry _Dbg_source_${filevar} $lineno`
}

# This is put at the so we have something at the end when we debug this.
[[ -z _Dbg_io_ver ]] && typeset -r _Dbg_io_ver=\
'$Id: dbg-io.inc,v 1.13 2008/05/27 03:51:45 rockyb Exp $'