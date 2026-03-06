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

    public void aceptar(){

        if (estado == EstadoS.PENDIENTE){
            estado = EstadoS.ACEPTADO;

            carta1 = buscarCartaPorId(idCarta1);
            carta2 = buscarCartaPorId(idCarta2);
            if (carta1 == null || carta2 == null) {
                System.out.println("Error: alguna carta no existe");
                return;
            }

            carta1.dueno = dueno2;
            carta2.dueno = dueno1;

            carta1.estado = EstadoC.DISPONIBLE;
            carta2.estado = EstadoC.DISPONIBLE;

            control *= carta1.modificarCarta();
            control *= carta2.modificarCarta();

            if(control){
                System.out.println("Intercambio realizado correctamente");
            }
            else{
                System.out.println("Intercambio no realizado, ha ocurrido un error con la BD");
            }
        }
        else {
            System.out.println("Error: la solicitud ya se ha resuelto");
            return;
        }
    }

    public void rechazar(){
        if (estado == EstadoS.PENDIENTE){
            estado = EstadoS.RECHAZADO;

            carta1 = buscarCartaPorId(idCarta1);
            carta2 = buscarCartaPorId(idCarta2);
            if (carta1 == null || carta2 == null) {
                System.out.println("Error: alguna carta no existe");
                return;
            }

            carta1.estado = EstadoC.DISPONIBLE;
            carta2.estado = EstadoC.DISPONIBLE;

            control1 = carta1.modificarCarta();
            control2 = carta2.modificarCarta();

            if(control1 && control2){
                System.out.println("Intercambio realizado correctamente");
            }
            else{
                System.out.println("Intercambio no realizado, ha ocurrido un error con la BD");
            }
        }
        else {
            System.out.println("Error: la solicitud ya se ha resuelto");
            return;
        }
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