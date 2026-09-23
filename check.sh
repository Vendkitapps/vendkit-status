#!/usr/bin/env bash
# Checks every app in apps.txt. An app counts as DOWN only after 3 failed
# attempts ~20s apart, so one slow response doesn't trigger a false alarm.
# Exits non-zero if any app is down -> GitHub marks the run failed -> email alert.
set -u

down=0
summary="## Vendkit app health — $(date -u '+%Y-%m-%d %H:%M UTC')"$'\n\n| App | Status | Detail |\n|---|---|---|\n'

while read -r name url; do
  [[ -z "${name:-}" || "$name" == \#* ]] && continue
  ok=0; detail=""
  for attempt in 1 2 3; do
    body=$(curl -s -m 20 -w '\n%{http_code}' "$url") || body=$'\n000'
    code=$(tail -n1 <<<"$body"); json=$(sed '$d' <<<"$body")
    if [[ "$code" == "200" && "$json" == *'"ok":true'* ]]; then ok=1; detail="HTTP 200"; break; fi
    detail="HTTP $code $(head -c 120 <<<"$json")"
    [[ $attempt -lt 3 ]] && sleep 20
  done
  if [[ $ok -eq 1 ]]; then
    echo "UP    $name  $detail"; summary+="| $name | ✅ up | $detail |"$'\n'
  else
    echo "DOWN  $name  $detail"; summary+="| $name | ❌ DOWN | $detail |"$'\n'
    echo "::error title=$name is DOWN::$url -> $detail"
    down=1
  fi
done < apps.txt

[[ -n "${GITHUB_STEP_SUMMARY:-}" ]] && printf '%s' "$summary" >> "$GITHUB_STEP_SUMMARY"
exit $down
