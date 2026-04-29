package main.java.pokemon;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests de Caja Blanca - Solicitud
 *
 * CP AS-1 : Alta Solicitud - camino correcto                        -> 1-2-3-5
 * CP AS-2 : Alta Solicitud - camino de error                        -> 1-2-4-5
 * CP AC-1 : Aceptar Solicitud - estado no pendiente                 -> 1-14-15
 * CP AC-2 : Aceptar Solicitud - primera carta no existe             -> 1-2-3-5-15
 * CP AC-3 : Aceptar Solicitud - segunda carta no existe             -> 1-2-3-4-5-15
 * CP AC-4 : Aceptar Solicitud - camino correcto                     -> 1-2-3-4-6-7-8-9-10-11-12-15
 * CP AC-5 : Aceptar Solicitud - fallo en la primera actualizacion   -> 1-2-3-4-6-7-13-15
 * CP AC-6 : Aceptar Solicitud - fallo en la segunda actualizacion
 * CP AC-7 : Aceptar Solicitud - fallo en la actualizacion final
 */
public class SolicitudTest {

    private static final String URL =
            "jdbc:mysql://localhost:3306/CartasPokemon" +
            "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "pokemon_user";
    private static final String DB_PASSWORD = "12345678";

    private int idCarta1;
    private int idCarta2;
    private int idCarta3;
    private int idSolicitudTest;

