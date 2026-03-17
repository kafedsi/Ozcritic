-- ============================================================
-- OzCritic Seed Data
-- Run AFTER schema.sql in Supabase SQL Editor
-- ============================================================

-- ── PUBLICATIONS ──────────────────────────────────────────
insert into publications (name, slug, website) values
  ('The Guardian Australia',    'guardian-au',    'https://theguardian.com/au'),
  ('Sydney Morning Herald',     'smh',            'https://smh.com.au'),
  ('The Australian',            'the-australian', 'https://theaustralian.com.au'),
  ('ABC Arts',                  'abc-arts',       'https://abc.net.au/arts'),
  ('Rolling Stone Australia',   'rolling-stone-au','https://au.rollingstone.com'),
  ('Tone Deaf',                 'tone-deaf',      'https://tonedeaf.thebrag.com'),
  ('Double J',                  'double-j',       'https://doublej.net.au'),
  ('Time Out Melbourne',        'timeout-melb',   'https://timeout.com/melbourne'),
  ('The Saturday Paper',        'saturday-paper', 'https://thesaturdaypaper.com.au'),
  ('NME Australia',             'nme-au',         'https://nme.com/au');

-- ── CRITICS ───────────────────────────────────────────────
insert into critics (name, slug, publication_id) values
  ('Marcus McAllister', 'marcus-mcallister',
    (select id from publications where slug = 'guardian-au')),
  ('Sarah Leung',       'sarah-leung',
    (select id from publications where slug = 'smh')),
  ('James Broadbent',   'james-broadbent',
    (select id from publications where slug = 'the-australian')),
  ('Priya Nair',        'priya-nair',
    (select id from publications where slug = 'abc-arts')),
  ('Tara Kourakis',     'tara-kourakis',
    (select id from publications where slug = 'rolling-stone-au')),
  ('Cam Robertson',     'cam-robertson',
    (select id from publications where slug = 'tone-deaf')),
  ('Erin Foo',          'erin-foo',
    (select id from publications where slug = 'double-j')),
  ('Kat Irving',        'kat-irving',
    (select id from publications where slug = 'timeout-melb')),
  ('Louise Chen',       'louise-chen',
    (select id from publications where slug = 'saturday-paper')),
  ('Dev Patel',         'dev-patel',
    (select id from publications where slug = 'nme-au'));

-- ── TITLES ────────────────────────────────────────────────
insert into titles (slug, title, type, genre, release_date, creator, description, is_featured) values

  ('saltbush', 'Saltbush', 'film',
    array['Drama'],
    '2025-06-01',
    'Mia Nguyen',
    'A sweeping drama set in outback South Australia following three generations of a Ngarrindjeri family navigating land rights, identity, and memory.',
    true),

  ('the-gate', 'The Gate', 'film',
    array['Thriller'],
    '2025-06-07',
    'Sam Walsh',
    'A taut psychological thriller set across Melbourne and the Gold Coast, following a forensic accountant who uncovers a money-laundering network.',
    false),

  ('redfern-rising', 'Redfern Rising', 'tv',
    array['Drama'],
    '2025-05-20',
    'ABC',
    'A six-part drama series tracing the lives of four young people in Sydney''s Redfern neighbourhood across a single year.',
    false),

  ('the-barrens', 'The Barrens', 'film',
    array['Documentary'],
    '2025-06-05',
    'Paul Tran',
    'A feature documentary about the decline of the Murray-Darling river system, following farmers, ecologists and government officials over three years.',
    false),

  ('larrikin', 'Larrikin', 'film',
    array['Comedy'],
    '2025-06-12',
    'Bec Wallace',
    'A crowd-funded comedy about a failed comedian returning to regional Victoria for her father''s funeral.',
    false),

  ('red-dirt-gospel', 'Red Dirt Gospel', 'album',
    array['Country','Folk'],
    '2025-06-03',
    'Stella Ray',
    'The third studio album from Broken Hill-born Stella Ray — ten songs that weave outback mythology with raw personal confessional.',
    false),

  ('harbour-lights', 'Harbour Lights', 'album',
    array['Indie','Dream Pop'],
    '2025-05-30',
    'The Bondi Set',
    'Sydney indie five-piece The Bondi Set deliver their most cohesive record — a shimmering set of dream-pop songs that evoke Sydney Harbour at dusk.',
    false),

  ('western-mystic', 'Western Mystic', 'album',
    array['Electronic','Ambient'],
    '2025-05-25',
    'Noon Collective',
    'Perth-based electronic duo Noon Collective''s fourth record, recorded with found sounds across the Nullarbor Plain.',
    false),

  ('gone-bush', 'Gone Bush', 'album',
    array['Folk','Acoustic'],
    '2025-06-08',
    'Marlow & Dean',
    'A collaborative acoustic album from two Melbourne singer-songwriters, recorded over a weekend in a Daylesford farmhouse.',
    false),

  ('concrete-sunrise', 'Concrete Sunrise', 'album',
    array['Hip-Hop','R&B'],
    '2025-06-10',
    'TXL',
    'Brisbane rapper TXL''s sophomore album — lyrically dexterous and deeply rooted in South-East Queensland hip-hop culture.',
    false);

