package com.example.elearning.controllers;

import com.example.elearning.dto.*;
import com.example.elearning.entities.*;
import com.example.elearning.services.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/quiz")
@CrossOrigin(origins = "http://localhost:5001")
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;
    // ================= ADMIN =================
    @PreAuthorize("hasRole('ADMIN') ")

    @PostMapping("/create")
    public ResponseEntity<Quiz> createQuiz(@RequestBody QuizCreateDTO quizDTO) {
        Quiz quiz = new Quiz();
        quiz.setTitle(quizDTO.getTitle());

        // récupérer le course
        Course course = quizService.getCourseById(quizDTO.getCourseId());
        quiz.setCourse(course);

        Quiz savedQuiz = quizService.createQuiz(quiz);
        return ResponseEntity.ok(savedQuiz);
    }

    @PreAuthorize("hasRole('ADMIN') ")

    @PostMapping("/{quizId}/question")
    public ResponseEntity<Question> addQuestion(
            @PathVariable Long quizId,
            @RequestBody Question question
    ) {
        Question savedQuestion = quizService.addQuestion(quizId, question);
        return ResponseEntity.ok(savedQuestion);
    }
    @PreAuthorize("hasRole('ADMIN') ")

    @PostMapping("/question/{questionId}/answer")
    public ResponseEntity<Answer> addAnswer(
            @PathVariable Long questionId,
            @RequestBody Answer answer
    ) {
        Answer savedAnswer = quizService.addAnswer(questionId, answer);
        return ResponseEntity.ok(savedAnswer);
    }

    // ================= STUDENT =================
    @GetMapping("/{quizId}")
    public ResponseEntity<QuizDTO> getQuiz(@PathVariable Long quizId) {
        Quiz quiz = quizService.getQuiz(quizId);
        return ResponseEntity.ok(convertToDTO(quiz));
    }

    @PostMapping("/{quizId}/submit/{studentId}")
    public ResponseEntity<StudentQuiz> submitQuiz(
            @PathVariable Long quizId,
            @PathVariable UUID studentId,
            @RequestBody List<Long> answerIds
    ) {
        StudentQuiz studentQuiz = quizService.submitQuiz(studentId, quizId, answerIds);
        return ResponseEntity.ok(studentQuiz);
    }


    // ================= DTO Converter =================
    private QuizDTO convertToDTO(Quiz quiz) {
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
