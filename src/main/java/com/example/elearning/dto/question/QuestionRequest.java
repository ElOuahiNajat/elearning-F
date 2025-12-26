package com.example.elearning.dto.question;

import com.example.elearning.dto.answer.AnswerRequest;
import lombok.Data;

import java.util.List;

@Data
public class QuestionRequest {
    private String text;
    private List<AnswerRequest> answers;
}
