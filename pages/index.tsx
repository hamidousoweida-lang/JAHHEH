import Head from "next/head";

export default function Home() {
  return (
    <>
      <Head>
        <title>The Journey to Janneh — Janneh</title>
        <meta name="description" content="Janneh — Quran, prayer times, Hadith & more" />
      </Head>

      <main className="container mx-auto px-4 py-16">
        <h1 className="text-4xl font-extrabold mb-4">The Journey to Janneh</h1>
        <p className="text-lg text-slate-700 mb-8">
          Welcome — this is the Janneh starter. I scaffolded the project with Next.js, TypeScript, Tailwind CSS and Supabase placeholders.
        </p>

        <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div className="p-6 rounded-xl bg-white shadow">
            <h2 className="font-semibold">Full Qur'an Reader</h2>
            <p className="mt-2 text-sm text-slate-600">Arabic + transliteration + translations (integrations pending).</p>
          </div>

          <div className="p-6 rounded-xl bg-white shadow">
            <h2 className="font-semibold">Audio Player</h2>
            <p className="mt-2 text-sm text-slate-600">Selectable reciters, streaming, and offline caching.</p>
          </div>

          <div className="p-6 rounded-xl bg-white shadow">
            <h2 className="font-semibold">Prayer Times</h2>
            <p className="mt-2 text-sm text-slate-600">Location-based prayer times and reminders.</p>
          </div>
        </section>
      </main>
    </>
  );
}