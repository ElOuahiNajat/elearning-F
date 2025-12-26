//package com.example.elearning.entities;
//
//import jakarta.persistence.*;
//import lombok.AllArgsConstructor;
//import lombok.Getter;
//import lombok.NoArgsConstructor;
//import lombok.Setter;
//
//@Entity
//@Table(name = "chapter_answer")
//@Getter
//@Setter
//@NoArgsConstructor
//@AllArgsConstructor
//public class ChapterAnswer {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    private String text;
//
//    @Column(name = "is_correct")
//    private Boolean isCorrect;
//
//    @ManyToOne
//    @JoinColumn(name = "question_id")
//    private ChapterQuestion question;
//}
