proc getProgramPath {} {
   global argv0
   return [file dirname $argv0]
}
proc getProgramName {} {
   global argv0
   return [file tail $argv0]
}
proc putProgramMessage {message} {
   puts stderr "[getProgramName]: $message"
   flush stderr
}
proc putProgramError {{message ""} {returnCode 2}} {
   if {[clength $message] > 0} {
      putProgramMessage $message
   }
   exit $returnCode
}
proc parseProgramArguments {operandsArray parameters options} {
   global argv
   upvar 1 $operandsArray operands
   tryCommand {
      uplevel 1 [list parseArguments $operandsArray $argv $parameters $options]
   } error {
      putProgramError $errorMessage
   }
}
