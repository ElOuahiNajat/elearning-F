package com.example.elearning;

import com.example.elearning.dto.CreateUserRequest;
import com.example.elearning.dto.UpdateUserRequest;
import com.example.elearning.dto.UserResponse;
import com.example.elearning.entities.User;
import com.example.elearning.enums.Role;
import com.example.elearning.exceptions.UserNotFoundException;
import com.example.elearning.repositories.UserRepository;
import com.example.elearning.services.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.context.MessageSource;
import org.springframework.data.domain.*;

import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private MessageSource messageSource;
    @Mock
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private User user;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        user = new User();
        user.setId(UUID.randomUUID());
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("john@example.com");
        user.setPassword("password");
        user.setRole(Role.USER);
    }

    @Test
    void testCreateUser() {
        CreateUserRequest request = new CreateUserRequest("Jane", "Smith", "jane@example.com", "123456", Role.ADMIN);

        when(passwordEncoder.encode(request.password())).thenReturn("hashed123");
        when(userRepository.save(any(User.class))).thenReturn(user);

        userService.createUser(request);

        verify(userRepository, times(1)).save(any(User.class));
        verify(passwordEncoder, times(1)).encode("123456");
    }

    @Test
    void testUpdateUser_Success() {
        UpdateUserRequest request = new UpdateUserRequest("Jane", "Smith", "jane@example.com", Role.ADMIN);
        when(userRepository.findById(user.getId())).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        UserResponse response = userService.updateUser(user.getId(), request);

        assertEquals("Jane", response.firstName());
        assertEquals("Smith", response.lastName());
        assertEquals(Role.ADMIN, response.role());
        verify(userRepository).save(user);
    }

    @Test
    void testUpdateUser_NotFound() {
        UUID id = UUID.randomUUID();
        UpdateUserRequest request = new UpdateUserRequest("Jane", "Smith", "jane@example.com", Role.ADMIN);

        when(userRepository.findById(id)).thenReturn(Optional.empty());
        when(messageSource.getMessage(anyString(), any(), any(Locale.class))).thenReturn("User not found");

        assertThrows(UserNotFoundException.class, () -> userService.updateUser(id, request));
    }

    @Test
    void testDeleteUser() {
        UUID id = UUID.randomUUID();
        doNothing().when(userRepository).deleteById(id);

        userService.deleteUser(id);

        verify(userRepository, times(1)).deleteById(id);
    }

    @Test
    void testGetUsers() {
        Pageable pageable = PageRequest.of(0, 10);
        Page<User> page = new PageImpl<>(List.of(user));
        when(userRepository.findAll(pageable)).thenReturn(page);

        Page<UserResponse> result = userService.getUsers(pageable);

        assertEquals(1, result.getContent().size());
        assertEquals("John", result.getContent().get(0).firstName());
    }

    @Test
    void testGetTotalUsers() {
        when(userRepository.count()).thenReturn(5L);

        long total = userService.getTotalUsers();

        assertEquals(5, total);
    }

    @Test
    void testGetUserCountByRole() {
        when(userRepository.findAll()).thenReturn(List.of(user));

        var result = userService.getUserCountByRole();

        assertEquals(1, result.get(Role.USER));
    }

    @Test
    void testGetLatestUsers() {
        when(userRepository.findAll(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(user)));

        List<UserResponse> latest = userService.getLatestUsers(5);

        assertEquals(1, latest.size());
        assertEquals("John", latest.get(0).firstName());
    }
}

