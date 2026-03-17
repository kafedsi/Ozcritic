// ============================================================
// src/lib/supabase.js
// Central Supabase client + all data-fetching functions
// ============================================================

import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm'

// ── Replace these with your real values from:
//    Supabase Dashboard → Project Settings → API
export const supabase = createClient(
  'YOUR_SUPABASE_PROJECT_URL',   // e.g. https://xyzabc.supabase.co
  'YOUR_SUPABASE_ANON_KEY'       // starts with "eyJ..."
)

// ============================================================
// TITLES
// ============================================================

/**
 * Fetch all titles, optionally filtered by type and/or genre.
 * Returns newest first, then by critic_score desc.
 *
 * @param {{ type?: 'film'|'tv'|'album'|'ep'|'single', genre?: string, limit?: number }} opts
 */
export async function getTitles({ type, genre, limit = 20 } = {}) {
  let query = supabase
    .from('titles')
    .select('id, slug, title, type, genre, release_date, creator, cover_url, critic_score, user_score, review_count')
    .order('release_date', { ascending: false })
    .order('critic_score', { ascending: false, nullsFirst: false })
    .limit(limit)

  if (type)  query = query.eq('type', type)
  if (genre) query = query.contains('genre', [genre])

  const { data, error } = await query
  if (error) throw error
  return data
}

/**
 * Fetch a single title by slug, including all critic reviews with
 * critic name and publication name joined in.
 */
export async function getTitleBySlug(slug) {
  const { data, error } = await supabase
    .from('titles')
    .select(`
      *,
      critic_reviews (
        id, score, snippet, full_review_url, reviewed_at,
        critics (
          name, slug,
          publications ( name, slug )
        )
      )
    `)
    .eq('slug', slug)
    .single()

  if (error) throw error
  return data
}

/**
 * Fetch featured title (used for hero banner).
 */
export async function getFeaturedTitle() {
  const { data, error } = await supabase
    .from('titles')
    .select('id, slug, title, type, genre, release_date, creator, cover_url, critic_score, user_score, review_count')
    .eq('is_featured', true)
    .order('updated_at', { ascending: false })
    .limit(1)
    .single()

  if (error) throw error
  return data
}

/**
 * Fetch top-rated titles of the year.
 */
export async function getTopRated({ type, year = new Date().getFullYear(), limit = 10 } = {}) {
  let query = supabase
    .from('titles')
    .select('id, slug, title, type, genre, release_date, creator, cover_url, critic_score, user_score, review_count')
    .gte('release_date', `${year}-01-01`)
    .lte('release_date', `${year}-12-31`)
    .not('critic_score', 'is', null)
    .order('critic_score', { ascending: false })
    .limit(limit)

  if (type) query = query.eq('type', type)

  const { data, error } = await query
  if (error) throw error
  return data
}

/**
 * Search titles by name (case-insensitive partial match).
 */
export async function searchTitles(q, limit = 12) {
  const { data, error } = await supabase
    .from('titles')
    .select('id, slug, title, type, genre, critic_score, cover_url')
    .ilike('title', `%${q}%`)
    .order('critic_score', { ascending: false, nullsFirst: false })
    .limit(limit)

  if (error) throw error
  return data
}

// ============================================================
// CRITIC REVIEWS
// ============================================================

/**
 * Fetch all critic reviews for a title, sorted by score desc.
 */
export async function getCriticReviews(titleId) {
  const { data, error } = await supabase
    .from('critic_reviews')
    .select(`
      id, score, snippet, full_review_url, reviewed_at,
      critics (
        name, slug, avatar_url,
        publications ( name, slug, website )
      )
    `)
    .eq('title_id', titleId)
    .order('score', { ascending: false, nullsFirst: false })

  if (error) throw error
  return data
}

// ============================================================
// USER REVIEWS
// ============================================================

/**
 * Fetch all user reviews for a title, newest first.
 */
export async function getUserReviews(titleId, limit = 20) {
  const { data, error } = await supabase
    .from('user_reviews')
    .select(`
      id, score, body, created_at,
      profiles ( username, display_name, avatar_url )
    `)
    .eq('title_id', titleId)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw error
  return data
}

/**
 * Submit or update a user review for a title.
 * Requires the user to be signed in.
 *
 * @param {{ titleId: string, score: number, body?: string }} review
 */
export async function upsertUserReview({ titleId, score, body }) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('You must be signed in to leave a review.')

  const { data, error } = await supabase
    .from('user_reviews')
    .upsert({
      title_id: titleId,
      user_id: user.id,
      score,
      body: body || null,
    }, { onConflict: 'title_id,user_id' })
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * Delete a user's own review.
 */
export async function deleteUserReview(reviewId) {
  const { error } = await supabase
    .from('user_reviews')
    .delete()
    .eq('id', reviewId)

  if (error) throw error
}

// ============================================================
// WATCHLIST
// ============================================================

/**
 * Get all watchlist entries for the current user.
 */
export async function getWatchlist() {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return []

  const { data, error } = await supabase
    .from('watchlist')
    .select(`
      id, added_at,
      titles ( id, slug, title, type, cover_url, critic_score )
    `)
    .eq('user_id', user.id)
    .order('added_at', { ascending: false })

  if (error) throw error
  return data
}

/**
 * Toggle a title on/off the watchlist. Returns true if added, false if removed.
 */
export async function toggleWatchlist(titleId) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('You must be signed in to use your watchlist.')

  // Check if already exists
  const { data: existing } = await supabase
    .from('watchlist')
    .select('id')
    .eq('user_id', user.id)
    .eq('title_id', titleId)
    .maybeSingle()

  if (existing) {
    await supabase.from('watchlist').delete().eq('id', existing.id)
    return false
  } else {
    await supabase.from('watchlist').insert({ user_id: user.id, title_id: titleId })
    return true
  }
}

// ============================================================
// PUBLICATIONS & CRITICS
// ============================================================

export async function getPublications() {
  const { data, error } = await supabase
    .from('publications')
    .select('id, name, slug, website, logo_url')
    .eq('is_active', true)
    .order('name')

  if (error) throw error
  return data
}

export async function getCritics(limit = 20) {
  const { data, error } = await supabase
    .from('critics')
    .select(`
      id, name, slug, avatar_url, review_count,
      publications ( name, slug )
    `)
    .order('review_count', { ascending: false })
    .limit(limit)

  if (error) throw error
  return data
}

// ============================================================
// AUTH HELPERS
// ============================================================

export async function signUp(email, password, username) {
  const { data, error } = await supabase.auth.signUp({ email, password })
  if (error) throw error

  // Create profile row
  if (data.user) {
    await supabase.from('profiles').insert({
      id: data.user.id,
      username,
      display_name: username,
    })
  }
  return data
}

export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password })
  if (error) throw error
  return data
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}
