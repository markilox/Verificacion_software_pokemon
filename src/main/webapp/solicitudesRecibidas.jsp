<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.Solicitud" %>
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
            try {
                Solicitud solicitud = Solicitud.obtenerPorIdYDueno1(idSolicitud, usuario);
                if (solicitud == null) {
                    mensajeTexto = "Error: solicitud no encontrada.";
                    mensajeClase = "mensaje_error";
                } else if ("aceptar".equalsIgnoreCase(action)) {
                    solicitud.aceptar();
                    String destino = "solicitudesRecibidas.jsp?mensaje="
                            + java.net.URLEncoder.encode("Solicitud aceptada correctamente", "UTF-8");
                    response.sendRedirect(destino);
                    return;
                } else {
                    solicitud.rechazar();
                    String destino = "solicitudesRecibidas.jsp?mensaje="
                            + java.net.URLEncoder.encode("Solicitud rechazada correctamente", "UTF-8");
                    response.sendRedirect(destino);
                    return;
                }
            } catch (IllegalArgumentException e) {
                mensajeTexto = "Error: " + e.getMessage();
                mensajeClase = "mensaje_error";
            } catch (IllegalStateException e) {
                mensajeTexto = "Error: " + e.getMessage();
                mensajeClase = "mensaje_error";
            } catch (Exception e) {
                mensajeTexto = "Error: fallo en base de datos al procesar la solicitud.";
                mensajeClase = "mensaje_error";
            }
        }
    }

    List<Solicitud.ResumenSolicitud> solicitudes = new ArrayList<Solicitud.ResumenSolicitud>();
    try {
        solicitudes = Solicitud.obtenerSolicitudesRecibidas(usuario);
    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: no se pudieron cargar las solicitudes recibidas.";
            mensajeClase = "mensaje_error";
        }
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
                <% for (Solicitud.ResumenSolicitud fila : solicitudes) { %>
                <tr>
                    <td>
                        <input type="radio" name="seleccionarSolicitud"
                               value="<%= fila.idSolicitud %>"
                               data-estado="<%= fila.estado %>"
                               onclick="habilitarBotones()">
                    </td>
                    <td><%= fila.cartaSolicitada %></td>
                    <td><%= fila.cartaOfrecida %></td>
                    <td><%= fila.duenoCartaOfrecida %></td>
                    <td><%= fila.estado %></td>
                    <td><%= fila.fechaSolicitud %></td>
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
