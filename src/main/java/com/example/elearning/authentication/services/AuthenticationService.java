package com.example.elearning.authentication.services;
import java.util.List;


import com.example.elearning.authentication.dto.AuthenticationRequest;
import com.example.elearning.authentication.dto.AuthenticationResponse;
import com.example.elearning.entities.User;
import com.example.elearning.exceptions.UserNotFoundException;
import com.example.elearning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final MessageSource messageSource;

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UserNotFoundException(messageSource.getMessage("user.not.found.error", null, Locale.getDefault())));


        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("userId", user.getId());
        extraClaims.put("role", List.of("ROLE_" + user.getRole().name()));
        extraClaims.put("firstName", user.getFirstName());
        extraClaims.put("lastName", user.getLastName());
        String accessToken = jwtService.generateToken(extraClaims, user.getEmail());

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .build();
    }
}
