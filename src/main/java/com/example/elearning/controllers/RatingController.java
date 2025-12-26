package com.example.elearning.controllers;

import com.example.elearning.dto.RatingRequest;
import com.example.elearning.entities.Rating;
import com.example.elearning.services.RatingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/ratings")
@RequiredArgsConstructor
public class RatingController {

    private final RatingService ratingService;

    @PostMapping
    public ResponseEntity<Rating> addRating(
            @RequestBody RatingRequest request,
            Principal principal
    ) {
        return ResponseEntity.ok(
                ratingService.addRating(principal.getName(), request)
        );
    }

    @GetMapping("/course/{courseId}")
    public ResponseEntity<List<Rating>> getRatingsByCourse(
            @PathVariable Long courseId
    ) {
        return ResponseEntity.ok(
                ratingService.getRatingsByCourse(courseId)
        );
    }
}
