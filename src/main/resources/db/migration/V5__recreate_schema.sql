-- 1️⃣ Activer l'extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2️⃣ Supprimer les contraintes FK existantes
ALTER TABLE course DROP CONSTRAINT IF EXISTS course_teacher_id_fkey;
ALTER TABLE enrollment DROP CONSTRAINT IF EXISTS enrollment_student_id_fkey;
ALTER TABLE rating DROP CONSTRAINT IF EXISTS rating_student_id_fkey;

-- 3️⃣ Supprimer les colonnes INTEGER existantes
ALTER TABLE course DROP COLUMN IF EXISTS teacher_id;
ALTER TABLE enrollment DROP COLUMN IF EXISTS student_id;
ALTER TABLE rating DROP COLUMN IF EXISTS student_id;

-- 4️⃣ Recréer les colonnes avec UUID et FK vers users
ALTER TABLE course
    ADD COLUMN teacher_id UUID REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE enrollment
    ADD COLUMN student_id UUID REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE rating
    ADD COLUMN student_id UUID REFERENCES users(id) ON DELETE CASCADE;
