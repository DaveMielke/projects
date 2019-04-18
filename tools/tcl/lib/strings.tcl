proc stringLeft {string count {pad " "}} {
   if {$count > [set length [clength $string]]} {
      incr count -$length
      set length [clength $pad]
      return "$string[crange [replicate $pad [expr {($count + $length - 1) / $length}]] len-$count end]"
   }
   return [csubstr $string 0 $count]
}
proc stringRight {string count {pad " "}} {
   if {$count > [set length [clength $string]]} {
      incr count -$length
      set length [clength $pad]
      return "[csubstr [replicate $pad [expr {($count + $length - 1) / $length}]] 0 $count]$string"
   }
   return [crange $string len-$count end]
}
proc stringInsert {characters string {column 0} {pad " "}} {
   if {$column < [set length [clength $string]]} {
      return "[csubstr $string 0 $column]$characters[crange $string $column end]"
   }
   return "[stringLeft $string $column $pad]$characters"
}
proc stringOverlay {characters string {column 0} {pad " "}} {
   if {$column < [set length [clength $string]]} {
      return "[csubstr $string 0 $column]$characters[crange $string [min $length [expr {$column + [clength $characters]}]] end]"
   }
   return "[stringLeft $string $column $pad]$characters"
}
proc formatTable {table {spacing 1} {formats {}}} {
   set columnCount 0
   foreach row $table {
      set columnIndex 0
      foreach column $row {
         if {$columnIndex == $columnCount} {
	    set columnWidth($columnCount) 0
	    if {[lempty $formats]} {
	       set format [list]
	    } else {
	       set format [lvarpop formats]
	    }
	    set alignment left
	    foreach item $format {
	       switch -exact -- $item {
	          left {
		     set alignment left
		  }
	          right {
		     set alignment right
		  }
		  default {
		     return -code error "invalid format item: $item"
		  }
	       }
	    }
	    set columnAttributes($columnCount) [list $alignment]
	    incr columnCount
	 }
	 set columnWidth($columnIndex) [max $columnWidth($columnIndex) [clength $column]]
	 incr columnIndex
      }
   }
   set lines ""
   set columnDelimiter [replicate " " $spacing]
   foreach row $table {
      set columnIndex 0
      foreach column $row {
	 if {$columnIndex > 0} {
	    append lines $columnDelimiter
	 }
	 lassign $columnAttributes($columnIndex) alignment
	 switch -exact -- $alignment {
	    left {
	       set column [stringLeft $column $columnWidth($columnIndex)]
	    }
	    right {
	       set column [stringRight $column $columnWidth($columnIndex)]
	    }
	    default {
	       error "invalid column alignment: $alignment"
	    }
	 }
         append lines $column
	 incr columnIndex
      }
      set lines [string trimright $lines]
      append lines "\n"
   }
   return $lines
}
proc commonPrefix {string1 string2} {
   loop index 0 [set length [min [clength $string1] [clength $string2]]] {
      if {![cequal [cindex $string1 $index] [cindex $string2 $index]]} {
         break
      }
   }
   return [csubstr $string1 0 $index]
}
proc isAbbreviation {string abbreviation {minimum 1}} {
   if {[set length [clength $abbreviation]] >= $minimum} {
      if {$length <= [clength $string]} {
         if {[cequal $abbreviation [csubstr $string 0 $length]]} {
	    return 1
	 }
      }
   }
   return 0
}
