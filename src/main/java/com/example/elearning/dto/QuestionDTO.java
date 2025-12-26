package com.example.elearning.dto;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class QuestionDTO {
    private Long id;
    private String text;
    private List<AnswerDTO> answers;
}
