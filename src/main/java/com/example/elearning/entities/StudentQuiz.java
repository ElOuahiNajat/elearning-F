package com.example.elearning.entities;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "student_quiz",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"student_id", "quiz_id"})})
public class StudentQuiz {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false)
    private UUID studentId;

    @ManyToOne
    @JoinColumn(name = "quiz_id")
    private Quiz quiz;

    @Column(nullable = false)
    private Integer score = 0;
}
