package com.example.elearning.services;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.nio.file.*;
import java.util.UUID;

@Service
public class ChapterFileStorageService {

    private final Path uploadDir = Paths.get("uploads/chapters");

    public ChapterFileStorageService() {
        try {
            Files.createDirectories(uploadDir);
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory!", e);
        }
    }

    public String store(MultipartFile file) {
        try {
            if (file.isEmpty()) throw new RuntimeException("File is empty");

            String fileName = UUID.randomUUID() + getFileExtension(file.getOriginalFilename());
            Path target = uploadDir.resolve(fileName).normalize().toAbsolutePath();

            if (!target.getParent().equals(uploadDir.toAbsolutePath())) {
                throw new RuntimeException("Cannot store file outside upload directory");
            }

            try (InputStream inputStream = file.getInputStream()) {
                Files.copy(inputStream, target, StandardCopyOption.REPLACE_EXISTING);
            }

            return "/uploads/chapters/" + fileName;
        } catch (IOException e) {
            throw new RuntimeException("Could not store file", e);
        }
    }

    private String getFileExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return (dot == -1) ? "" : fileName.substring(dot);
    }

    public Resource loadAsResource(String fileName) {
        try {
            Path file = uploadDir.resolve(fileName);
            Resource resource = new UrlResource(file.toUri());
            if (resource.exists() && resource.isReadable()) return resource;
            else throw new RuntimeException("File not readable: " + fileName);
        } catch (MalformedURLException e) {
            throw new RuntimeException("File not found: " + fileName, e);
        }
    }
}
