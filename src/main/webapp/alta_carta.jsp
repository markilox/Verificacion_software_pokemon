<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.Carta" %>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
<%@ include file="WEB-INF/includes/atributosComunes.jsp" %>
<%
    String mensaje = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nombre = request.getParameter("nombre");
        String puntos = request.getParameter("puntos");
        String tipo = request.getParameter("tipo");
        String estado = request.getParameter("estado");

        if (nombre == null) {
            nombre = "";
        }
        if (puntos == null) {
            puntos = "";
        }
        if (tipo == null || tipo.isEmpty()) {
            tipo = "Planta";
        }
        if (estado == null || estado.isEmpty()) {
            estado = "DISPONIBLE";
        }

        nombre = nombre.trim();
        puntos = puntos.trim();

        int puntosValor = -1;
        try {
            puntosValor = Integer.parseInt(puntos);
        }
        catch (NumberFormatException e) {
            puntosValor = -1;
        }

        if (nombre.isEmpty()) {
            mensaje = "<div class='mensaje_error'>Error: el nombre es obligatorio.</div>";
        }
        else if (puntosValor < 0) {
            mensaje = "<div class='mensaje_error'>Error: la puntuacion debe ser un numero valido.</div>";
        }
        else {
            try {
                Carta.EstadoC estadoCarta = Carta.EstadoC.valueOf(estado);
                Carta carta = new Carta(usuario, nombre, tipo, puntosValor, estadoCarta, new java.util.Date());
                boolean guardada = carta.guardar();

                if (guardada) {
                    String destino = "miColeccion.jsp?mensaje="
                            + java.net.URLEncoder.encode("Carta creada correctamente", "UTF-8");
                    response.sendRedirect(destino);
                    return;
                }
                else {
                    mensaje = "<div class='mensaje_error'>Error: no se pudo crear la carta.</div>";
                }
            }
            catch (IllegalArgumentException e) {
                mensaje = "<div class='mensaje_error'>Error: estado de carta invalido.</div>";
            }
            catch (Exception e) {
                mensaje = "<div class='mensaje_error'>Error al guardar la carta en base de datos.</div>";
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alta Carta Nueva</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <script>
        var usuario = "<%= jsUsuario %>";

        function ir_miColeccion() {
            window.location.href = "miColeccion.jsp";
            return true;
        }
        function ir_SolicitudesEnviadas() {
            window.location.href = "solicitudesEnviadas.jsp";
            return true;
        }
        function ir_SolicitudesRecibidas() {
            window.location.href = "solicitudesRecibidas.jsp";
            return true;
        }

        function cancelar_Alta() {
            window.location.href = "miColeccion.jsp";
            return false;
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
            <a class="active" href="#" onclick="ir_miColeccion(); return false;">Mi Coleccion</a>
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
        <div class="content-container">
            <%= mensaje %>
            <form id="alta-carta-form" method="post" action="alta_carta.jsp">
                <h2>Nueva Carta</h2>
                <div>
                    <label for="dueno">Dueno:</label>
                    <input type="text" id="dueno" name="dueno" value="<%= usuario %>" readonly>
                </div>
                <div>
                    <label for="nombre">Nombre:</label>
                    <input type="text" id="nombre" name="nombre" maxlength="20" required>
                </div>
                <div>
                    <label for="puntos">Puntos:</label>
                    <input type="number" id="puntos" name="puntos" max="9999" required>
                </div>
                <div>
                    <label for="tipo">Tipo:</label>
                    <select id="tipo" name="tipo" required>
                        <option value="Planta">Planta</option>
                        <option value="Electrico">Electrico</option>
                        <option value="Agua">Agua</option>
                        <option value="Dragon">Dragon</option>
                    </select>
                </div>
                <div>
                    <label for="estado">Estado:</label>
                    <select id="estado" name="estado" required>
                        <option value="DISPONIBLE">Disponible</option>
                        <option value="RESERVADA">Reservada</option>
                        <option value="NO_INTERCAMBIA">No intercambiable</option>
                    </select>
                </div>
                <div>
                    <label for="fecha-alta">Fecha de alta:</label>
                    <input type="text" id="fecha-alta" name="fecha-alta" value="<%= fechaHoy %>" readonly>
                </div>
                <div>
                    <button class="aceptar" type="submit">Aceptar</button>
                    <button class="cancelar" type="button" class="navegacion" onclick="cancelar_Alta();">Cancelar</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
