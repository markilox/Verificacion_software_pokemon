package main.java.pokemon;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;

public class Carta {

    public enum EstadoC{
        DISPONIBLE,
        RESERVADA,
        NO_INTERCAMBIABLE
    }

    public int idCarta;
    public String dueno;
    public String nombre;
    public String tipo;
    public int puntuacion;
    public EstadoC estado;
    public Date fechaAlta;

    // Constructor vacío
    public Carta() {
    }

    // Constructor sin id (para INSERT)
    public Carta(String dueno, String nombre, String tipo,
                 int puntuacion, EstadoC estado, Date fechaAlta) {
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

    // Constructor completo
    public Carta(int idCarta, String dueno, String nombre, String tipo,
                 int puntuacion, EstadoC estado, Date fechaAlta) {
        this.idCarta = idCarta;
        this.dueno = dueno;
        this.nombre = nombre;
        this.tipo = tipo;
        this.puntuacion = puntuacion;
        this.estado = estado;
        this.fechaAlta = fechaAlta;
    }

}
