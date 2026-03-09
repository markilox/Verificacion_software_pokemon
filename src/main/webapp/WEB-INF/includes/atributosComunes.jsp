<%
    String fechaHoy = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String jsUsuario = "";
    if (usuario != null) {
        jsUsuario = usuario.replace("\\", "\\\\").replace("\"", "\\\"");
    }
%>
