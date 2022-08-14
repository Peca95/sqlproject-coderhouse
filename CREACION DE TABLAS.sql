CREATE DATABASE IF NOT EXISTS tellevo;
USE tellevo;

CREATE TABLE IF NOT EXISTS vehiculos
(matricula INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 marca VARCHAR (50) NOT NULL,
 modelo VARCHAR (50) NOT NULL,
 tipo VARCHAR (50),
 color VARCHAR (50) NOT NULL);
 
 
CREATE TABLE IF NOT EXISTS ciudades
(id_ciudad INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 nombre_ciudad VARCHAR (50) NOT NULL,
 costo_kilometraje INT NOT NULL);
 
   CREATE TABLE IF NOT EXISTS clientes
(id_cliente INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR (50) NOT NULL,
 apellido VARCHAR (50) NOT NULL,
 telefono VARCHAR (20),
 sexo VARCHAR (30) NOT NULL,
 edad VARCHAR (50) NOT NULL);
 
 CREATE TABLE IF NOT EXISTS conductores
(id_conductor INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 matricula INT NOT NULL,
 nombre VARCHAR (50) NOT NULL,
 apellido VARCHAR (50) NOT NULL,
 edad VARCHAR (50) NOT NULL,
 telefono VARCHAR (20),
 sexo VARCHAR (30) NOT NULL,
 domicilio VARCHAR (100),
 estado_contrato VARCHAR (30) NOT NULL,
 id_ciudad INT NOT NULL,
 FOREIGN KEY (matricula) REFERENCES vehiculos(matricula),
 FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad));
 
 
  CREATE TABLE IF NOT EXISTS recorridos
(id_recorrido INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
id_conductor INT NOT NULL,
 FOREIGN KEY (id_conductor) REFERENCES conductores(id_conductor),
 id_cliente INT NOT NULL,
 FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
 fecha DATE NOT NULL DEFAULT (CURRENT_DATE),
 kilometraje INT NOT NULL);
 