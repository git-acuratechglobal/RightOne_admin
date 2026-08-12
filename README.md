# RightOne Admin Panel (Flutter Web)

Static UI build — no backend wired up yet. Login accepts any email/password
and drops you straight into the dashboard shell.

## What's here

- **Login** (`/login`) — static form, "logs in" instantly (no Firebase yet).
- **Dashboard** (`/dashboard`) — stat cards, growth chart, recent signups, report breakdown.
- **Users** (`/users`) — mock user table with status pills.
- **Matches** (`/matches`) — mock match pairs table.
- **Chats** (`/chats`) — mock conversation list for moderation.
- **Subscriptions** (`/subscriptions`) — mock billing table.
- **Reports** (`/reports`) — mock moderation report breakdown.
- **Settings** (`/settings`) — static app + team settings.

All data lives in `lib/data/mock_data.dart` — swap it out for real
Firestore/API calls when you're ready to wire up the backend.

Styling follows the reference wireframe: near-black background, dashed
hairline borders (`lib/widgets/dashed_container.dart`), monospace font
(JetBrains Mono via `google_fonts`), with RightOne's neon magenta/cyan
brand accents layered on top.

## Run it

```bash
flutter pub get
flutter run -d chrome
```

## Build for deployment

```bash
flutter build web
```

Output lands in `build/web/` — deploy that folder to Firebase Hosting,
Vercel, Netlify, or any static host.

## Next steps (when you're ready to go beyond static)

1. Wire `lib/data/auth_state.dart` up to Firebase Auth (the mobile app
   already has `firebase_auth` configured — reuse the same project).
2. Replace `MockData` with real Firestore queries / Cloud Functions calls.
3. Add role-based access if you'll have multiple admin levels
   (Owner / Moderator, as sketched in the Settings screen).
4. Add pagination + filters to the Users/Matches/Subscriptions tables
   once real data volume shows up.
