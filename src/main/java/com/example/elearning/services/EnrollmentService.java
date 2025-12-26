package com.example.elearning.services;

import com.example.elearning.entities.Course;
import com.example.elearning.entities.Enrollment;
import com.example.elearning.entities.User;
import com.example.elearning.exceptions.NotFoundException;
import com.example.elearning.repositories.CourseRepository;
import com.example.elearning.repositories.EnrollmentRepository;
import com.example.elearning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final CourseRepository courseRepository;

    @Transactional
    public Enrollment enrollUserToCourse(UUID userId, Long courseId) {
        if (enrollmentRepository.existsByUserIdAndCourseId(userId, courseId)) {
            throw new RuntimeException("Utilisateur déjà inscrit à ce cours");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("Utilisateur non trouvé"));

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new NotFoundException("Cours non trouvé"));

        Enrollment enrollment = new Enrollment();
        enrollment.setUser(user);
        enrollment.setCourse(course);

        return enrollmentRepository.save(enrollment);
    }

    public List<Enrollment> getEnrollmentsByUser(UUID userId) {
        return enrollmentRepository.findByUserId(userId);
    }

    public List<Enrollment> getEnrollmentsByCourse(Long courseId) {
        return enrollmentRepository.findByCourseId(courseId);
    }
}
