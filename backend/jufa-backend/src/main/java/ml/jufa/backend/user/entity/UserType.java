package ml.jufa.backend.user.entity;

public enum UserType {
    INDIVIDUAL,      // Particulier (B2C)
    WHOLESALER,      // Grossiste (B2B Fournisseur)
    RETAILER,        // Détaillant / Boutiquier
    AGENT,           // Agent JUFA
    MERCHANT,        // Commerçant générique (legacy)
    ADMIN,           // Administrateur JUFA
    BANK_ADMIN,      // Administrateur Banque Partenaire
    SUPER_ADMIN      // Super Administrateur
}
