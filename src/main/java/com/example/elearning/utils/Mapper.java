package com.example.elearning.utils;


import com.example.elearning.dto.course.CourseResponse;
import com.example.elearning.entities.Course;

public class Mapper {

    public static CourseResponse toCourseResponse(Course c) {
        if (c == null) return null;
        CourseResponse r = new CourseResponse();
        r.setId(c.getId());
        r.setTitle(c.getTitle());
        r.setDescription(c.getDescription());
        r.setCategory(c.getCategory());
        r.setVideoUrl(c.getVideoUrl());
        r.setPdfUrl(c.getPdfUrl());
//        if (c.getTeacher() != null) {
//            r.setTeacherId(c.getTeacher().getId());
//            r.setTeacherUsername(c.getTeacher().getUsername());
//        }
        return r;
    }
}

