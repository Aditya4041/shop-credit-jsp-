package doa;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * ShopConfig — reads the shop identity (English + Marathi name) from the
 * shop_config table where code = '0001' and caches it for the JVM lifetime.
 *
 * Usage in JSP:
 *   <%@ page import="doa.ShopConfig" %>
 *   <%  ShopConfig shop = ShopConfig.getInstance(); %>
 *   <%= shop.getEnglishName() %>   <!-- Mauali Tredars -->
 *   <%= shop.getMarathiName()  %>  <!-- माऊली ट्रेडर्स  -->
 *
 * Call ShopConfig.reload() if the name is updated in the DB at runtime.
 */
public class ShopConfig {

    // ── Primary shop record code — never change ──────────────────────────────
    private static final String PRIMARY_CODE = "0001";

    // ── Safe fallbacks if DB is unreachable ──────────────────────────────────
    private static final String FALLBACK_EN = "Mauali Tredars";
    private static final String FALLBACK_MR = "माऊली ट्रेडर्स";

    // ── Singleton ─────────────────────────────────────────────────────────────
    private static volatile ShopConfig instance;

    private final String englishName;
    private final String marathiName;

    // ── Private constructor — loads from DB ───────────────────────────────────
    private ShopConfig() {
        String en = FALLBACK_EN;
        String mr = FALLBACK_MR;

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT english_name, marathi_name FROM shop_config WHERE code = ?");
            ps.setString(1, PRIMARY_CODE);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String dbEn = rs.getString("english_name");
                String dbMr = rs.getString("marathi_name");
                if (dbEn != null && !dbEn.trim().isEmpty()) en = dbEn.trim();
                if (dbMr != null && !dbMr.trim().isEmpty()) mr = dbMr.trim();
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            // Keep fallback values; log but do not crash the app
            System.err.println("[ShopConfig] Could not load from DB — using fallback. " + e.getMessage());
        }

        this.englishName = en;
        this.marathiName = mr;
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /** Returns the cached ShopConfig instance, creating it if needed. */
    public static ShopConfig getInstance() {
        if (instance == null) {
            synchronized (ShopConfig.class) {
                if (instance == null) {
                    instance = new ShopConfig();
                }
            }
        }
        return instance;
    }

    /**
     * Force a fresh DB read on the next call to getInstance().
     * Call this after updating shop_config in the database.
     */
    public static synchronized void reload() {
        instance = null;
    }

    /** e.g. "Mauali Tredars" */
    public String getEnglishName() {
        return englishName;
    }

    /** e.g. "माऊली ट्रेडर्स" */
    public String getMarathiName() {
        return marathiName;
    }

    /**
     * Returns the English name safe for embedding inside a JavaScript string
     * (double-quotes and backslashes escaped).
     */
    public String getEnglishNameJs() {
        return englishName.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    /**
     * Returns the Marathi name safe for embedding inside a JavaScript string.
     */
    public String getMarathiNameJs() {
        return marathiName.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    @Override
    public String toString() {
        return "ShopConfig{en='" + englishName + "', mr='" + marathiName + "'}";
    }
}
