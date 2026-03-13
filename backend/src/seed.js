const db = require('./database');

function seed() {
  console.log('Seeding database...');

  // Clear existing data
  db.exec(`
    DELETE FROM user_progress;
    DELETE FROM reports;
    DELETE FROM contributions;
    DELETE FROM concepts;
    DELETE FROM categories;
    DELETE FROM languages;
    DELETE FROM regions;
  `);

  // --- Regions ---
  const insertRegion = db.prepare(
    'INSERT INTO regions (name, description, map_coordinates) VALUES (?, ?, ?)'
  );

  const sabahId = insertRegion.run(
    'Sabah',
    'Located on the northern part of Borneo, Sabah is home to diverse indigenous communities including the Kadazan-Dusun, Murut, and Bajau peoples.',
    JSON.stringify({ lat: 5.9804, lng: 116.0735 })
  ).lastInsertRowid;

  const sarawakId = insertRegion.run(
    'Sarawak',
    'The largest state in Malaysia, Sarawak on Borneo island is rich with indigenous cultures including the Iban, Bidayuh, and Melanau communities.',
    JSON.stringify({ lat: 2.4894, lng: 111.0149 })
  ).lastInsertRowid;

  // --- Languages ---
  const insertLanguage = db.prepare(
    'INSERT INTO languages (region_id, name, native_name, speaker_count, status) VALUES (?, ?, ?, ?, ?)'
  );

  const kadazanDusunId = insertLanguage.run(sabahId, 'Kadazan-Dusun', 'Kadazan Dusun', 500000, 'active').lastInsertRowid;
  const murutId = insertLanguage.run(sabahId, 'Murut', 'Murut', 100000, 'endangered').lastInsertRowid;
  const bajauId = insertLanguage.run(sabahId, 'Bajau', 'Sama-Bajau', 400000, 'active').lastInsertRowid;
  const ibanId = insertLanguage.run(sarawakId, 'Iban', 'Iban', 700000, 'active').lastInsertRowid;
  const bidayuhId = insertLanguage.run(sarawakId, 'Bidayuh', 'Bidayuh', 200000, 'vulnerable').lastInsertRowid;
  const melanauId = insertLanguage.run(sarawakId, 'Melanau', 'Melanau', 120000, 'vulnerable').lastInsertRowid;

  // --- Categories ---
  const insertCategory = db.prepare(
    'INSERT INTO categories (name, icon, description) VALUES (?, ?, ?)'
  );

  const familyId = insertCategory.run('Family', 'people', 'Family members and relationships').lastInsertRowid;
  const foodId = insertCategory.run('Fruit & Food', 'nutrition', 'Fruits, foods, and traditional dishes').lastInsertRowid;
  const natureId = insertCategory.run('Nature', 'leaf', 'Natural elements, landscapes, and environment').lastInsertRowid;
  const objectsId = insertCategory.run('Daily Objects', 'cube', 'Everyday objects and household items').lastInsertRowid;
  const actionsId = insertCategory.run('Actions', 'zap', 'Common verbs and actions').lastInsertRowid;
  const greetingsId = insertCategory.run('Greetings', 'message-circle', 'Greetings and common phrases').lastInsertRowid;

  // --- Concepts ---
  const insertConcept = db.prepare(
    'INSERT INTO concepts (category_id, language_id, word, translation, pronunciation_guide, audio_url, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)'
  );

  // =====================
  // KADAZAN-DUSUN CONCEPTS
  // =====================

  // Family
  insertConcept.run(familyId, kadazanDusunId, 'Tama', 'Father', 'tah-mah', null, null);
  insertConcept.run(familyId, kadazanDusunId, 'Tina', 'Mother', 'tee-nah', null, null);
  insertConcept.run(familyId, kadazanDusunId, 'Wuhu', 'Grandfather', 'woo-hoo', null, null);
  insertConcept.run(familyId, kadazanDusunId, 'Vodu', 'Grandmother', 'voh-doo', null, null);
  insertConcept.run(familyId, kadazanDusunId, 'Tanak', 'Child', 'tah-nahk', null, null);
  insertConcept.run(familyId, kadazanDusunId, 'Tuai', 'Elder/Older sibling', 'too-aye', null, null);
  insertConcept.run(familyId, kadazanDusunId, 'Adi', 'Younger sibling', 'ah-dee', null, null);

  // Greetings
  insertConcept.run(greetingsId, kadazanDusunId, 'Kotobian', 'Hello/Good', 'koh-toh-bee-an', null, null);
  insertConcept.run(greetingsId, kadazanDusunId, 'Aramai ti', 'How are you', 'ah-rah-my tee', null, null);
  insertConcept.run(greetingsId, kadazanDusunId, 'Koposion', 'Thank you', 'koh-poh-see-on', null, null);
  insertConcept.run(greetingsId, kadazanDusunId, 'Pounsikou', 'Welcome', 'pown-see-kow', null, null);

  // Fruit & Food
  insertConcept.run(foodId, kadazanDusunId, 'Tondiu', 'Mango', 'ton-dee-oo', null, null);
  insertConcept.run(foodId, kadazanDusunId, 'Pisang', 'Banana', 'pee-sahng', null, null);
  insertConcept.run(foodId, kadazanDusunId, 'Nasi', 'Rice', 'nah-see', null, null);
  insertConcept.run(foodId, kadazanDusunId, 'Hinava', 'Traditional dish', 'hee-nah-vah', null, null);
  insertConcept.run(foodId, kadazanDusunId, 'Sada', 'Fish', 'sah-dah', null, null);

  // Nature
  insertConcept.run(natureId, kadazanDusunId, 'Toboh', 'Mountain', 'toh-boh', null, null);
  insertConcept.run(natureId, kadazanDusunId, 'Waiig', 'Water/River', 'why-eeg', null, null);
  insertConcept.run(natureId, kadazanDusunId, 'Tana', 'Earth/Land', 'tah-nah', null, null);
  insertConcept.run(natureId, kadazanDusunId, 'Rindu', 'Forest', 'rin-doo', null, null);
  insertConcept.run(natureId, kadazanDusunId, 'Tadau', 'Sun/Day', 'tah-dow', null, null);

  // Daily Objects
  insertConcept.run(objectsId, kadazanDusunId, 'Walai', 'House', 'wah-lye', null, null);
  insertConcept.run(objectsId, kadazanDusunId, 'Sompog', 'Basket', 'som-pog', null, null);
  insertConcept.run(objectsId, kadazanDusunId, 'Totungkus', 'Cloth', 'toh-toong-koos', null, null);
  insertConcept.run(objectsId, kadazanDusunId, 'Gantangan', 'Cooking pot', 'gahn-tahng-ahn', null, null);

  // Actions
  insertConcept.run(actionsId, kadazanDusunId, 'Kakan', 'Eat', 'kah-kahn', null, null);
  insertConcept.run(actionsId, kadazanDusunId, 'Moginum', 'Drink', 'moh-gee-noom', null, null);
  insertConcept.run(actionsId, kadazanDusunId, 'Manaid', 'Walk', 'mah-nah-eed', null, null);
  insertConcept.run(actionsId, kadazanDusunId, 'Mitabang', 'Help', 'mee-tah-bahng', null, null);
  insertConcept.run(actionsId, kadazanDusunId, 'Mongoi', 'Go', 'mon-goy', null, null);

  // =============
  // IBAN CONCEPTS
  // =============

  // Family
  insertConcept.run(familyId, ibanId, 'Apai', 'Father', 'ah-pie', null, null);
  insertConcept.run(familyId, ibanId, 'Indai', 'Mother', 'in-dye', null, null);
  insertConcept.run(familyId, ibanId, 'Aki', 'Grandfather', 'ah-kee', null, null);
  insertConcept.run(familyId, ibanId, 'Ini', 'Grandmother', 'ee-nee', null, null);
  insertConcept.run(familyId, ibanId, 'Anak', 'Child', 'ah-nahk', null, null);

  // Greetings
  insertConcept.run(greetingsId, ibanId, 'Selamat datai', 'Welcome', 'seh-lah-maht dah-tye', null, null);
  insertConcept.run(greetingsId, ibanId, 'Anang gawa', "Don't worry", 'ah-nahng gah-wah', null, null);
  insertConcept.run(greetingsId, ibanId, 'Terima kasih', 'Thank you', 'teh-ree-mah kah-see', null, null);
  insertConcept.run(greetingsId, ibanId, 'Apa cherita?', "What's the story/How are you?", 'ah-pah cheh-ree-tah', null, null);

  // Fruit & Food
  insertConcept.run(foodId, ibanId, 'Buah', 'Fruit', 'boo-ah', null, null);
  insertConcept.run(foodId, ibanId, 'Manok', 'Chicken', 'mah-nok', null, null);
  insertConcept.run(foodId, ibanId, 'Padi', 'Rice paddy', 'pah-dee', null, null);
  insertConcept.run(foodId, ibanId, 'Ikan', 'Fish', 'ee-kahn', null, null);
  insertConcept.run(foodId, ibanId, 'Tuak', 'Rice wine', 'too-ahk', null, null);

  // Nature
  insertConcept.run(natureId, ibanId, 'Sungai', 'River', 'soong-eye', null, null);
  insertConcept.run(natureId, ibanId, 'Bukit', 'Hill', 'boo-kit', null, null);
  insertConcept.run(natureId, ibanId, 'Tanah', 'Land', 'tah-nah', null, null);
  insertConcept.run(natureId, ibanId, 'Rimba', 'Jungle', 'rim-bah', null, null);
  insertConcept.run(natureId, ibanId, 'Langit', 'Sky', 'lahng-it', null, null);

  // Actions
  insertConcept.run(actionsId, ibanId, 'Makai', 'Eat', 'mah-kye', null, null);
  insertConcept.run(actionsId, ibanId, 'Ngirup', 'Drink', 'ngee-roop', null, null);
  insertConcept.run(actionsId, ibanId, 'Bejalai', 'Walk/Journey', 'beh-jah-lye', null, null);
  insertConcept.run(actionsId, ibanId, 'Nemu', 'Find', 'neh-moo', null, null);
  insertConcept.run(actionsId, ibanId, 'Datai', 'Come', 'dah-tye', null, null);

  // Daily Objects
  insertConcept.run(objectsId, ibanId, 'Rumah', 'House', 'roo-mah', null, null);
  insertConcept.run(objectsId, ibanId, 'Tikai', 'Mat', 'tee-kye', null, null);
  insertConcept.run(objectsId, ibanId, 'Terabai', 'Shield', 'teh-rah-bye', null, null);
  insertConcept.run(objectsId, ibanId, 'Parang', 'Machete', 'pah-rahng', null, null);

  console.log('Database seeded successfully!');
  console.log(`  Regions: 2`);
  console.log(`  Languages: 6`);
  console.log(`  Categories: 6`);

  const conceptCount = db.prepare('SELECT COUNT(*) as count FROM concepts').get();
  console.log(`  Concepts: ${conceptCount.count}`);
}

seed();
