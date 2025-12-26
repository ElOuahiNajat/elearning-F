

-- TABLE course
CREATE TABLE course (
                        id SERIAL PRIMARY KEY,
                        title VARCHAR(255) NOT NULL,
                        description TEXT,
                        category VARCHAR(100),
                        video_url TEXT,
                        pdf_url TEXT,
                        teacher_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- TABLE enrollment
CREATE TABLE enrollment (
                            id SERIAL PRIMARY KEY,
                            student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                            course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
                            progress DOUBLE PRECISION DEFAULT 0
);

-- TABLE rating
CREATE TABLE rating (
                        id SERIAL PRIMARY KEY,
                        rating INTEGER CHECK (rating BETWEEN 1 AND 5),
                        comment TEXT,
                        student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                        course_id INTEGER REFERENCES course(id) ON DELETE CASCADE
);
