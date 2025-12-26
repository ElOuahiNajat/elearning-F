package com.example.elearning.entities;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "course")
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String category;

    @Column(name = "video_url", columnDefinition = "TEXT")
    private String videoUrl;

    @Column(name = "pdf_url", columnDefinition = "TEXT")
    private String pdfUrl;

    @ManyToOne
    @JoinColumn(name = "teacher_id")
    private User teacher;
    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference

    private List<Chapter> chapters;
//    @ManyToOne
//    @JoinColumn(name = "course_id")
//    private Course course;

}
