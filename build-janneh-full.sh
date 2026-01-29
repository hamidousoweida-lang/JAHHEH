#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="janneh"
ZIP_NAME="janneh.zip"

echo "Creating full Janneh project at ./${ROOT_DIR} ..."

rm -rf "$ROOT_DIR" "$ZIP_NAME"
mkdir -p "$ROOT_DIR"

# --- package.json (expanded)
cat > "$ROOT_DIR/package.json" <<'EOF'
{
  "name": "janneh",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint",
    "seed": "ts-node scripts/seed.ts"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.0.0",
    "idb": "^7.0.1",
    "next": "14.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "tailwindcss": "^3.4.8",
    "workbox-window": "^8.2.0"
  },
  "devDependencies": {
    "@types/node": "20.4.2",
    "@types/react": "18.2.28",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.21",
    "ts-node": "^10.9.1",
    "typescript": "5.5.6"
  }
}
EOF

# --- tsconfig.json
cat > "$ROOT_DIR/tsconfig.json" <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "types": ["node"]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

# --- next.config.js
cat > "$ROOT_DIR/next.config.js" <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ["cdn.jsdelivr.net", "quran.com", "cdn.alquran.cloud", "everyayah.com"]
  },
  experimental: {
    appDir: false
  }
};
module.exports = nextConfig;
EOF

# --- postcss.config.js
cat > "$ROOT_DIR/postcss.config.js" <<'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
};
EOF

# --- tailwind.config.js
cat > "$ROOT_DIR/tailwind.config.js" <<'EOF'
module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {}
  },
  plugins: []
};
EOF

# --- .gitignore
cat > "$ROOT_DIR/.gitignore" <<'EOF'
node_modules
.next
.env.local
.env.development.local
.env.production.local
.vscode
.DS_Store
dist
EOF

# --- .env.example
cat > "$ROOT_DIR/.env.example" <<'EOF'
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# VAPID keys for Web Push (optional)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=yourVapidPublicKey
VAPID_PRIVATE_KEY=yourVapidPrivateKey

# SMTP (optional) for email reminders
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=you@example.com
SMTP_PASS=supersecret

# Other config
NEXT_PUBLIC_APP_NAME=Janneh
EOF

# --- styles
mkdir -p "$ROOT_DIR/styles"
cat > "$ROOT_DIR/styles/globals.css" <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Basic watermark overlay (HAMIDOU) */
.watermark {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.12; /* adjust opacity here */
}
.watermark span {
  transform: rotate(-30deg);
  font-size: 6rem;
  font-weight: 700;
  letter-spacing: 0.15em;
  color: #111827;
  mix-blend-mode: multiply;
  user-select: none;
}

/* Simple readable Arabic font fallback for Quran text */
.font-arabic {
  font-family: "Noto Naskh Arabic", "Times New Roman", serif;
}
EOF

# --- public
mkdir -p "$ROOT_DIR/public"
cat > "$ROOT_DIR/public/manifest.json" <<'EOF'
{
  "name": "Janneh",
  "short_name": "Janneh",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#4f46e5",
  "icons": []
}
EOF

cat > "$ROOT_DIR/public/robots.txt" <<'EOF'
User-agent: *
Disallow:
EOF

# --- public/sw.js (improved caching strategy placeholder)
cat > "$ROOT_DIR/public/sw.js" <<'EOF'
const CACHE = 'janneh-v1';
const PRECACHE_URLS = [
  '/',
  '/favicon.ico',
  '/_next/static/*'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => {
      return cache.addAll(PRECACHE_URLS);
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(clients.claim());
});

self.addEventListener('fetch', event => {
  // network first for API requests, cache-first for static
  const url = new URL(event.request.url);
  if (url.pathname.startsWith('/api/') || url.hostname.includes('api.alquran.cloud') || url.hostname.includes('api.aladhan.com')) {
    event.respondWith(
      fetch(event.request).catch(() => caches.match(event.request))
    );
  } else {
    event.respondWith(
      caches.match(event.request).then(resp => resp || fetch(event.request))
    );
  }
});
EOF

# --- pages/_app.tsx
mkdir -p "$ROOT_DIR/pages"
cat > "$ROOT_DIR/pages/_app.tsx" <<'EOF'
import type { AppProps } from "next/app";
import "../styles/globals.css";

function registerServiceWorker() {
  if (typeof window === "undefined") return;
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker
      .register("/sw.js")
      .then(() => console.log("Service worker registered"))
      .catch(console.error);
  }
}

