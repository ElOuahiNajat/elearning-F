package com.example.elearning.exceptions;

import jakarta.validation.ConstraintViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.HashMap;
import java.util.Map;

public interface MethodArgumentNotValidExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    default ResponseEntity<?> handleMethodArgumentNotValidException(
            MethodArgumentNotValidException ex
    ) {
        var errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.badRequest().body(Map.of("errors", errors));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    default ResponseEntity<?> handleMethodArgumentNotValidException(
            ConstraintViolationException ex
    ) {
        var errors = new HashMap<>();
        ex.getConstraintViolations().forEach((error) -> {
            String fieldName = error.getPropertyPath().toString().replaceFirst("^[^.]*\\.[^.]*\\.", "");
            String errorMessage = error.getMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.badRequest().body(Map.of("errors", errors));
    }
}
