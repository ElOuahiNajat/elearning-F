package com.example.elearning.dto;


import com.example.elearning.enums.Role;

import java.util.UUID;

public record UserResponse(
        UUID id,
        String firstName,
        String lastName,
        String email,
        Role role
) {
}