export default function App({ Component, pageProps }: AppProps) {
  if (typeof window !== "undefined") {
    if (document.readyState === "complete") {
      registerServiceWorker();
    } else {
      window.addEventListener("load", registerServiceWorker);
    }
  }
  return (
    <>
      <div className="min-h-screen bg-slate-50 text-slate-900">
        <Component {...pageProps} />
      </div>

      <div className="watermark">
        <span>HAMIDOU</span>
      </div>
    </>
  );
}
EOF

# --- components/Navbar.tsx
mkdir -p "$ROOT_DIR/components"
cat > "$ROOT_DIR/components/Navbar.tsx" <<'EOF'
import Link from "next/link";

export default function Navbar() {
  return (
    <nav className="bg-white shadow">
      <div className="container mx-auto px-4 py-3 flex items-center justify-between">
        <Link href="/">
          <a className="font-bold text-xl">Janneh</a>
        </Link>
        <div className="flex items-center gap-4">
          <Link href="/quran"><a className="text-sm">Qur'an</a></Link>
          <Link href="/hadith"><a className="text-sm">Hadith</a></Link>
          <Link href="/duas"><a className="text-sm">Du'as</a></Link>
          <Link href="/account"><a className="text-sm">Account</a></Link>
        </div>
      </div>
    </nav>
  );
}
EOF

# --- components/Footer.tsx
cat > "$ROOT_DIR/components/Footer.tsx" <<'EOF'
export default function Footer() {
  return (
    <footer className="bg-white border-t mt-10">
      <div className="container mx-auto px-4 py-6 text-sm text-slate-600">
        © {new Date().getFullYear()} Janneh — The Journey to Janneh. All rights reserved.
      </div>
    </footer>
  );
}
EOF

# --- lib/supabaseClient.ts
mkdir -p "$ROOT_DIR/lib"
cat > "$ROOT_DIR/lib/supabaseClient.ts" <<'EOF'
import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.warn("Supabase env not set. Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY");
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
EOF

# --- lib/idb.ts (simple idb helper using idb library)
cat > "$ROOT_DIR/lib/idb.ts" <<'EOF'
import { openDB } from "idb";

const DB_NAME = "janneh-db";
const DB_VERSION = 1;

export async function getDB() {
  return openDB(DB_NAME, DB_VERSION, {
    upgrade(db) {
      if (!db.objectStoreNames.contains("surahs")) {
        db.createObjectStore("surahs", { keyPath: "number" });
      }
      if (!db.objectStoreNames.contains("audioCache")) {
        db.createObjectStore("audioCache", { keyPath: "key" });
      }
      if (!db.objectStoreNames.contains("bookmarks")) {
        db.createObjectStore("bookmarks", { autoIncrement: true });
      }
    }
  });
}
EOF

# --- utils/quran-api.ts
mkdir -p "$ROOT_DIR/utils"
cat > "$ROOT_DIR/utils/quran-api.ts" <<'EOF'
export type Verse = {
  numberInSurah: number;
  text: string;
  translation?: string;
  transliteration?: string;
};

export type Surah = {
  number: number;
  name: string;
  englishName: string;
  ayahs: Verse[];
};

const buildEditionParam = (editions: string[]) => editions.join(",");

export async function fetchSurah(surahNumber: number): Promise<Surah | null> {
  const editions = buildEditionParam(["quran-uthmani", "en.transliteration", "en.sahih"]);
  try {
    const res = await fetch(`https://api.alquran.cloud/v1/surah/${surahNumber}/${editions}`);
    if (!res.ok) return null;
    const body = await res.json();
    const editionsData = body.data;
    const arabic = editionsData.find((e: any) => e.edition.identifier === "quran-uthmani");
    const translit = editionsData.find((e: any) => e.edition.identifier === "en.transliteration");
    const trans = editionsData.find((e: any) => e.edition.identifier === "en.sahih");

    if (!arabic) return null;

    const ayahs = arabic.ayahs.map((ayah: any, idx: number) => {
      return {
        numberInSurah: ayah.numberInSurah,
        text: ayah.text,
        transliteration: translit?.ayahs?.[idx]?.text ?? "",
        translation: trans?.ayahs?.[idx]?.text ?? ""
      } as Verse;
    });

    return {
      number: arabic.number,
      name: arabic.englishName ?? arabic.name,
      englishName: arabic.englishName,
      ayahs
    };
  } catch (err) {
    console.error("fetchSurah error", err);
    return null;
  }
}

