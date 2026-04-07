package main.java.pokemon;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Date;
import java.util.logging.Logger;

public class Carta {

    private static final Logger logger = Logger.getLogger(Carta.class.getName());

    public enum EstadoC {
        DISPONIBLE,
        RESERVADA,
        NO_INTERCAMBIA
    }

    public int idCarta;
    public String dueno;
    public String nombre;
    public String tipo;
    public int puntuacion;
    public EstadoC estado;
    public Date fechaAlta;

    public Carta() {
    }

    public Carta(String dueno, String nombre, String tipo,
                 int puntuacion, EstadoC estado, Date fechaAlta) {
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

    public Carta(int idCarta, String dueno, String nombre, String tipo,
                 int puntuacion, EstadoC estado, Date fechaAlta) {
        this.idCarta = idCarta;
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

    public boolean guardar() throws Exception {
        logger.info("Guardando carta: " + this.nombre);
        return insertarCartaBD();
    }

    public boolean actualizarDueno(String nuevoDueno) throws Exception {
        logger.info("Actualizando carta id: " + this.idCarta);
        this.dueno = nuevoDueno;
        return modificarCartaBD();
    }

    public boolean actualizarNombre(String nuevoNombre) throws Exception {
        logger.info("Actualizando carta id: " + this.idCarta);
        this.nombre = nuevoNombre;
        return modificarCartaBD();
    }

    public boolean actualizarTipo(String nuevoTipo) throws Exception {
        logger.info("Actualizando carta id: " + this.idCarta);
        this.tipo = nuevoTipo;
        return modificarCartaBD();
    }

    public boolean actualizarEstado(EstadoC nuevoEstado) throws Exception {
        logger.info("Actualizando carta id: " + this.idCarta);
        this.estado = nuevoEstado;
        return modificarCartaBD();
    }

    public boolean actualizarDatos(String nuevoNombre, String nuevoTipo,
                                   int nuevaPuntuacion, EstadoC nuevoEstado) throws Exception {
        logger.info("Actualizando carta id: " + this.idCarta);
        this.nombre = nuevoNombre;
        this.tipo = nuevoTipo;
        this.puntuacion = nuevaPuntuacion;
        this.estado = nuevoEstado;
        return modificarCartaBD();
    }

    public boolean eliminar() throws Exception {
        logger.info("Eliminando carta id: " + this.idCarta);
        return borrarCartaBD();
    }

    private boolean insertarCartaBD() {
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();
            Connection connection = db.getConnection();
            String sql = "INSERT INTO Carta (Dueno, Nombre, Tipo, Puntuacion, Estado, FechaAlta) " +
                    "VALUES (?, ?, ?, ?, ?, NOW())";

            try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, this.dueno);
                ps.setString(2, this.nombre);
                ps.setString(3, this.tipo);
                ps.setInt(4, this.puntuacion);
                ps.setString(5, this.estado.name());

                int resultado = ps.executeUpdate();
                if (resultado > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            this.idCarta = rs.getInt(1);
                        }
                    }
                    logger.info("Nueva carta creada correctamente.");
                    return true;
                }
            }

            return false;

        } catch (Exception e) {
            System.err.println("ERROR insertando carta");
            e.printStackTrace();
            return false;

        } finally {
            db.disconnect();
        }
    }

    private boolean modificarCartaBD() {
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();
            Connection connection = db.getConnection();
            String sql = "UPDATE Carta SET Dueno=?, Nombre=?, Tipo=?, Puntuacion=?, Estado=? " +
                    "WHERE id_carta=?";

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, this.dueno);
                ps.setString(2, this.nombre);
                ps.setString(3, this.tipo);
                ps.setInt(4, this.puntuacion);
                ps.setString(5, this.estado.name());
                ps.setInt(6, this.idCarta);

                int resultado = ps.executeUpdate();
                logger.info("Modificacion realizada correctamente.");
                return resultado > 0;
            }

        } catch (Exception e) {
            System.err.println("ERROR modificando carta");
            e.printStackTrace();
            return false;

        } finally {
            db.disconnect();
        }
    }

    private boolean borrarCartaBD() {
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();
            Connection connection = db.getConnection();
            String sql = "DELETE FROM Carta WHERE id_carta=?";

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, this.idCarta);
                int resultado = ps.executeUpdate();
                logger.info("Eliminacion realizada correctamente.");
                return resultado > 0;
            }

        } catch (Exception e) {
            System.err.println("ERROR borrando carta");
            e.printStackTrace();
            return false;

        } finally {
            db.disconnect();
        }
    }
}
