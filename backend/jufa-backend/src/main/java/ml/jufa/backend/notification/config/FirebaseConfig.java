package ml.jufa.backend.notification.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.enabled:false}")
    private boolean firebaseEnabled;

    @Value("${firebase.credentials-file:firebase-service-account.json}")
    private String credentialsFile;

    @PostConstruct
    public void initialize() {
        if (!firebaseEnabled) {
            log.info("Firebase is disabled. Push notifications will be logged only.");
            return;
        }

        try {
            if (FirebaseApp.getApps().isEmpty()) {
                ClassPathResource resource = new ClassPathResource(credentialsFile);
                InputStream serviceAccount = resource.getInputStream();

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
                log.info("Firebase initialized successfully");
            }
        } catch (IOException e) {
            log.warn("Failed to initialize Firebase: {}. Push notifications will be logged only.", e.getMessage());
        }
    }

    @Bean
    public FirebaseMessaging firebaseMessaging() {
        if (!firebaseEnabled || FirebaseApp.getApps().isEmpty()) {
            return null;
        }
        return FirebaseMessaging.getInstance();
    }
}
