package com.example.elearning.services;

import com.example.elearning.dto.AiDocumentInfoDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.apache.tika.Tika;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

@Service
@RequiredArgsConstructor
public class PdfAiService {

    private final Tika tika = new Tika();
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient client = HttpClient.newHttpClient();

    public AiDocumentInfoDto analyzePdf(MultipartFile pdf) {
        try {
            // 1️⃣ Extraire texte du PDF
            String content = tika.parseToString(pdf.getInputStream());

            if (content.length() > 6000) {
                content = content.substring(0, 6000); // sécurité tokens
            }

            // 2️⃣ Prompt AI
            String prompt = """
                Analyze the following course chapter content.
                Respond ONLY with valid JSON (no markdown):

                {
                  "title": "Chapter title",
                  "description": "Short chapter description"
                }

                Content:
                """ + content;

            var body = objectMapper.createObjectNode();
            body.put("model", "gemma3:1b");
            body.put("prompt", prompt);
            body.put("stream", false);
            body.put("format", "json");

            String json = objectMapper.writeValueAsString(body);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:11434/api/generate"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(json, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response =
                    client.send(request, HttpResponse.BodyHandlers.ofString());

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode aiResponse = objectMapper.readTree(root.get("response").asText());

            return new AiDocumentInfoDto(
                    aiResponse.path("title").asText("Untitled Chapter"),
                    aiResponse.path("description").asText("No description available")
            );

        } catch (Exception e) {
            throw new RuntimeException("AI PDF analysis failed", e);
        }
    }
}