export async function fetchSurahList(): Promise<{ number: number; englishName: string }[] | null> {
  try {
    const res = await fetch("https://api.alquran.cloud/v1/surah");
    if (!res.ok) return null;
    const body = await res.json();
    return body.data.map((s: any) => ({ number: s.number, englishName: s.englishName }));
  } catch (err) {
    console.error("fetchSurahList error", err);
    return null;
  }
}
EOF

# --- components/AudioPlayer.tsx
cat > "$ROOT_DIR/components/AudioPlayer.tsx" <<'EOF'
import React, { useEffect, useRef, useState } from "react";

type AudioPlayerProps = {
  audioUrl?: string | null;
  reciters?: { id: string; name: string; baseUrl: string }[];
  surahNumber?: number;
};

export default function AudioPlayer({ audioUrl, reciters = [], surahNumber }: AudioPlayerProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [playing, setPlaying] = useState(false);
  const [currentUrl, setCurrentUrl] = useState<string | undefined>(audioUrl ?? undefined);
  const [progress, setProgress] = useState(0);
  const [selectedReciter, setSelectedReciter] = useState(reciters[0]?.id ?? "");

  useEffect(() => {
    setCurrentUrl(audioUrl ?? (reciters[0] ? buildReciterUrl(reciters[0], surahNumber) : undefined));
    setSelectedReciter(reciters[0]?.id ?? "");
  }, [audioUrl, reciters, surahNumber]);

  function buildReciterUrl(reciter: any, surah?: number) {
    if (!surah) return reciter.baseUrl;
    return `${reciter.baseUrl.replace(/\/$/, "")}/${surah}.mp3`;
  }

  function togglePlay() {
    if (!audioRef.current) return;
    if (playing) {
      audioRef.current.pause();
      setPlaying(false);
    } else {
      audioRef.current.play().then(() => setPlaying(true)).catch(console.error);
    }
  }

  function onTimeUpdate() {
    if (!audioRef.current) return;
    setProgress((audioRef.current.currentTime / Math.max(1, audioRef.current.duration)) * 100);
  }

  function onReciterChange(id: string) {
    const r = reciters.find((x) => x.id === id);
    setSelectedReciter(id);
    setCurrentUrl(r ? buildReciterUrl(r, surahNumber) : undefined);
  }

  return (
    <div className="bg-white p-4 rounded shadow">
      <div className="flex items-center gap-4">
        <button
          onClick={togglePlay}
          className="px-3 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700"
        >
          {playing ? "Pause" : "Play"}
        </button>

        <div className="flex-1">
          <div className="h-2 bg-slate-200 rounded overflow-hidden">
            <div className="h-full bg-indigo-500" style={{ width: `${progress}%` }} />
          </div>
        </div>
      </div>

      <div className="mt-3">
        <label className="text-sm mr-2">Reciter:</label>
        <select
          value={selectedReciter}
          onChange={(e) => onReciterChange(e.target.value)}
          className="border px-2 py-1 rounded"
        >
          {reciters.map((r) => (
            <option key={r.id} value={r.id}>
              {r.name}
            </option>
          ))}
        </select>
      </div>

      <audio
        ref={audioRef}
        src={currentUrl}
        onTimeUpdate={onTimeUpdate}
        onEnded={() => setPlaying(false)}
        preload="metadata"
      />
      <div className="mt-3 text-sm text-slate-600">
        <div>Source: {currentUrl ?? "No audio configured"}</div>
      </div>
    </div>
  );
}
EOF

# --- pages/quran/index.tsx (list of surahs)
mkdir -p "$ROOT_DIR/pages/quran"
cat > "$ROOT_DIR/pages/quran/index.tsx" <<'EOF'
import React, { useEffect, useState } from "react";
import Link from "next/link";
import { fetchSurahList } from "../../utils/quran-api";

export default function QuranIndex() {
  const [list, setList] = useState<{ number: number; englishName: string }[] | null>(null);

  useEffect(() => {
    fetchSurahList().then(setList);
  }, []);

  if (!list) return <div className="p-4">Loading surah list…</div>;

  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-4">Full Qur'an</h1>
      <div className="grid gap-2 sm:grid-cols-2 md:grid-cols-3">
        {list.map((s) => (
          <Link key={s.number} href={`/quran/${s.number}`}>
            <a className="p-3 bg-white rounded shadow hover:bg-slate-50">
              <div className="font-semibold">Surah {s.number}</div>
              <div className="text-sm text-slate-600">{s.englishName}</div>
            </a>
          </Link>
        ))}
      </div>
    </main>
  );
}
EOF

