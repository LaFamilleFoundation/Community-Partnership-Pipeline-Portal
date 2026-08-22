// js/auth.js
// Email + password authentication gate. Nothing in app.js runs until a
// signed-in session exists. Public sign-ups stay disabled in the Supabase
// dashboard, so accounts only exist for people an admin added by hand
// (Authentication → Users → Add user) — this file never creates accounts.

let authState = { session: null, checked: false, message: null, messageKind: null, mode: 'signin' };

function escAuth(s){ return (s||'').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

function renderAuthScreen(){
  const root = document.getElementById('root');
  const msg = authState.message ? `<div class="auth-msg ${authState.messageKind}">${escAuth(authState.message)}</div>` : '';

  if(authState.mode === 'reset'){
    root.innerHTML = `
      <div class="auth-wrap">
        <div class="auth-card">
          <h1>La Famille Foundation</h1>
          <div class="sub">Community Partnership Pipeline</div>
          ${msg}
          <label>Email address</label>
          <input id="auth-email" type="email" placeholder="you@lafamillefoundation.org" autocomplete="email">
          <button class="btn btn-primary" style="width:100%;justify-content:center;" onclick="requestPasswordReset()">Send reset link</button>
          <p style="font-size:12px;color:var(--ink-soft);margin-top:14px;">
            <a href="#" onclick="setAuthMode('signin');return false;" style="color:var(--teal);">← Back to sign in</a>
          </p>
        </div>
      </div>`;
    return;
  }

  root.innerHTML = `
    <div class="auth-wrap">
      <div class="auth-card">
        <h1>La Famille Foundation</h1>
        <div class="sub">Community Partnership Pipeline</div>
        ${msg}
        <label>Email address</label>
        <input id="auth-email" type="email" placeholder="you@lafamillefoundation.org" autocomplete="email">
        <label>Password</label>
        <input id="auth-password" type="password" placeholder="••••••••" autocomplete="current-password" onkeydown="if(event.key==='Enter') signIn()">
        <button class="btn btn-primary" style="width:100%;justify-content:center;" onclick="signIn()">Sign in</button>
        <p style="font-size:12px;color:var(--ink-soft);margin-top:14px;">
          Only people an admin has added can sign in.
          <a href="#" onclick="setAuthMode('reset');return false;" style="color:var(--teal);">Forgot your password?</a>
        </p>
      </div>
    </div>`;
}

window.setAuthMode = function(mode){
  authState.mode = mode;
  authState.message = null;
  renderAuthScreen();
};

window.signIn = async function(){
  const email = document.getElementById('auth-email').value.trim();
  const password = document.getElementById('auth-password').value;
  if(!email || !password){ authState.message='Enter your email and password.'; authState.messageKind='err'; renderAuthScreen(); return; }
  authState.message = 'Signing in…'; authState.messageKind = 'ok'; renderAuthScreen();
  const { error } = await window.sb.auth.signInWithPassword({ email, password });
  if(error){
    authState.message = error.message.includes('Invalid login credentials')
      ? 'Incorrect email or password.'
      : error.message;
    authState.messageKind = 'err';
    renderAuthScreen();
  }
  // on success, onAuthStateChange below handles the transition into the app
};

window.requestPasswordReset = async function(){
  const email = document.getElementById('auth-email').value.trim();
  if(!email){ authState.message='Enter your email first.'; authState.messageKind='err'; renderAuthScreen(); return; }
  authState.message = 'Sending…'; authState.messageKind = 'ok'; renderAuthScreen();
  const { error } = await window.sb.auth.resetPasswordForEmail(email, {
    redirectTo: window.location.origin + window.location.pathname
  });
  if(error){
    authState.message = error.message;
    authState.messageKind = 'err';
  } else {
    authState.message = 'If that email has an account, a reset link is on its way.';
    authState.messageKind = 'ok';
  }
  renderAuthScreen();
};

window.signOut = async function(){
  await window.sb.auth.signOut();
  authState.session = null;
  authState.mode = 'signin';
  renderAuthScreen();
};

async function bootAuth(){
  const { data: { session } } = await window.sb.auth.getSession();
  authState.session = session;
  authState.checked = true;

  window.sb.auth.onAuthStateChange((event, session) => {
    authState.session = session;
    if (event === 'PASSWORD_RECOVERY') {
      renderPasswordUpdateScreen();
      return;
    }
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

// Shown after a user clicks the link from requestPasswordReset() above —
// Supabase signs them into a temporary recovery session so they can pick
// a new password with a plain updateUser() call (still just the anon key).
function renderPasswordUpdateScreen(){
  const root = document.getElementById('root');
  const msg = authState.message ? `<div class="auth-msg ${authState.messageKind}">${escAuth(authState.message)}</div>` : '';
  root.innerHTML = `
    <div class="auth-wrap">
      <div class="auth-card">
        <h1>Set a new password</h1>
        <div class="sub">Community Partnership Pipeline</div>
        ${msg}
        <label>New password</label>
        <input id="auth-newpassword" type="password" placeholder="At least 8 characters" autocomplete="new-password">
        <button class="btn btn-primary" style="width:100%;justify-content:center;" onclick="submitNewPassword()">Set password</button>
      </div>
    </div>`;
}

window.submitNewPassword = async function(){
  const password = document.getElementById('auth-newpassword').value;
  if(!password || password.length < 8){ authState.message='Password must be at least 8 characters.'; authState.messageKind='err'; renderPasswordUpdateScreen(); return; }
  const { error } = await window.sb.auth.updateUser({ password });
  if(error){
    authState.message = error.message;
    authState.messageKind = 'err';
    renderPasswordUpdateScreen();
    return;
  }
  const { data: { session } } = await window.sb.auth.getSession();
  if (session) bootApp(session);
};

bootAuth();
