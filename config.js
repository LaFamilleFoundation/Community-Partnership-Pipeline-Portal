// Copy this file to config.js and fill in your own project's values, then
// COMMIT config.js — unlike an API token, this is meant to be public.
//
// Find these in your Supabase project: Settings → API
//   Project URL      -> SUPABASE_URL
//   anon public key  -> SUPABASE_ANON_KEY
//
// Why this is safe to commit: the anon key does not by itself grant access
// to anything. Every read and write is checked against the Row Level
// Security policies in sql/schema.sql, which require a signed-in session —
// and only people you've explicitly invited can ever get a session, since
// public sign-ups are disabled (see README Part 3). If someone finds this
// key with no valid login, they can do nothing with it.

window.SUPABASE_URL = "https://vffsrpohqfmhwzzhfkgf.supabase.co";
window.SUPABASE_ANON_KEY = "sb_publishable_A_hFz5_E97MDy-0i4X5etg_HFuyzDa8";
