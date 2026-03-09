<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.Carta" %>
<%@ page import="main.java.pokemon.CartaDada" %>
<%@ page import="main.java.pokemon.DatabaseManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.PreparedStatement" %>
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
            String idCartaParam = request.getParameter("idCarta");
            int idCarta = -1;
            try {
                idCarta = Integer.parseInt(idCartaParam);
            } catch (NumberFormatException e) {
                idCarta = -1;
            }

            if (idCarta <= 0) {
                mensajeTexto = "Error: carta no valida.";
                mensajeClase = "mensaje_error";
            } else {
                DatabaseManager db = new DatabaseManager();
                try {
                    db.connect();
                    try (PreparedStatement ps = db.getConnection().prepareStatement(
                            "DELETE FROM Carta WHERE id_carta=? AND Dueno=?")) {
                        ps.setInt(1, idCarta);
                        ps.setString(2, usuario);
                        int borradas = ps.executeUpdate();
                        if (borradas > 0) {
                            String destino = "miColeccion.jsp?mensaje="
                                    + java.net.URLEncoder.encode("Carta borrada correctamente", "UTF-8");
                            response.sendRedirect(destino);
                            return;
                        }
                        mensajeTexto = "Error: no se pudo borrar la carta.";
                        mensajeClase = "mensaje_error";
                    }
                } catch (Exception e) {
                    mensajeTexto = "Error: fallo al borrar la carta en base de datos.";
                    mensajeClase = "mensaje_error";
                } finally {
                    db.disconnect();
                }
            }
        }
    }

    CartaDada cartaDada = new CartaDada();
    List<Carta> listaCartas = null;
    try {
        listaCartas = cartaDada.buscarCartas("", false, usuario, false, "");
    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: fallo de conexion con la base de datos.";
            mensajeClase = "mensaje_error";
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Coleccion</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <script>
        function habilitarBotones() {
            const radioButtons = document.querySelectorAll('input[name="seleccionarCarta"]');
            const modificarBtn = document.getElementById("modificarCarta");
            const borrarBtn = document.getElementById("borrarCarta");
            const isAnySelected = Array.from(radioButtons).some(radio => radio.checked);

            modificarBtn.disabled = !isAnySelected;
            borrarBtn.disabled = !isAnySelected;
        }

        function Nueva_Carta() {
            window.location.href = "alta_carta.jsp";
            return true;
        }

        function Modificar_Carta() {
            const id = document.querySelector('input[name="seleccionarCarta"]:checked');
            if (id) {
                window.location.href = "modificarCarta.jsp?id=" + encodeURIComponent(id.value);
            }
            return true;
        }

        function Borrar_Carta() {
            const id = document.querySelector('input[name="seleccionarCarta"]:checked');
            if (!id) {
                return false;
            }
            if (confirm("Estas seguro de querer eliminar esta carta para siempre?")) {
                document.getElementById("idCartaBorrar").value = id.value;
                document.getElementById("formBorrarCarta").submit();
            }
            return false;
        }

        function ir_SolicitudesEnviadas() {
            window.location.href = "solicitudesEnviadas.jsp";
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
        <a href="#" class="active">Mi Coleccion</a>
        <a href="#" onclick="ir_SolicitudesRecibidas(); return false;">Solicitudes Recibidas</a>
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
        <h2>Mi Coleccion</h2>
        <p>En esta seccion veras todas las cartas de tu coleccion.</p>
        <div class="action-buttons">
            <button id="nuevaCarta" onclick="Nueva_Carta();">Nueva Carta</button>
            <button id="modificarCarta" disabled onclick="Modificar_Carta();">Modificar Carta</button>
            <button id="borrarCarta" disabled onclick="Borrar_Carta();">Borrar Carta</button>
        </div>

        <form id="formBorrarCarta" method="post" action="miColeccion.jsp" style="display:none;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" id="idCartaBorrar" name="idCarta" value="">
        </form>

        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Seleccionar</th>
                    <th>Nombre</th>
                    <th>Puntos</th>
                    <th>Tipo</th>
                    <th>Fecha Alta</th>
                    <th>Estado</th>
                </tr>
                </thead>
                <tbody>
                <% if (listaCartas == null || listaCartas.isEmpty()) { %>
                <tr>
                    <td colspan="6">Todavia no tienes ninguna carta en tu coleccion.</td>
                </tr>
                <% } else { %>
                <% for (Carta carta : listaCartas) { %>
                <tr>
                    <td><input type="radio" name="seleccionarCarta" onclick="habilitarBotones();" value="<%= carta.idCarta %>"></td>
                    <td><%= carta.nombre %></td>
                    <td><%= carta.puntuacion %></td>
                    <td><%= carta.tipo %></td>
                    <%
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
                        String fechaFormateada = carta.fechaAlta != null ? sdf.format(carta.fechaAlta) : "";
                    %>
                    <td><%= fechaFormateada %></td>
                    <td><%= carta.estado %></td>
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
