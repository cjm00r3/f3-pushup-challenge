# F3 10,000 Pushup Challenge

Mobile web app for the F3 Nation 10,000 Pushup Challenge (Oct 1 – Dec 31, 109 a day). Open to any PAX in any region.
Tracks sets and reminders on each man's phone and posts daily totals to a shared leaderboard with a My Region / All F3 view.

## Files
- `index.html` – the whole app (Today, Progress, PAX board, Settings)
- `config.js` – Supabase URL + anon key (the only file you edit to go live)
- `sw.js`, `manifest.json`, `icon.svg` – offline support and "Add to Home Screen"
- `supabase/migrations/*.sql` – creates the `f3_pushups` table and `f3_board` view

## Go live
1. **Supabase**: open your project → SQL Editor → run each file in `supabase/migrations/` in order (or `supabase db push`).
2. **Keys**: Project Settings → API. Copy the Project URL and the `anon` public key into `config.js`.
3. **Host**: push this folder to a public GitHub repo and turn on GitHub Pages (Settings → Pages → Deploy from branch `main`, folder `/`).
4. Share the Pages URL. Each man enters his F3 name and region in Settings and his totals appear on the PAX tab.

## Local test
```bash
python -m http.server 8765
```
Open http://localhost:8765

## Privacy
Rep logs live on the phone. Only F3 name, region, a random device id, date, daily count, and daily goal are sent to the shared board.
Rows can be inserted and updated by anyone with the app (honor system; each phone owns its own rows by device id); nothing can be deleted from the app.
