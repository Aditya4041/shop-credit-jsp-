package doa;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;
import java.security.SecureRandom;

/**
 * AES-256 Encryption / Decryption Utility
 * Used for storing admin passwords securely in the database.
 *
 * KEY MUST match what was used when passwords were first encrypted.
 * Change SECRET_KEY only during initial setup — never after.
 */
public class AESEncryption {

    private static final String ALGORITHM  = "AES";

    /**
     * 32-character key  →  256-bit AES key.
     * ⚠ KEEP THIS SECRET — do not expose in logs or UI.
     */
    private static final String SECRET_KEY = "MySecretKey12345MySecretKey12345";

    // ── Public API ─────────────────────────────────────────────────────────────

    /** Encrypt plain text → Base64 encoded cipher text */
    public static String encrypt(String plainText) throws Exception {
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.ENCRYPT_MODE, buildKey());
        return Base64.getEncoder().encodeToString(cipher.doFinal(plainText.getBytes("UTF-8")));
    }

    /** Decrypt Base64 encoded cipher text → plain text */
    public static String decrypt(String encryptedText) throws Exception {
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.DECRYPT_MODE, buildKey());
        byte[] decoded = Base64.getDecoder().decode(encryptedText);
        return new String(cipher.doFinal(decoded), "UTF-8");
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private static SecretKey buildKey() {
        byte[] raw     = SECRET_KEY.getBytes();
        byte[] keyBytes = new byte[32];
        System.arraycopy(raw, 0, keyBytes, 0, Math.min(raw.length, 32));
        return new SecretKeySpec(keyBytes, ALGORITHM);
    }

    /** Utility — run once to generate a strong random key */
    public static String generateRandomKey() throws Exception {
        KeyGenerator kg = KeyGenerator.getInstance(ALGORITHM);
        kg.init(256, new SecureRandom());
        return Base64.getEncoder().encodeToString(kg.generateKey().getEncoded());
    }

    // ── Quick test main ────────────────────────────────────────────────────────

    public static void main(String[] args) throws Exception {
        String plain     = (args.length > 0) ? args[0] : "admin123";
        String encrypted = encrypt(plain);
        String decrypted = decrypt(encrypted);

        System.out.println("Plain     : " + plain);
        System.out.println("Encrypted : " + encrypted);
        System.out.println("Decrypted : " + decrypted);
        System.out.println("Match     : " + plain.equals(decrypted));
    }
}
