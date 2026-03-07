package main.java.pokemon;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CartaDada {

    // ===== MÉTODOS PÚBLICOS =====

    public List<Carta> buscarCartas(String texto, boolean soloDisponibles, String dueno,
                                    boolean ordenarPorPuntos, String tipoFiltro) throws Exception {

        System.out.println("Buscando cartas del usuario: " + dueno);

        return buscarCartasBD(texto, soloDisponibles, dueno, ordenarPorPuntos, tipoFiltro);
    }

    public boolean guardarCarta(Carta carta) throws Exception {

        System.out.println("Guardando carta: " + carta.nombre);

        return insertarCartaBD(carta);
    }

    public boolean actualizarCarta(Carta carta) throws Exception {

        System.out.println("Actualizando carta id: " + carta.idCarta);

        return modificarCartaBD(carta);
    }

    public boolean eliminarCarta(int id) throws Exception {

        System.out.println("Eliminando carta id: " + id);

        return borrarCartaBD(id);
    }

    public Carta obtenerCartaPorId(int id) throws Exception {

        System.out.println("Buscando carta id: " + id);

        return buscarCartaPorIdBD(id);
    }

    public boolean actualizarEstado(int id, String nuevoEstado) throws Exception {

        System.out.println("Actualizando estado carta " + id + " -> " + nuevoEstado);

        return actualizarEstadoBD(id, nuevoEstado);
    }

    // ===== MÉTODOS PRIVADOS (SQL REAL) =====

    private List<Carta> buscarCartasBD(String texto, boolean soloDisponibles, String dueno,
                                       boolean ordenarPorPuntos, String tipoFiltro) {

        List<Carta> lista = new ArrayList<>();

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "SELECT * FROM Carta WHERE Dueno='" + dueno + "'";

            if (texto != null && !texto.isEmpty()) {
                sql += " AND Nombre LIKE '%" + texto + "%'";
            }

            if (soloDisponibles) {
                sql += " AND Estado='DISPONIBLE'";
            }

            if (tipoFiltro != null && !tipoFiltro.isEmpty()) {
                sql += " AND Tipo='" + tipoFiltro + "'";
            }

            if (ordenarPorPuntos) {
                sql += " ORDER BY Puntuacion DESC";
            }

            System.out.println("SQL ejecutado: " + sql);

            ResultSet rs = db.executeQuery(sql);

            while (rs.next()) {

                Carta carta = new Carta(
                        rs.getInt("id_carta"),
                        rs.getString("Dueno"),
                        rs.getString("Nombre"),
                        rs.getString("Tipo"),
                        rs.getInt("Puntuacion"),
                        Carta.EstadoC.valueOf(rs.getString("Estado")),
                        rs.getDate("FechaAlta")
                );

                lista.add(carta);
            }

            System.out.println("Cartas encontradas: " + lista.size());

        } catch (Exception e) {

            System.err.println("ERROR buscando cartas");
            e.printStackTrace();

        } finally {

            db.disconnect();
        }

        return lista;
    }

    private boolean insertarCartaBD(Carta carta) {

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "INSERT INTO Carta (Dueno, Nombre, Tipo, Puntuacion, Estado, FechaAlta) VALUES (" +
                    "'" + carta.dueno + "', " +
                    "'" + carta.nombre + "', " +
                    "'" + carta.tipo + "', " +
                    carta.puntuacion + ", " +
                    "'" + carta.estado + "', NOW())";

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

    private boolean modificarCartaBD(Carta carta) {

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "UPDATE Carta SET " +
                    "Dueno='" + carta.dueno + "', " +
                    "Nombre='" + carta.nombre + "', " +
                    "Tipo='" + carta.tipo + "', " +
                    "Puntuacion=" + carta.puntuacion + ", " +
                    "Estado='" + carta.estado + "' " +
                    "WHERE id_carta=" + carta.idCarta;

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

    private boolean borrarCartaBD(int id) {

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "DELETE FROM Carta WHERE id_carta=" + id;

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

    private Carta buscarCartaPorIdBD(int id) {

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "SELECT * FROM Carta WHERE id_carta=" + id;

            System.out.println("SQL SELECT: " + sql);

            ResultSet rs = db.executeQuery(sql);

            if (rs.next()) {

                return new Carta(
                        rs.getInt("id_carta"),
                        rs.getString("Dueno"),
                        rs.getString("Nombre"),
                        rs.getString("Tipo"),
                        rs.getInt("Puntuacion"),
                        Carta.EstadoC.valueOf(rs.getString("Estado")),
                        rs.getDate("FechaAlta")
                );
            }

        } catch (Exception e) {

            System.err.println("ERROR buscando carta por id");
            e.printStackTrace();

        } finally {

            db.disconnect();
        }

        return null;
    }

    private boolean actualizarEstadoBD(int id, String nuevoEstado) {

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "UPDATE Carta SET Estado='" + nuevoEstado + "' WHERE id_carta=" + id;

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