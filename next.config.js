/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ["cdn.jsdelivr.net", "quran.com", "cdn.alquran.cloud"]
  },
  experimental: {
    appDir: false
  }
};
module.exports = nextConfig;