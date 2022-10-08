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
 
 
 
 
 
 
 -- CREACION DE VISTAS
 
 
 USE tellevo;


/* AGREGANDO EL COSTO DEL KM A LA TABLA DE CONDUCTORES*/
CREATE OR REPLACE VIEW Costo_km_conductores AS 
SELECT
	co.id_conductor,
	co.id_ciudad,
	ci.costo_kilometraje
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad;




/* TABLA DE RECORRIDOS CON COSTO DE CADA KM RECORRITO*/
CREATE OR REPLACE VIEW Costo_recorrido AS
SELECT 
	r.id_recorrido,
    r.fecha,
    r.kilometraje,
    t.id_ciudad,
    t.costo_km
FROM recorridos AS r
JOIN (SELECT
co.id_conductor,
co.id_ciudad,
ci.costo_kilometraje AS costo_km
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad) AS t ON r.id_conductor = t.id_conductor;


/* VISTA DEL COSTO TOTAL DE LOS RECORRIDOS X ID DE RECORRIDO*/
CREATE OR REPLACE VIEW Costo_total_id_recorrido AS
SELECT 
	r.id_recorrido,
    r.fecha,
    r.kilometraje,
    r.id_cliente,
    t.id_conductor,
    t.id_ciudad,
    t.costo_km,
    r.kilometraje * t.costo_km AS costo_total
FROM recorridos AS r
JOIN (SELECT
co.id_conductor,
co.id_ciudad,
ci.costo_kilometraje AS costo_km
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad) AS t ON r.id_conductor = t.id_conductor
ORDER BY 1,2;


/*QUERY DE INFO DRIVERS VEHICULOS CIUDAD Y NOMBRE COMPLETO*/
CREATE OR REPLACE VIEW info_drivers_vehiculo_ciudad AS
SELECT
	co.id_conductor,
	co.id_ciudad,
	co.nombre AS nombre,
	co.apellido AS apellido,
	CONCAT(co.nombre,' ',co.apellido) AS nombre_completo,
	ci.nombre_ciudad AS ciudad,
	vh.marca AS marca_vehiculo,
	vh.modelo AS modelo_vehiculo,
	vh.color AS color_vehiculo
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad
JOIN vehiculos AS vh ON co.matricula = vh.matricula 
ORDER BY 1 ASC;

/* QUERY INFO DE CLIENTES*/
CREATE OR REPLACE VIEW info_clientes AS
SELECT 
	id_cliente,
    CONCAT(nombre,' ',apellido) AS nombre_cliente,
    sexo,
    fecha_nacimiento,
    year(current_date()) - YEAR(fecha_nacimiento) AS edad
FROM clientes
ORDER BY 1;




/* GANANCIAS DE DRIVERS EN LA PRIMERA SEMANA DE JULIO*/
CREATE OR REPLACE VIEW ganancia_drivers_1rasemana_julio AS
WITH 
	info_recorridos AS
	(SELECT 
	r.id_recorrido,
    r.fecha AS fecha,
    r.kilometraje AS kilometraje,
    r.id_cliente,
    t.id_conductor AS id_conductor,
    t.id_ciudad,
    t.costo_km,
    r.kilometraje * t.costo_km AS costo_total
FROM recorridos AS r
JOIN (SELECT
co.id_conductor,
co.id_ciudad,
ci.costo_kilometraje AS costo_km
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad) AS t ON r.id_conductor = t.id_conductor),

drivers AS
(SELECT
	co.id_conductor AS id_conductor,
	co.id_ciudad,
	co.nombre AS nombre,
	co.apellido AS apellido,
	CONCAT(co.nombre,' ',co.apellido) AS nombre_completo,
	ci.nombre_ciudad AS ciudad,
	vh.marca AS marca_vehiculo,
	vh.modelo AS modelo_vehiculo,
	vh.color AS color_vehiculo
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad
JOIN vehiculos AS vh ON co.matricula = vh.matricula 
ORDER BY 1 ASC)


