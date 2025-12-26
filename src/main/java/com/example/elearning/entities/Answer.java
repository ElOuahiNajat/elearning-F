package com.example.elearning.entities;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "answer")
public class Answer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String text;

    @Column(name = "is_correct", nullable = false)
    private Boolean isCorrect = false;

    @ManyToOne
    @JoinColumn(name = "question_id")
    @JsonBackReference
    private Question question;
}
