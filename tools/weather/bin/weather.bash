#!/bin/bash

readonly latitudeSetting="latitude"
readonly longitudeSetting="longitude"
readonly locationDescriptorSetting="location-descriptor"
readonly locationPhraseSetting="location-phrase"
readonly distanceUnitSetting="distance-unit"
readonly pressureUnitSetting="pressure-unit"
readonly speedUnitSetting="speed-unit"
readonly temperatureUnitSetting="temperature-unit"
readonly timeFormatSetting="time-format"

readonly -A distanceUnits=(
   # TRANSLATORS: this is the name of a distance unit
   ["ft"]="$(gettext "Feet")"

   # TRANSLATORS: this is the name of a distance unit
   ["km"]="$(gettext "Kilometers")"

   # TRANSLATORS: this is the name of a distance unit
   ["m"]="$(gettext "Meters")"

   # TRANSLATORS: this is the name of a distance unit
   ["mi"]="$(gettext "Miles")"
)

readonly -A pressureUnits=(
   # TRANSLATORS: this is the name of a pressure unit
   ["hpa"]="$(gettext "Hectopascals")"

   # TRANSLATORS: this is the name of a pressure unit
   ["inHg"]="$(gettext "Inches of Mercury")"

   # TRANSLATORS: this is the name of a pressure unit
   ["kpa"]="$(gettext "Kilopascals")"

   # TRANSLATORS: this is the name of a pressure unit
   ["mb"]="$(gettext "Millibars")"
)

readonly -A speedUnits=(
   # TRANSLATORS: this is the name of a speed unit
   ["km/hr"]="$(gettext "Kilometers per Hour")"

   # TRANSLATORS: this is the name of a speed unit
   ["knots"]="$(gettext "Knots")"

   # TRANSLATORS: this is the name of a speed unit
   ["m/s"]="$(gettext "Meters per Second")"

   # TRANSLATORS: this is the name of a speed unit
   ["mph"]="$(gettext "Miles per Hour")"
)

readonly -A temperatureUnits=(
   # TRANSLATORS: this is the name of a temperature scale
   ["C"]="$(gettext "Celsius")"

   # TRANSLATORS: this is the name of a temperature scale
   ["F"]="$(gettext "Fahrenheit")"

   # TRANSLATORS: this is the name of a temperature scale
   ["K"]="$(gettext "Kelvin")"

   # TRANSLATORS: this is the name of a temperature scale
   ["R"]="$(gettext "Rankine")"
)

readonly -A timeUnits=(
   # TRANSLATORS: this is the name of a time format
   ["24-hours"]="$(gettext "24-Hour Mode")"

   # TRANSLATORS: this is the name of a time format
   ["12-hours"]="$(gettext "12-Hour Mode")"
)

readonly -A timeFormats=(
  ["24-hours"]="%H:%M"
  ["12-hours"]="%l:%M%p"
)

readonly -A metricUnits=(
   ["${distanceUnitSetting}"]="km"
   ["${pressureUnitSetting}"]="kpa"
   ["${speedUnitSetting}"]="km/hr"
   ["${temperatureUnitSetting}"]="C"
   ["${timeFormatSetting}"]="24-hours"
)

readonly -A imperialUnits=(
   ["${distanceUnitSetting}"]="mi"
   ["${pressureUnitSetting}"]="inHg"
   ["${speedUnitSetting}"]="mph"
   ["${temperatureUnitSetting}"]="F"
   ["${timeFormatSetting}"]="12-hours"
)

readonly unitsTypeNames=(metric imperial)

readonly compassDirections=(
   # TRANSLATORS: this is a compass direction
   "$(gettext "north")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "north-northeast")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "northeast")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "east-northeast")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "east")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "east-southeast")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "southeast")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "south-southeast")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "south")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "south-southwest")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "southwest")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "west-southwest")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "west")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "west-northwest")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "northwest")"

   # TRANSLATORS: this is a compass direction
   "$(gettext "north-northwest")"
)

toCompassDirection() {
   local directionVariable="${1}"
   local degrees="${2}"

   local direction=$(( ((((degrees * 4) + 45) % 1440) / 90) ))
   direction="${compassDirections[direction]}"
   setVariable "${directionVariable}" "${direction}"
}

parseCoordinate() {
   local valueVariable="${1}"
   local maximumValue="${2}"
   local positiveLetter="${3}"
   local negativeLetter="${4}"

   local value="${!valueVariable}"
   local pattern='^([-+])?(0|[1-9][0-9]*)?(\.[0-9]+)?([A-Za-z])?$'

   [[ "${value}" =~ ${pattern} ]] || return 1
   local sign="${BASH_REMATCH[1]}"
   local integer="${BASH_REMATCH[2]}"
   local fraction="${BASH_REMATCH[3]}"
   local letter="${BASH_REMATCH[4]}"

   if [ "${integer}" -eq "${maximumValue}" ]
   then
      fraction="${fraction##.*(0)}"
      [ -n "${fraction}" ] && return 1
   elif [ "${integer}" -gt "${maximumValue}" ]
   then
      return 1
   fi

   local negativeSign=false
   [ "${sign}" = "-" ] && negativeSign=true

   [ -n "${letter}" ] && {
      if [ "${letter}" = "${negativeLetter}" ]
      then
         "${negativeSign}" && negativeSign=false || negativeSign=true
      elif [ "${letter}" != "${positiveLetter}" ]
      then
         return 1
      fi
   }

   value="${integer:-0}${fraction}"
   "${negativeSign}" && value="-${value}"
   setVariable "${valueVariable}" "${value}"
   return 0
}

readonly positiveLatitudeLetter="N"
readonly negativeLatitudeLetter="S"

parseLatitude() {
   local latitudeVariable="${1}"

   parseCoordinate "${latitudeVariable}" 90 "${positiveLatitudeLetter}" "${negativeLatitudeLetter}" || return 1
   return 0
}

readonly positiveLongitudeLetter="E"
readonly negativeLongitudeLetter="W"

parseLongitude() {
   local longitudeVariable="${1}"

   parseCoordinate "${longitudeVariable}" 180 "${positiveLongitudeLetter}" "${negativeLongitudeLetter}" || return 1
   return 0
}

