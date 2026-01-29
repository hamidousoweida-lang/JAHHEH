// Small helper that uses the Aladhan public API for prayer times.
// Docs: https://aladhan.com/prayer-times-api

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
  // method 2 = Islamic Society of North America default; allow different methods
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