-- ⚠️ RESET (uniquement si tu repars de zéro)
DROP TABLE IF EXISTS rating CASCADE;
DROP TABLE IF EXISTS enrollment CASCADE;
DROP TABLE IF EXISTS chapter CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================
-- Activer l'extension UUID
-- ============================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================
-- TABLE users
-- ============================
CREATE TABLE users (
                       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       first_name VARCHAR(100) NOT NULL,
                       last_name  VARCHAR(100) NOT NULL,
                       email VARCHAR(255) NOT NULL UNIQUE,
                       password VARCHAR(255) NOT NULL,
                       role VARCHAR(50) NOT NULL
);

-- ============================
-- TABLE course
-- ============================
CREATE TABLE course (
                        id SERIAL PRIMARY KEY,
                        title VARCHAR(255) NOT NULL,
                        description TEXT,
                        category VARCHAR(100),
                        video_url TEXT,
                        pdf_url TEXT,
                        teacher_id UUID REFERENCES users(id) ON DELETE SET NULL
);

-- ============================
-- TABLE chapter
-- ============================
CREATE TABLE chapter (
                         id SERIAL PRIMARY KEY,
                         title VARCHAR(255) NOT NULL,
                         description TEXT,
                         course_id INTEGER NOT NULL REFERENCES course(id) ON DELETE CASCADE,
                         order_number INTEGER NOT NULL,
                         video_url TEXT,
                         pdf_url TEXT,
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         CONSTRAINT unique_chapter_order UNIQUE (course_id, order_number)
);

-- ============================
-- TABLE enrollment
-- ============================
-- CREATE TABLE enrollment (
--                             id SERIAL PRIMARY KEY,
--                             student_id UUID REFERENCES users(id) ON DELETE CASCADE,
--                             course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
--                             progress DOUBLE PRECISION DEFAULT 0
-- );
CREATE TABLE IF NOT EXISTS enrollment (
                                          id SERIAL PRIMARY KEY,
                                          student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    progress DOUBLE PRECISION DEFAULT 0,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_student_course UNIQUE(student_id, course_id)
    );
-- ============================
-- TABLE rating
-- ============================
CREATE TABLE rating (
                        id SERIAL PRIMARY KEY,
                        rating INTEGER CHECK (rating BETWEEN 1 AND 5),
                        comment TEXT,
                        student_id UUID REFERENCES users(id) ON DELETE CASCADE,
                        course_id INTEGER REFERENCES course(id) ON DELETE CASCADE
);
