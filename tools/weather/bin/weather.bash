#!/bin/bash

readonly latitudeSetting="latitude"
readonly longitudeSetting="longitude"
readonly distanceUnitSetting="distance-unit"
readonly pressureUnitSetting="pressure-unit"
readonly speedUnitSetting="speed-unit"
readonly temperatureUnitSetting="temperature-unit"
readonly timeFormatSetting="time-format"

readonly latitudePositiveLetter="N"
readonly latitudeNegativeLetter="S"

readonly longitudePositiveLetter="E"
readonly longitudeNegativeLetter="W"

readonly -A distanceUnits=(
   ft "Feet"
   km "Kilometers"
   m  "Meters"
   mi "Miles"
)

readonly -A pressureUnits=(
   hpa  "Hectopascals"
   inHg "Inches of Mercury"
   kpa  "Kilopascals"
   mb   "Millibars"
)

readonly -A speedUnits=(
   km/hr "Kilometers per Hour"
   m/s   "Meters per Second"
   mph   "Miles per Hour"
)

readonly -A temperatureUnits=(
   C "Celsius"
   F "Fahrenheit"
   K "Kelvin"
   R "Rankein"
)

readonly -A timeFormats=(
  24-hours "%H:%M"
  12-hours "%l:%M%p"
)

readonly windDirections=(N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW)
toWindDirection() {
   local directionVariable="${1}"
   local degrees="${2}"

   local direction=$(( ((((degrees * 4) + 45) % 1440) / 90) ))
   direction="${windDirections[direction]}"
   setVariable "${directionVariable}" "${direction}"
}

