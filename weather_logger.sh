#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${BASH_VERSION:-}" ]]; then
  printf 'Error: this script must be run with Bash.\n' >&2
  exit 1
fi

for cmd in bash curl grep awk head date; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$cmd" >&2
    exit 1
  fi
done

if [[ $# -gt 0 && -z "${1//[[:space:]]/}" ]]; then
  printf 'Error: city argument cannot be empty. Provide a city name, or omit it to use the default city.\n' >&2
  exit 1
fi

CITY="${1:-Casablanca}"
TIMEZONE="${TIMEZONE:-Africa/Casablanca}"
OUTPUT_DIR="${OUTPUT_DIR:-logs}"
REPORT_FILE="${OUTPUT_DIR}/weather_report.txt"
LOG_FILE="${OUTPUT_DIR}/weather.log"

if [[ -d /usr/share/zoneinfo && ! -e "/usr/share/zoneinfo/$TIMEZONE" ]]; then
  printf 'Error: invalid TIMEZONE value: %s\n' "$TIMEZONE" >&2
  exit 1
fi

if ! TZ="$TIMEZONE" date '+%Y-%m-%d %H:%M:%S' >/dev/null 2>&1; then
  printf 'Error: invalid TIMEZONE value: %s\n' "$TIMEZONE" >&2
  exit 1
fi

if ! mkdir -p "$OUTPUT_DIR"; then
  printf 'Error: unable to create output directory: %s\n' "$OUTPUT_DIR" >&2
  exit 1
fi

if ! weather_report="$(curl --fail --silent --show-error \
  --connect-timeout 10 \
  --max-time 30 \
  --retry 2 \
  --retry-delay 1 \
  --retry-all-errors \
  "https://wttr.in/${CITY}?T" 2>&1)"; then
  printf 'Error: failed to fetch weather data for "%s" from wttr.in. %s\n' "$CITY" "$weather_report" >&2
  exit 1
fi

if ! printf '%s\n' "$weather_report" > "$REPORT_FILE"; then
  printf 'Error: unable to write weather report file: %s\n' "$REPORT_FILE" >&2
  exit 1
fi

current_temp="$(printf '%s\n' "$weather_report" | grep -m1 '°C' | grep -Eo '[-+]?[0-9]+(\([0-9]+\))?' | head -n1 || true)"
forecast_temp="$(printf '%s\n' "$weather_report" | awk 'NR==23 { print; exit }' | grep -Eo '[-+]?[0-9]+(\([0-9]+\))?' | head -n1 || true)"
timestamp="$(TZ="$TIMEZONE" date '+%Y-%m-%d %H:%M:%S')"

if [[ ! -f "$LOG_FILE" ]]; then
  if ! printf 'timestamp\tcity\tcurrent_temp\tnoon_forecast\n' > "$LOG_FILE"; then
    printf 'Error: unable to initialize log file: %s\n' "$LOG_FILE" >&2
    exit 1
  fi
fi

if ! printf '%s\t%s\t%s\t%s\n' \
  "$timestamp" \
  "$CITY" \
  "${current_temp:-unknown}" \
  "${forecast_temp:-unknown}" >> "$LOG_FILE"; then
  printf 'Error: unable to append to log file: %s\n' "$LOG_FILE" >&2
  exit 1
fi

printf 'Weather report saved to %s\n' "$REPORT_FILE"
printf 'Log entry appended to %s\n' "$LOG_FILE"
printf 'Current temperature in %s: %s\n' "$CITY" "${current_temp:-unknown}"
printf 'Forecast temperature for noon tomorrow in %s: %s\n' "$CITY" "${forecast_temp:-unknown}"
