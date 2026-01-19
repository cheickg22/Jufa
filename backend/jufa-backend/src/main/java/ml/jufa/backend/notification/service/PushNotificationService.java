package ml.jufa.backend.notification.service;

import com.google.firebase.messaging.*;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.notification.entity.Notification;
import ml.jufa.backend.notification.entity.NotificationType;
import ml.jufa.backend.notification.repository.NotificationRepository;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Service
@Slf4j
public class PushNotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final FirebaseMessaging firebaseMessaging;

    private final NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(Locale.FRANCE);

    @Autowired
    public PushNotificationService(
            NotificationRepository notificationRepository,
            UserRepository userRepository,
            @Autowired(required = false) FirebaseMessaging firebaseMessaging) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.firebaseMessaging = firebaseMessaging;
    }

    @Async
    @Transactional
    public void sendTransactionReceived(User receiver, BigDecimal amount, String senderPhone, String transactionRef) {
        String formattedAmount = formatAmount(amount);
        String title = "Paiement reçu";
        String body = String.format("Vous avez reçu %s de %s", formattedAmount, senderPhone);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.TRANSACTION_RECEIVED.name());
        data.put("transactionRef", transactionRef);
        data.put("amount", amount.toString());

        sendNotification(receiver, NotificationType.TRANSACTION_RECEIVED, title, body, data, transactionRef);
    }

    @Async
    @Transactional
    public void sendTransactionSent(User sender, BigDecimal amount, String receiverPhone, String transactionRef) {
        String formattedAmount = formatAmount(amount);
        String title = "Transfert effectué";
        String body = String.format("Vous avez envoyé %s à %s", formattedAmount, receiverPhone);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.TRANSACTION_SENT.name());
        data.put("transactionRef", transactionRef);
        data.put("amount", amount.toString());

        sendNotification(sender, NotificationType.TRANSACTION_SENT, title, body, data, transactionRef);
    }

    @Async
    @Transactional
    public void sendTransactionFailed(User user, BigDecimal amount, String reason, String transactionRef) {
        String formattedAmount = formatAmount(amount);
        String title = "Transaction échouée";
        String body = String.format("Le transfert de %s a échoué: %s", formattedAmount, reason);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.TRANSACTION_FAILED.name());
        data.put("transactionRef", transactionRef);

        sendNotification(user, NotificationType.TRANSACTION_FAILED, title, body, data, transactionRef);
    }

    @Async
    @Transactional
    public void sendKycApproved(User user, String kycLevel) {
        String title = "KYC Approuvé";
        String body = String.format("Félicitations! Votre compte a été vérifié au niveau %s", kycLevel);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.KYC_APPROVED.name());
        data.put("kycLevel", kycLevel);

        sendNotification(user, NotificationType.KYC_APPROVED, title, body, data, null);
    }

    @Async
    @Transactional
    public void sendKycRejected(User user, String reason) {
        String title = "Document KYC rejeté";
        String body = String.format("Votre document a été rejeté: %s. Veuillez soumettre à nouveau.", reason);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.KYC_REJECTED.name());

        sendNotification(user, NotificationType.KYC_REJECTED, title, body, data, null);
    }

    @Async
    @Transactional
    public void sendLimitWarning(User user, BigDecimal usedAmount, BigDecimal limit, int percentUsed) {
        String title = "Alerte limite";
        String body = String.format("Vous avez utilisé %d%% de votre limite mensuelle (%s/%s)",
                percentUsed, formatAmount(usedAmount), formatAmount(limit));

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.LIMIT_WARNING.name());
        data.put("percentUsed", String.valueOf(percentUsed));

        sendNotification(user, NotificationType.LIMIT_WARNING, title, body, data, null);
    }

    @Async
    @Transactional
    public void sendQrPaymentReceived(User merchant, BigDecimal amount, String payerPhone, String paymentId) {
        String formattedAmount = formatAmount(amount);
        String title = "Paiement QR reçu";
        String body = String.format("Vous avez reçu %s via QR Code de %s", formattedAmount, payerPhone);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.QR_PAYMENT_RECEIVED.name());
        data.put("paymentId", paymentId);
        data.put("amount", amount.toString());

        sendNotification(merchant, NotificationType.QR_PAYMENT_RECEIVED, title, body, data, paymentId);
    }

    @Async
    @Transactional
    public void sendMerchantRelationRequest(User retailer, String wholesalerName) {
        String title = "Nouvelle demande de partenariat";
        String body = String.format("%s souhaite vous ajouter comme détaillant", wholesalerName);

        Map<String, String> data = new HashMap<>();
        data.put("type", NotificationType.MERCHANT_RELATION_REQUEST.name());
        data.put("wholesalerName", wholesalerName);

        sendNotification(retailer, NotificationType.MERCHANT_RELATION_REQUEST, title, body, data, null);
    }

    private void sendNotification(User user, NotificationType type, String title, String body, 
                                   Map<String, String> data, String referenceId) {
        Notification notification = Notification.builder()
                .user(user)
                .type(type)
                .title(title)
                .body(body)
                .data(data != null ? data.toString() : null)
                .referenceId(referenceId)
                .build();

        notification = notificationRepository.save(notification);

        if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
            sendPushNotification(user.getFcmToken(), title, body, data, notification);
        } else {
            log.debug("No FCM token for user {}, notification saved to DB only", user.getPhone());
        }
    }

    private void sendPushNotification(String fcmToken, String title, String body,
                                       Map<String, String> data, Notification notification) {
        if (firebaseMessaging == null) {
            log.info("[FCM MOCK] Push notification: {} - {}", title, body);
            notification.setPushSent(true);
            notification.setPushSentAt(LocalDateTime.now());
            notificationRepository.save(notification);
            return;
        }

        try {
            Message message = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putAllData(data != null ? data : new HashMap<>())
                    .setAndroidConfig(AndroidConfig.builder()
                            .setPriority(AndroidConfig.Priority.HIGH)
                            .setNotification(AndroidNotification.builder()
                                    .setClickAction("FLUTTER_NOTIFICATION_CLICK")
                                    .setSound("default")
                                    .build())
                            .build())
                    .setApnsConfig(ApnsConfig.builder()
                            .setAps(Aps.builder()
                                    .setSound("default")
                                    .setBadge(1)
                                    .build())
                            .build())
                    .build();

            String response = firebaseMessaging.send(message);
            log.info("Push notification sent successfully: {}", response);

            notification.setPushSent(true);
            notification.setPushSentAt(LocalDateTime.now());
            notificationRepository.save(notification);

        } catch (FirebaseMessagingException e) {
            log.error("Failed to send push notification: {}", e.getMessage());
            if (e.getMessagingErrorCode() == MessagingErrorCode.UNREGISTERED) {
                log.info("Clearing invalid FCM token for user");
                User user = notification.getUser();
                user.setFcmToken(null);
                userRepository.save(user);
            }
        }
    }

    @Transactional
    public void registerFcmToken(User user, String fcmToken) {
        user.setFcmToken(fcmToken);
        userRepository.save(user);
        log.info("FCM token registered for user {}", user.getPhone());
    }

    private String formatAmount(BigDecimal amount) {
        return amount.setScale(0, java.math.RoundingMode.HALF_UP).toString() + " XOF";
    }
}
