<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="WEB-INF/includes/sessionUsuario.jsp" %>

<%
    String mensaje = request.getParameter("mensaje");
    if (mensaje == null) {
        mensaje = "";
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String loginUsuario = request.getParameter("usuario");
        String password = request.getParameter("password");

        if (loginUsuario == null) {
            loginUsuario = "";
        }
        if (password == null) {
            password = "";
        }

        loginUsuario = loginUsuario.trim();
        password = password.trim();

        if (loginUsuario.isEmpty() || password.isEmpty()) {
            mensaje = "Por favor, completa usuario y contrasena.";
        }
        else {
            session.setAttribute("usuario", loginUsuario);
            String destino = "miColeccion.jsp?usuario=" + java.net.URLEncoder.encode(loginUsuario, "UTF-8");
            response.sendRedirect(destino);
            return;
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="styles.css">
    <script>
        function Validar_Usuario(event) {
            const usuario = document.getElementById("usuario").value.trim();
            const password = document.getElementById("password").value.trim();

            if (usuario === "" || password === "") {
                event.preventDefault();
                alert("Por favor, completa ambos campos.");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="login-container">
        <form class="login-form" method="post" action="index.jsp" onsubmit="return Validar_Usuario(event);">
            <h2>Inicio de Sesion</h2>

            <% if (!mensaje.isEmpty()) { %>
            <div style="color: red; margin-bottom: 10px; text-align: center;">
                <%= mensaje %>
            </div>
            <% } %>

            <label for="usuario">Usuario:</label>
            <input type="text" id="usuario" name="usuario" maxlength="8" placeholder="Max. 8 caracteres" required>

            <label for="password">Contrasena:</label>
            <input type="password" id="password" name="password" maxlength="8" placeholder="Max. 8 caracteres" required>

            <button type="submit">Aceptar</button>
        </form>
    </div>
</body>
</html>
