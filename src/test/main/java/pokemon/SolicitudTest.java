package main.java.pokemon;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests de Caja Blanca - Solicitud
 *
 * CP AS-1 : Alta Solicitud - camino correcto      (insercion BD OK)       -> 1-2-3-5
 * CP AS-2 : Alta Solicitud - camino de error      (carta no DISPONIBLE)   -> 1-2-4-5
 * CP AC-1 : Aceptar Solicitud - estado no pendiente (salida temprana)     -> 1-14-15
 */
public class SolicitudTest {

    private static final String URL =
            "jdbc:mysql://localhost:3306/CartasPokemon" +
            "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER     = "pokemon_user";
    private static final String DB_PASSWORD = "12345678";

    private int idCarta1;        // User1 - DISPONIBLE
    private int idCarta2;        // User2 - DISPONIBLE
    private int idCarta3;        // User1 - RESERVADA  (fuerza fallo en CP AS-2)
    private int idSolicitudTest; // Solicitud creada durante el test

    // -------------------------------------------------------------------------
    // Setup / Teardown
    // -------------------------------------------------------------------------

    @BeforeEach
    void setUp() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        idSolicitudTest = 0;

        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            idCarta1 = insertarCarta(conn, "User1", "TestPikachu",   "DISPONIBLE");
            idCarta2 = insertarCarta(conn, "User2", "TestBulbasaur", "DISPONIBLE");
            idCarta3 = insertarCarta(conn, "User1", "TestCharizard", "RESERVADA");
        }
    }

    @AfterEach
    void tearDown() throws Exception {
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {

            // Borrar solicitudes que involucren las cartas de prueba
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

            // Borrar solicitud insertada directamente (CP AC-1)
            if (idSolicitudTest > 0) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM Solicitud WHERE id_solicitud = ?")) {
                    ps.setInt(1, idSolicitudTest);
                    ps.executeUpdate();
                }
            }

            // Borrar cartas de prueba
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

    // -------------------------------------------------------------------------
    // CP AS-1 : Alta Solicitud - insercion correcta
    // -------------------------------------------------------------------------

    @Test
    void altaSolicitud_CP_AS1_insercionCorrecta() throws Exception {
        Solicitud solicitud = Solicitud.crear(idCarta1, idCarta2, "User2");

        assertNotNull(solicitud,
                "La solicitud debe crearse y devolver un objeto no nulo");
        assertTrue(solicitud.idSolicitud > 0,
                "Debe generarse un id de solicitud valido");
        assertEquals(Solicitud.EstadoS.PENDIENTE, solicitud.estado,
                "El estado inicial de la solicitud debe ser PENDIENTE");
        assertEquals(idCarta1, solicitud.idCarta1,
                "id_carta1 debe coincidir con la carta solicitada");
        assertEquals(idCarta2, solicitud.idCarta2,
                "id_carta2 debe coincidir con la carta ofrecida");
        assertEquals("User1", solicitud.dueno1,
                "Dueno1 debe ser el dueno de la carta solicitada");
        assertEquals("User2", solicitud.dueno2,
                "Dueno2 debe ser el usuario solicitante");

        idSolicitudTest = solicitud.idSolicitud;

        // Verificar en BD que ambas cartas han pasado a RESERVADA
        try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD)) {
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta1),
                    "La carta solicitada debe quedar en estado RESERVADA");
            assertEquals("RESERVADA", getEstadoCarta(conn, idCarta2),
                    "La carta ofrecida debe quedar en estado RESERVADA");
        }
    }

    // -------------------------------------------------------------------------
    // CP AS-2 : Alta Solicitud - insercion falla
    // -------------------------------------------------------------------------

    @Test
    void altaSolicitud_CP_AS2_insercionFalla() {
        Exception ex = assertThrows(Exception.class,
                () -> Solicitud.crear(idCarta3, idCarta2, "User2"),
                "Debe lanzarse excepcion al intentar intercambiar una carta no DISPONIBLE");

        assertNotNull(ex.getMessage(),
                "La excepcion debe incluir un mensaje de error descriptivo");
    }

    // -------------------------------------------------------------------------
    // CP AC-1 : Aceptar Solicitud - estado no pendiente
    // -------------------------------------------------------------------------

    @Test
    void aceptarSolicitud_CP_AC1_estadoNoPendiente() throws Exception {
        // Insertar en BD una solicitud ya ACEPTADA
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
                    if (rs.next()) idSolicitudTest = rs.getInt(1);
                }
            }
        }

        // Recuperar la solicitud de BD
        Solicitud solicitud = Solicitud.obtenerPorId(idSolicitudTest);
        assertNotNull(solicitud,
                "La solicitud insertada debe poder recuperarse de BD");
        assertEquals(Solicitud.EstadoS.ACEPTADO, solicitud.estado,
                "La solicitud debe tener estado ACEPTADO en BD");

        // Intentar aceptar una solicitud ya resuelta -> IllegalStateException
        assertThrows(IllegalStateException.class,
                solicitud::aceptar,
                "Debe lanzarse IllegalStateException al aceptar una solicitud ya resuelta");
    }

    // -------------------------------------------------------------------------
    // Metodos auxiliares
    // -------------------------------------------------------------------------

    private int insertarCarta(Connection conn, String dueno, String nombre,
                              String estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Carta (Dueno, Nombre, Tipo, Puntuacion, Estado, FechaAlta) " +
                "VALUES (?, ?, 'Electrico', 60, ?, NOW())",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dueno);
            ps.setString(2, nombre);
            ps.setString(3, estado);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    private String getEstadoCarta(Connection conn, int idCarta) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT Estado FROM Carta WHERE id_carta = ?")) {
            ps.setInt(1, idCarta);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("Estado");
            }
        }
        return null;
    }
}
