<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.Carta" %>
<%@ page import="main.java.pokemon.CartaDada" %>
<%@ page import="main.java.pokemon.Solicitud" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>
<%@ include file="WEB-INF/includes/atributosComunes.jsp" %>
<%
    String mensajeTexto = request.getParameter("mensaje");
    String mensajeClase = "mensaje";
    if (mensajeTexto == null) {
        mensajeTexto = "";
    }
    if (mensajeTexto.toLowerCase().contains("error")) {
        mensajeClase = "mensaje_error";
    }

    String idCartaSolicitadaSel = request.getParameter("idCartaSolicitada");
    String idCartaOfrecidaSel = request.getParameter("idCartaOfrecida");
    if (idCartaSolicitadaSel == null) {
        idCartaSolicitadaSel = "";
    }
    if (idCartaOfrecidaSel == null) {
        idCartaOfrecidaSel = "";
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int idCartaSolicitada = -1;
        int idCartaOfrecida = -1;
        try {
            idCartaSolicitada = Integer.parseInt(idCartaSolicitadaSel);
            idCartaOfrecida = Integer.parseInt(idCartaOfrecidaSel);
        } catch (NumberFormatException e) {
            idCartaSolicitada = -1;
            idCartaOfrecida = -1;
        }

        if (idCartaSolicitada <= 0 || idCartaOfrecida <= 0) {
            mensajeTexto = "Error: debes seleccionar ambas cartas.";
            mensajeClase = "mensaje_error";
        } else if (idCartaSolicitada == idCartaOfrecida) {
            mensajeTexto = "Error: no puedes intercambiar una carta consigo misma.";
            mensajeClase = "mensaje_error";
        } else {
            try {
                Solicitud.crear(idCartaSolicitada, idCartaOfrecida, usuario);
                String destino = "solicitudesEnviadas.jsp?mensaje="
                        + java.net.URLEncoder.encode("Solicitud enviada correctamente", "UTF-8");
                response.sendRedirect(destino);
                return;
            } catch (IllegalArgumentException e) {
                mensajeTexto = "Error: " + e.getMessage();
                mensajeClase = "mensaje_error";
            } catch (IllegalStateException e) {
                mensajeTexto = "Error: " + e.getMessage();
                mensajeClase = "mensaje_error";
            } catch (Exception e) {
                mensajeTexto = "Error: fallo en base de datos al crear la solicitud.";
                mensajeClase = "mensaje_error";
            }
        }
    }

    List<Carta> cartasOtros = new ArrayList<Carta>();
    List<Carta> misCartas = new ArrayList<Carta>();

    try {
        CartaDada cartaDada = new CartaDada();
        cartasOtros = cartaDada.buscarCartasDeOtrosUsuarios("", false, usuario, false, "");
        misCartas = cartaDada.buscarCartas("", false, usuario, false, "");
    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: no se pudieron cargar las cartas disponibles.";
            mensajeClase = "mensaje_error";
        }
    }

    String textoCartaSolicitada = "";
    for (Carta carta : cartasOtros) {
        if (String.valueOf(carta.idCarta).equals(idCartaSolicitadaSel)) {
            textoCartaSolicitada = carta.nombre + " (Dueno: " + carta.dueno + ")";
            break;
        }
    }

    String textoCartaOfrecida = "";
    for (Carta carta : misCartas) {
        if (String.valueOf(carta.idCarta).equals(idCartaOfrecidaSel)) {
            textoCartaOfrecida = carta.nombre + " (Dueno: " + usuario + ")";
            break;
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva Solicitud</title>
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

        function abrirModal1() { document.getElementById("modal1").style.display = "flex"; }
        function cerrarModal1() { document.getElementById("modal1").style.display = "none"; }
        function abrirModal2() { document.getElementById("modal2").style.display = "flex"; }
        function cerrarModal2() { document.getElementById("modal2").style.display = "none"; }

        function seleccionarCarta1(id, nombre, dueno, event) {
            if (event) event.preventDefault();
            document.getElementById("carta").value = nombre + " (Dueno: " + dueno + ")";
            document.getElementById("idCartaSolicitada").value = id;
            cerrarModal1();
        }

        function seleccionarCarta2(id, nombre, event) {
            if (event) event.preventDefault();
            const usuario = "<%= jsUsuario %>";
            document.getElementById("micarta").value = nombre + " (Dueno: " + usuario + ")";
            document.getElementById("idCartaOfrecida").value = id;
            cerrarModal2();
        }

        function validarEnvio() {
            const idCartaSolicitada = document.getElementById("idCartaSolicitada").value;
            const idCartaOfrecida = document.getElementById("idCartaOfrecida").value;
            if (!idCartaSolicitada || !idCartaOfrecida) {
                alert("Debes seleccionar una carta solicitada y una carta ofrecida.");
                return false;
            }
            return true;
        }

        function cancelar_Solicitud() {
            window.location.href = "solicitudesEnviadas.jsp";
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
        <a href="#" onclick="ir_miColeccion(); return false;">Mi Coleccion</a>
        <a href="#" onclick="ir_SolicitudesRecibidas(); return false;">Solicitudes Recibidas</a>
        <a class="active" href="#" onclick="ir_SolicitudesEnviadas(); return false;">Solicitudes Enviadas</a>
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
        <form id="nueva-solicitud-form" method="post" action="nuevaSolicitud.jsp" onsubmit="return validarEnvio();">
            <h2>Nueva Solicitud</h2>

            <div>
                <label for="carta">Carta de otro usuario:</label>
                <div class="adyacente">
                    <input type="text" id="carta" name="carta" value="<%= textoCartaSolicitada %>" readonly>
                    <button type="button" onclick="abrirModal1()">...</button>
                </div>
                <input type="hidden" id="idCartaSolicitada" name="idCartaSolicitada" value="<%= idCartaSolicitadaSel %>">
            </div>

            <div id="modal1" class="ventana_modal">
                <div class="modal-content">
                    <span class="close" onclick="cerrarModal1()">&times;</span>
                    <h3>Selecciona carta solicitada</h3>
                    <div class="table-container">
                        <table>
                            <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Dueno</th>
                                <th>Estado</th>
                                <th>Seleccionar</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (cartasOtros.isEmpty()) { %>
                            <tr><td colspan="4">No hay cartas de otros usuarios.</td></tr>
                            <% } else { %>
                            <% for (Carta carta : cartasOtros) {
                                String nombreJs = carta.nombre.replace("\\", "\\\\").replace("'", "\\'");
                                String duenoJs = carta.dueno.replace("\\", "\\\\").replace("'", "\\'");
                                boolean seleccionable = Carta.EstadoC.DISPONIBLE.equals(carta.estado);
                            %>
                            <tr>
                                <td><%= carta.nombre %></td>
                                <td><%= carta.dueno %></td>
                                <td><%= carta.estado %></td>
                                <td>
                                    <% if (seleccionable) { %>
                                    <button type="button"
                                            onclick="seleccionarCarta1('<%= carta.idCarta %>', '<%= nombreJs %>', '<%= duenoJs %>', event)">
                                        Seleccionar
                                    </button>
                                    <% } else { %>
                                    <button type="button" disabled>No disponible</button>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div>
                <label for="micarta">Carta que ofreces:</label>
                <div class="adyacente">
                    <input type="text" id="micarta" name="micarta" value="<%= textoCartaOfrecida %>" readonly>
                    <button type="button" onclick="abrirModal2()">...</button>
                </div>
                <input type="hidden" id="idCartaOfrecida" name="idCartaOfrecida" value="<%= idCartaOfrecidaSel %>">
            </div>

            <div id="modal2" class="ventana_modal">
                <div class="modal-content">
                    <span class="close" onclick="cerrarModal2()">&times;</span>
                    <h3>Selecciona tu carta</h3>
                    <div class="table-container">
                        <table>
                            <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Estado</th>
                                <th>Seleccionar</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (misCartas.isEmpty()) { %>
                            <tr><td colspan="3">No tienes cartas en tu coleccion.</td></tr>
                            <% } else { %>
                            <% for (Carta carta : misCartas) {
                                String nombreJs = carta.nombre.replace("\\", "\\\\").replace("'", "\\'");
                                boolean seleccionable = Carta.EstadoC.DISPONIBLE.equals(carta.estado);
                            %>
                            <tr>
                                <td><%= carta.nombre %></td>
                                <td><%= carta.estado %></td>
                                <td>
                                    <% if (seleccionable) { %>
                                    <button type="button"
                                            onclick="seleccionarCarta2('<%= carta.idCarta %>', '<%= nombreJs %>', event)">
                                        Seleccionar
                                    </button>
                                    <% } else { %>
                                    <button type="button" disabled>No disponible</button>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div>
                <label for="estado">Estado de la Solicitud:</label>
                <input type="text" id="estado" name="estado" value="PENDIENTE" readonly>
            </div>
            <div>
                <label for="fecha-solicitud">Fecha de la Solicitud:</label>
                <input type="text" id="fecha-solicitud" name="fecha-solicitud" value="<%= fechaHoy %>" readonly>
            </div>

            <div>
                <button class="aceptar" type="submit">Aceptar</button>
                <button class="cancelar" type="button" onclick="cancelar_Solicitud();">Cancelar</button>
            </div>
        </form>
    </div>
</main>
</body>
</html>
