package com.example.elearning.dto.course;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
@JsonIgnoreProperties(ignoreUnknown = true) // <-- Ajouter cette annotation

@Data
public class CourseRequest {
    private String title;
    private String description;
    private String category;
    private String videoUrl;
    private String pdfUrl;
    private Long teacherId; // optional
}

