// ChapterRequest.java - OPTION A: Utiliser une classe normale
package com.example.elearning.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class ChapterRequest {
//    @NotBlank(message = "Le titre est requis")
    private String title;

    private String description;

    @NotNull(message = "Le numéro d'ordre est requis")
    private Integer orderNumber;

    private MultipartFile video;

    private MultipartFile pdf;
}