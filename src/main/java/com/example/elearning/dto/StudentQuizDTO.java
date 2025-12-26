package com.example.elearning.dto;

import java.util.UUID;

public class StudentQuizDTO {
    private Long quizId;
    private UUID studentId;
    private int score;

    public StudentQuizDTO(Long quizId, UUID studentId, int score) {
        this.quizId = quizId;
        this.studentId = studentId;
        this.score = score;
    }

    // getters et setters
}