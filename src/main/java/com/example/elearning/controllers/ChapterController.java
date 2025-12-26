package com.example.elearning.controllers;

import com.example.elearning.dto.AiDocumentInfoDto;
import com.example.elearning.dto.ChapterRequest;
import com.example.elearning.entities.Chapter;
import com.example.elearning.services.ChapterService;
import com.example.elearning.services.PdfAiService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/courses/{courseId}/chapters")
@CrossOrigin(origins = "http://localhost:5001") // Port Flutter Web
@RequiredArgsConstructor
public class ChapterController {

    private final ChapterService chapterService;
    private final PdfAiService pdfAiService;  // ✅ Injection du service
    @PreAuthorize("hasRole('ADMIN') ")

    @PostMapping
    public ResponseEntity<Chapter> createChapter(
            @PathVariable Long courseId,
            @Valid @ModelAttribute ChapterRequest request
    ) {
        Chapter createdChapter = chapterService.createChapter(courseId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdChapter);
    }
    @PreAuthorize("hasRole('ADMIN') ")

    @PostMapping("/analyze-pdf")
    public ResponseEntity<AiDocumentInfoDto> analyzePdf(
            @PathVariable Long courseId,
            @RequestParam("pdf") MultipartFile pdf
    ) {
        AiDocumentInfoDto aiInfo = pdfAiService.analyzePdf(pdf);
        return ResponseEntity.ok(aiInfo);
    }
    @PreAuthorize("hasRole('ADLIN') ")


    @PutMapping("/{chapterId}")
    public ResponseEntity<Chapter> updateChapter(
            @PathVariable Long courseId,
            @PathVariable Long chapterId,
            @Valid @ModelAttribute ChapterRequest request
    ) {
        Chapter updatedChapter = chapterService.updateChapter(chapterId, request);
        return ResponseEntity.ok(updatedChapter);
    }
    @PreAuthorize("hasRole('ADMIN') ")

    @DeleteMapping("/{chapterId}")
    public ResponseEntity<Void> deleteChapter(
            @PathVariable Long courseId,
            @PathVariable Long chapterId
    ) {
        chapterService.deleteChapter(chapterId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{chapterId}")
    public ResponseEntity<Chapter> getChapter(
            @PathVariable Long courseId,
            @PathVariable Long chapterId
    ) {
        Chapter chapter = chapterService.getChapterById(chapterId);
        return ResponseEntity.ok(chapter);
    }

    @GetMapping
    public ResponseEntity<List<Chapter>> getChaptersByCourse(
            @PathVariable Long courseId
    ) {
        List<Chapter> chapters = chapterService.getChaptersByCourse(courseId);
        return ResponseEntity.ok(chapters);
    }

    // Prévisualiser PDF d’un chapitre
    @GetMapping("/{chapterId}/pdf")
    public ResponseEntity<?> viewPdf(@PathVariable Long chapterId) {
        return chapterService.loadPdf(chapterId);
    }

    // Prévisualiser vidéo d’un chapitre
    @GetMapping("/{chapterId}/video")
    public ResponseEntity<?> streamVideo(@PathVariable Long chapterId) {
        return chapterService.loadVideo(chapterId);
    }
}
