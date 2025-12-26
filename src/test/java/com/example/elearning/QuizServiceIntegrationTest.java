//package com.example.elearning;
//
//import com.example.elearning.entities.Quiz;
//import com.example.elearning.repositories.QuizRepository;
//import com.example.elearning.services.QuizService;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.test.context.SpringBootTest;
//import org.springframework.transaction.annotation.Transactional;
//
//import static org.junit.jupiter.api.Assertions.*;
//
//@SpringBootTest
//@Transactional
//public class QuizServiceIntegrationTest {
//
//    @Autowired
//    private QuizService quizService;
//
//    @Autowired
//    private QuizRepository quizRepository;
//
//    @Test
//    public void testCreateAndFindQuiz() {
//        Quiz quiz = new Quiz();
//        quiz.setTitle("Test Integration Quiz");
//
//        quizRepository.save(quiz);
//
//        Quiz found = quizRepository.findById(quiz.getId()).orElse(null);
//        assertNotNull(found);
//        assertEquals("Test Integration Quiz", found.getTitle());
//    }
//}
