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