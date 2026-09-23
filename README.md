# Vendkit status

A 24/7 uptime checker for the Vendkit Shopify apps. Runs on GitHub's servers every
5 minutes and does not depend on anyone's PC being on.

- **What it checks:** each app's `/healthz` page, which confirms the app responds
  and its database is reachable. List in [`apps.txt`](apps.txt).
- **When something breaks:** an app counts as down after 3 failed attempts about
  20 seconds apart, so a single slow reply doesn't trigger an alarm. The run then
  fails and GitHub emails the account owner.
- **Latest results:** the [Actions tab](../../actions/workflows/uptime.yml). Each run
  shows a table of every app's status.
- **Add a new app:** add one line to `apps.txt`.
- **Manual check:** Actions → "Uptime check" → "Run workflow".

`backbeam-jobs.yml` runs every 15 minutes. It calls Backbeam's protected
`/api/cron/drain` endpoint to retry failed restock alerts and send Pro reminders.
The shared secret lives in the repo secret `BACKBEAM_CRON_SECRET` and in
`CRON_SECRET` on Railway.

`keepalive.yml` makes a tiny commit once a month. Without it, GitHub pauses
scheduled workflows in repos that go 60 days without activity.
