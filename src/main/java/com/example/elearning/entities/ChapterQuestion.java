//package com.example.elearning.entities;
//
//import jakarta.persistence.*;
//import lombok.AllArgsConstructor;
//import lombok.Getter;
//import lombok.NoArgsConstructor;
//import lombok.Setter;
//
//import java.util.ArrayList;
//import java.util.List;
//@Entity
//@Table(name = "chapter_question")
//@Getter
//@Setter
//@NoArgsConstructor
//@AllArgsConstructor
//public class ChapterQuestion {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    private String text;
//
//    @ManyToOne
//    @JoinColumn(name = "quiz_id")
//    private ChapterQuiz quiz;
//
//    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
//    private List<ChapterAnswer> answers = new ArrayList<>();
//}
//
