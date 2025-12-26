package com.example.elearning.controllers;

import com.example.elearning.services.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final FileStorageService fileStorageService;

    // Télécharger un fichier
    @GetMapping("/download/{fileName:.+}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String fileName) {
        Resource resource = fileStorageService.loadFileAsResource(fileName);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    // Prévisualiser un fichier (PDF, vidéo, image)
    @GetMapping("/preview/{fileName:.+}")
    public ResponseEntity<Resource> previewFile(@PathVariable String fileName) {
        Resource resource = fileStorageService.loadFileAsResource(fileName);
        String contentType = getContentType(fileName);

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    private String getContentType(String fileName) {
        if (fileName.endsWith(".pdf")) return "application/pdf";
        else if (fileName.endsWith(".mp4") || fileName.endsWith(".avi") || fileName.endsWith(".mov")) return "video/mp4";
        else if (fileName.endsWith(".webm")) return "video/webm";
        else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) return "image/jpeg";
        else if (fileName.endsWith(".png")) return "image/png";
        else return "application/octet-stream";
    }
}
