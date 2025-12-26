package com.example.elearning.dto.question;

import com.example.elearning.dto.answer.AnswerResponse;
import lombok.Data;

import java.util.List;

@Data
public class QuestionResponse {
    private Long id;
    private String text;
    private List<AnswerResponse> answers;
}
