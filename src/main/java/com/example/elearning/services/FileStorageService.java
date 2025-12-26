package com.example.elearning.services;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@Service
public class FileStorageService {

    private final Path uploadDir = Paths.get("uploads/chapters"); // Dossier où sont stockés les fichiers

    public String storeFile(MultipartFile file) {
        try {
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String fileName = java.util.UUID.randomUUID() + "-" + file.getOriginalFilename();
            Path targetLocation = uploadDir.resolve(fileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
            return fileName;
        } catch (IOException e) {
            throw new RuntimeException("Impossible de stocker le fichier : " + file.getOriginalFilename(), e);
        }
    }
    public void deleteFile(String fileName) {
        try {
            Path filePath = uploadDir.resolve(fileName).normalize();
            if (Files.exists(filePath)) {
                Files.delete(filePath);
            } else {
                throw new RuntimeException("Fichier introuvable pour suppression : " + fileName);
            }
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la suppression du fichier : " + fileName, e);
        }
    }

    public Resource loadFileAsResource(String fileName) {
        try {
            Path filePath = uploadDir.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                return resource;
            } else {
                throw new RuntimeException("Fichier introuvable ou non lisible : " + fileName);
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("Chemin de fichier invalide : " + fileName, e);
        }
    }
}
