# Casablanca Weather Logger

A small Bash project that fetches the current weather for a city, saves the raw report, and appends a timestamped log entry.

This is a good profile project because it shows a complete mini workflow:

- shell scripting
- command-line APIs with `curl`
- text processing with `grep`, `awk`, and `date`
- generated output files and simple logging

## What it does

- Pulls live weather data from [wttr.in](https://wttr.in)
- Saves the full report to `logs/weather_report.txt`
- Extracts a current temperature and a noon forecast value
- Appends the result to `logs/weather.log`

## Requirements

- Bash
- `curl`
- A Unix-like shell environment

## Usage

Run the script from the project root:

```bash
bash weather_logger.sh
```

Use a different city:

```bash
bash weather_logger.sh "Rabat"
```

Optional environment variables:

- `TIMEZONE` controls the timestamp timezone. Default: `Africa/Casablanca`
- `OUTPUT_DIR` changes where generated files are written. Default: `logs`

Example:

```bash
TIMEZONE="Africa/Casablanca" OUTPUT_DIR="logs" bash weather_logger.sh "Casablanca"
```

## Output

After a run, you will get:

- `logs/weather_report.txt` with the raw weather text
- `logs/weather.log` with a tab-separated history of runs

Log format:

```text
timestamp    city    current_temp    noon_forecast
```

## Project Structure

```text
casablanca-weather-logger/
├── README.md
├── weather_logger.sh
└── logs/
    └── .gitkeep
```

## Notes

The forecast parsing is intentionally lightweight so the script stays small and easy to follow. If you want, the next version can switch to a JSON-based weather API and make the parsing more reliable.
