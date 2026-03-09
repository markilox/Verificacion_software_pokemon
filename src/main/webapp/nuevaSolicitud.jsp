<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
<%`r`n    String fechaHoy = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String jsUsuario = usuario.replace("\\", "\\\\").replace("\"", "\\\"");

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva Solicitud</title>
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

        function abrirModal1() { document.getElementById("modal1").style.display = "flex"; }
        function cerrarModal1() { document.getElementById("modal1").style.display = "none"; }
        function abrirModal2() { document.getElementById("modal2").style.display = "flex"; }
        function cerrarModal2() { document.getElementById("modal2").style.display = "none"; }

        function Buscar1() { }
        function Buscar2() { }

        function seleccionarCarta1(nombre, dueno, event) {
            if (event) event.preventDefault();
            document.getElementById("carta").value = nombre + " (Dueno: " + dueno + ")";
            cerrarModal1();
        }
        function seleccionarCarta2(nombre, event) {
            if (event) event.preventDefault();
            document.getElementById("micarta").value = nombre + " (Dueno: " + usuario + ")";
            cerrarModal2();
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
            <a class="active" href="#" onclick="ir_SolicitudesEnviadas(); return false;">Solicitudes Enviadas</a>
        </nav>

        <div class="user-info">
            <div class="user-name" id="user-name"><%= usuario %></div>
            <a href="index.jsp" class="logout-link"> <i class="fas fa-sign-out-alt"></i>
            </a>
        </div>

    </header>

    <main>
        <div class="content-container">
            <form id="nueva-solicitud-form" method="post" action="nuevaSolicitud.jsp">
                <h2>Nueva Solicitud</h2>

                <div>
                    <label for="carta">Carta de otro usuario:</label>
                    <div class="adyacente">
                        <input type="text" id="carta" name="carta" maxlength="20" readonly>
                        <button type="button" onclick="abrirModal1()">...</button>
                    </div>
                </div>

                <div id="modal1" class="ventana_modal">
                    <div class="modal-content">
                        <span class="close" onclick="cerrarModal1()">&times;</span>
                        <input type="text" id="buscar1" placeholder="Buscar carta por nombre...">
                        <button type="button" onclick="Buscar1()">Buscar</button>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Nombre</th>
                                        <th>Dueno</th>
                                        <th>Seleccionar</th>
                                    </tr>
                                </thead>
                                <tbody id="tabla-modal1">
                                    <tr><td>Pikachu</td><td>user2</td><td><button onclick="seleccionarCarta1('Pikachu', 'user2', event)">Seleccionar</button></td></tr>
                                    <tr><td>Bulbasaur</td><td>user3</td><td><button onclick="seleccionarCarta1('Bulbasaur', 'user3', event)">Seleccionar</button></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div>
                    <label for="micarta">Carta que ofreces:</label>
                    <div class="adyacente">
                        <input type="text" id="micarta" name="micarta" maxlength="20" readonly>
                        <button type="button" onclick="abrirModal2()">...</button>
                    </div>
                </div>

                <div id="modal2" class="ventana_modal">
                    <div class="modal-content">
                        <span class="close" onclick="cerrarModal2()">&times;</span>
                        <input type="text" id="buscar2" placeholder="Buscar entre mis cartas por nombre...">
                        <button type="button" onclick="Buscar2()">Buscar</button>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Nombre</th>
                                        <th>Estado</th>
                                        <th>Seleccionar</th>
                                    </tr>
                                </thead>
                                <tbody id="tabla-modal2">
                                    <tr><td>Pikachu</td><td>Disponible</td><td><button onclick="seleccionarCarta2('Pikachu', event)">Seleccionar</button></td></tr>
                                    <tr><td>Bulbasaur</td><td>Disponible</td><td><button onclick="seleccionarCarta2('Bulbasaur', event)">Seleccionar</button></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div>
                    <label for="estado">Estado de la Solicitud:</label>
                    <input type="text" id="estado" name="estado" value="Pendiente" readonly>
                </div>
                <div>
                    <label for="fecha-solicitud">Fecha de la Solicitud:</label>
                    <input type="text" id="fecha-solicitud" name="fecha-solicitud" value="<%= fechaHoy %>" readonly>
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
