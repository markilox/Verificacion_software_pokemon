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
        String idSolicitudParam = request.getParameter("idSolicitud");
        int idSolicitud = -1;
        try {
            idSolicitud = Integer.parseInt(idSolicitudParam);
        } catch (NumberFormatException e) {
            idSolicitud = -1;
        }

        if (idSolicitud <= 0 || (!"aceptar".equalsIgnoreCase(action) && !"rechazar".equalsIgnoreCase(action))) {
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
                String dueno1 = null;
                String dueno2 = null;
                String estado = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id_carta1, id_carta2, Dueno1, Dueno2, Estado "
                                + "FROM Solicitud WHERE id_solicitud=? AND Dueno1=? FOR UPDATE")) {
                    ps.setInt(1, idSolicitud);
                    ps.setString(2, usuario);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            idCarta1 = rs.getInt("id_carta1");
                            idCarta2 = rs.getInt("id_carta2");
                            dueno1 = rs.getString("Dueno1");
                            dueno2 = rs.getString("Dueno2");
                            estado = rs.getString("Estado");
                        }
                    }
                }

                if (idCarta1 <= 0 || idCarta2 <= 0) {
                    conn.rollback();
                    mensajeTexto = "Error: solicitud no encontrada.";
                    mensajeClase = "mensaje_error";
                } else if (!"PENDIENTE".equals(estado)) {
                    conn.rollback();
                    mensajeTexto = "Error: la solicitud ya esta resuelta.";
                    mensajeClase = "mensaje_error";
                } else if ("aceptar".equalsIgnoreCase(action)) {
                    int up1;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Carta SET Dueno=?, Estado='DISPONIBLE' WHERE id_carta=?")) {
                        ps.setString(1, dueno2);
                        ps.setInt(2, idCarta1);
                        up1 = ps.executeUpdate();
                    }

                    int up2;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Carta SET Dueno=?, Estado='DISPONIBLE' WHERE id_carta=?")) {
                        ps.setString(1, dueno1);
                        ps.setInt(2, idCarta2);
                        up2 = ps.executeUpdate();
                    }

                    int upSolicitud;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Solicitud SET Estado='ACEPTADO' WHERE id_solicitud=?")) {
                        ps.setInt(1, idSolicitud);
                        upSolicitud = ps.executeUpdate();
                    }

                    if (up1 == 1 && up2 == 1 && upSolicitud == 1) {
                        conn.commit();
                        String destino = "solicitudesRecibidas.jsp?mensaje="
                                + java.net.URLEncoder.encode("Solicitud aceptada correctamente", "UTF-8");
                        response.sendRedirect(destino);
                        return;
                    }

                    conn.rollback();
                    mensajeTexto = "Error: no se pudo aceptar la solicitud.";
                    mensajeClase = "mensaje_error";
                } else {
                    int upCartas;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Carta SET Estado='DISPONIBLE' WHERE id_carta IN (?, ?)")) {
                        ps.setInt(1, idCarta1);
                        ps.setInt(2, idCarta2);
                        upCartas = ps.executeUpdate();
                    }

                    int upSolicitud;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Solicitud SET Estado='RECHAZADO' WHERE id_solicitud=?")) {
                        ps.setInt(1, idSolicitud);
                        upSolicitud = ps.executeUpdate();
                    }

                    if (upCartas >= 1 && upSolicitud == 1) {
                        conn.commit();
                        String destino = "solicitudesRecibidas.jsp?mensaje="
                                + java.net.URLEncoder.encode("Solicitud rechazada correctamente", "UTF-8");
                        response.sendRedirect(destino);
                        return;
                    }

                    conn.rollback();
                    mensajeTexto = "Error: no se pudo rechazar la solicitud.";
                    mensajeClase = "mensaje_error";
                }
            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (Exception ignored) { }
                }
                mensajeTexto = "Error: fallo en base de datos al procesar la solicitud.";
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

    List<String[]> solicitudes = new ArrayList<String[]>();
    DatabaseManager dbList = new DatabaseManager();
    try {
        dbList.connect();
        try (PreparedStatement ps = dbList.getConnection().prepareStatement(
                "SELECT s.id_solicitud, c1.Nombre AS cartaSolicitada, c2.Nombre AS cartaOfrecida, "
                        + "s.Dueno2, s.Estado, DATE_FORMAT(s.FechaSolicitud, '%Y-%m-%d') AS fecha "
                        + "FROM Solicitud s "
                        + "JOIN Carta c1 ON c1.id_carta = s.id_carta1 "
                        + "JOIN Carta c2 ON c2.id_carta = s.id_carta2 "
                        + "WHERE s.Dueno1=? "
                        + "ORDER BY s.FechaSolicitud DESC")) {
            ps.setString(1, usuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    solicitudes.add(new String[] {
                            String.valueOf(rs.getInt("id_solicitud")),
                            rs.getString("cartaSolicitada"),
                            rs.getString("cartaOfrecida"),
                            rs.getString("Dueno2"),
                            rs.getString("Estado"),
                            rs.getString("fecha")
                    });
                }
            }
        }
    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: no se pudieron cargar las solicitudes recibidas.";
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
    <title>Solicitudes Recibidas</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <script>
        function habilitarBotones() {
            const selected = document.querySelector('input[name="seleccionarSolicitud"]:checked');
            const aceptarBtn = document.getElementById("aceptarSolicitud");
            const rechazarBtn = document.getElementById("rechazarSolicitud");
            if (!selected) {
                aceptarBtn.disabled = true;
                rechazarBtn.disabled = true;
                return;
            }
            const esPendiente = selected.dataset.estado === "PENDIENTE";
            aceptarBtn.disabled = !esPendiente;
            rechazarBtn.disabled = !esPendiente;
        }

        function procesarSolicitud(action) {
            const selected = document.querySelector('input[name="seleccionarSolicitud"]:checked');
            if (!selected) {
                return false;
            }
            const texto = action === "aceptar"
                    ? "Estas seguro de querer aceptar esta solicitud?"
                    : "Estas seguro de querer rechazar esta solicitud?";
            if (confirm(texto)) {
                document.getElementById("accionSolicitud").value = action;
                document.getElementById("idSolicitudAccion").value = selected.value;
                document.getElementById("formAccionSolicitud").submit();
            }
            return false;
        }

        function ir_miColeccion() {
            window.location.href = "miColeccion.jsp";
            return true;
        }

        function ir_SolicitudesEnviadas() {
            window.location.href = "solicitudesEnviadas.jsp";
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
        <a class="active" href="#" onclick="return false;">Solicitudes Recibidas</a>
        <a href="#" onclick="ir_SolicitudesEnviadas(); return false;">Solicitudes Enviadas</a>
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
        <h2>Solicitudes Recibidas</h2>
        <p>Seccion para revisar las solicitudes de intercambio que te han enviado.</p>
        <div class="action-buttons">
            <button id="aceptarSolicitud" disabled onclick="procesarSolicitud('aceptar');">Aceptar Solicitud</button>
            <button id="rechazarSolicitud" disabled onclick="procesarSolicitud('rechazar');">Rechazar Solicitud</button>
        </div>

        <form id="formAccionSolicitud" method="post" action="solicitudesRecibidas.jsp" style="display:none;">
            <input type="hidden" id="accionSolicitud" name="action" value="">
            <input type="hidden" id="idSolicitudAccion" name="idSolicitud" value="">
        </form>

        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Seleccionar</th>
                    <th>Carta Solicitada</th>
                    <th>Carta a cambio</th>
                    <th>Dueno</th>
                    <th>Estado</th>
                    <th>Fecha Solicitud</th>
                </tr>
                </thead>
                <tbody>
                <% if (solicitudes.isEmpty()) { %>
                <tr><td colspan="6">No tienes solicitudes recibidas.</td></tr>
                <% } else { %>
                <% for (String[] fila : solicitudes) { %>
                <tr>
                    <td>
                        <input type="radio" name="seleccionarSolicitud"
                               value="<%= fila[0] %>"
                               data-estado="<%= fila[4] %>"
                               onclick="habilitarBotones()">
                    </td>
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
