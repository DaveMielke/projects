set -e

programName="$(basename "${0}")"
programDirectory="$(cd "$(dirname "${0}")" && pwd)"

programMessage() {
   local message="${1}"

   [ -z "${message}" ] || echo >&2 "${programName}: ${message}"
}

syntaxError() {
   local message="${1}"

   programMessage "${message}"
   exit 2
}

semanticError() {
   local message="${1}"

   programMessage "${message}"
   exit 3
}

internalError() {
   local message="${1}"

   programMessage "${message}"
   exit 4
}

setVariable() {
   eval "${1}="'"${2}"'
}

evaluate() {
   setVariable "${1}" "$(bc -q <<< "${2}")"

   [[ "${!1}" =~ ^-?"." ]] && {
      setVariable "${1}" "${!1/./0.}"
   } || :
}

isTrue() {
   local expression="${1}"
   local result

   evaluate result "${expression}"
   [ "${result}" -eq 0 ] && return 1
   return 0
}

wordifyString() {
   local variable="${1}"

   local string="${!variable}"
   local result=""

   local words="$(echo "${string}" | sed -e 's/\([[:lower:]]\)\([^[:lower:]]\)/\1 \2/g')"
   words="$(echo "${words}" | sed -e 's/\([[:upper:]]\)\([[:upper:]]\)/\1 \2/g')"

   local word
   for word in ${words}
   do
      [ -z "${result}" ] || {
         result+=" "

         case "${word}"
         in
            A|Above|After|Ahead|An|And|Around|At|Before|Behind|Below|Beside|Between|Beyond|By|For|From|In|Into|Of|On|Or|Out|Over|The|Through|Till|To|Under|Until|Unto|Upon|With|Within|Without)
               word="$(echo "${word}" | sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')"
               ;;
         esac
      }

      result+="${word}"
   done

   setVariable "${variable}" "${result}"
}

editString() {
   local variable="${1}"
   local prompt="${2}"

   local result
   read -p "${prompt}> " -r -e -i "${!variable}" result
   setVariable "${variable}" "${result}"
}
isAbbreviation() {
   local supplied="${1}"
   local actual="${2}"
   local length="${#supplied}"

   [ "${length}" -eq 0 ] || {
      [ "${length}" -le "${#actual}" ] && {
         [ "${supplied}" = "${actual:0:length}" ] && {
            return 0
         }
      }
   }

   return 1
}

confirmAction() {
   local question="${1}"

   local yes="yes"
   local no="no"

   local response
   local extra

   while :
   do
      read -p "${question}? " -r -e response extra || {
         echo >&2 ""
         return 1
      }

      [ -n "${extra}" ] || {
         response="${response,,*}"
         isAbbreviation "${response}" "${yes}" && return 0
         isAbbreviation "${response}" "${no}" && return 1
      }

      echo >&2 "Response msut be either ${yes} or ${no}."
   done
}

