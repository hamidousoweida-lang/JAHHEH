import React, { useEffect, useRef, useState } from "react";

type AudioPlayerProps = {
  audioUrl?: string | null;
  reciters?: { id: string; name: string; baseUrl: string }[]; // baseUrl + /{surah}.mp3 etc.
  surahNumber?: number;
};

export default function AudioPlayer({ audioUrl, reciters = [], surahNumber }: AudioPlayerProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [playing, setPlaying] = useState(false);
  const [currentUrl, setCurrentUrl] = useState<string | undefined>(audioUrl ?? undefined);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    setCurrentUrl(audioUrl ?? (reciters[0] ? buildReciterUrl(reciters[0], surahNumber) : undefined));
  }, [audioUrl, reciters, surahNumber]);

  function buildReciterUrl(reciter: any, surah?: number) {
    if (!surah) return reciter.baseUrl;
    // caller should ensure reciter.baseUrl pattern supports surah substitution or is the direct file
    // common pattern: `${baseUrl}/${surah}.mp3`
    return `${reciter.baseUrl.replace(/\/$/, "")}/${surah}.mp3`;
  }

  function togglePlay() {
    if (!audioRef.current) return;
    if (playing) {
      audioRef.current.pause();
    } else {
      audioRef.current.play().catch(console.error);
    }
    setPlaying(!playing);
  }

  function onTimeUpdate() {
    if (!audioRef.current) return;
    setProgress((audioRef.current.currentTime / Math.max(1, audioRef.current.duration)) * 100);
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