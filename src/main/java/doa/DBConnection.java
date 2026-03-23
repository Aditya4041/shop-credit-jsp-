package doa;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static Connection conn = null;

    public static Connection getConnection() {
        try {
            // Step 1: Load the Oracle JDBC Driver
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Step 2: Create connection using JDBC URL, username, password
            if (conn == null || conn.isClosed()) {
                conn = DriverManager.getConnection(
                    "jdbc:oracle:thin:@192.168.1.152:1521:xe", // database URL
                    "spring",                              // username
                    "info123"                        // password
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}
  