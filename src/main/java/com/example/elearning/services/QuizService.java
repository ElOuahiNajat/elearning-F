package com.example.elearning.services;

import com.example.elearning.entities.*;
import com.example.elearning.exceptions.NotFoundException;
import com.example.elearning.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;
    private final StudentQuizRepository studentQuizRepository;
    private final StudentAnswerRepository studentAnswerRepository;
    private final UserRepository userRepository;
    private final CourseRepository courseRepository;

    // ================= ADMIN =================
    public Quiz createQuiz(Quiz quiz) {
        return quizRepository.save(quiz);
    }

    public Course getCourseById(Long courseId) {
        return courseRepository.findById(courseId)
                .orElseThrow(() -> new NotFoundException("Course not found"));
    }

    public Question addQuestion(Long quizId, Question question) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));
        question.setQuiz(quiz);
        return questionRepository.save(question);
    }

    public Answer addAnswer(Long questionId, Answer answer) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));
        answer.setQuestion(question);
        return answerRepository.save(answer);
    }

    // ================= STUDENT =================
    public Quiz getQuiz(Long quizId) {
        return quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));
    }

    @Transactional
    public StudentQuiz submitQuiz(UUID studentId, Long quizId, List<Long> answerIds) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        // Vérifier si le quiz a déjà été soumis
        studentQuizRepository.findByStudentIdAndQuizId(student.getId(), quizId)
                .ifPresent(sq -> { throw new RuntimeException("Quiz already submitted"); });

        StudentQuiz studentQuiz = new StudentQuiz();
        studentQuiz.setStudentId(student.getId());
        studentQuiz.setQuiz(quiz);
        studentQuiz.setScore(0);
        studentQuiz = studentQuizRepository.save(studentQuiz);

        int correctCount = 0;
        List<Question> questions = quiz.getQuestions();

        for (Question question : questions) {
            List<Long> selectedAnswerIdsForQuestion = answerIds.stream()
                    .filter(id -> answerRepository.findById(id)
                            .orElseThrow(() -> new RuntimeException("Answer not found"))
                            .getQuestion().getId().equals(question.getId()))
                    .toList();

            List<Long> correctAnswerIds = question.getAnswers().stream()
                    .filter(Answer::getIsCorrect)
                    .map(Answer::getId)
                    .toList();

            // Vérifier que seules les bonnes réponses ont été sélectionnées
            if (selectedAnswerIdsForQuestion.size() == correctAnswerIds.size() &&
                    selectedAnswerIdsForQuestion.containsAll(correctAnswerIds)) {
                correctCount++;
            }

            for (Long answerId : selectedAnswerIdsForQuestion) {
                Answer answer = answerRepository.findById(answerId)
                        .orElseThrow(() -> new RuntimeException("Answer not found"));
                StudentAnswer sa = new StudentAnswer();
                sa.setStudentQuiz(studentQuiz);
                sa.setQuestion(question);
                sa.setAnswer(answer);
                studentAnswerRepository.save(sa);
            }
        }

        // Calcul du score en pourcentage
        int totalQuestions = questions.size();
        int scorePercent = (int) ((double) correctCount / totalQuestions * 100);
        studentQuiz.setScore(scorePercent);

        return studentQuizRepository.save(studentQuiz);
    }



}
