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

  // Example reciters (public streams may vary). These are placeholders; replace with proper reciter URLs or Supabase storage later.
  const reciters = [
    { id: "abdul-basit", name: "Abdul Basit", baseUrl: "https://everyayah.com/data/Abdul_Basit_Murattal_128kbps" },
    { id: "mishary", name: "Mishary", baseUrl: "https://everyayah.com/data/Mishary_Alafasy_128kbps" }
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
            <div className="text-2xl font-arabic mb-2" dir="rtl" style={{ fontFamily: "serif" }}>
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