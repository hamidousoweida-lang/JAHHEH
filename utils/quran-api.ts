// Small helper that uses the public AlQuran Cloud API with editions for Arabic, transliteration & translation.
// Docs: https://alquran.cloud/api

export type Verse = {
  numberInSurah: number;
  text: string; // Arabic (uthmani)
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
  // request Arabic (quran-uthmani), transliteration (en.transliteration) and translation (en.sahih)
  const editions = buildEditionParam(["quran-uthmani", "en.transliteration", "en.sahih"]);
  try {
    const res = await fetch(`https://api.alquran.cloud/v1/surah/${surahNumber}/${editions}`);
    if (!res.ok) return null;
    const body = await res.json();
    // response format: data is array of editions. We need to merge per ayah index.
    // The API returns an array: each element is an edition object with ayahs.
    const editionsData = body.data;
    // find each edition by edition.identifier
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