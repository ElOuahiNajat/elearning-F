package com.example.elearning.authentication.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;

@Data
@Builder
@Getter
@AllArgsConstructor
public class AuthenticationResponse {
    private String accessToken;
}