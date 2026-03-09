<%
    String usuario = (String) session.getAttribute("usuario");
    if (usuario == null || usuario.isEmpty()) {
        usuario = request.getParameter("usuario");
        if (usuario == null || usuario.isEmpty()) {
            usuario = "Anonimo";
        }
        session.setAttribute("usuario", usuario);
    }
%>
