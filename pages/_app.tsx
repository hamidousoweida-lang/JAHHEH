import type { AppProps } from "next/app";
import "../styles/globals.css";

export default function App({ Component, pageProps }: AppProps) {
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