# --- pages/quran/[surah].tsx
cat > "$ROOT_DIR/pages/quran/[surah].tsx" <<'EOF'
import { useRouter } from "next/router";
import React, { useEffect, useState } from "react";
import { fetchSurah, Surah } from "../../utils/quran-api";
import AudioPlayer from "../../components/AudioPlayer";

export default function SurahPage() {
  const router = useRouter();
  const { surah } = router.query;
  const [data, setData] = useState<Surah | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!surah) return;
    const num = Array.isArray(surah) ? Number(surah[0]) : Number(surah);
    if (!num) return;
    setLoading(true);
    fetchSurah(num).then((s) => {
      setData(s);
      setLoading(false);
    });
  }, [surah]);

  if (loading) return <div className="p-8">Loading surah...</div>;
  if (!data) return <div className="p-8">Surah not found.</div>;

  const reciters = [
    { id: "abdul-basit", name: "Abdul Basit", baseUrl: "https://everyayah.com/data/Abdul_Basit_Murattal_128kbps" },
    { id: "mishary", name: "Mishary Alafasy", baseUrl: "https://everyayah.com/data/Mishary_Alafasy_128kbps" }
  ];

  return (
    <main className="container mx-auto px-4 py-8">
      <header className="mb-6">
        <h1 className="text-3xl font-bold">{data.englishName} — Surah {data.number}</h1>
        <p className="text-sm text-slate-600">Quran reader with transliteration & translation</p>
      </header>

      <section className="mb-6">
        <AudioPlayer reciters={reciters} surahNumber={data.number} />
      </section>

      <section>
        {data.ayahs.map((ayah) => (
          <article key={ayah.numberInSurah} className="bg-white p-4 rounded mb-3 shadow">
            <div className="text-2xl font-arabic mb-2" dir="rtl">
              {ayah.text}
            </div>
            <div className="text-sm text-slate-700 italic">{ayah.transliteration}</div>
            <div className="mt-2 text-sm text-slate-600">{ayah.translation}</div>
          </article>
        ))}
      </section>
    </main>
  );
}
EOF

# --- utils/prayer-times.ts
cat > "$ROOT_DIR/utils/prayer-times.ts" <<'EOF'
export type PrayerTimes = {
  Fajr: string;
  Sunrise: string;
  Dhuhr: string;
  Asr: string;
  Maghrib: string;
  Isha: string;
  dateReadable?: string;
};

export async function fetchPrayerTimes(lat: number, lon: number, method = 2): Promise<PrayerTimes | null> {
  const url = `https://api.aladhan.com/v1/timings?latitude=${lat}&longitude=${lon}&method=${method}`;
  try {
    const res = await fetch(url);
    if (!res.ok) return null;
    const body = await res.json();
    const timings = body.data?.timings;
    const dateReadable = body.data?.date?.readable;
    if (!timings) return null;
    return {
      Fajr: timings.Fajr,
      Sunrise: timings.Sunrise,
      Dhuhr: timings.Dhuhr,
      Asr: timings.Asr,
      Maghrib: timings.Maghrib,
      Isha: timings.Isha,
      dateReadable
    };
  } catch (err) {
    console.error("fetchPrayerTimes error", err);
    return null;
  }
}
EOF

# --- components/PrayerTimes.tsx
cat > "$ROOT_DIR/components/PrayerTimes.tsx" <<'EOF'
import React, { useEffect, useState } from "react";
import { fetchPrayerTimes, PrayerTimes } from "../utils/prayer-times";

export default function PrayerTimesComponent() {
  const [times, setTimes] = useState<PrayerTimes | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!("geolocation" in navigator)) {
      setLoading(false);
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        fetchPrayerTimes(pos.coords.latitude, pos.coords.longitude).then((t) => {
          setTimes(t);
          setLoading(false);
        });
      },
      (err) => {
        console.warn("Location denied or error", err);
        setLoading(false);
      },
      { maximumAge: 60_000, timeout: 10_000 }
    );
  }, []);

  if (loading) return <div>Loading prayer times…</div>;
  if (!times) return <div>Prayer times unavailable. Allow location or set manually.</div>;

  return (
    <div className="bg-white p-4 rounded shadow max-w-md">
      <h3 className="font-semibold mb-2">Prayer Times ({times.dateReadable})</h3>
      <ul className="text-sm text-slate-700">
        <li>Fajr: {times.Fajr}</li>
        <li>Sunrise: {times.Sunrise}</li>
        <li>Dhuhr: {times.Dhuhr}</li>
        <li>Asr: {times.Asr}</li>
        <li>Maghrib: {times.Maghrib}</li>
        <li>Isha: {times.Isha}</li>
      </ul>
    </div>
  );
}
EOF

