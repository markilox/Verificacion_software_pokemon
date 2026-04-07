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
                try {
                    Solicitud solicitud = Solicitud.obtenerPorIdYDueno2(idSolicitud, usuario);
                    if (solicitud == null) {
                        mensajeTexto = "Error: solicitud no encontrada.";
                        mensajeClase = "mensaje_error";
                    } else {
                        solicitud.borrar();
                        String destino = "solicitudesEnviadas.jsp?mensaje="
                                + java.net.URLEncoder.encode("Solicitud borrada correctamente", "UTF-8");
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
                    mensajeTexto = "Error: fallo en base de datos al borrar la solicitud.";
                    mensajeClase = "mensaje_error";
                }
            }
        }
    }

    List<Solicitud.ResumenSolicitud> solicitudes = new ArrayList<Solicitud.ResumenSolicitud>();
    try {
        solicitudes = Solicitud.obtenerSolicitudesEnviadas(usuario);
    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: no se pudieron cargar las solicitudes enviadas.";
            mensajeClase = "mensaje_error";
        }
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
                <% for (Solicitud.ResumenSolicitud fila : solicitudes) { %>
                <tr>
                    <td><input type="radio" name="seleccionarSolicitud" value="<%= fila.idSolicitud %>" onclick="habilitarBotones()"></td>
                    <td><%= fila.cartaSolicitada %></td>
                    <td><%= fila.duenoCartaSolicitada %></td>
                    <td><%= fila.cartaOfrecida %></td>
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
