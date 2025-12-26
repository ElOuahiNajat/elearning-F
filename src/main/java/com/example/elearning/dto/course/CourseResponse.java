package com.example.elearning.dto.course;


import lombok.Data;

@Data
public class CourseResponse {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String videoUrl;
    private String pdfUrl;
    private Long teacherId;
    private String teacherUsername;
}

