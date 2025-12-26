package com.example.elearning.services;


import com.example.elearning.dto.AnswerDTO;
import com.example.elearning.dto.QuestionDTO;
import com.example.elearning.dto.QuizDTO;
import com.example.elearning.dto.course.CourseRequest;
import com.example.elearning.entities.Course;
import com.example.elearning.entities.Quiz;
import com.example.elearning.entities.User;
import com.example.elearning.exceptions.NotFoundException;
import com.example.elearning.repositories.CourseRepository;
import com.example.elearning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CourseService {
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;

    public Course create(CourseRequest req) {
        Course c = new Course();
        c.setTitle(req.getTitle());
        c.setDescription(req.getDescription());
        c.setCategory(req.getCategory());
        c.setVideoUrl(req.getVideoUrl());
        c.setPdfUrl(req.getPdfUrl());
//        if (req.getTeacherId() != null) {
//            User t = userRepository.findById(req.getTeacherId()).orElseThrow(() -> new NotFoundException("Teacher not found"));
//            c.setTeacher(t);
//        }
        return courseRepository.save(c);
    }

    public Course update(Long id, CourseRequest req) {
        Course c = courseRepository.findById(id).orElseThrow(() -> new NotFoundException("Course not found"));
        c.setTitle(req.getTitle());
        c.setDescription(req.getDescription());
        c.setCategory(req.getCategory());
        c.setVideoUrl(req.getVideoUrl());
        c.setPdfUrl(req.getPdfUrl());
//        if (req.getTeacherId() != null) {
//            User t = userRepository.findById(req.getTeacherId()).orElseThrow(() -> new NotFoundException("Teacher not found"));
//            c.setTeacher(t);
//        }
        return courseRepository.save(c);
    }
    public List<Course> searchByTitle(String title) {
        return courseRepository.findByTitleContainingIgnoreCase(title);
    }

    public void delete(Long id) {
        courseRepository.deleteById(id);
    }
    public long countCourses() {
        return courseRepository.count();
    }

    public Course getById(Long id) {
        return courseRepository.findById(id).orElseThrow(() -> new NotFoundException("Course not found"));
    }

    public List<Course> getAll() {
        return courseRepository.findAll();
    }

    public long getTotalCourses() {
        return courseRepository.count();
    }

    // Les derniers cours créés (limit N)
    public List<Course> getLatestCourses(int limit) {
        return courseRepository.findAll(
                org.springframework.data.domain.PageRequest.of(0, limit,
                        org.springframework.data.domain.Sort.by(Sort.Direction.DESC, "id")
                        )
        ).getContent();
    }
    // Cours avec le plus de chapitres
    public List<Course> getCoursesWithMostChapters(int limit) {
        return courseRepository.findAll().stream()
                .sorted((c1, c2) -> Integer.compare(
                        c2.getChapters().size(),
                        c1.getChapters().size()
                ))
                .limit(limit)
                .toList();
    }


    public QuizDTO convertToDTO(Quiz quiz) {
        List<QuestionDTO> questions = quiz.getQuestions().stream()
                .map(q -> new QuestionDTO(
                        q.getId(),
                        q.getText(),
                        q.getAnswers().stream()
                                .map(a -> new AnswerDTO(a.getId(), a.getText(), a.getIsCorrect()))
                                .collect(Collectors.toList())
                ))
                .collect(Collectors.toList());

        return new QuizDTO(quiz.getId(), quiz.getTitle(), quiz.getCreatedAt(), questions);
    }

}

