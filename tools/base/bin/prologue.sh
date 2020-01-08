set -e

programName="$(basename "${0}")"
programDirectory="$(cd "$(dirname "${0}")" && pwd)"

function programMessage() {
   local message="${1}"

   [ -z "${message}" ] || echo >&2 "${programName}: ${message}"
}

function syntaxError() {
   local message="${1}"

   programMessage "${message}"
   exit 2
}

function semanticError() {
   local message="${1}"

   programMessage "${message}"
   exit 3
}

function setVariable() {
   eval "${1}="'"${2}"'
}

function wordifyString() {
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
            A|After|An|And|Before|Behind|Beside|Between|Beyond|By|For|From|In|Into|Of|On|Or|Out|Over|The|Through|To|Under|Unto|Upon|With|Within|Without)
               word="$(echo "${word}" | sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')"
               ;;
         esac
      }

      result+="${word}"
   done

   setVariable "${variable}" "${result}"
}

function editString() {
   local variable="${1}"
   local prompt="${2}"

   local result
   read -p "${prompt}> " -r -e -i "${!variable}" result
   setVariable "${variable}" "${result}"
}