# --- pages/hadith/index.tsx (simple list using a small sample dataset)
mkdir -p "$ROOT_DIR/pages/hadith"
cat > "$ROOT_DIR/pages/hadith/index.tsx" <<'EOF'
import React from "react";
import sample from "../../data/hadith-sample.json";

export default function HadithIndex() {
  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-4">Hadith Library (Sample)</h1>
      <div className="space-y-3">
        {sample.slice(0, 20).map((h: any, i: number) => (
          <article key={i} className="bg-white p-4 rounded shadow">
            <h3 className="font-semibold">{h.collection} — {h.number}</h3>
            <p className="mt-2 text-sm text-slate-700">{h.text}</p>
          </article>
        ))}
      </div>
    </main>
  );
}
EOF

# --- data/hadith-sample.json
mkdir -p "$ROOT_DIR/data"
cat > "$ROOT_DIR/data/hadith-sample.json" <<'EOF'
[
  {"collection":"Bukhari","number":"1","text":"Actions are judged by intentions."},
  {"collection":"Muslim","number":"2","text":"None of you will have faith until he loves for his brother what he loves for himself."},
  {"collection":"Bukhari","number":"3","text":"The best of you are those who learn the Quran and teach it."}
]
EOF

# --- pages/duas/index.tsx (du'a manager skeleton)
mkdir -p "$ROOT_DIR/pages/duas"
cat > "$ROOT_DIR/pages/duas/index.tsx" <<'EOF'
import React from "react";

const sampleDuas = [
  { id: 1, title: "Morning Du'a", text: "Sample morning du'a text..." },
  { id: 2, title: "Before Sleep", text: "Sample before sleep du'a..." }
];

export default function Duas() {
  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-4">Du'as</h1>
      <div className="grid gap-4 md:grid-cols-2">
        {sampleDuas.map(d => (
          <div key={d.id} className="bg-white p-4 rounded shadow">
            <h3 className="font-semibold">{d.title}</h3>
            <p className="mt-2 text-sm text-slate-700">{d.text}</p>
          </div>
        ))}
      </div>
    </main>
  );
}
EOF

# --- components/Tasbeeh.tsx
cat > "$ROOT_DIR/components/Tasbeeh.tsx" <<'EOF'
import React, { useEffect, useState } from "react";

export default function Tasbeeh() {
  const [count, setCount] = useState(0);
  const [auto, setAuto] = useState(false);

  useEffect(() => {
    let id: number | undefined;
    if (auto) {
      id = window.setInterval(() => {
        setCount(c => c + 1);
      }, 3 * 60 * 1000); // every 3 minutes as requested
    }
    return () => { if (id) clearInterval(id); };
  }, [auto]);

  return (
    <div className="bg-white p-4 rounded shadow max-w-sm">
      <h3 className="font-semibold">Tasbeeh</h3>
      <div className="mt-2 text-2xl">{count}</div>
      <div className="mt-3 flex gap-2">
        <button onClick={() => setCount(0)} className="px-3 py-1 bg-gray-200 rounded">Reset</button>
        <button onClick={() => setAuto(a => !a)} className="px-3 py-1 bg-indigo-600 text-white rounded">
          {auto ? "Stop Auto" : "Start Auto (3m)"}
        </button>
      </div>
    </div>
  );
}
EOF

# --- components/NasheedPlayer.tsx (simple audio playlist)
cat > "$ROOT_DIR/components/NasheedPlayer.tsx" <<'EOF'
import React, { useRef, useState } from "react";

