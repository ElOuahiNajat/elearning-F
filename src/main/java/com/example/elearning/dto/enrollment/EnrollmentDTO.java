package com.example.elearning.dto.enrollment;


import lombok.Data;

@Data
public class EnrollmentDTO {
    private Long id;
    private Long studentId;
    private Long courseId;
    private Double progress;
}

