package com.example.elearning.repositories;

import com.example.elearning.entities.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    List<Rating> findByCourseId(Long courseId);

    List<Rating> findByStudentId(UUID studentId);

    boolean existsByStudentIdAndCourseId(UUID studentId, Long courseId);
}
