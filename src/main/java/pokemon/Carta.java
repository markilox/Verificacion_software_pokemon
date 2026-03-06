package main.java.pokemon;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;

public class Carta {

    public enum EstadoC{
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
                 int puntuacion, String estado, Date fechaAlta) {
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

    // Constructor completo
    public Carta(int idCarta, String dueno, String nombre, String tipo,
                 int puntuacion, String estado, Date fechaAlta) {
        this.idCarta = idCarta;
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

    public List<Carta> buscarCartas(String texto, boolean soloDisponibles, String dueno,
                                    boolean ordenarPorPuntos, String tipoFiltro) throws Exception {

        List<Carta> lista = new ArrayList<>();

        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {

            String sql = "SELECT * FROM cartas WHERE dueno='" + dueno + "'";

            if (texto != null && !texto.isEmpty()) {
                sql += " AND nombre LIKE '%" + texto + "%'";
            }

            if (soloDisponibles) {
                sql += " AND estado='DISPONIBLE'";
            }

            if (tipoFiltro != null && !tipoFiltro.isEmpty()) {
                sql += " AND tipo='" + tipoFiltro + "'";
            }

            if (ordenarPorPuntos) {
                sql += " ORDER BY puntuacion DESC";
            }

            java.sql.ResultSet rs = db.executeQuery(sql);

            while (rs.next()) {

                Carta carta = new Carta(
                        rs.getInt("idCarta"),
                        rs.getString("dueno"),
                        rs.getString("nombre"),
                        rs.getString("tipo"),
                        rs.getInt("puntuacion"),
                        rs.getString("estado"),
                        rs.getDate("fechaAlta")
                );

                lista.add(carta);
            }

        } finally {
            db.disconnect();
        }

        return lista;
    }

    // Insertar una nueva carta
    public boolean insertarCarta() throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "INSERT INTO cartas (dueno, nombre, tipo, puntuacion, estado, fechaAlta) VALUES (" +
                    "'" + dueno + "'," +
                    "'" + nombre + "'," +
                    "'" + tipo + "'," +
                    puntuacion + "," +
                    "'" + estado + "'," +
                    "NOW()" +
                    ")";

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }

    // Modificar una carta existente
    public boolean modificarCarta() throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "UPDATE cartas SET " +
                    "nombre='" + nombre + "', " +
                    "tipo='" + tipo + "', " +
                    "puntuacion=" + puntuacion + ", " +
                    "estado='" + estado + "' " +
                    "WHERE idCarta=" + idCarta;

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }

    // Borrar carta
    public boolean borrarCarta(int id) throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "DELETE FROM cartas WHERE idCarta=" + id;

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }

    // Buscar carta por ID (para la página modificar)
    public Carta buscarCartaPorId(int id) throws Exception {

        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "SELECT * FROM cartas WHERE idCarta=" + id;

            java.sql.ResultSet rs = db.executeQuery(sql);

            if (rs.next()) {
                return new Carta(
                        rs.getInt("idCarta"),
                        rs.getString("dueno"),
                        rs.getString("nombre"),
                        rs.getString("tipo"),
                        rs.getInt("puntuacion"),
                        rs.getString("estado"),
                        rs.getDate("fechaAlta")
                );
            }

            return null;

        } finally {
            db.disconnect();
        }
    }
}
