# OzCritic — Setup Guide
## From zero to live on the internet in ~20 minutes

---

## What you're building

```
ozcritic.com  (Vercel — free)
     │
     └── calls ──► Supabase (free Postgres database + auth)
```

Everything runs on free tiers. No credit card needed to start.

---

## Step 1 — Create your Supabase project (5 min)

1. Go to **https://supabase.com** and click "Start your project"
2. Sign up with GitHub or email
3. Click **"New project"**
   - Name: `ozcritic`
   - Database password: choose something strong, save it somewhere
   - Region: **Sydney (ap-southeast-2)** ← important for Australian users
4. Wait ~2 minutes for it to provision

---

## Step 2 — Run the database schema (2 min)

1. In your Supabase project, click **SQL Editor** in the left sidebar
2. Click **"New query"**
3. Open `supabase/schema.sql` from this folder
4. Copy the entire contents and paste into the editor
5. Click **"Run"** (green button)
6. You should see "Success. No rows returned"

---

## Step 3 — Seed the database with sample data (1 min)

1. Click **"New query"** again in the SQL Editor
2. Open `supabase/seed.sql`
3. Copy and paste the entire contents
4. Click **"Run"**
5. You should see messages like "18 rows affected"

To verify it worked:
- Click **Table Editor** in the sidebar
- You should see tables: `titles`, `critics`, `publications`, `critic_reviews`
- Click `titles` — you should see 10 Australian titles listed

---

## Step 4 — Get your API keys (1 min)

1. In Supabase, click **Project Settings** (gear icon, bottom left)
2. Click **API**
3. You need two values:
   - **Project URL** — looks like `https://xyzabcdef.supabase.co`
   - **anon / public key** — a long string starting with `eyJ...`

Keep this tab open.

---

## Step 5 — Add your keys to the frontend (2 min)

1. Open `src/index.html` in a text editor
2. Find these two lines near the bottom (inside the `<script>` tag):

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_PROJECT_URL'
const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY'
```

3. Replace the placeholder strings with your actual values:

```javascript
const SUPABASE_URL = 'https://xyzabcdef.supabase.co'
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

4. Save the file

> ✅ At this point you can open `src/index.html` directly in your browser
> and the site will load real data from your database.

---

## Step 6 — Deploy to Vercel (5 min)

### Option A: Drag and drop (easiest)
1. Go to **https://vercel.com** and sign up (free)
2. Click **"Add New Project"**
3. Choose **"Deploy without a Git repository"** at the bottom
4. Drag your entire `ozcritic` folder onto the upload area
5. Click **Deploy**
6. Vercel gives you a free URL like `ozcritic-abc123.vercel.app`

### Option B: Via GitHub (better for ongoing updates)
1. Push this folder to a GitHub repository
2. Go to vercel.com → "Add New Project" → Import from GitHub
3. Select your repo → Deploy
4. Future: every `git push` auto-deploys

---

## Step 7 — Connect your domain (optional, ~5 min)

If you own `ozcritic.com.au` or similar:
1. In Vercel → your project → **Settings → Domains**
2. Add your domain
3. Update your domain's DNS to point to Vercel (they give you exact instructions)
4. HTTPS is automatic

---

## Adding real content

### Add a title via Supabase dashboard
1. Go to **Table Editor → titles**
2. Click **"Insert row"**
3. Fill in the fields (title, type, genre, etc.)

### Add a critic review
1. First make sure the critic and publication exist in their tables
2. Go to **Table Editor → critic_reviews**
3. Insert a row with `title_id`, `critic_id`, `score`, `snippet`
4. The critic score on the title **auto-updates** via the database trigger

### Add a publication / critic
- **Table Editor → publications** → Insert row
- **Table Editor → critics** → Insert row (link to publication via `publication_id`)

---

## User accounts & reviews

- User sign-up and sign-in are built into the site
- Supabase handles all authentication — no extra setup needed
- User passwords are securely hashed; you never see them
- To view registered users: Supabase Dashboard → **Authentication → Users**
- To moderate reviews: **Table Editor → user_reviews** (set `is_flagged = true` to hide)

---

## Free tier limits (Supabase)

| Resource         | Free limit      | Notes                        |
|------------------|-----------------|------------------------------|
| Database size    | 500 MB          | Plenty for thousands of titles |
| API requests     | 50,000/month    | ~1,600/day                   |
| Auth users       | 50,000          | More than enough              |
| Bandwidth        | 5 GB/month      | Upgrade if you go viral 🎉   |

Vercel free tier: 100 GB bandwidth/month, unlimited deploys.

---

## File structure

```
ozcritic/
├── supabase/
│   ├── schema.sql     ← Run first: creates all tables, triggers, policies
│   └── seed.sql       ← Run second: adds sample data
├── src/
│   ├── index.html     ← Main site (add your Supabase keys here)
│   └── lib/
│       └── supabase.js ← All query functions (reference / for future use)
└── SETUP.md           ← You are here
```

---

## Need help?

- Supabase docs: https://supabase.com/docs
- Vercel docs: https://vercel.com/docs
- Supabase Discord: https://discord.supabase.com (very helpful community)
