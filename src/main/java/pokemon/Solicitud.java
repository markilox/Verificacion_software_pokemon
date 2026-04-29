package main.java.pokemon;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Solicitud {

    private static final Logger logger = Logger.getLogger(Solicitud.class.getName());

    public enum EstadoS {
        PENDIENTE,
        ACEPTADO,
        RECHAZADO
    }

    public static class ResumenSolicitud {
        public final int idSolicitud;
        public final String cartaSolicitada;
        public final String duenoCartaSolicitada;
        public final String cartaOfrecida;
        public final String duenoCartaOfrecida;
        public final String estado;
        public final String fechaSolicitud;

        public ResumenSolicitud(int idSolicitud, String cartaSolicitada, String duenoCartaSolicitada,
                                String cartaOfrecida, String duenoCartaOfrecida,
                                String estado, String fechaSolicitud) {
            this.idSolicitud = idSolicitud;
            this.cartaSolicitada = cartaSolicitada;
            this.duenoCartaSolicitada = duenoCartaSolicitada;
            this.cartaOfrecida = cartaOfrecida;
            this.duenoCartaOfrecida = duenoCartaOfrecida;
            this.estado = estado;
            this.fechaSolicitud = fechaSolicitud;
        }
    }

    private static class CartaBloqueada {
        private final int idCarta;
        private final String dueno;
        private final Carta.EstadoC estado;

        private CartaBloqueada(int idCarta, String dueno, Carta.EstadoC estado) {
            this.idCarta = idCarta;
            this.dueno = dueno;
            this.estado = estado;
        }
    }

    public int idSolicitud;
    public int idCarta1;
    public String dueno1;
    public int idCarta2;
    public String dueno2;
    public Date fechaSolicitud;
    public EstadoS estado;

    private Solicitud(int idSolicitud, int idCarta1, String dueno1, int idCarta2,
                      String dueno2, EstadoS estado, Date fechaSolicitud) {
        this.idSolicitud = idSolicitud;
        this.idCarta1 = idCarta1;
        this.dueno1 = dueno1;
        this.idCarta2 = idCarta2;
        this.dueno2 = dueno2;
        this.estado = estado;
        this.fechaSolicitud = fechaSolicitud;
    }

    public static Solicitud crear(int idCartaSolicitada, int idCartaOfrecida, String usuarioSolicitante) throws Exception {
        if (idCartaSolicitada <= 0 || idCartaOfrecida <= 0) {
            throw new IllegalArgumentException("Debes seleccionar ambas cartas.");
        }
        if (idCartaSolicitada == idCartaOfrecida) {
            throw new IllegalArgumentException("No puedes intercambiar una carta consigo misma.");
        }

        DatabaseManager db = new DatabaseManager();
        Connection conn = null;

        try {
            db.connect();
            conn = db.getConnection();
            conn.setAutoCommit(false);

            CartaBloqueada cartaSolicitada = obtenerCartaBloqueada(conn, idCartaSolicitada);
            CartaBloqueada cartaOfrecida = obtenerCartaBloqueada(conn, idCartaOfrecida);

            if (cartaSolicitada == null || cartaOfrecida == null) {
                throw new IllegalArgumentException("Alguna carta seleccionada no existe.");
            }
            if (usuarioSolicitante.equals(cartaSolicitada.dueno)) {
                throw new IllegalArgumentException("La carta solicitada debe ser de otro usuario.");
            }
            if (!usuarioSolicitante.equals(cartaOfrecida.dueno)) {
                throw new IllegalArgumentException("La carta ofrecida debe ser tuya.");
            }
            if (cartaSolicitada.estado != Carta.EstadoC.DISPONIBLE || cartaOfrecida.estado != Carta.EstadoC.DISPONIBLE) {
                throw new IllegalStateException("Solo se pueden intercambiar cartas en estado DISPONIBLE.");
            }

            actualizarEstadoCarta(conn, cartaSolicitada.idCarta, Carta.EstadoC.RESERVADA);
            actualizarEstadoCarta(conn, cartaOfrecida.idCarta, Carta.EstadoC.RESERVADA);

            Date fechaActual = new Date();
            int idGenerado = insertarSolicitud(conn, idCartaSolicitada, cartaSolicitada.dueno,
                    idCartaOfrecida, usuarioSolicitante, EstadoS.PENDIENTE, fechaActual);

            conn.commit();
            logger.info("Intercambio solicitado correctamente.");
            return new Solicitud(idGenerado, idCartaSolicitada, cartaSolicitada.dueno,
                    idCartaOfrecida, usuarioSolicitante, EstadoS.PENDIENTE, fechaActual);

        } catch (Exception e) {
            rollbackSilencioso(conn);
            throw e;

        } finally {
            restaurarAutoCommit(conn);
            db.disconnect();
        }
    }

    public static Solicitud obtenerPorId(int idSolicitud) throws Exception {
        return obtenerPorIdYDueno(idSolicitud, null, null);
    }

    public static Solicitud obtenerPorIdYDueno1(int idSolicitud, String dueno1) throws Exception {
        return obtenerPorIdYDueno(idSolicitud, "Dueno1", dueno1);
    }

    public static Solicitud obtenerPorIdYDueno2(int idSolicitud, String dueno2) throws Exception {
        return obtenerPorIdYDueno(idSolicitud, "Dueno2", dueno2);
    }

    public static List<ResumenSolicitud> obtenerSolicitudesRecibidas(String dueno1) throws Exception {
        return obtenerResumenes(
                "SELECT s.id_solicitud, c1.Nombre AS cartaSolicitada, s.Dueno1, c2.Nombre AS cartaOfrecida, " +
                        "s.Dueno2, s.Estado, DATE_FORMAT(s.FechaSolicitud, '%Y-%m-%d') AS fecha " +
                        "FROM Solicitud s " +
                        "JOIN Carta c1 ON c1.id_carta = s.id_carta1 " +
                        "JOIN Carta c2 ON c2.id_carta = s.id_carta2 " +
                        "WHERE s.Dueno1=? " +
                        "ORDER BY s.FechaSolicitud DESC",
                dueno1
        );
    }

    public static List<ResumenSolicitud> buscarSolicitud(String textoBusqueda) {
        List<ResumenSolicitud> resultado = new ArrayList<ResumenSolicitud>();
        DatabaseManager db = new DatabaseManager();
        try {
            db.connect();
            Connection conn = db.getConnection();
            String sql =
                    "SELECT s.id_solicitud, c1.Nombre AS cartaSolicitada, s.Dueno1, " +
                    "c2.Nombre AS cartaOfrecida, s.Dueno2, s.Estado, " +
                    "DATE_FORMAT(s.FechaSolicitud, '%Y-%m-%d') AS fecha " +
                    "FROM Solicitud s " +
                    "JOIN Carta c1 ON c1.id_carta = s.id_carta1 " +
                    "JOIN Carta c2 ON c2.id_carta = s.id_carta2 " +
                    "WHERE s.Dueno1=? OR s.Dueno2=? " +
                    "ORDER BY s.FechaSolicitud DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, textoBusqueda);
                ps.setString(2, textoBusqueda);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        resultado.add(new ResumenSolicitud(
                                rs.getInt("id_solicitud"),
                                rs.getString("cartaSolicitada"),
                                rs.getString("Dueno1"),
                                rs.getString("cartaOfrecida"),
                                rs.getString("Dueno2"),
                                rs.getString("Estado"),
                                rs.getString("fecha")
                        ));
                    }
                }
            }
        } catch (Exception e) {
            logger.log(Level.WARNING, "Error al buscar solicitud.", e);
        } finally {
            db.disconnect();
        }
        return resultado;
    }

    public static List<ResumenSolicitud> obtenerSolicitudesEnviadas(String dueno2) throws Exception {
        return obtenerResumenes(
                "SELECT s.id_solicitud, c1.Nombre AS cartaSolicitada, s.Dueno1, c2.Nombre AS cartaOfrecida, " +
                        "s.Dueno2, s.Estado, DATE_FORMAT(s.FechaSolicitud, '%Y-%m-%d') AS fecha " +
                        "FROM Solicitud s " +
                        "JOIN Carta c1 ON c1.id_carta = s.id_carta1 " +
                        "JOIN Carta c2 ON c2.id_carta = s.id_carta2 " +
                        "WHERE s.Dueno2=? " +
                        "ORDER BY s.FechaSolicitud DESC",
                dueno2
        );
    }

    public void aceptar() throws Exception {
        DatabaseManager db = new DatabaseManager();
        Connection conn = null;

        try {
            db.connect();
            conn = db.getConnection();
            conn.setAutoCommit(false);

            Solicitud actual = obtenerPorIdParaActualizacion(conn, this.idSolicitud);
            validarSolicitudPendiente(actual);

            actualizarCarta(conn, actual.idCarta1, actual.dueno2, Carta.EstadoC.DISPONIBLE);
            actualizarCarta(conn, actual.idCarta2, actual.dueno1, Carta.EstadoC.DISPONIBLE);
            actualizarEstadoSolicitud(conn, actual.idSolicitud, EstadoS.ACEPTADO);

            conn.commit();
            this.estado = EstadoS.ACEPTADO;
            this.dueno1 = actual.dueno1;
            this.dueno2 = actual.dueno2;
            this.idCarta1 = actual.idCarta1;
            this.idCarta2 = actual.idCarta2;
            this.fechaSolicitud = actual.fechaSolicitud;
            logger.info("Intercambio realizado correctamente.");

        } catch (Exception e) {
            rollbackSilencioso(conn);
            throw e;

        } finally {
            restaurarAutoCommit(conn);
            db.disconnect();
        }
    }

    public void rechazar() throws Exception {
        DatabaseManager db = new DatabaseManager();
        Connection conn = null;

        try {
            db.connect();
            conn = db.getConnection();
            conn.setAutoCommit(false);

            Solicitud actual = obtenerPorIdParaActualizacion(conn, this.idSolicitud);
            validarSolicitudPendiente(actual);

            actualizarEstadoCarta(conn, actual.idCarta1, Carta.EstadoC.DISPONIBLE);
            actualizarEstadoCarta(conn, actual.idCarta2, Carta.EstadoC.DISPONIBLE);
            actualizarEstadoSolicitud(conn, actual.idSolicitud, EstadoS.RECHAZADO);

            conn.commit();
            this.estado = EstadoS.RECHAZADO;
            this.dueno1 = actual.dueno1;
            this.dueno2 = actual.dueno2;
            this.idCarta1 = actual.idCarta1;
            this.idCarta2 = actual.idCarta2;
            this.fechaSolicitud = actual.fechaSolicitud;
            logger.info("Intercambio rechazado correctamente.");

        } catch (Exception e) {
            rollbackSilencioso(conn);
            throw e;

        } finally {
            restaurarAutoCommit(conn);
            db.disconnect();
        }
    }

    public void cancelar() throws Exception {
        DatabaseManager db = new DatabaseManager();
        Connection conn = null;

        try {
            db.connect();
            conn = db.getConnection();
            conn.setAutoCommit(false);

            Solicitud actual = obtenerPorIdParaActualizacion(conn, this.idSolicitud);
            validarSolicitudPendiente(actual);

            actualizarEstadoCarta(conn, actual.idCarta1, Carta.EstadoC.DISPONIBLE);
            actualizarEstadoCarta(conn, actual.idCarta2, Carta.EstadoC.DISPONIBLE);
            borrarSolicitud(conn, actual.idSolicitud);

            conn.commit();
            this.dueno1 = actual.dueno1;
            this.dueno2 = actual.dueno2;
            this.idCarta1 = actual.idCarta1;
            this.idCarta2 = actual.idCarta2;
            this.fechaSolicitud = actual.fechaSolicitud;
            logger.info("Intercambio cancelado correctamente.");

        } catch (Exception e) {
            rollbackSilencioso(conn);
            throw e;

        } finally {
            restaurarAutoCommit(conn);
            db.disconnect();
        }
    }

    public void borrar() throws Exception {
        DatabaseManager db = new DatabaseManager();
        Connection conn = null;

        try {
            db.connect();
            conn = db.getConnection();
            conn.setAutoCommit(false);

            Solicitud actual = obtenerPorIdParaActualizacion(conn, this.idSolicitud);
            if (actual == null) {
                throw new IllegalArgumentException("La solicitud no existe.");
            }

            if (actual.estado == EstadoS.PENDIENTE) {
                actualizarEstadoCarta(conn, actual.idCarta1, Carta.EstadoC.DISPONIBLE);
                actualizarEstadoCarta(conn, actual.idCarta2, Carta.EstadoC.DISPONIBLE);
            }

            borrarSolicitud(conn, actual.idSolicitud);

            conn.commit();
            this.estado = actual.estado;
            this.dueno1 = actual.dueno1;
            this.dueno2 = actual.dueno2;
            this.idCarta1 = actual.idCarta1;
            this.idCarta2 = actual.idCarta2;
            this.fechaSolicitud = actual.fechaSolicitud;
            logger.info("Solicitud borrada correctamente.");

        } catch (Exception e) {
            rollbackSilencioso(conn);
            throw e;

        } finally {
            restaurarAutoCommit(conn);
            db.disconnect();
        }
    }

    private static Solicitud obtenerPorIdYDueno(int idSolicitud, String columnaDueno, String dueno) throws Exception {
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();
            Connection conn = db.getConnection();

            String sql = "SELECT id_solicitud, id_carta1, Dueno1, id_carta2, Dueno2, Estado, FechaSolicitud " +
                    "FROM Solicitud WHERE id_solicitud=?";
            if (columnaDueno != null) {
                sql += " AND " + columnaDueno + "=?";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, idSolicitud);
                if (columnaDueno != null) {
                    ps.setString(2, dueno);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapearSolicitud(rs);
                    }
                }
            }

            return null;

        } finally {
            db.disconnect();
        }
    }

    private static List<ResumenSolicitud> obtenerResumenes(String sql, String dueno) throws Exception {
        List<ResumenSolicitud> solicitudes = new ArrayList<ResumenSolicitud>();
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();
            Connection conn = db.getConnection();

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, dueno);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        solicitudes.add(new ResumenSolicitud(
                                rs.getInt("id_solicitud"),
                                rs.getString("cartaSolicitada"),
                                rs.getString("Dueno1"),
                                rs.getString("cartaOfrecida"),
                                rs.getString("Dueno2"),
                                rs.getString("Estado"),
                                rs.getString("fecha")
                        ));
                    }
                }
            }

            return solicitudes;

        } finally {
            db.disconnect();
        }
    }

    private static Solicitud obtenerPorIdParaActualizacion(Connection conn, int idSolicitud) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id_solicitud, id_carta1, Dueno1, id_carta2, Dueno2, Estado, FechaSolicitud " +
                        "FROM Solicitud WHERE id_solicitud=? FOR UPDATE")) {
            ps.setInt(1, idSolicitud);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearSolicitud(rs);
                }
            }
        }

        return null;
    }

    private static CartaBloqueada obtenerCartaBloqueada(Connection conn, int idCarta) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id_carta, Dueno, Estado FROM Carta WHERE id_carta=? FOR UPDATE")) {
            ps.setInt(1, idCarta);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CartaBloqueada(
                            rs.getInt("id_carta"),
                            rs.getString("Dueno"),
                            Carta.EstadoC.valueOf(rs.getString("Estado"))
                    );
                }
            }
        }

        return null;
    }

    private static int insertarSolicitud(Connection conn, int idCarta1, String dueno1, int idCarta2,
                                         String dueno2, EstadoS estado, Date fechaSolicitud) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Solicitud (id_carta1, Dueno1, id_carta2, Dueno2, Estado, FechaSolicitud) " +
                        "VALUES (?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, idCarta1);
            ps.setString(2, dueno1);
            ps.setInt(3, idCarta2);
            ps.setString(4, dueno2);
            ps.setString(5, estado.name());
            ps.setDate(6, new java.sql.Date(fechaSolicitud.getTime()));

            int filas = ps.executeUpdate();
            if (filas != 1) {
                throw new SQLException("No se pudo crear la solicitud.");
            }

            try (ResultSet claves = ps.getGeneratedKeys()) {
                if (claves.next()) {
                    return claves.getInt(1);
                }
            }
        }

        throw new SQLException("No se pudo recuperar el id de la solicitud.");
    }

    private static void actualizarCarta(Connection conn, int idCarta, String dueno, Carta.EstadoC estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Carta SET Dueno=?, Estado=? WHERE id_carta=?")) {
            ps.setString(1, dueno);
            ps.setString(2, estado.name());
            ps.setInt(3, idCarta);

            if (ps.executeUpdate() != 1) {
                throw new SQLException("No se pudo actualizar la carta.");
            }
        }
    }

    private static void actualizarEstadoCarta(Connection conn, int idCarta, Carta.EstadoC estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Carta SET Estado=? WHERE id_carta=?")) {
            ps.setString(1, estado.name());
            ps.setInt(2, idCarta);

            if (ps.executeUpdate() != 1) {
                throw new SQLException("No se pudo actualizar el estado de la carta.");
            }
        }
    }

    private static void actualizarEstadoSolicitud(Connection conn, int idSolicitud, EstadoS estado) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Solicitud SET Estado=? WHERE id_solicitud=?")) {
            ps.setString(1, estado.name());
            ps.setInt(2, idSolicitud);

            if (ps.executeUpdate() != 1) {
                throw new SQLException("No se pudo actualizar la solicitud.");
            }
        }
    }

    private static void borrarSolicitud(Connection conn, int idSolicitud) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM Solicitud WHERE id_solicitud=?")) {
            ps.setInt(1, idSolicitud);

            if (ps.executeUpdate() != 1) {
                throw new SQLException("No se pudo borrar la solicitud.");
            }
        }
    }

    private static Solicitud mapearSolicitud(ResultSet rs) throws Exception {
        return new Solicitud(
                rs.getInt("id_solicitud"),
                rs.getInt("id_carta1"),
                rs.getString("Dueno1"),
                rs.getInt("id_carta2"),
                rs.getString("Dueno2"),
                EstadoS.valueOf(rs.getString("Estado")),
                rs.getDate("FechaSolicitud")
        );
    }

    private static void validarSolicitudPendiente(Solicitud solicitud) {
        if (solicitud == null) {
            throw new IllegalArgumentException("La solicitud no existe.");
        }
        if (solicitud.estado != EstadoS.PENDIENTE) {
            throw new IllegalStateException("La solicitud ya esta resuelta.");
        }
    }

    private static void rollbackSilencioso(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "No se pudo hacer rollback de la solicitud.", e);
            }
        }
    }

    private static void restaurarAutoCommit(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                logger.log(Level.WARNING, "No se pudo restaurar autocommit.", e);
            }
        }
    }
}
