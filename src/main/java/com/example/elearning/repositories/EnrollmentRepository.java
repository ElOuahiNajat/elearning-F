package com.example.elearning.repositories;

import com.example.elearning.entities.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {
    boolean existsByUserIdAndCourseId(UUID userId, Long courseId);
    List<Enrollment> findByUserId(UUID userId);
    List<Enrollment> findByCourseId(Long courseId);
}
