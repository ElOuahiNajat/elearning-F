package com.example.elearning;

import com.example.elearning.entities.*;
import com.example.elearning.repositories.*;
import com.example.elearning.services.QuizService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class QuizServiceTest {

    @Mock
    private QuizRepository quizRepository;
    @Mock
    private QuestionRepository questionRepository;
    @Mock
    private AnswerRepository answerRepository;
    @Mock
    private StudentQuizRepository studentQuizRepository;
    @Mock
    private StudentAnswerRepository studentAnswerRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private CourseRepository courseRepository;

    @InjectMocks
    private QuizService quizService;

    private User student;
    private Quiz quiz;
    private Question question;
    private Answer correctAnswer;
    private Answer wrongAnswer;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        // Créer un utilisateur
        student = new User();
        student.setId(UUID.randomUUID());
        student.setFirstName("John");
        student.setLastName("Doe");
        student.setEmail("john@example.com");
        student.setPassword("password");
        student.setRole(com.example.elearning.enums.Role.USER);

        // Créer un quiz
        quiz = new Quiz();
        quiz.setId(1L);
        quiz.setTitle("Quiz Java");

        // Créer une question
        question = new Question();
        question.setId(1L);
        question.setText("Quelle est la bonne réponse?");
        question.setQuiz(quiz);

        // Réponses
        correctAnswer = new Answer();
        correctAnswer.setId(1L);
        correctAnswer.setIsCorrect(true);
        correctAnswer.setQuestion(question);

        wrongAnswer = new Answer();
        wrongAnswer.setId(2L);
        wrongAnswer.setIsCorrect(false);
        wrongAnswer.setQuestion(question);

        question.setAnswers(List.of(correctAnswer, wrongAnswer));
        quiz.setQuestions(List.of(question));
    }

    @Test
    void testSubmitQuiz_AllCorrect_ShouldReturn100Percent() {
        // Mocks
        when(userRepository.findById(student.getId())).thenReturn(Optional.of(student));
        when(quizRepository.findById(quiz.getId())).thenReturn(Optional.of(quiz));
        when(studentQuizRepository.findByStudentIdAndQuizId(student.getId(), quiz.getId()))
                .thenReturn(Optional.empty());
        when(studentQuizRepository.save(any(StudentQuiz.class)))
                .thenAnswer(i -> i.getArguments()[0]);
        when(answerRepository.findById(correctAnswer.getId())).thenReturn(Optional.of(correctAnswer));

        // Appel du service
        StudentQuiz studentQuiz = quizService.submitQuiz(student.getId(), quiz.getId(), List.of(correctAnswer.getId()));

        // Vérification
        assertEquals(100, studentQuiz.getScore());
        verify(studentAnswerRepository, times(1)).save(any());
    }

    @Test
    void testSubmitQuiz_WrongAnswer_ShouldReturn0Percent() {
        // Mocks
        when(userRepository.findById(student.getId())).thenReturn(Optional.of(student));
        when(quizRepository.findById(quiz.getId())).thenReturn(Optional.of(quiz));
        when(studentQuizRepository.findByStudentIdAndQuizId(student.getId(), quiz.getId()))
                .thenReturn(Optional.empty());
        when(studentQuizRepository.save(any(StudentQuiz.class)))
                .thenAnswer(i -> i.getArguments()[0]);
        when(answerRepository.findById(wrongAnswer.getId())).thenReturn(Optional.of(wrongAnswer));

        // Appel du service
        StudentQuiz studentQuiz = quizService.submitQuiz(student.getId(), quiz.getId(), List.of(wrongAnswer.getId()));

        // Vérification
        assertEquals(0, studentQuiz.getScore());
        verify(studentAnswerRepository, times(1)).save(any());
    }

    @Test
    void testSubmitQuiz_AlreadySubmitted_ShouldThrowException() {
        StudentQuiz existing = new StudentQuiz();
        existing.setId(1L);

        when(userRepository.findById(student.getId())).thenReturn(Optional.of(student));
        when(quizRepository.findById(quiz.getId())).thenReturn(Optional.of(quiz));
        when(studentQuizRepository.findByStudentIdAndQuizId(student.getId(), quiz.getId()))
                .thenReturn(Optional.of(existing));

        // Vérification
        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> quizService.submitQuiz(student.getId(), quiz.getId(), List.of(correctAnswer.getId())));
        assertEquals("Quiz already submitted", exception.getMessage());
    }
}
