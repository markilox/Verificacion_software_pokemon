<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.DatabaseManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
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
            DatabaseManager db = new DatabaseManager();
            Connection conn = null;
            try {
                db.connect();
                conn = db.getConnection();
                conn.setAutoCommit(false);

                String duenoCartaSolicitada = null;
                String estadoCartaSolicitada = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT Dueno, Estado FROM Carta WHERE id_carta=? FOR UPDATE")) {
                    ps.setInt(1, idCartaSolicitada);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            duenoCartaSolicitada = rs.getString("Dueno");
                            estadoCartaSolicitada = rs.getString("Estado");
                        }
                    }
                }

                String duenoCartaOfrecida = null;
                String estadoCartaOfrecida = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT Dueno, Estado FROM Carta WHERE id_carta=? FOR UPDATE")) {
                    ps.setInt(1, idCartaOfrecida);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            duenoCartaOfrecida = rs.getString("Dueno");
                            estadoCartaOfrecida = rs.getString("Estado");
                        }
                    }
                }

                if (duenoCartaSolicitada == null || duenoCartaOfrecida == null) {
                    conn.rollback();
                    mensajeTexto = "Error: alguna carta seleccionada no existe.";
                    mensajeClase = "mensaje_error";
                } else if (usuario.equals(duenoCartaSolicitada)) {
                    conn.rollback();
                    mensajeTexto = "Error: la carta solicitada debe ser de otro usuario.";
                    mensajeClase = "mensaje_error";
                } else if (!usuario.equals(duenoCartaOfrecida)) {
                    conn.rollback();
                    mensajeTexto = "Error: la carta ofrecida debe ser tuya.";
                    mensajeClase = "mensaje_error";
                } else if (!"DISPONIBLE".equals(estadoCartaSolicitada) || !"DISPONIBLE".equals(estadoCartaOfrecida)) {
                    conn.rollback();
                    mensajeTexto = "Error: solo se pueden intercambiar cartas en estado DISPONIBLE.";
                    mensajeClase = "mensaje_error";
                } else {
                    int reserva1 = 0;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Carta SET Estado='RESERVADA' WHERE id_carta=? AND Estado='DISPONIBLE'")) {
                        ps.setInt(1, idCartaSolicitada);
                        reserva1 = ps.executeUpdate();
                    }

                    int reserva2 = 0;
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Carta SET Estado='RESERVADA' WHERE id_carta=? AND Estado='DISPONIBLE'")) {
                        ps.setInt(1, idCartaOfrecida);
                        reserva2 = ps.executeUpdate();
                    }

                    if (reserva1 != 1 || reserva2 != 1) {
                        conn.rollback();
                        mensajeTexto = "Error: no se pudo reservar una de las cartas.";
                        mensajeClase = "mensaje_error";
                    } else {
                        int insertadas = 0;
                        try (PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO Solicitud (id_carta1, Dueno1, id_carta2, Dueno2, Estado, FechaSolicitud) "
                                        + "VALUES (?, ?, ?, ?, 'PENDIENTE', CURDATE())")) {
                            ps.setInt(1, idCartaSolicitada);
                            ps.setString(2, duenoCartaSolicitada);
                            ps.setInt(3, idCartaOfrecida);
                            ps.setString(4, usuario);
                            insertadas = ps.executeUpdate();
                        }

                        if (insertadas == 1) {
                            conn.commit();
                            String destino = "solicitudesEnviadas.jsp?mensaje="
                                    + java.net.URLEncoder.encode("Solicitud enviada correctamente", "UTF-8");
                            response.sendRedirect(destino);
                            return;
                        }

                        conn.rollback();
                        mensajeTexto = "Error: no se pudo crear la solicitud.";
                        mensajeClase = "mensaje_error";
                    }
                }
            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (Exception ignored) { }
                }
                mensajeTexto = "Error: fallo en base de datos al crear la solicitud.";
                mensajeClase = "mensaje_error";
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                    } catch (Exception ignored) { }
                }
                db.disconnect();
            }
        }
    }

    List<String[]> cartasOtros = new ArrayList<String[]>();
    List<String[]> misCartas = new ArrayList<String[]>();

    DatabaseManager dbListas = new DatabaseManager();
    try {
        dbListas.connect();

        try (PreparedStatement ps = dbListas.getConnection().prepareStatement(
                "SELECT id_carta, Nombre, Dueno, Estado FROM Carta "
                        + "WHERE Dueno<>? "
                        + "ORDER BY CASE WHEN Estado='DISPONIBLE' THEN 0 ELSE 1 END, Nombre ASC")) {
            ps.setString(1, usuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    cartasOtros.add(new String[] {
                            String.valueOf(rs.getInt("id_carta")),
                            rs.getString("Nombre"),
                            rs.getString("Dueno"),
                            rs.getString("Estado")
                    });
                }
            }
        }

        try (PreparedStatement ps = dbListas.getConnection().prepareStatement(
                "SELECT id_carta, Nombre, Dueno, Estado FROM Carta "
                        + "WHERE Dueno=? "
                        + "ORDER BY CASE WHEN Estado='DISPONIBLE' THEN 0 ELSE 1 END, Nombre ASC")) {
            ps.setString(1, usuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    misCartas.add(new String[] {
                            String.valueOf(rs.getInt("id_carta")),
                            rs.getString("Nombre"),
                            rs.getString("Dueno"),
                            rs.getString("Estado")
                    });
                }
            }
        }

    } catch (Exception e) {
        if (mensajeTexto.isEmpty()) {
            mensajeTexto = "Error: no se pudieron cargar las cartas disponibles.";
            mensajeClase = "mensaje_error";
        }
    } finally {
        dbListas.disconnect();
    }

    String textoCartaSolicitada = "";
    for (String[] fila : cartasOtros) {
        if (fila[0].equals(idCartaSolicitadaSel)) {
            textoCartaSolicitada = fila[1] + " (Dueno: " + fila[2] + ")";
            break;
        }
    }

    String textoCartaOfrecida = "";
    for (String[] fila : misCartas) {
        if (fila[0].equals(idCartaOfrecidaSel)) {
            textoCartaOfrecida = fila[1] + " (Dueno: " + usuario + ")";
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
                            <% for (String[] fila : cartasOtros) {
                                String nombreJs = fila[1].replace("\\", "\\\\").replace("'", "\\'");
                                String duenoJs = fila[2].replace("\\", "\\\\").replace("'", "\\'");
                                boolean seleccionable = "DISPONIBLE".equals(fila[3]);
                            %>
                            <tr>
                                <td><%= fila[1] %></td>
                                <td><%= fila[2] %></td>
                                <td><%= fila[3] %></td>
                                <td>
                                    <% if (seleccionable) { %>
                                    <button type="button"
                                            onclick="seleccionarCarta1('<%= fila[0] %>', '<%= nombreJs %>', '<%= duenoJs %>', event)">
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
                            <% for (String[] fila : misCartas) {
                                String nombreJs = fila[1].replace("\\", "\\\\").replace("'", "\\'");
                                boolean seleccionable = "DISPONIBLE".equals(fila[3]);
                            %>
                            <tr>
                                <td><%= fila[1] %></td>
                                <td><%= fila[3] %></td>
                                <td>
                                    <% if (seleccionable) { %>
                                    <button type="button"
                                            onclick="seleccionarCarta2('<%= fila[0] %>', '<%= nombreJs %>', event)">
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
