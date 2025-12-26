package com.example.elearning.entities;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "chapter",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"course_id", "order_number"})})
public class Chapter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToOne
    @JoinColumn(name = "course_id", nullable = false)
    @JsonBackReference
    private Course course;


    @Column(name = "order_number", nullable = false)
    private Integer orderNumber;

    @Column(name = "video_url", columnDefinition = "TEXT")
    private String videoUrl;

    @Column(name = "pdf_url", columnDefinition = "TEXT")
    private String pdfUrl;
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
//    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
//    private LocalDateTime createdAt;
}
