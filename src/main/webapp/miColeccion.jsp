<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.Carta" %>
<%@ page import="main.java.pokemon.CartaDada" %>
<%@ page import="java.util.List" %>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>

<%
    String mensaje = request.getParameter("mensaje");

    if (mensaje != null && !mensaje.isEmpty()) {
        if (mensaje.toLowerCase().contains("error")) {
            mensaje = "<div class='mensaje_error'>" + mensaje + "</div>";
        }
        else {
            mensaje = "<div class='mensaje'>" + mensaje + "</div>";
        }
    }
    else {
        mensaje = "";
    }

    CartaDada cartaDada = new CartaDada();
    List<Carta> listaCartas = null;
    try {
        listaCartas = cartaDada.buscarCartas("", true, usuario, false, "");
    }
    catch (Exception e) {
        mensaje = mensaje + "<div class='mensaje_error'>Error de conexion a base de datos.</div>";
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
                window.location.href = "modificarCarta.jsp?id=" + id.value;
            }
            return true;
        }

        function Borrar_Carta() {
            const id = document.querySelector('input[name="seleccionarCarta"]:checked');
            if (confirm("Estas seguro de querer eliminar esta carta para siempre?")) {
                if (id) {
                    window.location.href = "borrarCarta.jsp?id=" + id.value;
                }
            }
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
        <a href="index.jsp" class="logout-link"> <i class="fas fa-sign-out-alt"></i>
        </a>
    </div>
</header>

<main>
    <%= mensaje %>
    <div class="content-container">
        <h2>Mi Coleccion</h2>
        <p>En esta seccion veras todas las cartas de tu coleccion.</p>
        <div class="action-buttons">
            <button id="nuevaCarta" onclick="Nueva_Carta();">Nueva Carta</button>
            <button id="modificarCarta" disabled onclick="Modificar_Carta();">Modificar Carta</button>
            <button id="borrarCarta" disabled onclick="Borrar_Carta();">Borrar Carta</button>
        </div>
        <div class="table-container">
            <% if (listaCartas == null || listaCartas.isEmpty()) { %>
            <table>
                <thead>
                <tr><th>Todavia no tienes ninguna carta en tu coleccion.</th></tr>
                </thead>
            </table>
            <% } else { %>
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

                </tbody>
            </table>
            <% } %>
        </div>
    </div>
</main>
</body>
</html>
