-- Inicializacion de base de datos para Verificacion_software_pokemon
-- Esquema alineado con el PDF de la practica (Practica2_Desarrollo.pdf)

CREATE DATABASE IF NOT EXISTS CartasPokemon
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'pokemon_user'@'localhost' IDENTIFIED BY '12345678';
ALTER USER 'pokemon_user'@'localhost' IDENTIFIED BY '12345678';
GRANT ALL PRIVILEGES ON CartasPokemon.* TO 'pokemon_user'@'localhost';
FLUSH PRIVILEGES;

USE CartasPokemon;

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS solicitudes;
DROP TABLE IF EXISTS Solicitud;
DROP TABLE IF EXISTS Carta;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE Carta (
  id_carta INT AUTO_INCREMENT PRIMARY KEY,
  Dueno VARCHAR(8) NOT NULL,
  Nombre VARCHAR(20) NOT NULL,
  Tipo VARCHAR(10) NOT NULL,
  Puntuacion INT NOT NULL,
  Estado VARCHAR(15) NOT NULL,
  FechaAlta DATE NOT NULL
);

CREATE TABLE Solicitud (
  id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
  id_carta1 INT NOT NULL,
  Dueno1 VARCHAR(8) NOT NULL,
  id_carta2 INT NOT NULL,
  Dueno2 VARCHAR(8) NOT NULL,
  Estado VARCHAR(15) NOT NULL,
  FechaSolicitud DATE NOT NULL,
  UNIQUE (id_carta1, id_carta2, Estado),
  FOREIGN KEY (id_carta1) REFERENCES Carta(id_carta) ON DELETE CASCADE,
  FOREIGN KEY (id_carta2) REFERENCES Carta(id_carta) ON DELETE CASCADE
);
