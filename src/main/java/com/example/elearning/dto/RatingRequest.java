package com.example.elearning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class RatingRequest {

    @JsonProperty("score")
    private Integer rating;

    private String comment;
    private Long courseId;
}
