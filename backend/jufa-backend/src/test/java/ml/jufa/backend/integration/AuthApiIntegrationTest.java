package ml.jufa.backend.integration;

import ml.jufa.backend.auth.dto.*;
import ml.jufa.backend.user.entity.UserType;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import com.fasterxml.jackson.databind.ObjectMapper;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.assertj.core.api.Assertions.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Auth API Integration Tests")
class AuthApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static String registeredUserId;
    private static String accessToken;
    private static String refreshToken;
    private static final String TEST_PHONE = "+22370001111";
    private static final String TEST_PASSWORD = "password123";

    @Test
    @Order(1)
    @DisplayName("POST /v1/auth/register - should register new user")
    void shouldRegisterNewUser() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setPhone(TEST_PHONE);
        request.setPassword(TEST_PASSWORD);
        request.setUserType(UserType.INDIVIDUAL);

        MvcResult result = mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").exists())
                .andExpect(jsonPath("$.data.phone").value(TEST_PHONE))
                .andReturn();

        String response = result.getResponse().getContentAsString();
        registeredUserId = objectMapper.readTree(response).get("data").get("userId").asText();
        
        assertThat(registeredUserId).isNotNull();
    }

    @Test
    @Order(2)
    @DisplayName("POST /v1/auth/register - should reject duplicate phone")
    void shouldRejectDuplicatePhone() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setPhone(TEST_PHONE);
        request.setPassword(TEST_PASSWORD);
        request.setUserType(UserType.INDIVIDUAL);

        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.code").value("JUFA-AUTH-006"));
    }

    @Test
    @Order(3)
    @DisplayName("POST /v1/auth/login - should reject unverified user")
    void shouldRejectUnverifiedUser() throws Exception {
        LoginRequest request = new LoginRequest();
        request.setPhone(TEST_PHONE);
        request.setPassword(TEST_PASSWORD);

        mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @Order(4)
    @DisplayName("POST /v1/auth/verify-otp - should reject invalid OTP")
    void shouldRejectInvalidOtp() throws Exception {
        VerifyOtpRequest request = new VerifyOtpRequest();
        request.setUserId(java.util.UUID.fromString(registeredUserId));
        request.setOtp("000000");

        mockMvc.perform(post("/v1/auth/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.code").value("JUFA-AUTH-002"));
    }

    @Test
    @Order(10)
    @DisplayName("POST /v1/auth/login - should login verified user")
    void shouldLoginVerifiedUser() throws Exception {
        RegisterRequest regRequest = new RegisterRequest();
        regRequest.setPhone("+22370002222");
        regRequest.setPassword("password123");
        regRequest.setUserType(UserType.INDIVIDUAL);

        MvcResult regResult = mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(regRequest)))
                .andExpect(status().isOk())
                .andReturn();

        String regResponse = regResult.getResponse().getContentAsString();
        String userId = objectMapper.readTree(regResponse).get("data").get("userId").asText();

        mockMvc.perform(post("/v1/auth/verify-otp")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"userId\":\"" + userId + "\",\"otp\":\"123456\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    @Order(11)
    @DisplayName("POST /v1/auth/refresh - should reject invalid refresh token")
    void shouldRejectInvalidRefreshToken() throws Exception {
        RefreshTokenRequest request = new RefreshTokenRequest();
        request.setRefreshToken("invalid-token");

        mockMvc.perform(post("/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    @Order(20)
    @DisplayName("POST /v1/auth/register - should validate phone format")
    void shouldValidatePhoneFormat() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setPhone("invalid");
        request.setPassword(TEST_PASSWORD);
        request.setUserType(UserType.INDIVIDUAL);

        mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }
}
