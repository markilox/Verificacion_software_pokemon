<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.DatabaseManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
<%
    String mensajeTexto = request.getParameter("mensaje");
    String mensajeClase = "mensaje";
    if (mensajeTexto == null) {
        mensajeTexto = "";
    }
    if (mensajeTexto.toLowerCase().contains("error")) {
        mensajeClase = "mensaje_error";
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            String idSolicitudParam = request.getParameter("idSolicitud");
            int idSolicitud = -1;
            try {
                idSolicitud = Integer.parseInt(idSolicitudParam);
            } catch (NumberFormatException e) {
                idSolicitud = -1;
            }

            if (idSolicitud <= 0) {
                mensajeTexto = "Error: solicitud no valida.";
                mensajeClase = "mensaje_error";
            } else {
                DatabaseManager db = new DatabaseManager();
                Connection conn = null;
                try {
                    db.connect();
                    conn = db.getConnection();
                    conn.setAutoCommit(false);

                    int idCarta1 = -1;
                    int idCarta2 = -1;
                    String estado = null;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "SELECT id_carta1, id_carta2, Estado FROM Solicitud WHERE id_solicitud=? AND Dueno2=? FOR UPDATE")) {
                        ps.setInt(1, idSolicitud);
                        ps.setString(2, usuario);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                idCarta1 = rs.getInt("id_carta1");
                                idCarta2 = rs.getInt("id_carta2");
                                estado = rs.getString("Estado");
                            }
                        }
                    }

                    if (idCarta1 <= 0 || idCarta2 <= 0) {
                        conn.rollback();
                        mensajeTexto = "Error: solicitud no encontrada.";
                        mensajeClase = "mensaje_error";
                    } else {
                        if ("PENDIENTE".equals(estado)) {
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "UPDATE Carta SET Estado='DISPONIBLE' WHERE id_carta IN (?, ?)")) {
                                ps.setInt(1, idCarta1);
                                ps.setInt(2, idCarta2);
                                ps.executeUpdate();
                            }
                        }

                        int borradas = 0;
                        try (PreparedStatement ps = conn.prepareStatement(
                                "DELETE FROM Solicitud WHERE id_solicitud=? AND Dueno2=?")) {
                            ps.setInt(1, idSolicitud);
                            ps.setString(2, usuario);
                            borradas = ps.executeUpdate();
                        }

                        if (borradas > 0) {
                            conn.commit();
                            String destino = "solicitudesEnviadas.jsp?mensaje="
                                    + java.net.URLEncoder.encode("Solicitud borrada correctamente", "UTF-8");
                            response.sendRedirect(destino);
                            return;
                        }

                        conn.rollback();
                        mensajeTexto = "Error: no se pudo borrar la solicitud.";
                        mensajeClase = "mensaje_error";
                    }
                } catch (Exception e) {
                    if (conn != null) {
                        try {
                            conn.rollback();
                        } catch (Exception ignored) { }
                    }
                    mensajeTexto = "Error: fallo en base de datos al borrar la solicitud.";
                    mensajeClase = "mensaje_error";
                } finally {
                    if (conn != null) {
                        try {
                            conn.setAutoCommit(true);
                        } catch (Exception ignored) { }
                    }
                    db.disconnect();
                }
            }
        }
    }

    List<String[]> solicitudes = new ArrayList<String[]>();
    DatabaseManager dbList = new DatabaseManager();
    try {
        dbList.connect();
        try (PreparedStatement ps = dbList.getConnection().prepareStatement(
                "SELECT s.id_solicitud, c1.Nombre AS cartaSolicitada, s.Dueno1, c2.Nombre AS cartaOfrecida, "
                        + "s.Estado, DATE_FORMAT(s.FechaSolicitud, '%Y-%m-%d') AS fecha "
                        + "FROM Solicitud s "
                        + "JOIN Carta c1 ON c1.id_carta = s.id_carta1 "
                        + "JOIN Carta c2 ON c2.id_carta = s.id_carta2 "
                        + "WHERE s.Dueno2=? "
                        + "ORDER BY s.FechaSolicitud DESC")) {
            ps.setString(1, usuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    solicitudes.add(new String[] {
                            String.valueOf(rs.getInt("id_solicitud")),
                            rs.getString("cartaSolicitada"),
                            rs.getString("Dueno1"),
                            rs.getString("cartaOfrecida"),
                            rs.getString("Estado"),
                            rs.getString("fecha")
                    });
                }
            }
        }
    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: no se pudieron cargar las solicitudes enviadas.";
            mensajeClase = "mensaje_error";
        }
    } finally {
        dbList.disconnect();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitudes Enviadas</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <script>
        function habilitarBotones() {
            const radioButtons = document.querySelectorAll('input[name="seleccionarSolicitud"]');
            const borrarBtn = document.getElementById("borrarSolicitud");
            const isAnySelected = Array.from(radioButtons).some(radio => radio.checked);
            borrarBtn.disabled = !isAnySelected;
        }

        function nueva_Solicitud() {
            window.location.href = "nuevaSolicitud.jsp";
            return true;
        }

        function borrar_Solicitud() {
            const id = document.querySelector('input[name="seleccionarSolicitud"]:checked');
            if (!id) {
                return false;
            }
            if (confirm("Estas seguro de querer eliminar esta solicitud para siempre?")) {
                document.getElementById("idSolicitudBorrar").value = id.value;
                document.getElementById("formBorrarSolicitud").submit();
            }
            return false;
        }

        function ir_miColeccion() {
            window.location.href = "miColeccion.jsp";
            return true;
        }

        function ir_SolicitudesRecibidas() {
            window.location.href = "solicitudesRecibidas.jsp";
            return true;
        }
    </script>
</head>
<body>
<header class="header">
    <div class="header-left">
        <img src="logo.png" alt="Logo" class="logo">
        <h1>Pikachu Forever</h1>
    </div>

    <nav class="menu">
        <a href="#" onclick="ir_miColeccion(); return false;">Mi Coleccion</a>
        <a href="#" onclick="ir_SolicitudesRecibidas(); return false;">Solicitudes Recibidas</a>
        <a class="active" href="#" onclick="return false;">Solicitudes Enviadas</a>
    </nav>
    <div class="user-info">
        <div class="user-name" id="user-name"><%= usuario %></div>
        <a href="index.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i></a>
    </div>
</header>

<main>
    <% if (!mensajeTexto.isEmpty()) { %>
    <div class="<%= mensajeClase %>"><%= mensajeTexto %></div>
    <% } %>

    <div class="content-container">
        <h2>Solicitudes Enviadas</h2>
        <p>Seccion para revisar solicitudes que has enviado a otros usuarios.</p>

        <div class="action-buttons">
            <button id="nuevaSolicitud" onclick="nueva_Solicitud();">Nueva Solicitud</button>
            <button id="borrarSolicitud" disabled onclick="borrar_Solicitud();">Borrar Solicitud</button>
        </div>

        <form id="formBorrarSolicitud" method="post" action="solicitudesEnviadas.jsp" style="display:none;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" id="idSolicitudBorrar" name="idSolicitud" value="">
        </form>

        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Seleccionar</th>
                    <th>Carta Solicitada</th>
                    <th>Dueno</th>
                    <th>Carta a cambio</th>
                    <th>Estado Solicitud</th>
                    <th>Fecha Solicitud</th>
                </tr>
                </thead>
                <tbody>
                <% if (solicitudes.isEmpty()) { %>
                <tr><td colspan="6">No tienes solicitudes enviadas.</td></tr>
                <% } else { %>
                <% for (String[] fila : solicitudes) { %>
                <tr>
                    <td><input type="radio" name="seleccionarSolicitud" value="<%= fila[0] %>" onclick="habilitarBotones()"></td>
                    <td><%= fila[1] %></td>
                    <td><%= fila[2] %></td>
                    <td><%= fila[3] %></td>
                    <td><%= fila[4] %></td>
                    <td><%= fila[5] %></td>
                </tr>
                <% } %>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>
</body>
</html>
