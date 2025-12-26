//package com.example.elearning.config;
//
//import org.springframework.context.annotation.Configuration;
//import org.springframework.web.servlet.config.annotation.CorsRegistry;
//import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
//import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
//
//import java.nio.file.Paths;
//
//@Configuration
//public class WebConfig implements WebMvcConfigurer {
//
//    // ✅ GARDER : accès aux fichiers uploadés (PDF, vidéos, images)
//    @Override
//    public void addResourceHandlers(ResourceHandlerRegistry registry) {
//        String uploadPath = Paths.get("uploads")
//                .toAbsolutePath()
//                .toUri()
//                .toString();
//
//        registry.addResourceHandler("/uploads/**")
//                .addResourceLocations(uploadPath);
//    }
//
//    // ✅ AJOUTER : CORS pour Flutter Web (TOUT AUTORISÉ)
//    @Override
//    public void addCorsMappings(CorsRegistry registry) {
//        registry.addMapping("/api/**")
//                .allowedOrigins("*") // <-- Autorise toutes les origines pour dev
//                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
//                .allowedHeaders("*")
//                .allowCredentials(false); // <-- mettre false
//    }
//}

// WebConfig.java - Mise à jour
package com.example.elearning.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;
import java.util.List;

@Configuration
public class WebConfig implements WebMvcConfigurer {

//    @Bean
//    public ObjectMapper objectMapper() {
//        return new ObjectMapper();
//    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String uploadPath = Paths.get("uploads")
                .toAbsolutePath()
                .toUri()
                .toString();

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(uploadPath);
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false);
    }

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
//        converters.add(new MappingJackson2HttpMessageConverter(objectMapper()));
    }
}