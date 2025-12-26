package com.example.elearning.dto.quiz;

import com.example.elearning.dto.question.QuestionRequest;
import lombok.Data;

import java.util.List;

@Data
public class QuizRequest {
    private String title;
    private List<QuestionRequest> questions;
}
