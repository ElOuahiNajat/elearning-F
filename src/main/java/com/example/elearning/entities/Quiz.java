package com.example.elearning.entities;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "quiz")
public class Quiz {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @ManyToOne
    @JoinColumn(name = "course_id")
    private Course course;

    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<Question> questions;
}
