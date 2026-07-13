#!/usr/bin/env bash
set -euo pipefail

CITY="${1:-Casablanca}"
TIMEZONE="${TIMEZONE:-Africa/Casablanca}"
OUTPUT_DIR="${OUTPUT_DIR:-logs}"
REPORT_FILE="${OUTPUT_DIR}/weather_report.txt"
LOG_FILE="${OUTPUT_DIR}/weather.log"

mkdir -p "$OUTPUT_DIR"

weather_report="$(curl -fsS "https://wttr.in/${CITY}?T")"
printf '%s\n' "$weather_report" > "$REPORT_FILE"

current_temp="$(printf '%s\n' "$weather_report" | grep -m1 '°C' | grep -Eo '[-+]?[0-9]+(\([0-9]+\))?' | head -n1 || true)"
forecast_temp="$(printf '%s\n' "$weather_report" | awk 'NR==23 { print; exit }' | grep -Eo '[-+]?[0-9]+(\([0-9]+\))?' | head -n1 || true)"
timestamp="$(TZ="$TIMEZONE" date '+%Y-%m-%d %H:%M:%S')"

if [[ ! -f "$LOG_FILE" ]]; then
  printf 'timestamp\tcity\tcurrent_temp\tnoon_forecast\n' > "$LOG_FILE"
fi

printf '%s\t%s\t%s\t%s\n' \
  "$timestamp" \
  "$CITY" \
  "${current_temp:-unknown}" \
  "${forecast_temp:-unknown}" >> "$LOG_FILE"

printf 'Weather report saved to %s\n' "$REPORT_FILE"
printf 'Log entry appended to %s\n' "$LOG_FILE"
printf 'Current temperature in %s: %s\n' "$CITY" "${current_temp:-unknown}"
printf 'Forecast temperature for noon tomorrow in %s: %s\n' "$CITY" "${forecast_temp:-unknown}"