    @BeforeEach
    void setUp() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        idSolicitudTest = 0;

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            idCarta1 = insertarCarta(conn, "User1", "TestPikachu", "DISPONIBLE");
            idCarta2 = insertarCarta(conn, "User2", "TestBulbasaur", "DISPONIBLE");
            idCarta3 = insertarCarta(conn, "User1", "TestCharizard", "RESERVADA");
        }
    }

    @AfterEach
    void tearDown() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            eliminarRestriccionTemporalCarta(conn);

            for (int id : new int[]{idCarta1, idCarta2, idCarta3}) {
                if (id > 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Solicitud WHERE id_carta1 = ? OR id_carta2 = ?")) {
                        ps.setInt(1, id);
                        ps.setInt(2, id);
                        ps.executeUpdate();
                    }
                }
            }

            if (idSolicitudTest > 0) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM Solicitud WHERE id_solicitud = ?")) {
                    ps.setInt(1, idSolicitudTest);
                    ps.executeUpdate();
                }
            }

            for (int id : new int[]{idCarta1, idCarta2, idCarta3}) {
                if (id > 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Carta WHERE id_carta = ?")) {
                        ps.setInt(1, id);
                        ps.executeUpdate();
                    }
                }
            }
        }
    }

    @Test
    void altaSolicitud_CP_AS1_insercionCorrecta() throws Exception {
        Solicitud solicitud = Solicitud.crear(idCarta1, idCarta2, "User2");

        assertNotNull(solicitud);
        assertTrue(solicitud.idSolicitud > 0);
        assertEquals(Solicitud.EstadoS.PENDIENTE, solicitud.estado);
        assertEquals(idCarta1, solicitud.idCarta1);
        assertEquals(idCarta2, solicitud.idCarta2);
        assertEquals("User1", solicitud.dueno1);
        assertEquals("User2", solicitud.dueno2);

        idSolicitudTest = solicitud.idSolicitud;

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta1));
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta2));
        }
    }

    @Test
    void altaSolicitud_CP_AS2_insercionFalla() {
        Exception ex = assertThrows(Exception.class,
                () -> Solicitud.crear(idCarta3, idCarta2, "User2"));

        assertNotNull(ex.getMessage());
    }

    @Test
    void aceptarSolicitud_CP_AC1_estadoNoPendiente() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Solicitud " +
                    "(id_carta1, Dueno1, id_carta2, Dueno2, Estado, FechaSolicitud) " +
                    "VALUES (?, 'User1', ?, 'User2', 'ACEPTADO', ?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, idCarta1);
                ps.setInt(2, idCarta2);
                ps.setDate(3, new java.sql.Date(System.currentTimeMillis()));
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        idSolicitudTest = rs.getInt(1);
                    }
                }
            }
        }

        Solicitud solicitud = Solicitud.obtenerPorId(idSolicitudTest);
        assertNotNull(solicitud);
        assertEquals(Solicitud.EstadoS.ACEPTADO, solicitud.estado);

        assertThrows(IllegalStateException.class, solicitud::aceptar);
    }

    @Test
    @DisplayName("CP AC-2 - Primera carta no existe")
    void aceptarSolicitud_CP_AC2_primeraCartaNoExiste() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            setEstadoCarta(conn, idCarta2, "RESERVADA");
            idSolicitudTest = insertarSolicitudSinIntegridadReferencial(
                    conn, 999999, "User1", idCarta2, "User2", "PENDIENTE"
            );
        }

        Solicitud solicitud = Solicitud.obtenerPorId(idSolicitudTest);
        assertNotNull(solicitud);

        SQLException ex = assertThrows(SQLException.class, solicitud::aceptar);
        assertTrue(ex.getMessage().contains("No se pudo actualizar la carta."));

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            assertEquals("User2", getDuenoCarta(conn, idCarta2));
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta2));
            assertEquals("PENDIENTE", getEstadoSolicitud(conn, idSolicitudTest));
        }
    }

    @Test
    @DisplayName("CP AC-3 - Segunda carta no existe")
    void aceptarSolicitud_CP_AC3_segundaCartaNoExiste() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            setEstadoCarta(conn, idCarta1, "RESERVADA");
            idSolicitudTest = insertarSolicitudSinIntegridadReferencial(
                    conn, idCarta1, "User1", 999998, "User2", "PENDIENTE"
            );
        }

        Solicitud solicitud = Solicitud.obtenerPorId(idSolicitudTest);
        assertNotNull(solicitud);

        SQLException ex = assertThrows(SQLException.class, solicitud::aceptar);
        assertTrue(ex.getMessage().contains("No se pudo actualizar la carta."));

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            assertEquals("User1", getDuenoCarta(conn, idCarta1));
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta1));
            assertEquals("PENDIENTE", getEstadoSolicitud(conn, idSolicitudTest));
        }
    }

    @Test
    @DisplayName("CP AC-4 - Aceptacion correcta")
    void aceptarSolicitud_CP_AC4_caminoCorrecto() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            prepararCartasReservadas(conn, idCarta1, idCarta2);
            idSolicitudTest = insertarSolicitud(conn, idCarta1, "User1", idCarta2, "User2", "PENDIENTE");
        }

        Solicitud solicitud = Solicitud.obtenerPorId(idSolicitudTest);
        assertNotNull(solicitud);

        solicitud.aceptar();

        assertEquals(Solicitud.EstadoS.ACEPTADO, solicitud.estado);

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            assertEquals("User2", getDuenoCarta(conn, idCarta1));
            assertEquals("User1", getDuenoCarta(conn, idCarta2));
            assertEquals("DISPONIBLE", getEstadoCarta(conn, idCarta1));
            assertEquals("DISPONIBLE", getEstadoCarta(conn, idCarta2));
            assertEquals("ACEPTADO", getEstadoSolicitud(conn, idSolicitudTest));
        }
    }

    @Test
    @DisplayName("CP AC-5 - Falla la primera actualizacion")
    void aceptarSolicitud_CP_AC5_falloPrimeraActualizacion() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            prepararCartasReservadas(conn, idCarta1, idCarta2);
            idSolicitudTest = insertarSolicitud(conn, idCarta1, "User1", idCarta2, "User2", "PENDIENTE");
            bloquearPrimeraActualizacionCarta(conn, "TestPikachu");
        }

        Solicitud solicitud = Solicitud.obtenerPorId(idSolicitudTest);
        assertNotNull(solicitud);

        SQLException ex = assertThrows(SQLException.class, solicitud::aceptar);
        assertNotNull(ex.getMessage());

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            assertEquals("User1", getDuenoCarta(conn, idCarta1));
            assertEquals("User2", getDuenoCarta(conn, idCarta2));
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta1));
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta2));
            assertEquals("PENDIENTE", getEstadoSolicitud(conn, idSolicitudTest));
        }
    }

    @Test
    void aceptarSolicitud_CP_AC6_falloSegundaActualizacion() throws Exception {
        Solicitud solicitud = Solicitud.crear(idCarta1, idCarta2, "User2");
        idSolicitudTest = solicitud.idSolicitud;

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM Carta WHERE id_carta = ?")) {
                ps.setInt(1, idCarta2);
                ps.executeUpdate();
            }
        }

        assertThrows(Exception.class, solicitud::aceptar);
    }

    @Test
    void aceptarSolicitud_CP_AC7_falloActualizacionSolicitud() throws Exception {
        Solicitud solicitud = Solicitud.crear(idCarta1, idCarta2, "User2");
        idSolicitudTest = solicitud.idSolicitud;

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM Solicitud WHERE id_solicitud = ?")) {
                ps.setInt(1, idSolicitudTest);
                ps.executeUpdate();
            }
        }

        assertThrows(Exception.class, solicitud::aceptar);
    }

    private int insertarCarta(Connection conn, String dueno, String nombre, String estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Carta (Dueno, Nombre, Tipo, Puntuacion, Estado, FechaAlta) " +
                "VALUES (?, ?, 'Electrico', 60, ?, NOW())",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dueno);
            ps.setString(2, nombre);
            ps.setString(3, estado);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private String getEstadoCarta(Connection conn, int idCarta) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT Estado FROM Carta WHERE id_carta = ?")) {
            ps.setInt(1, idCarta);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Estado");
                }
            }
        }
        return null;
    }

    private String getDuenoCarta(Connection conn, int idCarta) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT Dueno FROM Carta WHERE id_carta = ?")) {
            ps.setInt(1, idCarta);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Dueno");
                }
            }
        }
        return null;
    }

    private String getEstadoSolicitud(Connection conn, int idSolicitud) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT Estado FROM Solicitud WHERE id_solicitud = ?")) {
            ps.setInt(1, idSolicitud);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Estado");
                }
            }
        }
        return null;
    }

    private void setEstadoCarta(Connection conn, int idCarta, String estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Carta SET Estado = ? WHERE id_carta = ?")) {
            ps.setString(1, estado);
            ps.setInt(2, idCarta);
            ps.executeUpdate();
        }
    }

    private void prepararCartasReservadas(Connection conn, int primeraCarta, int segundaCarta) throws Exception {
        setEstadoCarta(conn, primeraCarta, "RESERVADA");
        setEstadoCarta(conn, segundaCarta, "RESERVADA");
    }

    private int insertarSolicitud(Connection conn, int idCarta1, String dueno1,
                                  int idCarta2, String dueno2, String estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Solicitud (id_carta1, Dueno1, id_carta2, Dueno2, Estado, FechaSolicitud) " +
                "VALUES (?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, idCarta1);
            ps.setString(2, dueno1);
            ps.setInt(3, idCarta2);
            ps.setString(4, dueno2);
            ps.setString(5, estado);
            ps.setDate(6, new java.sql.Date(System.currentTimeMillis()));
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private int insertarSolicitudSinIntegridadReferencial(Connection conn, int idCarta1, String dueno1,
                                                          int idCarta2, String dueno2, String estado) throws Exception {
        try (Statement st = conn.createStatement()) {
            st.execute("SET FOREIGN_KEY_CHECKS=0");
        }
        try {
            return insertarSolicitud(conn, idCarta1, dueno1, idCarta2, dueno2, estado);
        } finally {
            try (Statement st = conn.createStatement()) {
                st.execute("SET FOREIGN_KEY_CHECKS=1");
            }
        }
    }

    private void bloquearPrimeraActualizacionCarta(Connection conn, String nombreCarta) throws Exception {
        eliminarRestriccionTemporalCarta(conn);
        try (Statement st = conn.createStatement()) {
            st.execute(
                    "ALTER TABLE Carta " +
                    "ADD CONSTRAINT chk_cp_ac5_primera_actualizacion " +
                    "CHECK (Nombre <> '" + nombreCarta + "' OR Dueno <> 'User2' OR Estado <> 'DISPONIBLE')"
            );
        }
    }

    private void eliminarRestriccionTemporalCarta(Connection conn) {
        try (Statement st = conn.createStatement()) {
            st.execute("ALTER TABLE Carta DROP CHECK chk_cp_ac5_primera_actualizacion");
        } catch (SQLException ignored) {
        }
    }
}
