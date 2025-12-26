package com.example.elearning.repositories;

import com.example.elearning.entities.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface StudentQuizRepository extends JpaRepository<StudentQuiz, Long> {
    Optional<StudentQuiz> findByStudentIdAndQuizId(UUID studentId, Long quizId);
}