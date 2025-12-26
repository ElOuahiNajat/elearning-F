package com.example.elearning;

import com.example.elearning.dto.AiDocumentInfoDto;
import com.example.elearning.dto.ChapterRequest;
import com.example.elearning.entities.Chapter;
import com.example.elearning.entities.Course;
import com.example.elearning.exceptions.NotFoundException;
import com.example.elearning.repositories.ChapterRepository;
import com.example.elearning.repositories.CourseRepository;
import com.example.elearning.services.ChapterService;
import com.example.elearning.services.FileStorageService;
import com.example.elearning.services.PdfAiService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.springframework.mock.web.MockMultipartFile;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ChapterServiceTest {

    private ChapterRepository chapterRepository;
    private CourseRepository courseRepository;
    private FileStorageService fileStorageService;
    private PdfAiService pdfAiService;

    private ChapterService chapterService;

    @BeforeEach
    void setUp() {
        chapterRepository = mock(ChapterRepository.class);
        courseRepository = mock(CourseRepository.class);
        fileStorageService = mock(FileStorageService.class);
        pdfAiService = mock(PdfAiService.class);

        chapterService = new ChapterService(chapterRepository, courseRepository, fileStorageService, pdfAiService);
    }

    @Test
    void createChapter_shouldSaveChapter_whenValidRequest() {
        Long courseId = 1L;
        ChapterRequest request = new ChapterRequest();
        request.setTitle("Intro");
        request.setDescription("Description");
        request.setOrderNumber(1);

        Course course = new Course();
        course.setId(courseId);

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(chapterRepository.existsByCourseIdAndOrderNumber(courseId, 1)).thenReturn(false);
        when(chapterRepository.save(any(Chapter.class))).thenAnswer(i -> i.getArguments()[0]);

        Chapter chapter = chapterService.createChapter(courseId, request);

        assertNotNull(chapter);
        assertEquals("Intro", chapter.getTitle());
        assertEquals("Description", chapter.getDescription());
        assertEquals(course, chapter.getCourse());
        verify(chapterRepository, times(1)).save(chapter);
    }

    @Test
    void createChapter_shouldThrowNotFoundException_whenCourseNotFound() {
        Long courseId = 1L;
        ChapterRequest request = new ChapterRequest();

        when(courseRepository.findById(courseId)).thenReturn(Optional.empty());

        NotFoundException exception = assertThrows(NotFoundException.class,
                () -> chapterService.createChapter(courseId, request));

        assertTrue(exception.getMessage().contains("Cours non trouvé"));
    }

    @Test
    void createChapter_shouldStorePdf_whenPdfProvided() {
        Long courseId = 1L;
        MockMultipartFile pdfFile = new MockMultipartFile("pdf", "doc.pdf", "application/pdf", "content".getBytes());
        ChapterRequest request = new ChapterRequest();
        request.setPdf(pdfFile);
        request.setOrderNumber(1);

        Course course = new Course();
        course.setId(courseId);

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(chapterRepository.existsByCourseIdAndOrderNumber(courseId, 1)).thenReturn(false);
        when(pdfAiService.analyzePdf(pdfFile)).thenReturn(new AiDocumentInfoDto("AI Title", "AI Desc"));
        when(fileStorageService.storeFile(pdfFile)).thenReturn("stored.pdf");
        when(chapterRepository.save(any(Chapter.class))).thenAnswer(i -> i.getArguments()[0]);

        Chapter chapter = chapterService.createChapter(courseId, request);

        assertEquals("AI Title", chapter.getTitle());
        assertEquals("AI Desc", chapter.getDescription());
        assertEquals("stored.pdf", chapter.getPdfUrl());
    }

    @Test
    void deleteChapter_shouldDeleteFilesAndChapter() {
        Chapter chapter = new Chapter();
        chapter.setId(1L);
        chapter.setPdfUrl("file.pdf");
        chapter.setVideoUrl("video.mp4");

        when(chapterRepository.findById(1L)).thenReturn(Optional.of(chapter));

        chapterService.deleteChapter(1L);

        verify(fileStorageService).deleteFile("file.pdf");
        verify(fileStorageService).deleteFile("video.mp4");
        verify(chapterRepository).deleteById(1L);
    }

    @Test
    void deleteChapter_shouldThrowNotFoundException_whenChapterNotFound() {
        when(chapterRepository.findById(1L)).thenReturn(Optional.empty());
        assertThrows(NotFoundException.class, () -> chapterService.deleteChapter(1L));
    }
}
