# -*- shell-script -*-
# "show history" debugger command
#
#   Copyright (C) 2011, 2019 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add_sub show history \
"**show history**

Show history settings." 1

_Dbg_do_show_history() {
    _Dbg_printf "%-12s-- " history
    _Dbg_msg \
	"  filename: The filename in which to record the command history is $_Dbg_histfile"
    _Dbg_msg \
	"  save: Saving of history save is" $(_Dbg_onoff $_Dbg_set_history)
    _Dbg_msg \
	"  size: Debugger history size is $_Dbg_history_length"
    typeset label="$1"
    return 0
}
