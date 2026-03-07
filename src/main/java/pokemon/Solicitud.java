package main.java.pokemon;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;

public class Solicitud {

    // Estados permitidos
    public enum EstadoS{
        PENDIENTE,
        ACEPTADO,
        RECHAZADO
    }

    // Atributos
    public int idSolicitud;
    public int idCarta1;
    public String dueno1;
    public int idCarta2;
    public String dueno2;
    public Date fechaSolicitud;
    public EstadoS estado;

    // Constructor para crear una solicitud desde BD
    public Solicitud(int idSolicitud, int idCarta1, String dueno1, int idCarta2, String dueno2, String estado, Date fechaSolicitud) {
        this.idSolicitud = idSolicitud;
        this.idCarta1 = idCarta1;
        this.dueno1 = dueno1;
        this.idCarta2 = idCarta2;
        this.dueno2 = dueno2;
        this.estado = estado;
        this.fechaSolicitud = fechaSolicitud;
        control = insertarsolicitud();
        if(control){
            logger.info("Intercambio solicitado correctamente.");
        }
        else{
            logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD", e);
        }
    }

    // Método para aceptar una solicitud
    public void aceptar(){

        if (estado == EstadoS.PENDIENTE){
            estado = EstadoS.ACEPTADO;

            carta1 = buscarCartaPorId(idCarta1);
            carta2 = buscarCartaPorId(idCarta2);
            if (carta1 == null || carta2 == null) {
                logger.log(Level.SEVERE, "Error: alguna carta no existe", e);
                return;
            }

            carta1.dueno = dueno2;
            carta2.dueno = dueno1;

            carta1.estado = EstadoC.DISPONIBLE;
            carta2.estado = EstadoC.DISPONIBLE;

            control1 = carta1.modificarCarta();
            control2 = carta2.modificarCarta();
            control3 = modificarSolicitud();

            if(control1 && control2 && control3){
                logger.info("Intercambio realizado correctamente.");
            }
            else{
                logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD", e);
            }
        }
        else {
            logger.log(Level.SEVERE, "Error: la solicitud ya se ha resuelto", e);
            return;
        }
    }

    // Método para rechazar
    public void rechazar(){
        if (estado == EstadoS.PENDIENTE){
            estado = EstadoS.RECHAZADO;

            carta1 = buscarCartaPorId(idCarta1);
            carta2 = buscarCartaPorId(idCarta2);
            if (carta1 == null || carta2 == null) {
                logger.log(Level.SEVERE, "Error: alguna carta no existe", e);
                return;
            }

            carta1.estado = EstadoC.DISPONIBLE;
            carta2.estado = EstadoC.DISPONIBLE;

            control1 = carta1.modificarCarta();
            control2 = carta2.modificarCarta();
            control3 = modificarSolicitud();

            if(control1 && control2 && control3){
                logger.info("Intercambio rechazado correctamente.");
            }
            else{
                logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD", e);
            }
        }
        else {
            logger.log(Level.SEVERE, "Error: la solicitud ya se ha resuelto", e);
            return;
        }
    }

    // Método para cancelar
    public void cancelar(){
        if (estado == EstadoS.PENDIENTE){

            carta1 = buscarCartaPorId(idCarta1);
            carta2 = buscarCartaPorId(idCarta2);
            if (carta1 == null || carta2 == null) {
                logger.log(Level.SEVERE, "Error: alguna carta no existe", e);
                return;
            }

            carta1.estado = EstadoC.DISPONIBLE;
            carta2.estado = EstadoC.DISPONIBLE;

            control1 = carta1.modificarCarta();
            control2 = carta2.modificarCarta();
            control3 = borrarSolicitud();

            if(control1 && control2 && control3){
                logger.info("Intercambio cancelado correctamente.");
            }
            else{
                logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD", e);
            }
        }
        else {
            logger.log(Level.SEVERE, "Error: la solicitud ya se ha resuelto", e);
            return;
        }
    }

    // Método para insertar una nueva solicitud
    private boolean insertarsolicitud() throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "INSERT INTO solicitudes (idSolicitud, idCarta1, dueno1, idCarta2, dueno2, fechaSolicitud, estado) VALUES (" +
                    idSolicitud + "," +
                    idCarta1 + "," +
                    "'" + dueno1 + "'," +
                    idCarta2 + "," +
                    "'" + dueno2 + "'," +
                    fechaSolicitud + ","  +
                    "'" + estado + "'," +
                    ")";

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }

    // Método para modificar una solicitud existente
    private boolean modificarSolicitud() throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "UPDATE solicitudes SET " +
                    "idCarta1=" + idCarta1 + ", " +
                    "dueno1='" + dueno1 + "', " +
                    "idCarta2=" + idCarta2 + ", " +
                    "dueno2='" + dueno2 + "', " +
                    "fechaSolicitud=" + fechaSolicitud + ", " +
                    "estado='" + estado + "', " +
                    "WHERE idSolicitud=" + idSolicitud;

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }

    // Método para borrar una solicitud existente
    private boolean borrarSolicitud() throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "DELETE FROM solicitudes WHERE idSolicitud=" + idSolicitud;

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }
}