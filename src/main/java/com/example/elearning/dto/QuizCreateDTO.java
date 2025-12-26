package com.example.elearning.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class QuizCreateDTO {
    private String title;
    private Long courseId; // ici on reçoit le courseId depuis le JSON
}
