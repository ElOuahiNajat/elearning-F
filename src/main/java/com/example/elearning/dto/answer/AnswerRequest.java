package com.example.elearning.dto.answer;

import lombok.Data;

@Data
public class AnswerRequest {
    private String text;
    private boolean correct;
}