const sampleTracks = [
  { title: "Nasheed 1", url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" },
  { title: "Nasheed 2", url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3" }
];

export default function NasheedPlayer() {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [index, setIndex] = useState(0);

  function playIndex(i: number) {
    setIndex(i);
    if (audioRef.current) {
      audioRef.current.src = sampleTracks[i].url;
      audioRef.current.play().catch(console.error);
    }
  }

  return (
    <div className="bg-white p-4 rounded shadow max-w-md">
      <h3 className="font-semibold mb-2">Nasheed Player</h3>
      <ul>
        {sampleTracks.map((t, i) => (
          <li key={i} className="flex items-center justify-between py-2">
            <div>{t.title}</div>
            <button onClick={() => playIndex(i)} className="px-3 py-1 bg-indigo-600 text-white rounded">Play</button>
          </li>
        ))}
      </ul>
      <audio ref={audioRef} controls className="w-full mt-3" />
    </div>
  );
}
EOF

# --- pages/account/index.tsx (auth placeholder)
mkdir -p "$ROOT_DIR/pages/account"
cat > "$ROOT_DIR/pages/account/index.tsx" <<'EOF'
import React from "react";

export default function AccountPage() {
  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-4">Account</h1>
      <p className="text-sm text-slate-700">Authentication is not yet wired. After you create a Supabase project, I will add full Auth pages and flows (email + Google).</p>
    </main>
  );
}
EOF

# --- admin skeleton
mkdir -p "$ROOT_DIR/pages/admin"
cat > "$ROOT_DIR/pages/admin/index.tsx" <<'EOF'
import React from "react";

export default function AdminIndex() {
  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-4">Admin</h1>
      <p className="text-sm text-slate-700">Admin UI skeleton. After you set Supabase, I will add secure admin functions to manage reciters, translations, quotes and content imports.</p>
    </main>
  );
}
EOF

# --- scripts/seed.ts (improved with sample tables)
mkdir -p "$ROOT_DIR/scripts"
cat > "$ROOT_DIR/scripts/seed.ts" <<'EOF'
/**
 * Example seed script (client anon key). For production, use service_role key and server migration tooling.
 * Usage: ts-node scripts/seed.ts
 */
import { supabase } from "../lib/supabaseClient";

async function run() {
  console.log("Seeding sample data...");
  try {
    // quotes table example
    await supabase.from("quotes").insert([
      { title: "Welcome", content: "May Allah guide us on the journey to Janneh." }
    ]).catch(e => console.warn("quotes seed:", e.message));
    console.log("Done (attempted seeds).");
  } catch (err) {
    console.error("Seed failed", err);
  }
}

run();
EOF

# --- migrations SQL (basic)
cat > "$ROOT_DIR/migration.sql" <<'EOF'
-- Example SQL for Supabase / Postgres to create simple tables used by the scaffold
CREATE TABLE IF NOT EXISTS quotes (
  id serial PRIMARY KEY,
  title text,
  content text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bookmarks (
  id serial PRIMARY KEY,
  user_id text,
  type text,
  reference jsonb,
  created_at timestamptz DEFAULT now()
);
EOF

# --- README.md (expanded)
cat > "$ROOT_DIR/README.md" <<'EOF'
# Janneh — The Journey to Janneh

This repository is a full Next.js + TypeScript scaffold for Janneh (Qur'an reader, audio, prayer times, hadith, reminders, PWA).

Important setup steps (brief)
1. Install:
   npm install

2. Create environment:
   cp .env.example .env.local
   Fill NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY (create a Supabase project)

3. Create DB tables:
   - Use the SQL in migration.sql to create simple tables in your Supabase database (or via Supabase SQL editor).

4. Run dev:
   npm run dev

5. Deploy:
   - Create a GitHub repo (e.g., hamidousoweida-lang/janneh), push files, and connect to Vercel.
   - Add environment variables in Vercel matching .env.local.

Notes
- This scaffold uses public APIs for Quran text/recitations and Aladhan prayer times.
- Replace any copyrighted translations/reciters with licensed assets you own as needed.
- After you push to GitHub and set up Supabase, reply "I pushed" here and I will provide the next set of files (full Auth pages, admin CRUD, offline sync improvements, web-push server code, and more).
EOF

# --- finalizing zip
echo "Created project files. Creating zip..."

if command -v zip >/dev/null 2>&1; then
  (cd "$(dirname "$ROOT_DIR")" || exit 0; zip -r "../$ZIP_NAME" "$(basename "$ROOT_DIR")" >/dev/null)
  echo "Created $ZIP_NAME in $(pwd)"
else
  echo "zip not found — project folder created at ./${ROOT_DIR}"
fi

echo "Done. Extract janneh.zip and push contents to your GitHub repo (hamidousoweida-lang/janneh)."
echo "Read README.md for next steps."
EOF