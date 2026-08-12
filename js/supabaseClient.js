// js/supabaseClient.js
// Requires config.js (SUPABASE_URL / SUPABASE_ANON_KEY) and the Supabase
// CDN script to have loaded first — see index.html for load order.

if (!window.SUPABASE_URL || !window.SUPABASE_ANON_KEY) {
  document.getElementById('root').innerHTML =
    '<div class="loading">Missing config.js — copy config.example.js to config.js and fill in your Supabase project URL and anon key.</div>';
  throw new Error('Missing Supabase config');
}

window.sb = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});
