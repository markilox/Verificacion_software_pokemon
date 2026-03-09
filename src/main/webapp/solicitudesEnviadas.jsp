<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
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
            if (confirm("Estas seguro de querer eliminar esta solicitud para siempre?")) {
                // TODO: enlazar borrarSolicitud.jsp
            }
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
            <a href="index.jsp" class="logout-link"> <i class="fas fa-sign-out-alt"></i>
            </a>
        </div>

    </header>

    <main><div class="content-container">
        <h2>Solicitudes Enviadas</h2>
        <p>Seccion para revisar solicitudes que has enviado a otros usuarios.</p>

        <div class="action-buttons">
            <button id="nuevaSolicitud" onclick="nueva_Solicitud();">Nueva Solicitud</button>
            <button id="borrarSolicitud" disabled onclick="borrar_Solicitud();">Borrar Solicitud</button>
        </div>
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
                    <tr>
                        <td><input type="radio" name="seleccionarSolicitud" onclick="habilitarBotones()"></td>
                        <td>Pikachu</td>
                        <td>user4</td>
                        <td>Bulbasaur</td>
                        <td>Pendiente</td>
                        <td>2025-02-02</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="seleccionarSolicitud" onclick="habilitarBotones()"></td>
                        <td>Charizar</td>
                        <td>user3</td>
                        <td>Bulbasaur</td>
                        <td>Aceptada</td>
                        <td>2025-02-01</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div></main>
</body>
</html>
