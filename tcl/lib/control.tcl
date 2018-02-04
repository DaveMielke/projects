proc tryCommand {code args} {
   if {([set count [llength $args]] % 2) != 0} {
      return -code error "missing code: [lindex $args end]"
   }
   if {($count > 0) && [cequal [string tolower [lindex $args [expr {$count - 2}]]] finally]} {
      set finally [lvarpop args end]
      lvarpop args end
   } else {
      set finally {}
   }
   set executeCode {
      set caught [catch [list uplevel 1 $code] response]
   }
   set handleError {
      if {$caught == 1} {
         upvar 1 errorMessage errorMessage
	 set errorMessage $response
      }
      eval $executeCode
   }
   eval $executeCode
   set even 1
   foreach item $args {
      if {[set even [expr {!$even}]]} {
         set code $item
	 if {($test == 0) || [regexp {^-?[1-9][0-9]*$} $test]} {
	    if {$caught == $test} {
	       eval $handleError
	       break
	    }
	 } elseif {$caught == 1} {
	    global errorCode
	    set tokens $errorCode
	    set ok 1
	    foreach token $test {
	       if {[lempty $tokens] || ![cequal $token [lvarpop tokens]]} {
		  set ok 0
	          break
	       }
	    }
	    if {$ok} {
	       eval $handleError
	       break
	    }
	 }
      } elseif {[set index [lsearch -exact {ok error return break continue} [string tolower $item]]] < 0} {
         set test $item
      } else {
         set test $index
      }
   }
   if {[set c [catch [list uplevel 1 $finally] r]] != 0} {
      set caught $c
      set response $r
   }
   if {$caught == 1} {
      global errorInfo errorCode
      return -code error -errorinfo $errorInfo -errorcode $errorCode $response
   }
   if {$caught == 2} {
      return -code return $response
   }
   return -code $caught
}
proc parseOperands {operandsArray argumentsList prototype} {
   upvar 1 $operandsArray operands
   upvar 1 $argumentsList arguments
   catch [list unset operands]
   array set operands {}
   set argsSpecified 0
   if {[set argsIndex [llength $prototype]] > 0} {
      if {[cequal [lindex $prototype [incr argsIndex -1]] args]} {
         lvarpop prototype $argsIndex
	 set argsSpecified 1
      }
   }
   foreach name $prototype {
      set description [translit "_" " " $name]
      if {[lempty $arguments]} {
	 error "missing $description."
      }
      set operands($name) [lvarpop arguments]
   }
   if {$argsSpecified} {
      set operands(args) $arguments
      set arguments {}
   }
}
proc parseArguments {operandsArray arguments parameters options} {
   upvar 1 $operandsArray operands
   set state 0
   foreach value $options {
      switch -exact -- [incr state] {
	 1 {
	    set name [string tolower $value]
	    if {[info exists code($name)]} {
	       error "duplicate option name: $value"
	    }
	    if {![regexp -- {^[a-z_]+$} $name]} {
	       error "invalid option name: $value"
	    }
	    set length [clength [set truncation [set full $name]]]
	    while {$length > 0} {
	       if {[info exists alias($truncation)]} {
		  if {[clength $alias($truncation)] == 0} {
		     break
		  }
		  set full ""
	       }
	       set alias($truncation) $full
	       set truncation [csubstr $truncation 0 [incr length -1]]
	    }
	 }
	 2 {
	    set prototype($name) $value
	 }
	 3 {
	    set code($name) $value
	    set state 0
	 }
         default {
	    error "unimplemented iteration state: $state"
	 }
      }
   }
   switch -exact -- $state {
      0 {
      }
      1 {
	 error "missing prototype: $name"
      }
      2 {
	 error "missing code: $name"
      }
      default {
	 error "unimplemented final state: $state"
      }
   }
   while {![lempty $arguments]} {
      if {[clength [set argument [lindex $arguments 0]]] == 0} {
         break
      }
      if {![cequal [cindex $argument 0] -]} {
         break
      }
      lvarpop arguments
      if {[clength [set option [string tolower [string trimleft $argument -]]]] == 0} {
         break
      }
      if {![info exists alias($option)] || ([clength [set option $alias($option)]] == 0)} {
         error "unknown option: $argument"
      }
      parseOperands operands arguments $prototype($option)
      set description [translit "_" " " $option]
      tryCommand {
         uplevel 1 $code($option)
      } break {
         error "invalid value: -$option"
      }
   }
   parseOperands operands arguments $parameters
}
