<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
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
            const radioButtons = document.querySelectorAll('input[name="seleccionarSolicitud"]');
            const aceptBtn = document.getElementById("aceptarSolicitud");
            const rechazarBtn = document.getElementById("rechazarSolicitud");
            const isAnySelected = Array.from(radioButtons).some(radio => radio.checked);

            aceptBtn.disabled = !isAnySelected;
            rechazarBtn.disabled = !isAnySelected;
        }

        function aceptar_Solicitud() {
            if (confirm("Estas seguro de querer aceptar esta solicitud?")) {
                // TODO: enlazar aceptarSolicitud.jsp
            }
        }

        function rechazar_Solicitud() {
            if (confirm("Estas seguro de querer rechazar esta solicitud?")) {
                // TODO: enlazar rechazarSolicitud.jsp
            }
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
            <a href="index.jsp" class="logout-link"> <i class="fas fa-sign-out-alt"></i>
            </a>
        </div>

    </header>
    <main><div class="content-container">
        <h2>Solicitudes Recibidas</h2>
        <p>Seccion para revisar las solicitudes de intercambio que te han enviado.</p>
        <div class="action-buttons">
            <button id="aceptarSolicitud" disabled onclick="aceptar_Solicitud();">Aceptar Solicitud</button>
            <button id="rechazarSolicitud" disabled onclick="rechazar_Solicitud();">Rechazar Solicitud</button>
        </div>
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
                    <tr>
                        <td><input type="radio" name="seleccionarSolicitud" onclick="habilitarBotones()"></td>
                        <td>Pikachu</td>
                        <td>Bulbasaur</td>
                        <td>user2</td>
                        <td>Pendiente</td>
                        <td>2025-02-01</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="seleccionarSolicitud" onclick="habilitarBotones()"></td>
                        <td>Charizar</td>
                        <td>Bulbasaur</td>
                        <td>user5</td>
                        <td>Aceptada</td>
                        <td>2025-02-10</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div></main>
</body>
</html>
