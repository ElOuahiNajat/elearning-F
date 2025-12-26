package com.example.elearning.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AnswerDTO {
    private Long id;
    private String text;
    private Boolean isCorrect;
}
