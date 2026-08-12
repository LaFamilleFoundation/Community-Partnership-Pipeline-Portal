// js/auth.js
// Passwordless (magic link) authentication gate. Nothing in app.js runs
// until a signed-in session exists. Combine with disabling public sign-ups
// in the Supabase dashboard so only people you've invited can ever get in.

let authState = { session: null, checked: false, message: null, messageKind: null };

function escAuth(s){ return (s||'').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

function renderAuthScreen(){
  const root = document.getElementById('root');
  root.innerHTML = `
    <div class="auth-wrap">
      <div class="auth-card">
        <h1>La Famille Foundation</h1>
        <div class="sub">Community Partnership Pipeline</div>
        ${authState.message ? `<div class="auth-msg ${authState.messageKind}">${escAuth(authState.message)}</div>` : ''}
        <label>Email address</label>
        <input id="auth-email" type="email" placeholder="you@lafamillefoundation.org" autocomplete="email">
        <button class="btn btn-primary" style="width:100%;justify-content:center;" onclick="requestMagicLink()">Send me a sign-in link</button>
        <p style="font-size:12px;color:var(--ink-soft);margin-top:14px;">
          Only people invited in Supabase can sign in. You'll get a one-time
          link by email — no password needed.
        </p>
      </div>
    </div>`;
}

window.requestMagicLink = async function(){
  const email = document.getElementById('auth-email').value.trim();
  if(!email){ authState.message='Enter your email first.'; authState.messageKind='err'; renderAuthScreen(); return; }
  authState.message = 'Sending…'; authState.messageKind = 'ok'; renderAuthScreen();
  const { error } = await window.sb.auth.signInWithOtp({
    email,
    options: { emailRedirectTo: window.location.origin + window.location.pathname }
  });
  if(error){
    authState.message = error.message.includes('Signups not allowed')
      ? 'This email hasn\'t been invited yet. Ask Jethro to add you in Supabase.'
      : error.message;
    authState.messageKind = 'err';
  } else {
    authState.message = 'Check your email for a sign-in link.';
    authState.messageKind = 'ok';
  }
  renderAuthScreen();
};

window.signOut = async function(){
  await window.sb.auth.signOut();
  authState.session = null;
  renderAuthScreen();
};

async function bootAuth(){
  const { data: { session } } = await window.sb.auth.getSession();
  authState.session = session;
  authState.checked = true;

  window.sb.auth.onAuthStateChange((_event, session) => {
    authState.session = session;
    if (session) {
      bootApp(session);
    } else {
      renderAuthScreen();
    }
  });

  if (authState.session) {
    bootApp(authState.session);
  } else {
    renderAuthScreen();
  }
}

bootAuth();
