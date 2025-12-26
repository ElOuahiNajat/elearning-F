package com.example.elearning.dto.enrollment;

import lombok.Data;

@Data
public class EnrollmentRequest {
    private Long studentId;
    private Long courseId;
    private Double progress; // optionnel pour update
}
