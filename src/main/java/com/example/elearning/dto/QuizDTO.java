package com.example.elearning.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class QuizDTO {
    private Long id;
    private String title;
    private LocalDateTime createdAt;
    private List<QuestionDTO> questions;
}
