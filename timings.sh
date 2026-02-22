#!/bin/bash

  # --- Parse Alfred query ---
  QUERY="{query}"
  read -ra TOKENS <<< "$QUERY"

  DAY=""
  INPUT_CITY=""
  INPUT_COUNTRY=""

  if [[ "${TOKENS[0]}" =~ ^[0-9]+$ ]]; then
      DAY="${TOKENS[0]}"
      INPUT_CITY="${TOKENS[1]:-}"
      INPUT_COUNTRY="${TOKENS[2]:-}"
  else
      INPUT_CITY="${TOKENS[0]:-}"
      INPUT_COUNTRY="${TOKENS[1]:-}"
  fi

  # --- Defaults ---
  CITY="${INPUT_CITY:-Amsterdam}"
  COUNTRY="${INPUT_COUNTRY:-Netherlands}"
  METHOD="${wf_method:-3}"
  DAY="${DAY:-$(date +%d)}"
  DATE="${DAY}-$(date +%m)-$(date +%Y)"

  # --- Cache ---
  CACHE_DIR="${alfred_workflow_cache:-${TMPDIR}ramadan_cache}"
  mkdir -p "$CACHE_DIR"
  CACHE_FILE="${CACHE_DIR}/timings_${DATE}_${CITY}_${COUNTRY}.json"

  if [[ ! -f "$CACHE_FILE" ]]; then

  API_URL="https://api.aladhan.com/v1/timingsByCity/${DATE}?city=${CITY}&country=${COUNTRY}&method=${METHOD}"
      RESPONSE=$(curl -sf "$API_URL")
      STATUS=$(echo "$RESPONSE" | jq -r '.code // 0')
      if [[ $? -ne 0 ]] || [[ -z "$RESPONSE" ]] || [[ "$STATUS" != "200" ]]; then
          ERROR=$(echo "$RESPONSE" | jq -r '.data // "Check city/country names and internet connection"')
          jq -n --arg err "$ERROR" '{"items":[{"title":"Failed to fetch prayer
  times","subtitle":$err,"valid":false}]}'
          exit 1
      fi
      echo "$RESPONSE" > "$CACHE_FILE"
  else
      RESPONSE=$(cat "$CACHE_FILE")
  fi

  # --- Parse timings ---
  FAJR=$(echo "$RESPONSE"    | jq -r '.data.timings.Fajr')
  SUNRISE=$(echo "$RESPONSE" | jq -r '.data.timings.Sunrise')
  DHUHR=$(echo "$RESPONSE"   | jq -r '.data.timings.Dhuhr')
  ASR=$(echo "$RESPONSE"     | jq -r '.data.timings.Asr')
  MAGHRIB=$(echo "$RESPONSE" | jq -r '.data.timings.Maghrib')
  ISHA=$(echo "$RESPONSE"    | jq -r '.data.timings.Isha')
  HIJRI=$(echo "$RESPONSE"   | jq -r '.data.date.hijri.date')

  # --- Countdown to Iftar (today only) ---
  IFTAR_SUBTITLE="Break fast at Maghrib — ${CITY}, ${COUNTRY}  [${HIJRI}]"
  if [[ "$DATE" == "$(date +%d-%m-%Y)" ]]; then
      NOW_MINS=$(date +%H:%M | awk -F: '{print $1*60+$2}')
      IFTAR_MINS=$(echo "$MAGHRIB" | awk -F: '{print $1*60+$2}')
      DIFF=$((IFTAR_MINS - NOW_MINS))
      if   [[ $DIFF -gt 0 ]]; then IFTAR_SUBTITLE="$(( DIFF/60 ))h $(( DIFF%60 ))m until Iftar — ${CITY},
  ${COUNTRY}"
      elif [[ $DIFF -eq 0 ]]; then IFTAR_SUBTITLE="Iftar time now! — ${CITY}, ${COUNTRY}"
      else                         IFTAR_SUBTITLE="Iftar was $(( (DIFF * -1)/60 ))h $(( (DIFF * -1)%60 ))m ago —
   ${CITY}, ${COUNTRY}"
      fi
  fi

  # --- Output ---
  jq -n \
    --arg city "$CITY" --arg country "$COUNTRY" \
    --arg hijri "$HIJRI" --arg date "$DATE" \
    --arg fajr "$FAJR" --arg sunrise "$SUNRISE" \
    --arg dhuhr "$DHUHR" --arg asr "$ASR" \
    --arg maghrib "$MAGHRIB" --arg isha "$ISHA" \
    --arg iftar_sub "$IFTAR_SUBTITLE" \
  '{
    items: [
      { title: ("Sehri ends:  \($fajr)"),    subtitle: ("Last meal before fast — \($city), \($country)
  [\($hijri)]"), arg: $fajr,    valid: true },
      { title: ("Iftar:       \($maghrib)"),  subtitle: $iftar_sub,
         arg: $maghrib, valid: true },
      { title: ("Fajr:        \($fajr)"),    subtitle: "Dawn prayer",      arg: $fajr,    valid: true },
      { title: ("Sunrise:     \($sunrise)"), subtitle: "Sunrise",          arg: $sunrise, valid: true },
      { title: ("Dhuhr:       \($dhuhr)"),   subtitle: "Midday prayer",    arg: $dhuhr,   valid: true },
      { title: ("Asr:         \($asr)"),     subtitle: "Afternoon prayer", arg: $asr,     valid: true },
      { title: ("Isha:        \($isha)"),    subtitle: "Night prayer",     arg: $isha,    valid: true }
    ]
  }'
