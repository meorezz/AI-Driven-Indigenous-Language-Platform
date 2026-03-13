-- =============================================================================
-- Supabase Migration: AI-Driven Indigenous Language Platform
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 1. CREATE TABLES
-- =============================================================================

CREATE TABLE regions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    map_coordinates jsonb
);

CREATE TABLE languages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id uuid REFERENCES regions(id) ON DELETE CASCADE,
    name text NOT NULL,
    native_name text,
    speaker_count int DEFAULT 0,
    status text DEFAULT 'active'
);

CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    icon text,
    description text
);

CREATE TABLE concepts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
    language_id uuid REFERENCES languages(id) ON DELETE CASCADE,
    word text NOT NULL,
    translation text NOT NULL,
    pronunciation_guide text,
    audio_url text,
    image_url text
);

CREATE TABLE contributions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    language_id uuid REFERENCES languages(id) ON DELETE CASCADE,
    concept_id uuid REFERENCES concepts(id) ON DELETE SET NULL,
    contributor_type text NOT NULL,
    audio_url text,
    word text,
    translation text,
    status text DEFAULT 'pending',
    created_at timestamptz DEFAULT now()
);

CREATE TABLE reports (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    concept_id uuid REFERENCES concepts(id) ON DELETE CASCADE NOT NULL,
    report_type text NOT NULL,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE user_progress (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id text NOT NULL,
    concept_id uuid REFERENCES concepts(id) ON DELETE CASCADE NOT NULL,
    score int DEFAULT 0,
    attempts int DEFAULT 0,
    last_practiced timestamptz DEFAULT now()
);

-- =============================================================================
-- 2. ENABLE ROW LEVEL SECURITY AND CREATE POLICIES
-- =============================================================================

-- Regions: SELECT for anon
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous read access on regions"
    ON regions FOR SELECT TO anon USING (true);

-- Languages: SELECT for anon
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous read access on languages"
    ON languages FOR SELECT TO anon USING (true);

-- Categories: SELECT for anon
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous read access on categories"
    ON categories FOR SELECT TO anon USING (true);

-- Concepts: SELECT for anon
ALTER TABLE concepts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous read access on concepts"
    ON concepts FOR SELECT TO anon USING (true);

-- Contributions: SELECT and INSERT for anon
ALTER TABLE contributions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous read access on contributions"
    ON contributions FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous insert access on contributions"
    ON contributions FOR INSERT TO anon WITH CHECK (true);

-- Reports: INSERT for anon
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous insert access on reports"
    ON reports FOR INSERT TO anon WITH CHECK (true);

-- User Progress: SELECT, INSERT, UPDATE for anon filtered by user_id
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous read access on user_progress"
    ON user_progress FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous insert access on user_progress"
    ON user_progress FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Allow anonymous update access on user_progress"
    ON user_progress FOR UPDATE TO anon USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub')
    WITH CHECK (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- =============================================================================
-- 3. SEED DATA
-- =============================================================================

DO $$
DECLARE
    -- Region IDs
    v_region_sabah uuid := gen_random_uuid();
    v_region_sarawak uuid := gen_random_uuid();

    -- Language IDs - Sabah
    v_lang_kadazan uuid := gen_random_uuid();
    v_lang_murut uuid := gen_random_uuid();
    v_lang_bajau uuid := gen_random_uuid();

    -- Language IDs - Sarawak
    v_lang_iban uuid := gen_random_uuid();
    v_lang_bidayuh uuid := gen_random_uuid();
    v_lang_melanau uuid := gen_random_uuid();

    -- Category IDs
    v_cat_family uuid := gen_random_uuid();
    v_cat_fruit uuid := gen_random_uuid();
    v_cat_nature uuid := gen_random_uuid();
    v_cat_daily uuid := gen_random_uuid();
    v_cat_actions uuid := gen_random_uuid();
    v_cat_greetings uuid := gen_random_uuid();

BEGIN
    -- =========================================================================
    -- REGIONS
    -- =========================================================================
    INSERT INTO regions (id, name, description, map_coordinates) VALUES
    (v_region_sabah, 'Sabah',
     'Located on the northern part of Borneo, Sabah is home to diverse indigenous communities including the Kadazan-Dusun, Murut, and Bajau peoples.',
     '{"lat": 5.9804, "lng": 116.0735}'::jsonb),
    (v_region_sarawak, 'Sarawak',
     'The largest state in Malaysia, Sarawak on Borneo island is rich with indigenous cultures including the Iban, Bidayuh, and Melanau communities.',
     '{"lat": 2.4894, "lng": 111.0149}'::jsonb);

    -- =========================================================================
    -- LANGUAGES
    -- =========================================================================
    INSERT INTO languages (id, region_id, name, native_name, speaker_count, status) VALUES
    -- Sabah
    (v_lang_kadazan, v_region_sabah, 'Kadazan-Dusun', 'Kadazan Dusun', 500000, 'active'),
    (v_lang_murut, v_region_sabah, 'Murut', 'Murut', 100000, 'endangered'),
    (v_lang_bajau, v_region_sabah, 'Bajau', 'Sama-Bajau', 400000, 'active'),
    -- Sarawak
    (v_lang_iban, v_region_sarawak, 'Iban', 'Iban', 700000, 'active'),
    (v_lang_bidayuh, v_region_sarawak, 'Bidayuh', 'Bidayuh', 200000, 'vulnerable'),
    (v_lang_melanau, v_region_sarawak, 'Melanau', 'Melanau', 120000, 'vulnerable');

    -- =========================================================================
    -- CATEGORIES
    -- =========================================================================
    INSERT INTO categories (id, name, icon, description) VALUES
    (v_cat_family, 'Family', 'people', 'Family members and relationships'),
    (v_cat_fruit, 'Fruit & Food', 'nutrition', 'Fruits foods and traditional dishes'),
    (v_cat_nature, 'Nature', 'leaf', 'Natural elements landscapes and environment'),
    (v_cat_daily, 'Daily Objects', 'cube', 'Everyday objects and household items'),
    (v_cat_actions, 'Actions', 'zap', 'Common verbs and actions'),
    (v_cat_greetings, 'Greetings', 'message-circle', 'Greetings and common phrases');

    -- =========================================================================
    -- CONCEPTS: KADAZAN-DUSUN
    -- =========================================================================

    -- Family
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_family, v_lang_kadazan, 'Tama', 'Father', 'tah-mah'),
    (v_cat_family, v_lang_kadazan, 'Tina', 'Mother', 'tee-nah'),
    (v_cat_family, v_lang_kadazan, 'Wuhu', 'Grandfather', 'woo-hoo'),
    (v_cat_family, v_lang_kadazan, 'Vodu', 'Grandmother', 'voh-doo'),
    (v_cat_family, v_lang_kadazan, 'Tanak', 'Child', 'tah-nahk'),
    (v_cat_family, v_lang_kadazan, 'Tuai', 'Elder/Older sibling', 'too-aye'),
    (v_cat_family, v_lang_kadazan, 'Adi', 'Younger sibling', 'ah-dee');

    -- Greetings
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_greetings, v_lang_kadazan, 'Kotobian', 'Hello/Good', 'koh-toh-bee-an'),
    (v_cat_greetings, v_lang_kadazan, 'Aramai ti', 'How are you', 'ah-rah-my tee'),
    (v_cat_greetings, v_lang_kadazan, 'Koposion', 'Thank you', 'koh-poh-see-on'),
    (v_cat_greetings, v_lang_kadazan, 'Pounsikou', 'Welcome', 'pown-see-kow');

    -- Fruit & Food
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_fruit, v_lang_kadazan, 'Tondiu', 'Mango', 'ton-dee-oo'),
    (v_cat_fruit, v_lang_kadazan, 'Pisang', 'Banana', 'pee-sahng'),
    (v_cat_fruit, v_lang_kadazan, 'Nasi', 'Rice', 'nah-see'),
    (v_cat_fruit, v_lang_kadazan, 'Hinava', 'Traditional dish', 'hee-nah-vah'),
    (v_cat_fruit, v_lang_kadazan, 'Sada', 'Fish', 'sah-dah');

    -- Nature
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_nature, v_lang_kadazan, 'Toboh', 'Mountain', 'toh-boh'),
    (v_cat_nature, v_lang_kadazan, 'Waiig', 'Water/River', 'why-eeg'),
    (v_cat_nature, v_lang_kadazan, 'Tana', 'Earth/Land', 'tah-nah'),
    (v_cat_nature, v_lang_kadazan, 'Rindu', 'Forest', 'rin-doo'),
    (v_cat_nature, v_lang_kadazan, 'Tadau', 'Sun/Day', 'tah-dow');

    -- Daily Objects
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_daily, v_lang_kadazan, 'Walai', 'House', 'wah-lye'),
    (v_cat_daily, v_lang_kadazan, 'Sompog', 'Basket', 'som-pog'),
    (v_cat_daily, v_lang_kadazan, 'Totungkus', 'Cloth', 'toh-toong-koos'),
    (v_cat_daily, v_lang_kadazan, 'Gantangan', 'Cooking pot', 'gahn-tahng-ahn');

    -- Actions
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_actions, v_lang_kadazan, 'Kakan', 'Eat', 'kah-kahn'),
    (v_cat_actions, v_lang_kadazan, 'Moginum', 'Drink', 'moh-gee-noom'),
    (v_cat_actions, v_lang_kadazan, 'Manaid', 'Walk', 'mah-nah-eed'),
    (v_cat_actions, v_lang_kadazan, 'Mitabang', 'Help', 'mee-tah-bahng'),
    (v_cat_actions, v_lang_kadazan, 'Mongoi', 'Go', 'mon-goy');

    -- =========================================================================
    -- CONCEPTS: IBAN
    -- =========================================================================

    -- Family
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_family, v_lang_iban, 'Apai', 'Father', 'ah-pie'),
    (v_cat_family, v_lang_iban, 'Indai', 'Mother', 'in-dye'),
    (v_cat_family, v_lang_iban, 'Aki', 'Grandfather', 'ah-kee'),
    (v_cat_family, v_lang_iban, 'Ini', 'Grandmother', 'ee-nee'),
    (v_cat_family, v_lang_iban, 'Anak', 'Child', 'ah-nahk');

    -- Greetings
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_greetings, v_lang_iban, 'Selamat datai', 'Welcome', 'seh-lah-maht dah-tye'),
    (v_cat_greetings, v_lang_iban, 'Anang gawa', 'Don''t worry', 'ah-nahng gah-wah'),
    (v_cat_greetings, v_lang_iban, 'Terima kasih', 'Thank you', 'teh-ree-mah kah-see'),
    (v_cat_greetings, v_lang_iban, 'Apa cherita?', 'What''s the story/How are you?', 'ah-pah cheh-ree-tah');

    -- Fruit & Food
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_fruit, v_lang_iban, 'Buah', 'Fruit', 'boo-ah'),
    (v_cat_fruit, v_lang_iban, 'Manok', 'Chicken', 'mah-nok'),
    (v_cat_fruit, v_lang_iban, 'Padi', 'Rice paddy', 'pah-dee'),
    (v_cat_fruit, v_lang_iban, 'Ikan', 'Fish', 'ee-kahn'),
    (v_cat_fruit, v_lang_iban, 'Tuak', 'Rice wine', 'too-ahk');

    -- Nature
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_nature, v_lang_iban, 'Sungai', 'River', 'soong-eye'),
    (v_cat_nature, v_lang_iban, 'Bukit', 'Hill', 'boo-kit'),
    (v_cat_nature, v_lang_iban, 'Tanah', 'Land', 'tah-nah'),
    (v_cat_nature, v_lang_iban, 'Rimba', 'Jungle', 'rim-bah'),
    (v_cat_nature, v_lang_iban, 'Langit', 'Sky', 'lahng-it');

    -- Actions
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_actions, v_lang_iban, 'Makai', 'Eat', 'mah-kye'),
    (v_cat_actions, v_lang_iban, 'Ngirup', 'Drink', 'ngee-roop'),
    (v_cat_actions, v_lang_iban, 'Bejalai', 'Walk/Journey', 'beh-jah-lye'),
    (v_cat_actions, v_lang_iban, 'Nemu', 'Find', 'neh-moo'),
    (v_cat_actions, v_lang_iban, 'Datai', 'Come', 'dah-tye');

    -- Daily Objects
    INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide) VALUES
    (v_cat_daily, v_lang_iban, 'Rumah', 'House', 'roo-mah'),
    (v_cat_daily, v_lang_iban, 'Tikai', 'Mat', 'tee-kye'),
    (v_cat_daily, v_lang_iban, 'Terabai', 'Shield', 'teh-rah-bye'),
    (v_cat_daily, v_lang_iban, 'Parang', 'Machete', 'pah-rahng');

END $$;
