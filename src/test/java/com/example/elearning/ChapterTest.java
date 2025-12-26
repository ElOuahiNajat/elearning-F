//package com.example.elearning;
//
//import com.example.elearning.entities.Chapter;
//import org.junit.jupiter.api.Test;
//import java.time.LocalDateTime;
//
//import static org.junit.jupiter.api.Assertions.*;
//
//class ChapterTest {
//
//    @Test
//    void testGettersAndSetters() {
//        Chapter chapter = new Chapter();
//        chapter.setTitle("Introduction");
//        chapter.setDescription("Chapitre d’introduction");
//        chapter.setOrderNumber(1);
//        chapter.setVideoUrl("https://video.com/intro");
//        chapter.setPdfUrl("https://docs.com/intro.pdf");
//
//        assertEquals("Introduction", chapter.getTitle());
//        assertEquals("Chapitre d’introduction", chapter.getDescription());
//        assertEquals(1, chapter.getOrderNumber());
//        assertEquals("https://video.com/intro", chapter.getVideoUrl());
//        assertEquals("https://docs.com/intro.pdf", chapter.getPdfUrl());
//    }
//
//    @Test
//    void testPrePersistSetsCreatedAt() {
//        Chapter chapter = new Chapter();
//        assertNull(chapter.getCreatedAt());
////        chapter.onCreate(); // simuler @PrePersist
//        assertNotNull(chapter.getCreatedAt());
//        assertTrue(chapter.getCreatedAt().isBefore(LocalDateTime.now().plusSeconds(1)));
//    }
//}
