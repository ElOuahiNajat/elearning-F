package com.example.elearning.dto.quiz;

import com.example.elearning.dto.question.QuestionResponse;
import lombok.Data;

import java.util.List;

@Data
public class QuizResponse {
    private Long id;
    private String title;
    private List<QuestionResponse> questions;
}
