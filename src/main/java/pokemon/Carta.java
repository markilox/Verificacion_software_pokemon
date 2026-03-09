package main.java.pokemon;

import java.sql.ResultSet;
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

    // Constructor vacío
    public Carta() {
    }

    // Constructor sin id (para INSERT)
    public Carta(String dueno, String nombre, String tipo,
                 int puntuacion, EstadoC estado, Date fechaAlta) {
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

    // Constructor completo
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

    // ===== MÉTODOS PÚBLICOS =====

    public boolean guardar() throws Exception {
        logger.info("Guardando carta: "+ this.nombre);
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

    public boolean eliminar() throws Exception {
        logger.info("Eliminando carta id: " + this.idCarta);
        return borrarCartaBD();
    }

    // ===== MÉTODOS PRIVADOS (SQL REAL) =====

    private boolean insertarCartaBD() {
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();

            String sql = "INSERT INTO Carta (Dueno, Nombre, Tipo, Puntuacion, Estado, FechaAlta) VALUES (" +
                    "'" + this.dueno + "', " +
                    "'" + this.nombre + "', " +
                    "'" + this.tipo + "', " +
                    this.puntuacion + ", " +
                    "'" + this.estado + "', NOW())";

            int resultado = db.executeUpdate(sql);
            logger.info("Nueva carta creada correctamente.");

            return resultado > 0;

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

            String sql = "UPDATE Carta SET " +
                    "Dueno='" + this.dueno + "', " +
                    "Nombre='" + this.nombre + "', " +
                    "Tipo='" + this.tipo + "', " +
                    "Puntuacion=" + this.puntuacion + ", " +
                    "Estado='" + this.estado + "' " +
                    "WHERE id_carta=" + this.idCarta;

            int resultado = db.executeUpdate(sql);
            logger.info("Modificación realizada correctamente.");

            return resultado > 0;

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

            String sql = "DELETE FROM Carta WHERE id_carta=" + this.idCarta;

            int resultado = db.executeUpdate(sql);
            logger.info("Eliminación realizada correctamente.");

            return resultado > 0;

        } catch (Exception e) {
            System.err.println("ERROR borrando carta");
            e.printStackTrace();
            return false;

        } finally {
            db.disconnect();
        }
    }
}
