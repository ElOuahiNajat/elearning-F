-- Activer UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Supprimer les contraintes FK vers users
ALTER TABLE course DROP CONSTRAINT IF EXISTS course_teacher_id_fkey;
ALTER TABLE enrollment DROP CONSTRAINT IF EXISTS enrollment_student_id_fkey;
ALTER TABLE rating DROP CONSTRAINT IF EXISTS rating_student_id_fkey;

-- Supprimer users
DROP TABLE IF EXISTS users;

-- Recréer users avec UUID
CREATE TABLE users
(
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(50)  NOT NULL
);
