package ml.jufa.backend.mobilemoney.entity;

public enum MobileMoneyProvider {
    ORANGE_MONEY("Orange Money", "orange", "223"),
    MOOV_MONEY("Moov Money", "moov", "223");

    private final String displayName;
    private final String code;
    private final String countryCode;

    MobileMoneyProvider(String displayName, String code, String countryCode) {
        this.displayName = displayName;
        this.code = code;
        this.countryCode = countryCode;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getCode() {
        return code;
    }

    public String getCountryCode() {
        return countryCode;
    }
}
