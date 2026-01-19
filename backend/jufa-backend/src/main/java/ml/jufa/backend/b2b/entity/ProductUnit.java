package ml.jufa.backend.b2b.entity;

public enum ProductUnit {
    PIECE("Pièce"),
    CARTON("Carton"),
    PACK("Pack"),
    KG("Kilogramme"),
    LITRE("Litre"),
    SACK("Sac"),
    BOX("Boîte");

    private final String displayName;

    ProductUnit(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
