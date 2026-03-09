<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
<%@ include file="WEB-INF/includes/atributosComunes.jsp" %>
<%
    String idCarta = request.getParameter("id");
    if (idCarta == null) {
        idCarta = "";
    }

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modificar Carta</title>
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
            <form id="modificar-carta-form" method="post" action="modificarCarta.jsp">
                <h2>Modificar Carta</h2>
                <input type="hidden" name="id" value="<%= idCarta %>">
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
                        <option value="NO_INTERCAMBIABLE">No intercambiable</option>
                    </select>
                </div>
                <div>
                    <label for="fecha-alta">Fecha de alta:</label>
                    <input type="text" id="fecha-alta" name="fecha-alta" value="" readonly>
                </div>
                <div>
                    <button class="aceptar" type="submit">Aceptar</button>
                    <button class="cancelar" type="button" class="navegacion" onclick="window.history.back();">Cancelar</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
