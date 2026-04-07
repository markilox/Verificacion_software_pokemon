package main.java.pokemon;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CartaDada {

    public List<Carta> buscarCartas(String texto, boolean soloDisponibles, String dueno,
                                    boolean ordenarPorPuntos, String tipoFiltro) throws Exception {

        System.out.println("Buscando cartas del usuario: " + dueno);

        return buscarCartasBD(texto, soloDisponibles, dueno, ordenarPorPuntos, tipoFiltro, false);
    }

    public List<Carta> buscarCartasDeOtrosUsuarios(String texto, boolean soloDisponibles,
                                                   String duenoExcluido, boolean ordenarPorPuntos,
                                                   String tipoFiltro) throws Exception {

        System.out.println("Buscando cartas de usuarios distintos de: " + duenoExcluido);

        return buscarCartasBD(texto, soloDisponibles, duenoExcluido, ordenarPorPuntos, tipoFiltro, true);
    }

    public Carta obtenerCartaPorId(int id) throws Exception {

        System.out.println("Buscando carta id: " + id);

        return buscarCartaPorIdBD(id);
    }

    private List<Carta> buscarCartasBD(String texto, boolean soloDisponibles, String dueno,
                                       boolean ordenarPorPuntos, String tipoFiltro,
                                       boolean excluirDueno) {

        List<Carta> lista = new ArrayList<Carta>();

        DatabaseManager db = new DatabaseManager();

        try {

            db.connect();
            Connection connection = db.getConnection();
            StringBuilder sql = new StringBuilder("SELECT * FROM Carta WHERE ");
            List<Object> parametros = new ArrayList<Object>();

            if (excluirDueno) {
                sql.append("Dueno<>?");
            } else {
                sql.append("Dueno=?");
            }
            parametros.add(dueno);

            if (texto != null && !texto.isEmpty()) {
                sql.append(" AND Nombre LIKE ?");
                parametros.add("%" + texto + "%");
            }

            if (soloDisponibles) {
                sql.append(" AND Estado=?");
                parametros.add(Carta.EstadoC.DISPONIBLE.name());
            }

            if (tipoFiltro != null && !tipoFiltro.isEmpty()) {
                sql.append(" AND Tipo=?");
                parametros.add(tipoFiltro);
            }

            if (ordenarPorPuntos) {
                sql.append(" ORDER BY Puntuacion DESC");
            } else {
                sql.append(" ORDER BY CASE WHEN Estado='DISPONIBLE' THEN 0 ELSE 1 END, Nombre ASC");
            }

            System.out.println("SQL ejecutado: " + sql);

            try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
                for (int i = 0; i < parametros.size(); i++) {
                    ps.setObject(i + 1, parametros.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
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
                }
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
            Connection connection = db.getConnection();
            String sql = "SELECT * FROM Carta WHERE id_carta=?";

            System.out.println("SQL SELECT: " + sql);

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, id);

                try (ResultSet rs = ps.executeQuery()) {
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
                }
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
