/**
 * Example script to seed initial content into Supabase using the anon key.
 * Usage (locally):
 *   - copy .env.example -> .env.local and set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY
 *   - run: ts-node scripts/seed.ts  (or compile and run with node)
 *
 * NOTE: For production seeding, use a service_role key and server-side migration tooling.
 */

import { supabase } from "../lib/supabaseClient";

async function run() {
  console.log("Seeding example content...");
  // Example: insert a simple quotes table entry if table exists
  try {
    const { error } = await supabase.from("quotes").insert([
      {
        title: "Welcome",
        content: "May Allah guide us on the journey to Janneh."
      }
    ]);
    if (error) {
      console.warn("Seed insert error (maybe table doesn't exist):", error.message);
    } else {
      console.log("Seeded quotes");
    }
  } catch (err) {
    console.error("Seed failed", err);
  }
}

run();