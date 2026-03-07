package main.java.pokemon;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class Solicitud {

    private static final Logger logger = Logger.getLogger(Solicitud.class.getName());

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
    public Solicitud(int idSolicitud, int idCarta1, String dueno1, int idCarta2, String dueno2, EstadoS estado, Date fechaSolicitud) throws Exception {
        this.idSolicitud = idSolicitud;
        this.idCarta1 = idCarta1;
        this.dueno1 = dueno1;
        this.idCarta2 = idCarta2;
        this.dueno2 = dueno2;
        this.estado = estado;
        this.fechaSolicitud = fechaSolicitud;
        boolean control = insertarsolicitud();
        if(control){
            logger.info("Intercambio solicitado correctamente.");
        }
        else{
            logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD");
        }
    }

    // Método para aceptar una solicitud
    public void aceptar() throws Exception {

        if (this.estado == EstadoS.PENDIENTE){
            this.estado = EstadoS.ACEPTADO;

            CartaDada cartaDada = new CartaDada();

            Carta carta1 = cartaDada.obtenerCartaPorId(this.idCarta1);
            Carta carta2 = cartaDada.obtenerCartaPorId(this.idCarta2);
            if (carta1 == null || carta2 == null) {
                logger.log(Level.SEVERE, "Error: alguna carta no existe");
                return;
            }

            boolean control1 = carta1.actualizarDueno(this.dueno2);
            boolean control2 = carta2.actualizarDueno(this.dueno1);

            boolean control3 = carta1.actualizarEstado(Carta.EstadoC.DISPONIBLE);
            boolean control4 = carta2.actualizarEstado(Carta.EstadoC.DISPONIBLE);

            boolean control5 = this.modificarSolicitud();

            if(control1 && control2 && control3 && control4 && control5){
                logger.info("Intercambio realizado correctamente.");
            }
            else{
                logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD");
            }
        }
        else {
            logger.log(Level.SEVERE, "Error: la solicitud ya se ha resuelto");
            return;
        }
    }

    // Método para rechazar
    public void rechazar() throws Exception {
        if (this.estado == EstadoS.PENDIENTE){
            this.estado = EstadoS.RECHAZADO;

            CartaDada cartaDada = new CartaDada();

            Carta carta1 = cartaDada.obtenerCartaPorId(this.idCarta1);
            Carta carta2 = cartaDada.obtenerCartaPorId(this.idCarta2);
            if (carta1 == null || carta2 == null) {
                logger.log(Level.SEVERE, "Error: alguna carta no existe");
                return;
            }

            boolean control1 = carta1.actualizarEstado(Carta.EstadoC.DISPONIBLE);
            boolean control2 = carta2.actualizarEstado(Carta.EstadoC.DISPONIBLE);
            boolean control3 = this.modificarSolicitud();

            if(control1 && control2 && control3){
                logger.info("Intercambio rechazado correctamente.");
            }
            else{
                logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD");
            }
        }
        else {
            logger.log(Level.SEVERE, "Error: la solicitud ya se ha resuelto");
            return;
        }
    }

    // Método para cancelar
    public void cancelar() throws Exception {
        if (this.estado == EstadoS.PENDIENTE){

            CartaDada cartaDada = new CartaDada();

            Carta carta1 = cartaDada.obtenerCartaPorId(this.idCarta1);
            Carta carta2 = cartaDada.obtenerCartaPorId(this.idCarta2);
            if (carta1 == null || carta2 == null) {
                logger.log(Level.SEVERE, "Error: alguna carta no existe");
                return;
            }

            boolean control1 = carta1.actualizarEstado(Carta.EstadoC.DISPONIBLE);
            boolean control2 = carta2.actualizarEstado(Carta.EstadoC.DISPONIBLE);
            boolean control3 = this.borrarSolicitud();

            if(control1 && control2 && control3){
                logger.info("Intercambio cancelado correctamente.");
            }
            else{
                logger.log(Level.SEVERE, "Error: no se ha guardado correctamente en la BD");
            }
        }
        else {
            logger.log(Level.SEVERE, "Error: la solicitud ya se ha resuelto");
            return;
        }
    }

    // Método para insertar una nueva solicitud
    private boolean insertarsolicitud() throws Exception {
        DatabaseManager db = new DatabaseManager();
        db.connect();

        try {
            String sql = "INSERT INTO solicitudes (idSolicitud, idCarta1, dueno1, idCarta2, dueno2, fechaSolicitud, estado) VALUES (" +
                    this.idSolicitud + "," +
                    this.idCarta1 + "," +
                    "'" + this.dueno1 + "'," +
                    this.idCarta2 + "," +
                    "'" + this.dueno2 + "'," +
                    this.fechaSolicitud + ","  +
                    "'" + this.estado + "," +
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
                    "idCarta1=" + this.idCarta1 + ", " +
                    "dueno1='" + this.dueno1 + "', " +
                    "idCarta2=" + this.idCarta2 + ", " +
                    "dueno2='" + this.dueno2 + "', " +
                    "estado='" + this.estado + "' " +
                    "WHERE idSolicitud=" + this.idSolicitud;

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
            String sql = "DELETE FROM solicitudes WHERE idSolicitud=" + this.idSolicitud;

            int resultado = db.executeUpdate(sql);
            return resultado > 0;

        } finally {
            db.disconnect();
        }
    }
}