-- ── CRITIC REVIEWS ────────────────────────────────────────
-- Saltbush
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='saltbush'),
   (select id from critics where slug='marcus-mcallister'),
   95, 'A film of extraordinary patience and visual intelligence. Saltbush earns every frame of its 140-minute runtime.', '2025-06-02'),

  ((select id from titles where slug='saltbush'),
   (select id from critics where slug='sarah-leung'),
   90, 'Mia Nguyen announces herself as a major voice. The performances are staggering; the landscape, a character in itself.', '2025-06-02'),

  ((select id from titles where slug='saltbush'),
   (select id from critics where slug='james-broadbent'),
   85, 'Slow to start, but by the third act, Saltbush is undeniably moving. A film that stays with you.', '2025-06-03');

-- The Gate
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='the-gate'),
   (select id from critics where slug='priya-nair'),
   88, 'Walsh wrings genuine tension from boardrooms and spreadsheets. Surprising, assured, and very Australian in the best way.', '2025-06-08'),

  ((select id from titles where slug='the-gate'),
   (select id from critics where slug='kat-irving'),
   80, 'A thriller that trusts its audience''s intelligence. The third act wobbles slightly, but the ride is worth it.', '2025-06-08');

-- Redfern Rising
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='redfern-rising'),
   (select id from critics where slug='louise-chen'),
   83, 'Dense, funny and heartbreaking by turns. Redfern Rising is the best thing on Australian television this year.', '2025-05-21'),

  ((select id from titles where slug='redfern-rising'),
   (select id from critics where slug='sarah-leung'),
   75, 'Ambitious and mostly successful. The ensemble is flawless; only the pacing in episodes three and four lets it down.', '2025-05-21');

-- The Barrens
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='the-barrens'),
   (select id from critics where slug='james-broadbent'),
   65, 'Important subject matter, intermittently compelling filmmaking. Would be stronger at 80 minutes rather than 110.', '2025-06-06'),

  ((select id from titles where slug='the-barrens'),
   (select id from critics where slug='priya-nair'),
   60, 'The Barrens wears its heart on its sleeve, sometimes to its detriment. Worth watching for the drone photography alone.', '2025-06-06');

-- Larrikin
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='larrikin'),
   (select id from critics where slug='kat-irving'),
   55, 'Larrikin charms more than it earns. The lead performance is genuinely funny; the script around it, less so.', '2025-06-13'),

  ((select id from titles where slug='larrikin'),
   (select id from critics where slug='marcus-mcallister'),
   60, 'An affectionate mess. The funeral set-piece is worth the price of admission; the rest is scaffolding.', '2025-06-13');

-- Red Dirt Gospel
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='red-dirt-gospel'),
   (select id from critics where slug='tara-kourakis'),
   98, 'One of the great Australian albums of the decade. Stella Ray has made something genuinely timeless.', '2025-06-04'),

  ((select id from titles where slug='red-dirt-gospel'),
   (select id from critics where slug='marcus-mcallister'),
   92, 'Extraordinary. The production is bone-dry and perfect, and Ray''s voice has never sounded more assured.', '2025-06-04'),

  ((select id from titles where slug='red-dirt-gospel'),
   (select id from critics where slug='cam-robertson'),
   88, 'Red Dirt Gospel is the real deal — unhurried, uncompromising, and completely its own thing.', '2025-06-05');

-- Harbour Lights
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='harbour-lights'),
   (select id from critics where slug='erin-foo'),
   91, 'Harbour Lights sounds expensive — and it is, in the best sense. Every detail rewards repeated listening.', '2025-05-31'),

  ((select id from titles where slug='harbour-lights'),
   (select id from critics where slug='dev-patel'),
   85, 'The Bondi Set have been building to this. A mature, gorgeous record with genuine emotional stakes.', '2025-06-01');

-- Western Mystic
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='western-mystic'),
   (select id from critics where slug='erin-foo'),
   87, 'Western Mystic is genuinely transportive. Noon Collective are operating at the top of their game.', '2025-05-26'),

  ((select id from titles where slug='western-mystic'),
   (select id from critics where slug='cam-robertson'),
   78, 'Meditative and occasionally meandering — but when it locks in, it''s breathtaking.', '2025-05-27');

-- Concrete Sunrise
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='concrete-sunrise'),
   (select id from critics where slug='tara-kourakis'),
   80, 'TXL sounds fully formed on Concrete Sunrise. The production choices are bold; the flow, effortless.', '2025-06-11'),

  ((select id from titles where slug='concrete-sunrise'),
   (select id from critics where slug='cam-robertson'),
   72, 'A step forward in every direction. TXL is one of the most interesting voices in Australian hip-hop.', '2025-06-11');

-- Gone Bush
insert into critic_reviews (title_id, critic_id, score, snippet, reviewed_at) values
  ((select id from titles where slug='gone-bush'),
   (select id from critics where slug='erin-foo'),
   70, 'Gone Bush succeeds on feel rather than ambition. Uneven but winningly human.', '2025-06-09'),

  ((select id from titles where slug='gone-bush'),
   (select id from critics where slug='dev-patel'),
   64, 'Warm and intimate, not without its longueurs. Best heard on a Sunday morning with nowhere to be.', '2025-06-09');
