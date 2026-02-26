<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="main.java.pokemon.Carta" %>
<%@ page import="java.util.List" %>

<%-- Incluir al usuario logado como variable de sesión --%>
<%
    String usuario = (String) session.getAttribute("usuario"); //Si ya tenemos usuario en sesión, lo reutilizamos
	String mensaje = (String) request.getParameter("mensaje");
 
	if (usuario == null || usuario.isEmpty()) { //Si es la primera vez que accede, lo saca de los parámetros
    	usuario = request.getParameter("usuario");
		if (usuario == null) {
			usuario = "Anonimo";
		}
		session.setAttribute("usuario", usuario);  // Guardamos el usuario en la sesión
	}
	if (mensaje != null && !mensaje.isEmpty()) {
		if (mensaje.toLowerCase().contains("error")) {
			mensaje = "<div class='mensaje_error'>" + mensaje + "</div>";
		}
		else { mensaje = "<div class='mensaje'>" + mensaje + "</div>"; }
	}
	else { mensaje = ""; }

    // Buscar las cartas de ese usuario
    Carta nuevaCarta = new Carta();
    List<Carta> listaCartas = null;
    try {
    	listaCartas = nuevaCarta.buscarCartas("", true, usuario, false, "");
    }
    catch (Exception e) {
		mensaje = mensaje + "<div class='mensaje_error'>Error de conexión a base de datos.</div>";
	}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Colección</title>
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

		    window.location.href = "modificarCarta.jsp?id=" + document.querySelector('input[name="seleccionarCarta"]:checked').value;
		    return true;
		}
		function Borrar_Carta() {
			// Mostrar el mensaje de confirmación
	            if (confirm("¿Estás seguro/a de querer eliminar esta carta para siempre?")) {
	    	        // Si el usuario confirma (responde sí), llamar a Borrar_Carta pasando el id de la carta
	    		    window.location.href = "borrarCarta.jsp?id=" + document.querySelector('input[name="seleccionarCarta"]:checked').value;
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
       	 	<a href="#" class="active">Mi Colección</a>
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
	<h2>Mi Colección</h2>
	<p>En esta sección verás todas las cartas de tu colección. Puedes dar de alta nuevas cartas, modificar o borrar las que ya tienes.</p>
        <div class="action-buttons">
            <button id="nuevaCarta" onclick="Nueva_Carta();">Nueva Carta</button>
            <button id="modificarCarta" disabled onclick="Modificar_Carta();">Modificar Carta</button>
            <button id="borrarCarta" disabled onclick="Borrar_Carta();">Borrar Carta</button>
        </div>
	<div class="table-container">
		<% if (listaCartas == null ) { %>
		<table>
            <thead>
                <tr><th>Todavía no tienes ninguna carta en tu colección.</th></tr>
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
	            	<td><input type="radio" name="seleccionarCarta" onclick="habilitarBotones();" value="<%= carta.getId() %>"></td>
                    <td><%= carta.getNombre() %></td>
                    <td><%= carta.getPuntos() %></td>
                    <td><%= carta.getTipo() %></td>
                    <%
                    	java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
    					String fechaFormateada = sdf.format(carta.getFechaAlta());
					%>
                    
                    <td><%= fechaFormateada %></td>
                    <td><%= carta.getEstado() %></td>
	            </tr>
	        	<% } %>

            </tbody>
        </table>
        <% } %>
        </div>

        <!--
        <div class="pagination">
            <button>&lt; Anterior</button>
            <span>Página 1 de 10</span>
            <button>Siguiente &gt;</button>
        </div>
        //-->
    </div></main>
</body>
</html>