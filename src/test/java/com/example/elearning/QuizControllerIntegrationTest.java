package com.example.elearning;

import com.example.elearning.entities.Quiz;
import com.example.elearning.repositories.QuizRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class QuizControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private QuizRepository quizRepository;

    @Test
    public void testGetQuizEndpoint() throws Exception {
        Quiz quiz = new Quiz();
        quiz.setTitle("Quiz API Test");
        quizRepository.save(quiz);

        mockMvc.perform(get("/api/quiz/" + quiz.getId()))
                .andExpect(status().isOk());
    }
}
