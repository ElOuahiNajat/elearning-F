package com.example.elearning.dto;

import com.example.elearning.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateUserRequest(
        @NotBlank(message = "First name is required")
        @Size(max = 100)
        String firstName,

        @NotBlank(message = "Last name is required")
        @Size(max = 100)
        String lastName,

        @NotBlank(message = "Email is required")
        @Email(message = "Invalid email format")
        String email,

        Role role
) {}
