//package com.example.elearning.entities;
//
//import jakarta.persistence.*;
//import lombok.AllArgsConstructor;
//import lombok.Getter;
//import lombok.NoArgsConstructor;
//import lombok.Setter;
//
//import java.time.LocalDateTime;
//import java.util.ArrayList;
//import java.util.List;
//
//@Entity
//@Table(name = "chapter_quiz")
//@Getter
//@Setter
//@NoArgsConstructor
//@AllArgsConstructor
//public class ChapterQuiz {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    private String title;
//
//    @ManyToOne
//    @JoinColumn(name = "chapter_id")
//    private Chapter chapter;
//
//    @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, orphanRemoval = true)
//    private List<ChapterQuestion> questions = new ArrayList<>();
//}
//
