package com.example.elearning.dto.rating;


import lombok.Data;

@Data
public class RatingDTO {
    private Long id;
    private Integer rating;
    private String comment;
    private Long studentId;
    private Long courseId;
}
