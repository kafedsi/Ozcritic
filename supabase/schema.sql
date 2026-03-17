-- ============================================================
-- OzCritic Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- ── PUBLICATIONS (e.g. The Guardian AU, SMH) ──────────────
create table publications (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text unique not null,
  website     text,
  logo_url    text,
  is_active   boolean default true,
  created_at  timestamptz default now()
);

-- ── CRITICS ───────────────────────────────────────────────
create table critics (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  slug            text unique not null,
  publication_id  uuid references publications(id) on delete set null,
  bio             text,
  avatar_url      text,
  review_count    int default 0,
  created_at      timestamptz default now()
);

-- ── TITLES (films, TV, albums) ────────────────────────────
create table titles (
  id              uuid primary key default gen_random_uuid(),
  slug            text unique not null,
  title           text not null,
  type            text not null check (type in ('film','tv','album','ep','single')),
  genre           text[],                  -- e.g. ['Drama','Thriller']
  release_date    date,
  creator         text,                    -- director or artist name
  description     text,
  cover_url       text,
  runtime_mins    int,                     -- films/TV
  season_count    int,                     -- TV series
  label           text,                    -- music: record label
  critic_score    int,                     -- aggregated 0–100, null if < 2 reviews
  user_score      numeric(3,1),            -- aggregated user rating
  review_count    int default 0,
  user_review_count int default 0,
  is_featured     boolean default false,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ── CRITIC REVIEWS ────────────────────────────────────────
create table critic_reviews (
  id              uuid primary key default gen_random_uuid(),
  title_id        uuid not null references titles(id) on delete cascade,
  critic_id       uuid not null references critics(id) on delete cascade,
  score           int check (score >= 0 and score <= 100),
  snippet         text,                    -- pull quote shown on site
  full_review_url text,
  reviewed_at     date,
  created_at      timestamptz default now(),
  unique(title_id, critic_id)
);

-- ── USER REVIEWS ──────────────────────────────────────────
create table user_reviews (
  id          uuid primary key default gen_random_uuid(),
  title_id    uuid not null references titles(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  score       int check (score >= 0 and score <= 10),
  body        text,
  is_flagged  boolean default false,
  created_at  timestamptz default now(),
  unique(title_id, user_id)
);

-- ── USER PROFILES ─────────────────────────────────────────
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text unique not null,
  display_name text,
  avatar_url  text,
  bio         text,
  created_at  timestamptz default now()
);

-- ── WATCHLIST / FAVOURITES ────────────────────────────────
create table watchlist (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  title_id    uuid not null references titles(id) on delete cascade,
  added_at    timestamptz default now(),
  unique(user_id, title_id)
);

-- ============================================================
-- INDEXES — speed up common queries
-- ============================================================
create index idx_titles_type        on titles(type);
create index idx_titles_critic_score on titles(critic_score desc nulls last);
create index idx_titles_release_date on titles(release_date desc);
create index idx_titles_featured    on titles(is_featured) where is_featured = true;
create index idx_critic_reviews_title on critic_reviews(title_id);
create index idx_user_reviews_title  on user_reviews(title_id);
create index idx_watchlist_user      on watchlist(user_id);

-- ============================================================
-- FUNCTION: recalculate critic_score after each review insert/update
-- ============================================================
create or replace function recalculate_critic_score()
returns trigger language plpgsql as $$
begin
  update titles
  set
    critic_score = (
      select
        case when count(*) >= 2
        then round(avg(score))::int
        else null
        end
      from critic_reviews
      where title_id = coalesce(new.title_id, old.title_id)
        and score is not null
    ),
    review_count = (
      select count(*) from critic_reviews
      where title_id = coalesce(new.title_id, old.title_id)
    ),
    updated_at = now()
  where id = coalesce(new.title_id, old.title_id);
  return new;
end;
$$;

create trigger trg_critic_score
after insert or update or delete on critic_reviews
for each row execute function recalculate_critic_score();

-- ============================================================
-- FUNCTION: recalculate user_score after each user review
-- ============================================================
create or replace function recalculate_user_score()
returns trigger language plpgsql as $$
begin
  update titles
  set
    user_score = (
      select round(avg(score)::numeric, 1)
      from user_reviews
      where title_id = coalesce(new.title_id, old.title_id)
        and score is not null
    ),
    user_review_count = (
      select count(*) from user_reviews
      where title_id = coalesce(new.title_id, old.title_id)
    ),
    updated_at = now()
  where id = coalesce(new.title_id, old.title_id);
  return new;
end;
$$;

create trigger trg_user_score
after insert or update or delete on user_reviews
for each row execute function recalculate_user_score();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table profiles       enable row level security;
alter table user_reviews   enable row level security;
alter table watchlist      enable row level security;

-- Public can read everything
create policy "Public read titles"        on titles        for select using (true);
create policy "Public read publications"  on publications  for select using (true);
create policy "Public read critics"       on critics       for select using (true);
create policy "Public read critic_reviews" on critic_reviews for select using (true);
create policy "Public read user_reviews"  on user_reviews  for select using (true);
create policy "Public read profiles"      on profiles      for select using (true);

-- Users can only write their own data
create policy "Users insert own review"  on user_reviews  for insert with check (auth.uid() = user_id);
create policy "Users update own review"  on user_reviews  for update using (auth.uid() = user_id);
create policy "Users delete own review"  on user_reviews  for delete using (auth.uid() = user_id);

create policy "Users manage own watchlist" on watchlist   for all  using (auth.uid() = user_id);

create policy "Users manage own profile"  on profiles     for all  using (auth.uid() = id);
