# Janneh

The Journey to Janneh — starter scaffold.

Stack:
- Next.js + TypeScript
- Tailwind CSS
- Supabase (Auth / DB / Storage)
- PWA-ready (service worker placeholders)

Quick start (local)

1. Install
```bash
npm install
# or
yarn
```

2. Create environment
- Copy `.env.example` to `.env.local` and set your Supabase and VAPID keys.

3. Run dev
```bash
npm run dev
```

Deploy to Vercel
1. Create a GitHub repository named `janneh` under your account `hamidousoweida-lang`.
2. Push the scaffold to the repo.
3. Connect the repo to Vercel and set the environment variables in Vercel (same values as `.env.local`).
4. Deploy — Vercel will automatically build and host the app.

Next steps I will implement after you push the scaffold:
- Full Quran reader pages (text + translations + transliteration), integrated with a public Quran API or your assets.
- Audio player page and reciter selection with Supabase Storage / CDN streaming.
- Prayer times integration & location detection.
- Supabase auth integration (email + Google).
- PWA service worker & IndexedDB caching for offline surah storage.
- Admin UI and seed data import scripts.

If you want, I will now:
- Generate the remaining initial pages and components (Quran reader, audio player shell, Supabase client helper, and a basic admin seed script), OR
- Wait for you to create the repo and paste the files, then I will walk you step-by-step to push and I will provide the next batch of feature files.

Tell me which you prefer and I’ll continue.