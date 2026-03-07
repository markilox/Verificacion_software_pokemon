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

    public Carta obtenerCartaPorId(int id) throws Exception {

        System.out.println("Buscando carta id: " + id);

        return buscarCartaPorIdBD(id);
    }


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

            while (rs != null && rs.next()) {

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

    private Carta buscarCartaPorIdBD(int id) {

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();

            String sql = "SELECT * FROM Carta WHERE id_carta=" + id;

            System.out.println("SQL SELECT: " + sql);

            ResultSet rs = db.executeQuery(sql);

            if (rs != null && rs.next()) {

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
}