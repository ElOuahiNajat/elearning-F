-- TABLE Chapter
CREATE TABLE chapter (
                         id SERIAL PRIMARY KEY,
                         title VARCHAR(255) NOT NULL,
                         description TEXT,
                         course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
                         order_number INTEGER NOT NULL, -- pour gérer l'ordre des chapitres
                         video_url TEXT,
                         pdf_url TEXT,
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chaque chapitre peut avoir ses propres quiz si tu veux
CREATE TABLE chapter_quiz (
                              id SERIAL PRIMARY KEY,
                              title VARCHAR(255) NOT NULL,
                              chapter_id INTEGER REFERENCES chapter(id) ON DELETE CASCADE,
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Question et réponse pour les quiz du chapitre
CREATE TABLE chapter_question (
                                  id SERIAL PRIMARY KEY,
                                  text TEXT NOT NULL,
                                  quiz_id INTEGER REFERENCES chapter_quiz(id) ON DELETE CASCADE
);

CREATE TABLE chapter_answer (
                                id SERIAL PRIMARY KEY,
                                text TEXT NOT NULL,
                                is_correct BOOLEAN DEFAULT FALSE,
                                question_id INTEGER REFERENCES chapter_question(id) ON DELETE CASCADE
);

-- Score des étudiants pour les quiz du chapitre
CREATE TABLE student_chapter_quiz (
                                      id SERIAL PRIMARY KEY,
                                      student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                                      quiz_id INTEGER REFERENCES chapter_quiz(id) ON DELETE CASCADE,
                                      score INTEGER DEFAULT 0,
                                      CONSTRAINT unique_student_chapter_quiz UNIQUE(student_id, quiz_id)
);
