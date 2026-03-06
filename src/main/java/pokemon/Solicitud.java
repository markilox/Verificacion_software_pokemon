package main.java.pokemon;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;


public class Solicitud {

    // Estados permitidos
    public enum Estado{
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
    public Estado estado;


    // Constructor para crear una solicitud
    public Solicitud(int idCarta1, String dueno1, int idCarta2, String dueno2, String estado, Date fechaSolicitud) {
        this.idCarta1 = idCarta1;
        this.dueno1 = dueno1;
        this.idCarta2 = idCarta2;
        this.dueno2 = dueno2;
        this.estado = estado;
        this.fechaSolicitud = fechaSolicitud;
    }

    // Constructor para crear una solicitud desde BD
    public Solicitud(int idSolicitud, int idCarta1, String dueno1, int idCarta2, String dueno2, String estado, Date fechaSolicitud) {
        this.idSolicitud = idSolicitud;
        this.idCarta1 = idCarta1;
        this.dueno1 = dueno1;
        this.idCarta2 = idCarta2;
        this.dueno2 = dueno2;
        this.estado = estado;
        this.fechaSolicitud = fechaSolicitud;
    }
    
    @Override
    public String toString() {
        return "Solicitud{" +
                "idSolicitud=" + idSolicitud +
                ", idCarta1=" + idCarta1 +
                ", dueno1='" + dueno1 + '\'' +
                ", idCarta2=" + idCarta2 +
                ", dueno2='" + dueno2 + '\'' +
                ", estado='" + estado + '\'' +
                ", fechaSolicitud=" + fechaSolicitud +
                '}';
    }
}