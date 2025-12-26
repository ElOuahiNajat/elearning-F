// ChapterService.java
package com.example.elearning.services;

import com.example.elearning.dto.AiDocumentInfoDto;
import com.example.elearning.dto.ChapterRequest;
import com.example.elearning.entities.Chapter;
import com.example.elearning.entities.Course;
import com.example.elearning.exceptions.NotFoundException;
import com.example.elearning.repositories.ChapterRepository;
import com.example.elearning.repositories.CourseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChapterService {

    private final ChapterRepository chapterRepository;
    private final CourseRepository courseRepository;
    private final FileStorageService fileStorageService;
    private final PdfAiService pdfAiService;

    @Transactional
    public Chapter createChapter(Long courseId, ChapterRequest request) {

        log.info("Creating chapter for courseId: {}", courseId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new NotFoundException(
                        "Cours non trouvé avec l'ID: " + courseId
                ));

        // Vérifier unicité orderNumber
        if (chapterRepository.existsByCourseIdAndOrderNumber(courseId, request.getOrderNumber())) {
            throw new RuntimeException(
                    "Le numéro d'ordre " + request.getOrderNumber() +
                            " existe déjà pour ce cours."
            );
        }

        Chapter chapter = new Chapter();
        chapter.setCourse(course);
        chapter.setOrderNumber(request.getOrderNumber());

        // ===============================
        // 1️⃣ TITRE & DESCRIPTION (manuel)
        // ===============================
        chapter.setTitle(request.getTitle());
        chapter.setDescription(request.getDescription());

        // ===============================
        // 2️⃣ PDF → AI auto-fill (si besoin)
        // ===============================
        if (request.getPdf() != null && !request.getPdf().isEmpty()) {

            // 🧠 Analyse AI du PDF
            AiDocumentInfoDto aiInfo = pdfAiService.analyzePdf(request.getPdf());

            // ⚠️ On remplit SEULEMENT si vide
            if (chapter.getTitle() == null || chapter.getTitle().isBlank()) {
                chapter.setTitle(aiInfo.getTitle());
            }

            if (chapter.getDescription() == null || chapter.getDescription().isBlank()) {
                chapter.setDescription(aiInfo.getDescription());
            }

            // 📁 Stockage du PDF
            String pdfUrl = fileStorageService.storeFile(request.getPdf());
            chapter.setPdfUrl(pdfUrl);
        }

        // ===============================
        // 3️⃣ Vidéo (optionnelle)
        // ===============================
        if (request.getVideo() != null && !request.getVideo().isEmpty()) {
            String videoUrl = fileStorageService.storeFile(request.getVideo());
            chapter.setVideoUrl(videoUrl);
        }

        Chapter savedChapter = chapterRepository.save(chapter);
        log.info("Chapter created successfully with ID: {}", savedChapter.getId());

        return savedChapter;
    }

    @Transactional
    public Chapter updateChapter(Long id, ChapterRequest request) {
        log.info("Updating chapter ID: {}", id);

        Chapter chapter = chapterRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Chapitre non trouvé avec l'ID: " + id));

        // Si l'orderNumber change, vérifier s'il n'existe pas déjà
        if (request.getOrderNumber() != null &&
                !request.getOrderNumber().equals(chapter.getOrderNumber())) {

            boolean orderExists = chapterRepository.existsByCourseIdAndOrderNumber(
                    chapter.getCourse().getId(), request.getOrderNumber());

            if (orderExists) {
                throw new RuntimeException("Le numéro d'ordre " + request.getOrderNumber() +
                        " existe déjà pour ce cours. Veuillez choisir un autre numéro.");
            }
        }

        if (request.getTitle() != null) {
            chapter.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            chapter.setDescription(request.getDescription());
        }
        if (request.getOrderNumber() != null) {
            chapter.setOrderNumber(request.getOrderNumber());
        }

        // Gérer les fichiers
        if (request.getVideo() != null && !request.getVideo().isEmpty()) {
            // Supprimer l'ancien fichier s'il existe
            if (chapter.getVideoUrl() != null) {
                fileStorageService.deleteFile(chapter.getVideoUrl());
            }
            String videoUrl = fileStorageService.storeFile(request.getVideo());
            chapter.setVideoUrl(videoUrl);
        }

        if (request.getPdf() != null && !request.getPdf().isEmpty()) {
            // Supprimer l'ancien fichier s'il existe
            if (chapter.getPdfUrl() != null) {
                fileStorageService.deleteFile(chapter.getPdfUrl());
            }
            String pdfUrl = fileStorageService.storeFile(request.getPdf());
            chapter.setPdfUrl(pdfUrl);
        }

        return chapterRepository.save(chapter);
    }

    @Transactional
    public void deleteChapter(Long id) {
        Chapter chapter = chapterRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Chapitre non trouvé avec l'ID: " + id));

        // Supprimer les fichiers associés
        if (chapter.getVideoUrl() != null) {
            fileStorageService.deleteFile(chapter.getVideoUrl());
        }
        if (chapter.getPdfUrl() != null) {
            fileStorageService.deleteFile(chapter.getPdfUrl());
        }

        chapterRepository.deleteById(id);
        log.info("Chapter deleted successfully: {}", id);
    }

    public Chapter getChapterById(Long id) {
        return chapterRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Chapitre non trouvé avec l'ID: " + id));
    }

    public List<Chapter> getChaptersByCourse(Long courseId) {
        log.info("Getting chapters for courseId: {}", courseId);
        return chapterRepository.findByCourseId(courseId);
    }

    public Long countChaptersByCourse(Long courseId) {
        return chapterRepository.countByCourseId(courseId);
    }

    public ResponseEntity<Resource> loadPdf(Long chapterId) {
        Chapter chapter = getChapterById(chapterId);

        if (chapter.getPdfUrl() == null) {
            throw new NotFoundException("Aucun PDF pour ce chapitre");
        }

        Resource resource = fileStorageService.loadFileAsResource(chapter.getPdfUrl());

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"chapter.pdf\"")
                .body(resource);
    }
    public ResponseEntity<Resource> loadVideo(Long chapterId) {
        Chapter chapter = getChapterById(chapterId);

        if (chapter.getVideoUrl() == null) {
            throw new NotFoundException("Aucune vidéo pour ce chapitre");
        }

        Resource resource = fileStorageService.loadFileAsResource(chapter.getVideoUrl());

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("video/mp4"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline")
                .body(resource);
    }


}