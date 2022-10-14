-- CREACION DE TABLAS

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
 fecha_nacimiento DATE NOT NULL);
 
 CREATE TABLE IF NOT EXISTS conductores
(id_conductor INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 matricula INT NOT NULL,
 nombre VARCHAR (50) NOT NULL,
 apellido VARCHAR (50) NOT NULL,
 fecha_nacimiento DATE NOT NULL,
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
 
 
 
 
 -- CREACION TABLAS TRIGGER
 
 /* CREACION DE TABLAS PARA LOS TRIGGERS BEFORE Y AFTER EN LAS TABLAS "CONDUCTORES" Y "RECORRIDOS"*/

/*TABLAS PARA CONDUCTORES*/
/*se crea una tabla para ver los dias que los nuevos conductores fueron ingresados*/
CREATE TABLE IF NOT EXISTS registro_conductores
(id_conductor INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR (50) NOT NULL,
 apellido VARCHAR (50) NOT NULL,
 fecha_registro DATE);
 

 
 
/* se crea esta tabla para ir revisando los nuevos conductores y si aplica el bono, ya que se estara dando un bono de C$1000 a los conductores nuevos de la ciudad de Granada
y C$2000 a los conductores de la ciudad de Leon*/
 
 CREATE TABLE IF NOT EXISTS city_conductores_bonus
(id_conductor INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 id_ciudad INT NOT NULL,
 bono INT NOT NULL);
 
  /*TABLAS PARA RECORRIDOS*/
  
 /*se crea una tabla para ver las horas de ingreso de cada recorrido nuevo*/
 CREATE TABLE IF NOT EXISTS registro_recorrido
(id_recorrido INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
id_conductor INT NOT NULL,
 fechahora datetime);
 
  /*se crea una tabla para llevar registro de los descuentos de usuarios viejos*/
 CREATE TABLE IF NOT EXISTS descuento_recorrido
(id_recorrido INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
 id_cliente INT NOT NULL,
 descuento_porcentual INT NOT NULL)
 ;
 
 
 
 
 
 
