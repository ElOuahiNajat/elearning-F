CREATE TABLE quiz (
                      id SERIAL PRIMARY KEY,
                      title VARCHAR(255) NOT NULL,
                      course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE question (
                          id SERIAL PRIMARY KEY,
                          text TEXT NOT NULL,
                          quiz_id INTEGER REFERENCES quiz(id) ON DELETE CASCADE
);

CREATE TABLE answer (
                        id SERIAL PRIMARY KEY,
                        text TEXT NOT NULL,
                        is_correct BOOLEAN DEFAULT FALSE,
                        question_id INTEGER REFERENCES question(id) ON DELETE CASCADE
);

CREATE TABLE student_quiz (
                              id SERIAL PRIMARY KEY,
                              student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                              quiz_id INTEGER REFERENCES quiz(id) ON DELETE CASCADE,
                              score INTEGER DEFAULT 0,
                              CONSTRAINT unique_student_quiz UNIQUE(student_id, quiz_id)
);
ALTER TABLE quiz ADD COLUMN course_id INTEGER REFERENCES course(id) ON DELETE CASCADE;
