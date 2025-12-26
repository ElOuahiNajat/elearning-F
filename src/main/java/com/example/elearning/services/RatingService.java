package com.example.elearning.services;

import com.example.elearning.dto.RatingRequest;
import com.example.elearning.entities.Course;
import com.example.elearning.entities.Rating;
import com.example.elearning.entities.User;
import com.example.elearning.repositories.CourseRepository;
import com.example.elearning.repositories.RatingRepository;
import com.example.elearning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final UserRepository userRepository;
    private final CourseRepository courseRepository;

    public Rating addRating(String email, RatingRequest request) {

        User student = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Course course = courseRepository.findById(request.getCourseId())
                .orElseThrow(() -> new RuntimeException("Course not found"));

        if (ratingRepository.existsByStudentIdAndCourseId(student.getId(), course.getId())) {
            throw new IllegalStateException("You already rated this course");
        }

        Rating rating = Rating.builder()
                .rating(request.getRating())
                .comment(request.getComment())
                .student(student)
                .course(course)
                .build();

        return ratingRepository.save(rating);
    }

    public List<Rating> getRatingsByCourse(Long courseId) {
        return ratingRepository.findByCourseId(courseId);
    }
}
