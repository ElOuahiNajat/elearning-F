package com.example.elearning.dto.answer;

import lombok.Data;

@Data
public class AnswerResponse {
    private Long id;
    private String text;
    private boolean correct;
}
