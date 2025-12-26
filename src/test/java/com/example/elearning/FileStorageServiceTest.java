package com.example.elearning;

import com.example.elearning.services.FileStorageService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.util.FileSystemUtils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class FileStorageServiceTest {

    @Autowired
    private FileStorageService fileStorageService;

    private final Path uploadDir = Paths.get("uploads/chapters");

    @Test
    void storeFile_shouldStoreFileSuccessfully() throws IOException {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test.txt",
                "text/plain",
                "Hello World".getBytes()
        );

        String fileName = fileStorageService.storeFile(file);

        assertTrue(uploadDir.resolve(fileName).toFile().exists());

        // Cleanup
        fileStorageService.deleteFile(fileName);
    }

    @Test
    void deleteFile_shouldRemoveFile() throws IOException {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test.txt",
                "text/plain",
                "Hello World".getBytes()
        );

        String fileName = fileStorageService.storeFile(file);
        fileStorageService.deleteFile(fileName);

        assertFalse(uploadDir.resolve(fileName).toFile().exists());
    }
}
