import java.sql.*;
import java.util.Scanner;
import java.util.List;
import java.util.ArrayList;

interface QueryCallback {
    void runQuery(Connection conn, ResultSet rs, Statement stmt) throws SQLException;
}

public class Main {
    static final String DRIVER = "org.postgresql.Driver";
    static final String JDBC_URL = "jdbc:postgresql://localhost/alvr";
    static final String JDBC_USER = "postgres";
    static final String JDBC_PASSWORD = "123456";

    static final String SEARCH_QUERY_TEMPLATE =
        "SELECT DISTINCT pg.name, "
        + "     p.version, "
        + "    p.date::date "
        + "FROM preset_group AS pg "
        + "    LEFT JOIN pg_contains_t AS c ON c.pg_id = pg.id "
        + "    LEFT JOIN launches_with AS lw ON lw.pg_id = pg.id "
        + "    JOIN preset AS p ON p.pg_id = pg.id "
        + "    JOIN ( "
        + "        SELECT "
        + "            pg_id, "
        + "            MAX(date) AS date "
        + "        FROM preset as p "
        + "        WHERE NOT is_yanked "
        + "        GROUP BY pg_id "
        + "    ) AS p2 ON p2.pg_id = pg.id AND p2.date = p.date "
        + "WHERE ( "
        + "        pg.name LIKE '%<word>%' "
        + "        OR c.tag = '<word>' "
        + "        OR lw.game LIKE '%<word>%' "
        + "    ) "
        + "    AND is_public "
        + "ORDER BY p.date::date DESC;";

    static final String GET_USER_LANGUAGE_TEMPLATE =
        "SELECT language AS language_code "
        + "FROM public.user AS u "
        + "WHERE u.name = '<user_name>' AND NOT u.is_deleted; ";

    static final String GET_PRESET_LANGUAGES_TEMPLATE =
        "SELECT language AS language_code "
        + "FROM translated_in AS t "
        + "    JOIN preset_group AS pg ON pg.id = t.pg_id "
        + "WHERE pg.name = '<preset_name>' "
        + "    AND p_version = '<preset_version>';";

    static final String DOWNLOAD_PRESET_TEMPLATE =
        "SELECT u.name AS author, "
        + "    u.is_deleted AS is_author_deleted, "
        + "    p.code, "
        + "    is_yanked, "
        + "    date, "
        + "    description, "
        + "    game, "
        + "    ARRAY_AGG(w.setup) AS setups "
        + "FROM preset AS p "
        + "    JOIN preset_group AS pg ON pg.id = p.pg_id "
        + "    LEFT JOIN launches_with AS lw ON lw.pg_id = pg.id "
        + "    LEFT JOIN translated_in AS t ON t.p_version = p.version "
        + "    AND t.pg_id = p.pg_id "
        + "    LEFT JOIN works_on AS w ON w.p_version = p.version "
        + "    AND w.pg_id = p.pg_id "
        + "    JOIN public.user AS u ON u.id = p.author "
        + "WHERE pg.name = '<preset_name>' "
        + "    AND p.version = '<preset_version>' "
        + "    AND (t.language = '<language_code>' OR t.language IS NULL) "
        + "GROUP BY u.name, "
        + "    u.is_deleted, "
        + "    p.code, "
        + "    is_yanked, "
        + "    date, "
        + "    description, "
        + "    game;";

