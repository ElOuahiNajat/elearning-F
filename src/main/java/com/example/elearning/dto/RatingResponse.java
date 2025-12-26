package com.example.elearning.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RatingResponse {
    private Long id;
    private Integer rating;
    private String comment;
    private String studentName;
}
