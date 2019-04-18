###############################################################################
#
# ctkutils - A set of TCL/TK procs which work in both wish and cwish.
# 
# Copyright (C) 2003 by Dave Mielke <dave@mielke.cc> [http://mielke.cc/].
# All rights reserved.
# 
# ctkutils comes with ABSOLUTELY NO WARRANTY.
# 
# This is free software, placed under the terms of the
# GNU General Public License, as published by the Free Software
# Foundation.  Please see the file COPYING for details.
#
###############################################################################

###############################################################################
#
# An easy way to invoke ``wish'' (the standard TK interpreter) if the $DISPLAY
# environment variable is set but to invoke ``cwish'' (a curses-based TK shell)
# if it isn't is to start your script with the following three-line header.
#
#    #!/bin/sh
#    # Reinvoke with ``wish'' if DISPLAY is set but with ``cwish'' if not. \
#    exec "`if test -z "${DISPLAY}"; then echo cwish; else echo wish; fi`" "${0}" "${@}"
#
###############################################################################

proc getGlobal {variable} {
   upvar #0 $variable name
   return $name
}
proc setGlobal {variable value} {
   upvar #0 $variable name
   return [set name $value]
}
proc bindCommands {tag event append args} {
   if {!$append} {
      lappend args "break"
   }
   foreach command $args {
      if {![info complete $command]} {
         return -code error "incomplete command: $command"
      }
   }
   set commands [join $args \n]
   if {$append} {
      set commands "+$commands"
   }
   bind $tag $event $commands
}
proc bindDestroy {path args} {
   set event <Destroy>
   if {[string length [bind $path $event]] == 0} {
      set args [linsert $args 0 "if {!\[string equal %W $path\]} continue"]
   }
   eval [list bindCommands $path $event 1] $args
}
proc bindDestroyCommand {path command} {
   bindDestroy $path [list rename $command ""]
}
proc bindDestroyVariable {path variable} {
   bindDestroy $path [list unset $variable]
}
proc bindCommand {path event script} {
   proc [set command $event$path] {path} $script
   bindDestroyCommand $path $command
   bindCommands $path $event 0 [list $command $path]
}
proc addShortcut {path name} {
   upvar #0 [set variable shortcuts$path] shortcuts
   if {![info exists shortcuts]} {
      set shortcuts ""
      bindDestroyVariable $path $variable
   }
   foreach character [split $name ""] {
      if {[string is alpha $character]} {
         if {[string first $character $shortcuts] < 0} {
            append shortcuts $character
            return [string first $character $name]
         }
      }
   }
   return -1
}
proc giveBorder {path} {
   if {[$path cget -borderwidth] == 0} {
      global borderWidth
      if {![info exists borderWidth]} {
         set borderWidth 1
         set test .borderwidth
         foreach type {listbox text entry} {
            $type $test
            set width [$test cget -borderwidth]
            destroy $test
            if {$width > 0} {
               set borderWidth $width
               break
            }
         }
      }
      $path configure -borderwidth $borderWidth
   }
}
proc scrollbarWidth {path} {
   return [expr {(([$path cget -borderwidth] + [$path cget -highlightthickness]) * 2) + [$path cget -width]}]
}
proc packScrollbars {path} {
   set parent [winfo parent $path]
   frame [set bottom $parent.bottom]
   frame [set corner $parent.corner]
   scrollbar [set xscroll $parent.xscroll] -orient horizontal -takefocus 0 -command [list $path xview]
   scrollbar [set yscroll $parent.yscroll] -orient vertical -takefocus 0 -command [list $path yview]
   pack $bottom -side bottom -fill x -padx 0
   pack $xscroll -in $bottom -side left -expand 1 -fill x -padx 0
   pack $corner -in $bottom -side right -padx 0
   pack $yscroll -side right -fill y -padx 0
   pack $path -side left -expand 1 -fill both -padx 0
   $path configure -xscrollcommand [list $xscroll set] -yscrollcommand [list $yscroll set]
   $corner configure -height [scrollbarWidth $xscroll] -width [scrollbarWidth $yscroll]
}
proc packCaption {path caption} {
   if {[string length $caption] > 0} {
      label [set caption $path.caption] -text $caption
      pack $caption -side top -padx 0
   }
}
proc makeListboxFrame {path mode width height {caption ""}} {
   frame $path
   packCaption $path $caption
   listbox [set listbox $path.listbox] -selectmode $mode -width $width -height $height
   packScrollbars $listbox
   return $listbox
}
proc makeTextFrame {path width height {caption ""}} {
   frame $path
   packCaption $path $caption
   text [set text $path.text] -width $width -height $height
   packScrollbars $text
   return $text
}
proc makeEntryFrame {path width {prompt ""}} {
   frame $path
   if {[string length $prompt] > 0} {
      label [set promptLabel $path.prompt] -text $prompt
      pack $promptLabel -side left -anchor nw -padx 0
   }
   entry [set entry $path.entry] -width $width
   giveBorder $entry
   pack $entry -side top -anchor w -expand 1 -fill x -padx 0
   scrollbar [set scroll $path.scroll] -orient horizontal -takefocus 0 -command [list $entry xview]
   $entry configure -xscrollcommand [list $scroll set]
   pack $scroll -side top -fill x -padx 0
   return $entry
}
proc makeButtonFrame {path side} {
   frame $path
   pack $path -side $side -fill x -padx 0
}
proc packButton {path} {
   pack $path -side left -expand 1
}
proc addButton {frame caption script {type button} args} {
   set name [string tolower $caption]
   set top [winfo toplevel $frame]
   upvar #0 [set variable [string trimright ${name}Button$top .]] button
   set button $frame.$name
   proc [set command command$button] {button} $script
   eval [list $type $button -text $caption -command [list $command $button]] $args
   bindDestroyCommand $button $command
   bindDestroyVariable $button $variable
   if {[set shortcut [addShortcut $top $name]] >= 0} {
      set key [string index $name $shortcut]
      bindCommands $top <Key-$key> 0 [list $button flash] [list $button invoke]
      $button configure -underline $shortcut
   }
   packButton $button
   return $button
}
proc addCheckButton {frame caption variable script args} {
   return [eval [list addButton $frame $caption $script checkbutton -variable $variable] $args]
}
proc assignMenuShortcuts {path} {
   if {[string is integer [set last [$path index last]]]} {
      set index 0
      while {$index <= $last} {
         if {[catch [list $path entrycget $index -label] label] == 0} {
            if {[set shortcut [addShortcut $path [string tolower $label]]] >= 0} {
               $path entryconfigure $index -underline $shortcut
            }
         }
         incr index
      }
   }
}
proc makeMenu {path captions script} {
   menu $path -tearoff 0
   proc [set command command$path] {index name} $script
   bindDestroyCommand $path $command
   set index 0
   foreach caption $captions {
      $path add command -label $caption -command [list $command $index $caption]
      incr index
   }
   assignMenuShortcuts $path
}
proc makeMenuButton {path variable values} {
   set menu [eval [list tk_optionMenu $path $variable] $values]
   assignMenuShortcuts $menu
   return $menu
}
proc addMenuButton {path variable values} {
   set menu [makeMenuButton $path $variable $values]
   packButton $path
   return $menu
}
proc putRow {path} {
   upvar #0 [set variable Put$path] put
   if {![info exists put]} {
      set put(rows) 0
      bindDestroyVariable $path $variable
   }
   set put(row) $put(rows)
   set put(columns,$put(row)) 0
   incr put(rows)
   frame [set frame $path.$put(row)]
   pack $frame -side top -anchor w -fill x -padx 0
   return $frame
}
proc putColumn {path} {
   upvar #0 Put$path put
   set row $put(row)
   set put(column,$row) $put(columns,$row)
   incr put(columns,$row)
   return $path.$row.$put(column,$row)
}
proc putWidget {path} {
   pack $path -side left -anchor nw
   return $path
}
proc putLabel {path text} {
   label [set label [putColumn $path]] -text $text
   return [putWidget $label]
}
proc putEntry {path variable width {prompt ""}} {
   set entry [makeEntryFrame [set frame [putColumn $path]] $width $prompt]
   $entry configure -textvariable $variable
   putWidget $frame
   pack $frame -fill x -expand 1 -padx 0
   return $entry
}
proc putCheckButton {path text variable selected} {
   checkbutton [set button [putColumn $path]] -variable $variable -text $text
   $button [expr {$selected? "select": "deselect"}]
   return [putWidget $button]
}
proc putRadioButton {path text variable value selected} {
   radiobutton [set button [putColumn $path]] -variable $variable -value $value -text $text
   if {$selected} {
      $button select
   }
   return [putWidget $button]
}
proc putRadioButtons {path variable default definitions} {
   frame [set frame [putColumn $path]]
   set index 0
   foreach definition $definitions {
      radiobutton [set button $frame.$index] -variable $variable -value [lindex $definition 0] -text [lindex $definition 1]
      pack $button -side top -anchor w -padx 0
      lappend buttons $button
      incr index
   }
   [lindex $buttons $default] select
   putWidget $frame
   return [lindex $buttons 0]
}
proc putMenuButton {path variable default values} {
   set menu [makeMenuButton [set button [putColumn $path]] $variable $values]
   setGlobal $variable $default
   return [putWidget $button]
}
proc toggleToplevelSize {path} {
   set window [winfo toplevel $path]
   set windowWidth [winfo width $window]
   set windowHeight [winfo height $window]
   set screenWidth [winfo screenwidth .]
   set screenHeight [winfo screenheight .]
   if {($windowWidth == $screenWidth) && ($windowHeight == $screenHeight)} {
      set geometry ""
   } else {
      set geometry ${screenWidth}x${screenHeight}+0+0
   }
   wm geometry $window $geometry
}
proc prepareToplevel {path title} {
   wm title $path $title
   return $path
}
proc makeToplevel {path title} {
   return [prepareToplevel [toplevel $path] $title]
}
proc newToplevel {title} {
   global toplevelCount
   return [makeToplevel ".top[incr toplevelCount]" $title]
}
proc presentDialog {title data args} {
   set top [newToplevel $title]
   set text [makeTextFrame [set frame $top.frame] 40 15]
   $text insert end [string trimright $data \n]
   $text mark set insert 1.0
   $text configure -state disabled -takefocus 1 -wrap word
   pack $frame -side top -expand 1 -fill both -padx 0
   makeButtonFrame [set buttons $top.buttons] top
   setGlobal [set variable button$top] ""
   bindDestroyVariable $buttons $variable
   if {[llength $args] == 0} {
      set args [list Close]
   }
   set paths [list]
   foreach caption $args {
      set name [string tolower $caption]
      lappend paths [addButton $buttons $caption [list setGlobal $variable $name]]
   }
   focus [lindex $paths 0]
   tkwait variable $variable
   set result [getGlobal $variable]
   destroy $top
   return $result
}
proc presentPopup {menu button {index ""}} {
   tk_popup $menu [winfo rootx $button] [winfo rooty $button] $index
}
proc presentShell {{text ""}} {
   set top [newToplevel "TCL/TK Shell"]
   upvar #0 [set variable Shell$top] shell
   array set shell {}
   bindDestroyVariable $top $variable
   set shell(history,list) {}
   set shell(history,index) 0
   set shell(log) [makeTextFrame [set logFrame $top.log] 40 15]
   $shell(log) insert end $text
   $shell(log) mark set insert 1.0
   $shell(log) configure -state disabled -takefocus 1 -wrap word
   $shell(log) tag configure command -foreground [$shell(log) cget -background] -background [$shell(log) cget -foreground]
   pack $logFrame -side top -expand 1 -fill both -padx 0
   set shell(entry) [makeEntryFrame [set entryFrame $top.entry] 40 "TCL/TK Command:"]
   bindCommand $shell(entry) <Return> {
      upvar #0 Shell[winfo toplevel $path] shell
      if {[string length [set command [string trimright [$path get]]]] > 0} {
         if {([llength $shell(history,list)] == 0) || ![string equal $command [lindex $shell(history,list) end]]} {
            lappend shell(history,list) $command
         }
         set shell(history,index) [llength $shell(history,list)]
         switch -exact -- [set code [catch [list uplevel #0 $command] response]] {
            0 {
            }
            1 {
               global errorInfo
               append response "\n[string repeat - 3]\n$errorInfo"
            }
            2 {
            }
            3 {
               set response "invoked \"break\" outside of a loop"
            }
            4 {
               set response "invoked \"continue\" outside of a loop"
            }
            default {
               set response "command returned bad code: $code"
            }
         }
         $shell(log) configure -state normal
         $shell(log) insert end "\n\n"
         set index [$shell(log) index end-1l]
         $shell(log) insert end $command
         $shell(log) tag add command $index end-1c
         if {[string length $response] > 0} {
            $shell(log) insert end \n
            $shell(log) insert end $response
         }
         $shell(log) mark set insert $index
         $shell(log) yview $index
         $shell(log) xview moveto 0
         $shell(log) configure -state disabled
      }
      $path delete 0 end
   }
   bindCommand $shell(entry) <Key-Up> {
      upvar #0 Shell[winfo toplevel $path] shell
      if {$shell(history,index) == 0} {
         bell
      } else {
         if {$shell(history,index) == [llength $shell(history,list)]} {
            set shell(history,command) [$shell(entry) get]
            set shell(history,insert) [$shell(entry) index insert]
         }
         $shell(entry) delete 0 end
         $shell(entry) insert end [lindex $shell(history,list) [incr shell(history,index) -1]]
      }
   }
   bindCommand $shell(entry) <Key-Down> {
      upvar #0 Shell[winfo toplevel $path] shell
      if {$shell(history,index) == [set count [llength $shell(history,list)]]} {
         bell
      } else {
         $shell(entry) delete 0 end
         if {[incr shell(history,index)] == $count} {
            $shell(entry) insert end $shell(history,command)
            $shell(entry) icursor $shell(history,insert)
         } else {
            $shell(entry) insert end [lindex $shell(history,list) $shell(history,index)]
         }
      }
   }
   bindCommand $shell(entry) <Control-Key-a> {
      if {[$path index insert] == 0} {
         bell
      } else {
         $path icursor 0
      }
   }
   bindCommand $shell(entry) <Control-Key-b> {
      if {[set insert [$path index insert]] == 0} {
         bell
      } else {
         $path icursor [expr {$insert - 1}]
      }
   }
   bindCommand $shell(entry) <Control-Key-d> {
      if {[$path index insert] == [$path index end]} {
         bell
      } else {
         $path delete insert
      }
   }
   bindCommand $shell(entry) <Control-Key-e> {
      if {[$path index insert] == [set end [$path index end]]} {
         bell
      } else {
         $path icursor $end
      }
   }
   bindCommand $shell(entry) <Control-Key-f> {
      if {[set insert [$path index insert]] == [$path index end]} {
         bell
      } else {
         $path icursor [expr {$insert + 1}]
      }
   }
   bindCommand $shell(entry) <Control-Key-h> {
      if {[set insert [$path index insert]] == 0} {
         bell
      } else {
         $path delete [expr {$insert - 1}]
      }
   }
   bindCommand $shell(entry) <Control-Key-k> {
      if {[$path index insert] == [$path index end]} {
         bell
      } else {
         $path delete insert end
      }
   }
   bindCommand $shell(entry) <Control-Key-t> {
      if {[set insert [$path index insert]] == 0} {
         bell
      } elseif {$insert < [set end [$path index end]]} {
         set character [string index [$path get] [incr insert -1]]
         $path delete $insert
         $path icursor [incr insert]
         $path insert insert $character
      } elseif {$end == 1} {
         bell
      } else {
         set character [string index [$path get] [incr insert -2]]
         $path delete $insert
         $path insert insert $character
      }
   }
   bindCommand $shell(entry) <Control-Key-u> {
      if {[$path index end] == 0} {
         bell
      } else {
         $path delete 0 end
      }
   }
   bindCommand $shell(entry) <Control-Key-w> {
      if {[set insert [$path index insert]] == 0} {
         bell
      } else {
         $path delete [expr {[string last " " [string trimright [string range [$path get] 0 [expr {$insert - 1}]]]] + 1}] insert
      }
   }
   pack $entryFrame -side top -fill x -padx 0
   makeButtonFrame [set buttons $top.buttons] top
   addButton $buttons Close [list destroy $top]
   focus $shell(entry)
   tkwait window $top
}
proc presentError {problem} {
   global errorInfo
   set text "$problem\n[string repeat - 3]\n$errorInfo"
   while {1} {
      switch -exact -- [presentDialog "Internal Error" $text Continue Investigate Quit] {
         continue {
            return ""
         }
         investigate {
            presentShell $text
         }
         quit {
            exit 3
         }
      }
   }
}
proc presentWarning {problem} {
   switch -exact -- [set action [presentDialog "[winfo class .] Warning" $problem Continue Quit]] {
      continue {
         return ""
      }
      quit {
         exit 3
      }
      default {
         return -code error "$action is an unsupported warning action"
      }
   }
}
proc tkRepair {} {
   foreach tag {Entry Text} {
      bind $tag <Key> +\nbreak
   }
}
tkRepair
bindCommands all <Key-F9> 0 [list toggleToplevelSize %W]
bindCommands all <Key-F10> 0 [list presentShell]
set toplevelCount 0
