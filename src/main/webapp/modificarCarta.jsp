<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.DatabaseManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
<%@ include file="WEB-INF/includes/atributosComunes.jsp" %>
<%
    String mensajeTexto = "";
    String mensajeClase = "mensaje";

    String idCartaParam = request.getParameter("id");
    int idCarta = -1;
    try {
        idCarta = Integer.parseInt(idCartaParam);
    } catch (Exception e) {
        idCarta = -1;
    }

    String nombre = "";
    String puntos = "";
    String tipo = "Planta";
    String estado = "DISPONIBLE";
    String fechaAlta = "";
    boolean cartaEncontrada = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        nombre = request.getParameter("nombre");
        puntos = request.getParameter("puntos");
        tipo = request.getParameter("tipo");
        estado = request.getParameter("estado");

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
        } catch (NumberFormatException e) {
            puntosValor = -1;
        }

        boolean estadoValido = "DISPONIBLE".equals(estado)
                || "RESERVADA".equals(estado)
                || "NO_INTERCAMBIA".equals(estado);

        if (idCarta <= 0) {
            mensajeTexto = "Error: carta no valida.";
            mensajeClase = "mensaje_error";
        } else if (nombre.isEmpty()) {
            mensajeTexto = "Error: el nombre es obligatorio.";
            mensajeClase = "mensaje_error";
        } else if (puntosValor < 0) {
            mensajeTexto = "Error: la puntuacion debe ser un numero valido.";
            mensajeClase = "mensaje_error";
        } else if (!estadoValido) {
            mensajeTexto = "Error: estado no valido.";
            mensajeClase = "mensaje_error";
        } else {
            DatabaseManager db = new DatabaseManager();
            try {
                db.connect();
                try (PreparedStatement ps = db.getConnection().prepareStatement(
                        "UPDATE Carta SET Nombre=?, Tipo=?, Puntuacion=?, Estado=? WHERE id_carta=? AND Dueno=?")) {
                    ps.setString(1, nombre);
                    ps.setString(2, tipo);
                    ps.setInt(3, puntosValor);
                    ps.setString(4, estado);
                    ps.setInt(5, idCarta);
                    ps.setString(6, usuario);

                    int actualizadas = ps.executeUpdate();
                    if (actualizadas > 0) {
                        String destino = "miColeccion.jsp?mensaje="
                                + java.net.URLEncoder.encode("Carta modificada correctamente", "UTF-8");
                        response.sendRedirect(destino);
                        return;
                    }
                    mensajeTexto = "Error: no se pudo modificar la carta.";
                    mensajeClase = "mensaje_error";
                }
            } catch (Exception e) {
                mensajeTexto = "Error: fallo al modificar la carta en base de datos.";
                mensajeClase = "mensaje_error";
            } finally {
                db.disconnect();
            }
        }
    }

    if (idCarta > 0) {
        DatabaseManager db = new DatabaseManager();
        try {
            db.connect();
            try (PreparedStatement ps = db.getConnection().prepareStatement(
                    "SELECT Nombre, Puntuacion, Tipo, Estado, DATE_FORMAT(FechaAlta, '%Y-%m-%d') AS fecha "
                            + "FROM Carta WHERE id_carta=? AND Dueno=?")) {
                ps.setInt(1, idCarta);
                ps.setString(2, usuario);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        cartaEncontrada = true;
                        if (!"POST".equalsIgnoreCase(request.getMethod())) {
                            nombre = rs.getString("Nombre");
                            puntos = String.valueOf(rs.getInt("Puntuacion"));
                            tipo = rs.getString("Tipo");
                            estado = rs.getString("Estado");
                        }
                        fechaAlta = rs.getString("fecha");
                    }
                }
            }
        } catch (Exception e) {
            if (mensajeTexto.isEmpty()) {
                mensajeTexto = "Error: no se pudo cargar la carta.";
                mensajeClase = "mensaje_error";
            }
        } finally {
            db.disconnect();
        }
    }

    if (!cartaEncontrada && mensajeTexto.isEmpty()) {
        mensajeTexto = "Error: carta no encontrada para este usuario.";
        mensajeClase = "mensaje_error";
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modificar Carta</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <script>
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

        function cancelar_Modificacion() {
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
        <a href="index.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i></a>
    </div>
</header>

<main>
    <% if (!mensajeTexto.isEmpty()) { %>
    <div class="<%= mensajeClase %>"><%= mensajeTexto %></div>
    <% } %>

    <div class="content-container">
        <% if (cartaEncontrada) { %>
        <form id="modificar-carta-form" method="post" action="modificarCarta.jsp">
            <h2>Modificar Carta</h2>
            <input type="hidden" name="id" value="<%= idCarta %>">
            <div>
                <label for="dueno">Dueno:</label>
                <input type="text" id="dueno" name="dueno" value="<%= usuario %>" readonly>
            </div>
            <div>
                <label for="nombre">Nombre:</label>
                <input type="text" id="nombre" name="nombre" maxlength="20" value="<%= nombre %>" required>
            </div>
            <div>
                <label for="puntos">Puntos:</label>
                <input type="number" id="puntos" name="puntos" max="9999" value="<%= puntos %>" required>
            </div>
            <div>
                <label for="tipo">Tipo:</label>
                <select id="tipo" name="tipo" required>
                    <option value="Planta" <%= "Planta".equals(tipo) ? "selected" : "" %>>Planta</option>
                    <option value="Electrico" <%= "Electrico".equals(tipo) ? "selected" : "" %>>Electrico</option>
                    <option value="Agua" <%= "Agua".equals(tipo) ? "selected" : "" %>>Agua</option>
                    <option value="Dragon" <%= "Dragon".equals(tipo) ? "selected" : "" %>>Dragon</option>
                </select>
            </div>
            <div>
                <label for="estado">Estado:</label>
                <select id="estado" name="estado" required>
                    <option value="DISPONIBLE" <%= "DISPONIBLE".equals(estado) ? "selected" : "" %>>Disponible</option>
                    <option value="RESERVADA" <%= "RESERVADA".equals(estado) ? "selected" : "" %>>Reservada</option>
                    <option value="NO_INTERCAMBIA" <%= "NO_INTERCAMBIA".equals(estado) ? "selected" : "" %>>No intercambiable</option>
                </select>
            </div>
            <div>
                <label for="fecha-alta">Fecha de alta:</label>
                <input type="text" id="fecha-alta" name="fecha-alta" value="<%= fechaAlta %>" readonly>
            </div>
            <div>
                <button class="aceptar" type="submit">Aceptar</button>
                <button class="cancelar" type="button" onclick="cancelar_Modificacion();">Cancelar</button>
            </div>
        </form>
        <% } else { %>
        <div class="action-buttons">
            <button type="button" onclick="ir_miColeccion();">Volver a Mi Coleccion</button>
        </div>
        <% } %>
    </div>
</main>
</body>
</html>
