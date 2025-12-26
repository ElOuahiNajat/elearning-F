package com.example.elearning.controllers;


import com.example.elearning.dto.course.CourseRequest;
import com.example.elearning.dto.course.CourseResponse;
import com.example.elearning.entities.Course;
import com.example.elearning.services.CourseService;
import com.example.elearning.utils.Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/courses")
@CrossOrigin(origins = "http://localhost:5001") // Remplacez PORT par le port de Flutter Web

@RequiredArgsConstructor
public class CourseController {
    private final CourseService courseService;

    @PreAuthorize("hasRole('ADMIN') ")
    @PostMapping
    public ResponseEntity<CourseResponse> create(@RequestBody CourseRequest req) {
        Course c = courseService.create(req);
        return ResponseEntity.ok(Mapper.toCourseResponse(c));
    }

    @GetMapping
    public ResponseEntity<List<CourseResponse>> all() {
        return ResponseEntity.ok(courseService.getAll().stream()
                .map(Mapper::toCourseResponse).collect(Collectors.toList()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CourseResponse> one(@PathVariable Long id) {
        return ResponseEntity.ok(Mapper.toCourseResponse(courseService.getById(id)));
    }
    @PreAuthorize("hasRole('ADMIN') ")
    @PutMapping("/{id}")
    public ResponseEntity<CourseResponse> update(@PathVariable Long id, @RequestBody CourseRequest req) {
        return ResponseEntity.ok(Mapper.toCourseResponse(courseService.update(id, req)));
    }
    @GetMapping("/search")
    public ResponseEntity<List<CourseResponse>> search(@RequestParam String title) {
        List<CourseResponse> courses = courseService.searchByTitle(title)
                .stream()
                .map(Mapper::toCourseResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(courses);
    }

    @PreAuthorize("hasRole('USER') ")
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        courseService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // CourseController.java
    @GetMapping("/dashboard/total")
    public ResponseEntity<Long> getTotalCourses() {
        return ResponseEntity.ok(courseService.getTotalCourses());
    }

    @GetMapping("/dashboard/latest")
    public ResponseEntity<List<CourseResponse>> getLatestCourses(@RequestParam(defaultValue = "5") int limit) {
        List<CourseResponse> courses = courseService.getLatestCourses(limit).stream()
                .map(Mapper::toCourseResponse)
                .toList();
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/dashboard/most-chapters")
    public ResponseEntity<List<CourseResponse>> getCoursesWithMostChapters(@RequestParam(defaultValue = "5") int limit) {
        List<CourseResponse> courses = courseService.getCoursesWithMostChapters(limit).stream()
                .map(Mapper::toCourseResponse)
                .toList();
        return ResponseEntity.ok(courses);
    }

}