    static void execute(QueryCallback callback) {
        Connection conn = null;
        ResultSet rs = null;
        Statement stmt = null;

        try {
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            stmt = conn.createStatement();

            callback.runQuery(conn, rs, stmt);
        } catch (SQLException e) {
            System.out.println("Database access error:");

            while (e != null) {
                System.out.printf("- Message: %s\n", e.getMessage());
                System.out.printf("- SQL status code: %s\n", e.getSQLState());
                System.out.printf("- SQL error code: %s\n", e.getErrorCode());
                System.out.println();
                e = e.getNextException();
            }
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }

                if (stmt != null) {
                    stmt.close();
                }

                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Database access error:");

                while (e != null) {
                    System.out.printf("- Message: %s\n", e.getMessage());
                    System.out.printf("- SQL status code: %s\n", e.getSQLState());
                    System.out.printf("- SQL error code: %s\n", e.getErrorCode());
                    System.out.printf("%n");
                    e = e.getNextException();
                }
            } finally {
                rs = null;
                stmt = null;
                conn = null;
            }
        }
    }

    public static void main(String[] args) {
        try {
            Class.forName(DRIVER);
            System.out.printf("Driver %s successfully registered.\n", DRIVER);

        } catch (ClassNotFoundException e) {
            System.out.printf("Failed to register driver %s\n %s", DRIVER, e);

            System.exit(-1);
        }
        Scanner sc = new Scanner(System.in);

        // ---------------------- Search query -------------------------------
        System.out.println("------Search query------");
        Main.execute((conn, rs, stmt) -> {
            System.out.println("Query word: ");
            String queryWord = sc.nextLine();

            String searchQuery = SEARCH_QUERY_TEMPLATE.replace("<word>", queryWord);
            rs = stmt.executeQuery(searchQuery);

            System.out.println("Results:");
            System.out.println("name\t\tversion\t\tdate");
            while (rs.next()) {
                String presetName = rs.getString("name");
                String presetVersion = rs.getString("version");
                Date presetDate = rs.getDate("date");
                System.out.printf("%s\t\t%s\t\t%s\n", presetName, presetVersion, presetDate.toString());
            }
        });

        // ---------------------- Download preset query -------------------------------
        System.out.println("------Download preset query------");
        var downloadPresetData = new Object() {
            String userName;
            String presetName;
            String presetVersion;
            String userLanguageCode = null;
            List<String> presetLanguageCodes = new ArrayList<>();
            String chosenLanguageCode = "";
        };
        Main.execute((conn, rs, stmt) -> {
            System.out.println("Username (for description language): ");
            downloadPresetData.userName = sc.nextLine();
            System.out.println("Preset name: ");
            downloadPresetData.presetName = sc.nextLine();
            System.out.println("Preset version: ");
            downloadPresetData.presetVersion = sc.nextLine();

            String getUserLanguage = GET_USER_LANGUAGE_TEMPLATE.replace("<user_name>", downloadPresetData.userName);
            rs = stmt.executeQuery(getUserLanguage);

            if (rs.next()) {
                downloadPresetData.userLanguageCode = rs.getString("language_code");
            }
        });
        if (downloadPresetData.userLanguageCode != null) {
            Main.execute((conn, rs, stmt) -> {
                String getPresetLanguages = GET_PRESET_LANGUAGES_TEMPLATE.replace("<preset_name>",
                        downloadPresetData.presetName);
                getPresetLanguages = GET_PRESET_LANGUAGES_TEMPLATE.replace("<preset_version>",
                        downloadPresetData.presetVersion);

                rs = stmt.executeQuery(getPresetLanguages);

                while (rs.next()) {
                    downloadPresetData.presetLanguageCodes.add(rs.getString("language_code"));
                }
            });

            if (downloadPresetData.presetLanguageCodes.contains(downloadPresetData.userLanguageCode)) {
                downloadPresetData.chosenLanguageCode = downloadPresetData.userLanguageCode;
            } else if (downloadPresetData.presetLanguageCodes.contains("eng")) {
                downloadPresetData.chosenLanguageCode = "eng";
            } else if (!downloadPresetData.presetLanguageCodes.isEmpty()) {
                downloadPresetData.chosenLanguageCode = downloadPresetData.presetLanguageCodes.get(0);
            }

            Main.execute((conn, rs, stmt) -> {
                String downloadPreset = DOWNLOAD_PRESET_TEMPLATE.replace("<preset_name>",
                        downloadPresetData.presetName);
                downloadPreset = GET_PRESET_LANGUAGES_TEMPLATE.replace("<preset_version>",
                        downloadPresetData.presetVersion);
                downloadPreset = GET_PRESET_LANGUAGES_TEMPLATE.replace("<language_code>",
                        downloadPresetData.chosenLanguageCode);

                rs = stmt.executeQuery(downloadPreset);

                if (rs.next()) {
                    String author = rs.getString("author");
                    Boolean isAuthorDeleted = rs.getBoolean("is_author_deleted");
                    String code = rs.getString("code");
                    Boolean is_yanked = rs.getBoolean("is_yanked");
                    Date date = rs.getDate("date");
                    String description = rs.getString("description");
                    String game = rs.getString("game");
                    Array setups = rs.getArray("setups");

                    System.out.println("Results:");
                    System.out.println(
                            "author\t\tis author deleted\t\tcode\t\tis_yanked\t\tdate\t\tdescription\t\tgame\t\tsetups");
                    System.out.printf("%s\t\t%b\t\t%s\t\t%b\t\t%s\t\t%s\t\t%s\t\t%s", author, isAuthorDeleted, code,
                            is_yanked, date.toString(), description, game, setups.toString());

                } else {
                    System.out.println("No matching preset");
                }

            });
        } else {
            System.out.println("No matching user");
        }

        sc.close();
    }
}
