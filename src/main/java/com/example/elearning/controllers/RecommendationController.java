package com.example.elearning.controllers;

import com.example.elearning.dto.*;
import com.example.elearning.entities.*;
import com.example.elearning.repositories.CourseRepository;
import com.example.elearning.services.EnrollmentService;
import com.example.elearning.services.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/api/recommendations")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:5001")
public class RecommendationController {

    private final EnrollmentService enrollmentService;
    private final CourseRepository courseRepository;

    // -----------------------------
    // Endpoint pour recommander des cours
    // -----------------------------

    @PreAuthorize("hasRole('USER') ")

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Course>> recommendCoursesByCategory(@PathVariable UUID userId) {

        // Récupérer les cours déjà suivis
        List<Course> enrolledCourses = enrollmentService.getEnrollmentsByUser(userId)
                .stream()
                .map(Enrollment::getCourse)
                .toList();

        if (enrolledCourses.isEmpty()) {
            return ResponseEntity.ok(List.of()); // aucun cours suivi
        }

        // Extraire les catégories
        List<String> categories = enrolledCourses.stream()
                .map(Course::getCategory)
                .filter(c -> c != null)
                .distinct()
                .toList();

        // Liste des cours déjà suivis pour les exclure
        List<Long> excludedIds = enrolledCourses.stream()
                .map(Course::getId)
                .toList();

        // Ajouter -1 si la liste est vide pour éviter JPA [] vide
        if (excludedIds.isEmpty()) excludedIds = List.of(-1L);

        // Rechercher les cours dans les mêmes catégories mais jamais suivis
        List<Course> recommendedCourses = courseRepository.findByCategoryInAndIdNotIn(categories, excludedIds);

        return ResponseEntity.ok(recommendedCourses);
    }
}



