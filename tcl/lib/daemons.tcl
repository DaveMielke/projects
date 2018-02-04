proc writeLog {data} {
   puts stderr [format "%s %s\[%d\] %s" [clock format [clock seconds] -format "%Y/%m/%d@%H:%M:%S"] [getProgramName] [pid] $data]
   flush stderr
}
proc becomeDaemon {} {
   umask 077
   dup [open "/dev/null" {RDONLY}] stdin
   foreach directory {"/var/log" "/var/adm" "/usr/adm"} {
      if {[file isdirectory $directory] && [file writable $directory]} {
	 set logFile [file join $directory "[getProgramName].log"]
	 dup [open $logFile {WRONLY APPEND CREAT}] stdout
	 dup stdout stderr
	 break
      }
   }
   if {[fork] != 0} {
      exit 0
   }
   id process group set
   writeLog "starting"
}
