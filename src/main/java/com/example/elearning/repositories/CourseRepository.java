package com.example.elearning.repositories;

import java.util.List;

import com.example.elearning.entities.Course;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRepository extends JpaRepository<Course, Long> {
    List<Course> findByTitleContainingIgnoreCase(String title);
    long count();
    List<Course> findByCategoryInAndIdNotIn(List<String> categories, List<Long> excludedCourseIds);

}

