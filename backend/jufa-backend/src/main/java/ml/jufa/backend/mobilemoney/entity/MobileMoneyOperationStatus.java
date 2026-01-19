package ml.jufa.backend.mobilemoney.entity;

public enum MobileMoneyOperationStatus {
    PENDING,
    PROCESSING,
    AWAITING_CONFIRMATION,
    COMPLETED,
    FAILED,
    CANCELLED,
    EXPIRED
}
