# Alfred Prayer Timings

  Daily prayer times and Ramadan Sehri/Iftar timings for any city, powered by the
  [Aladhan API](https://aladhan.com/prayer-times-api).

  ## Requirements

  - [Alfred](https://www.alfredapp.com/) with Powerpack
  - `jq` — install via Homebrew: `brew install jq`

  ## Installation

  Download the latest `PrayerTimings.alfredworkflow` from
  [Releases](../../releases/latest) and double-click to install.

  ## Usage

  Trigger with the `pray` keyword. All arguments are optional.

  pray [day] [city] [country]

  | Example | Result |
  |---|---|
  | `pray` | Today, default city and country |
  | `pray 25` | 25th of current month/year, default city and country |
  | `pray London` | Today, London, default country |
  | `pray London UK` | Today, London, UK |
  | `pray 25 London UK` | 25th of current month/year, London, UK |

  Pressing Enter on any result copies the time to your clipboard.

  ## Changing Your Default City and Country

  By default the workflow uses **Amsterdam, Netherlands**. To set your own:

  1. Open **Alfred Preferences → Workflows**
  2. Select **Prayer Timings**
  3. Click the **[x]** icon in the top-right corner of the workflow panel
  4. Add the following variables:

  | Variable | Example value |
  |---|---|
  | `wf_default_city` | `Dubai` |
  | `wf_default_country` | `UAE` |

  These act as your personal defaults. You can still override them on the fly
  by passing a city or country directly in the query (e.g. `pray London`).

  ## Configuration

  Set the `wf_method` workflow variable to change the calculation method.

  | Value | Method |
  |---|---|
  | 2 | Islamic Society of North America (ISNA) |
  | 3 | Muslim World League — Europe (default) |
  | 4 | Umm Al-Qura University, Makkah |
  | 5 | Egyptian General Authority of Survey |
  | 15 | Turkey — Diyanet |

  ## Caching

  Timings are cached per date + city + country combination.
  To clear the cache, delete the contents of the workflow cache folder:
  `~/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/<bundle-id>/`

  ## Credits

  Prayer times provided by [Aladhan API](https://aladhan.com) — free, no API key required.
