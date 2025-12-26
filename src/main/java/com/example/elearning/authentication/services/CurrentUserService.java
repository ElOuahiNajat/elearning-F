package com.example.elearning.authentication.services;


import com.example.elearning.entities.User;
import com.example.elearning.exceptions.UserNotFoundException;
import com.example.elearning.repositories.CourseRepository;
import com.example.elearning.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.UUID;

@Service("currentUserService")
@RequiredArgsConstructor
public class CurrentUserService {

    private final UserRepository userRepository;
    private final MessageSource messageSource;
    private final CourseRepository courseRepository;

    public User getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null) {
            Object principal = authentication.getPrincipal();

            if (principal instanceof org.springframework.security.oauth2.jwt.Jwt) {
                org.springframework.security.oauth2.jwt.Jwt jwt = (org.springframework.security.oauth2.jwt.Jwt) principal;
                String email = jwt.getClaim("sub"); 
                return userRepository.findByEmail(email)
                        .orElseThrow(() -> new UserNotFoundException(
                                messageSource.getMessage("user.not.found.error", null, Locale.getDefault())
                        ));
            }
        }

        throw new UserNotFoundException(
                messageSource.getMessage("user.not.found.error", null, Locale.getDefault())
        );
    }

//    public boolean isOwnerOfDocument(User user, UUID documentId) {
//        return documentRepository.findById(documentId)
//                .map(doc -> doc.getOwner().getId().equals(user.getId()))
//                .orElse(false);
//    }

    public boolean isAdmin(User user) {
        return user.getRole().name().equals("ADMIN");
    }
}
