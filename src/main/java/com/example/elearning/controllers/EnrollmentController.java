package com.example.elearning.controllers;

import com.example.elearning.entities.Enrollment;
import com.example.elearning.services.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/enrollments")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:5001")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    // Enrôler un utilisateur à un cours
    @PostMapping("/course/{courseId}/user/{userId}")
    public ResponseEntity<Enrollment> enroll(
            @PathVariable Long courseId,
            @PathVariable UUID userId
    ) {
        Enrollment enrollment = enrollmentService.enrollUserToCourse(userId, courseId);
        return ResponseEntity.ok(enrollment);
    }

    // Lister les cours où l'utilisateur est inscrit
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Enrollment>> getUserEnrollments(
            @PathVariable UUID userId
    ) {
        List<Enrollment> enrollments = enrollmentService.getEnrollmentsByUser(userId);
        return ResponseEntity.ok(enrollments);
    }

    // Lister les utilisateurs inscrits à un cours
    @GetMapping("/course/{courseId}")
    public ResponseEntity<List<Enrollment>> getCourseEnrollments(
            @PathVariable Long courseId
    ) {
        List<Enrollment> enrollments = enrollmentService.getEnrollmentsByCourse(courseId);
        return ResponseEntity.ok(enrollments);
    }
}
