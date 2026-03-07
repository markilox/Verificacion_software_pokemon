package main.java.pokemon;

import java.sql.ResultSet;
import java.util.Date;

public class Carta {

    public enum EstadoC {
        DISPONIBLE,
        RESERVADA,
        NO_INTERCAMBIABLE
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
        System.out.println("Guardando carta: " + this.nombre);
        return insertarCartaBD();
    }

    public boolean actualizar() throws Exception {
        System.out.println("Actualizando carta id: " + this.idCarta);
        return modificarCartaBD();
    }

    public boolean eliminar() throws Exception {
        System.out.println("Eliminando carta id: " + this.idCarta);
        return borrarCartaBD();
    }

    public boolean actualizarEstado(EstadoC nuevoEstado) throws Exception {
        System.out.println("Actualizando estado carta " + this.idCarta + " -> " + nuevoEstado);
        this.estado = nuevoEstado;
        return actualizarEstadoBD();
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

            System.out.println("SQL INSERT: " + sql);

            int resultado = db.executeUpdate(sql);

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

            System.out.println("SQL UPDATE: " + sql);

            int resultado = db.executeUpdate(sql);

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

            System.out.println("SQL DELETE: " + sql);

            int resultado = db.executeUpdate(sql);

            return resultado > 0;

        } catch (Exception e) {
            System.err.println("ERROR borrando carta");
            e.printStackTrace();
            return false;

        } finally {
            db.disconnect();
        }
    }

    private boolean actualizarEstadoBD() {
        DatabaseManager db = new DatabaseManager();

        try {
            db.connect();

            String sql = "UPDATE Carta SET Estado='" + this.estado + "' WHERE id_carta=" + this.idCarta;

            System.out.println("SQL UPDATE ESTADO: " + sql);

            int resultado = db.executeUpdate(sql);

            return resultado > 0;

        } catch (Exception e) {
            System.err.println("ERROR actualizando estado carta");
            e.printStackTrace();
            return false;

        } finally {
            db.disconnect();
        }
    }


}