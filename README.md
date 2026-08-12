# LFF Partnership Pipeline — Setup Guide (Supabase edition)

This is a real, private, multi-user portal: Supabase (Postgres) holds the
data behind Row Level Security, authentication is invite-only magic-link
sign-in, and the whole frontend is static files — deployable straight from
this GitHub repo with no server to run yourself.

Total hands-on time: roughly 30–40 minutes.

---

## Part 1 — Create the Supabase project

1. Go to **supabase.com**, create a free account, and create a new project.
   Pick any region close to your users; note the database password it
   generates (you likely won't need it directly, but save it somewhere
   safe like a password manager).
2. Once the project finishes provisioning, go to **SQL Editor** → **New
   query**, paste in the entire contents of **`sql/schema.sql`** from this
   repo, and click **Run**.
   - This creates all 4 tables (`communities`, `documents`, `flags`,
     `comms`), turns on Row Level Security with an "authenticated users
     only" policy on every table, and loads your 4 existing records
     (OAVM, Teach Haiti's livestock proposal, OJEADS/Laval, and Teach
     Haiti's 2023 reservoir) so you're not starting from zero.
   - It's safe to re-run this script if something goes wrong — it won't
     duplicate the seed data.

## Part 2 — Lock down authentication (do this before sharing the link)

This is the step that makes the data actually private.

1. In Supabase: **Authentication → Providers → Email**.
   - Make sure **Email** is enabled.
   - **Turn OFF "Allow new users to sign up."** This is the key step —
     with it off, nobody can create an account except people you add
     yourself. Magic-link sign-in only works for accounts that already
     exist.
2. **Authentication → URL Configuration**:
   - Set **Site URL** to whatever URL you'll deploy to (e.g.
     `https://yourname.github.io/lff-pipeline` or your Vercel URL — you
     can update this later once you know the real URL).
   - Add the same URL under **Redirect URLs**.
3. **Authentication → Users → Invite user**, once for yourself and once
   per field staffer, using their real email addresses. Each invite sends
   them an email; the first magic-link sign-in completes their account
   setup.
4. Anyone not explicitly invited here will never be able to sign in, no
   matter what they try — that's what makes this private instead of a
   public link.

## Part 3 — Get your project keys

1. In Supabase: **Settings → API**.
2. Copy the **Project URL** and the **anon / public** key (not the
   `service_role` key — never put that one in frontend code).
3. In this repo, copy `config.example.js` to a new file named `config.js`
   and paste in those two values.
4. **Commit `config.js`.** Unlike an API token, this key is meant to be
   public — see the comment inside `config.example.js` for why. What
   actually protects your data is the Row Level Security policy plus
   invite-only sign-ups from Part 2, not keeping this key secret.

## Part 4 — Push to GitHub and deploy

1. Create a new GitHub repo and push this folder to it:
   ```
   git init
   git add .
   git commit -m "LFF partnership pipeline — Supabase edition"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
   git push -u origin main
   ```
2. **Easiest option — GitHub Pages** (everything stays inside GitHub):
   - Repo → **Settings → Pages** → under "Build and deployment," set
     **Source** to "Deploy from a branch," branch `main`, folder `/root`.
   - Save. GitHub gives you a URL like
     `https://your-username.github.io/your-repo/`.
   - Go back to Supabase (Part 2, step 2) and update **Site URL** /
     **Redirect URLs** to match this real URL.
3. **Alternative — Vercel or Netlify:** both can connect directly to a
   GitHub repo and auto-deploy on every push, no configuration needed
   since this is a static site (no `/api` folder, no build step). Either
   gives you a nicer custom-domain setup than GitHub Pages if you want
   `pipeline.lafamillefoundation.org` later.

## Local testing (optional, before you deploy)

```
npm run dev
```
Opens the app at `http://localhost:5173`. Add `http://localhost:5173` to
Supabase's Redirect URLs (Part 2) if you want magic links to work locally
too.

## How sign-in works day to day

- You and field staff each go to the site, enter your email, and get a
  one-time link. No passwords to manage or reset.
- Sessions persist in the browser, so people won't need to re-request a
  link every visit.
- "Sign out" is in the ⋮ menu next to your email in the top bar.

## What's different from the old Airtable/Claude versions

- **Real per-person authentication** — no more "anyone with the link."
- **Cascading deletes** — removing a community now automatically removes
  its linked documents, flags, and comms (handled at the database level).
- **No serverless proxy needed** — Supabase's client library is designed
  to run directly in the browser safely, because access control lives in
  the database (RLS), not in hiding a key.
- **Future changes to the app** (new fields, new views, design tweaks):
  bring the code back to this chat and I'll edit these same files — commit
  and push, and GitHub Pages/Vercel/Netlify redeploy automatically.
- Need a new field on a community? Add the column in Supabase's Table
  Editor (or another `alter table` statement), then add the matching input
  in `js/app.js`'s form section and `rowToCommunity()` mapping.