SELECT
ir.fecha,
d.nombre_completo AS driver,
SUM(ir.kilometraje) AS kilometraje_recorrido,
SUM(ir.costo_total) AS costo_total,
(SUM(ir.costo_total) * 0.20) AS ganancia_driver
FROM info_recorridos AS ir
LEFT JOIN drivers AS d ON ir.id_conductor = d.id_conductor
WHERE fecha BETWEEN '2022-07-01' AND '2022-07-07'
GROUP BY 1,2
ORDER BY 5 DESC;



/* TOP 10 CLIENTES CON MAS KM RECORRIDOS*/
CREATE OR REPLACE VIEW top10_clientes AS
WITH 
	info_recorridos AS
	(SELECT 
	r.id_recorrido,
    r.fecha AS fecha,
    r.kilometraje AS kilometraje,
    r.id_cliente,
    t.id_conductor AS id_conductor,
    t.id_ciudad,
    t.costo_km,
    r.kilometraje * t.costo_km AS costo_total
FROM recorridos AS r
JOIN (SELECT
co.id_conductor,
co.id_ciudad,
ci.costo_kilometraje AS costo_km
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad) AS t ON r.id_conductor = t.id_conductor),

clientes_recorrido AS
(SELECT 
	id_cliente,
    CONCAT(nombre,' ',apellido) AS nombre_cliente,
    sexo,
    fecha_nacimiento,
    year(current_date()) - YEAR(fecha_nacimiento) AS edad
FROM clientes
ORDER BY 1)


SELECT
cr.nombre_cliente AS cliente,
cr.sexo,
cr.edad,
SUM(ir.kilometraje) AS kilometraje_recorrido,
SUM(ir.costo_total) AS costo_total,
COUNT(ir.id_recorrido) AS total_recorridos
FROM info_recorridos AS ir
LEFT JOIN clientes_recorrido AS cr ON ir.id_cliente = cr.id_cliente
WHERE fecha >= '2022-07-01'
GROUP BY 1,2
ORDER BY 4 DESC
LIMIT 10;



-- CREACION DE USUARIOS Y PERMISOS

/* Empezamos creando el usuario 'coderprueba1'@'localhost' */
CREATE USER 'coderprueba1'@'localhost'; 
/* Vemos que permisos tiene el usuario 'coderprueba1'@'localhost', observando que aun no se le ha otorgado ninguno */
SHOW GRANTS FOR 'coderprueba1'@'localhost';

/* Le damos permiso de Lectura para las 5 tablas principales de la base tellevo al usuario 'coderprueba1'@'localhost' */

GRANT SELECT, UPDATE ON tellevo.ciudades TO 'coderprueba1'@'localhost';
GRANT SELECT, UPDATE ON tellevo.clientes TO 'coderprueba1'@'localhost';
GRANT SELECT, UPDATE ON tellevo.conductores TO 'coderprueba1'@'localhost';
GRANT SELECT, UPDATE ON tellevo.recorridos TO 'coderprueba1'@'localhost';
GRANT SELECT, UPDATE ON tellevo.vehiculos TO 'coderprueba1'@'localhost'; 




/* Empezamos creando el usuario 'coderpruebatodos'@'localhost' */
 CREATE USER 'coderpruebatodos'@'localhost'; 
/* Vemos que permisos tiene el usuario 'coderpruebatodos'@'localhost', observando que aun no se le ha otorgado ninguno */
SHOW GRANTS FOR 'coderpruebatodos'@'localhost';

/* Le damos permisos de Lectura, insercion y modificacion de valores para las 5 tablas principales de la base tellevo al usuario 'coderpruebatodos'@'localhost' */
GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, DROP ON tellevo.ciudades TO 'coderpruebatodos'@'localhost';
GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, DROP ON tellevo.clientes TO 'coderpruebatodos'@'localhost';
GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, DROP ON tellevo.conductores TO 'coderpruebatodos'@'localhost';
GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, DROP ON tellevo.recorridos TO 'coderpruebatodos'@'localhost';
GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, DROP ON tellevo.vehiculos TO 'coderpruebatodos'@'localhost';


 
 
 
 
 