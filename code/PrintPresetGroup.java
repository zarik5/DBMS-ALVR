import java.sql.*;

public class PrintPresetGroup {
    public static void main(String[] args) {
        String DRIVER = "org.postgresql.Driver";

        String JDBC_URL = "jdbc:postgresql://localhost/alvr";
        String JDBC_USER = "postgres";
        String JDBC_PASSWORD = "123456";
        String OurSql = "SELECT id, name, owner, game, is_public FROM preset_group;";


        try {
            Class.forName(DRIVER);
            System.out.printf("Driver %s successfully registered.", DRIVER);

        } catch (ClassNotFoundException e) {
            System.out.printf("Failed to register driver %s\n %s", DRIVER, e);
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            try (Statement stmt = conn.createStatement()) {
                try (ResultSet rs = stmt.executeQuery(OurSql)) {
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        String name = rs.getString("name");
                        int owner = rs.getInt("owner");
                        String game = rs.getString("game");
                        boolean is_public = rs.getBoolean("is_public");
                        System.out.printf("%d, %s, %d, %s,", id, name, owner);
                        System.out.println(is_public);
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Database access error:");

            while (e != null) {
                System.out.printf("- Message: %s%n", e.getMessage());
                System.out.printf("- SQL status code: %s%n", e.getSQLState());
                System.out.printf("- SQL error code: %s%n", e.getErrorCode());
                System.out.printf("%n");
                e = e.getNextException();
            }
        }

    }
}
