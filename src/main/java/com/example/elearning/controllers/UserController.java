package com.example.elearning.controllers;

import com.example.elearning.dto.CreateUserRequest;
import com.example.elearning.dto.UpdateUserRequest;
import com.example.elearning.dto.UserRequest;
import com.example.elearning.dto.UserResponse;
import com.example.elearning.entities.User;
import com.example.elearning.enums.Role;
import com.example.elearning.exceptions.MethodArgumentNotValidExceptionHandler;
import com.example.elearning.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.ResponseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:5001") // Port Flutter Web

public class UserController implements MethodArgumentNotValidExceptionHandler {
    private final UserService userService;
    @GetMapping
    public ResponseEntity<Page<UserResponse>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size
    ) {
        Pageable pageable = org.springframework.data.domain.PageRequest.of(page, size);
        Page<UserResponse> usersPage = userService.getUsers(pageable);
        return ResponseEntity.ok().body(usersPage);
    }

    @PostMapping
    public ResponseEntity<Void> createUser(@RequestBody @Valid CreateUserRequest request) {
        userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/export/csv")
    public ResponseEntity<InputStreamResource> exportUsersToCSV() {
        InputStreamResource resource = new InputStreamResource(userService.exportUsersToCSV());

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=users.csv");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(resource);
    }


    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateUserRequest request
    ) {
        UserResponse updatedUser = userService.updateUser(id, request);
        return ResponseEntity.ok(updatedUser);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/dashboard/total")
    public ResponseEntity<Long> getTotalUsers() {
        return ResponseEntity.ok(userService.getTotalUsers());
    }

    // Nombre d'utilisateurs par rôle
    @GetMapping("/dashboard/by-role")
    public ResponseEntity<Map<Role, Long>> getUsersByRole() {
        return ResponseEntity.ok(userService.getUserCountByRole());
    }


    // Derniers utilisateurs
    @GetMapping("/dashboard/latest")
    public ResponseEntity<List<UserResponse>> getLatestUsers(@RequestParam(defaultValue = "5") int limit) {
        return ResponseEntity.ok(userService.getLatestUsers(limit));
    }
}
