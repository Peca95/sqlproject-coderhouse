/* ACA PUEDEN ENCONTRAR LAS VISTAS CON SU DESCRIPCION DE QUE MUESTRA EN CADA UNA DE ELLAS*/

USE tellevo;


/* AGREGANDO EL COSTO DEL KM A LA TABLA DE CONDUCTORES*/
SELECT
	co.id_conductor,
	co.id_ciudad,
	ci.costo_kilometraje
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad;




/* TABLA DE RECORRIDOS CON COSTO DE CADA KM RECORRITO*/
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

SELECT 
	id_cliente,
    CONCAT(nombre,' ',apellido) AS nombre_cliente,
    sexo,
    fecha_nacimiento,
    year(current_date()) - YEAR(fecha_nacimiento) AS edad
FROM clientes
ORDER BY 1;




/* GANANCIAS DE DRIVERS EN LA PRIMERA SEMANA DE JULIO*/
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





/* ACA PUEDEN VER LAS FUNCIONES CON SUS COMENTARIOS DE QUE HACEN CADA UNA DE ELLAS */

/*FUNCION PARA OBTENER LA CANTIDAD DE VIAJES SEGUN LA CAPACIDAD DEL VEHICULO Y LA CANTIDAD DE PASAJEROS*/
/* SE QUIERE SABER LA CANTIDAD DE VIAJES O VEHICULOS NECESARIOS PARA LLEVAR 60 PASAJEROS, CADA VEHICULO TIENE UNA CAPACIDAD MAXIMA DE 4 PERSONAS */

USE `tellevo`;
DROP function IF EXISTS `calculo_viajes`;

DELIMITER $$
USE `tellevo`$$
CREATE FUNCTION `calculo_viajes` (capacidad INT, pasajeros INT)
RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE resultado INT;
    SET resultado = pasajeros / capacidad;
RETURN resultado;
END$$

DELIMITER ;

/*SELECT `calculo_viajes` (4,100)*/


/* FUNCION PARA OBTENER EL NOMBRE Y APELLIDO DEL DRIVER SEGUN SU DRIVER ID*/


USE `tellevo`;
DROP function IF EXISTS `driver_info`;

USE `tellevo`;
DROP function IF EXISTS `tellevo`.`driver_info`;
;

DELIMITER $$
USE `tellevo`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `driver_info`(id INT) RETURNS varchar(100) CHARSET utf8mb4
    READS SQL DATA
BEGIN
	DECLARE info VARCHAR(100);
    SET info = '';
    SELECT
		CONCAT(co.nombre,' ',co.apellido) AS nombre_completo INTO info
	FROM conductores AS co
	JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad
	JOIN vehiculos AS vh ON co.matricula = vh.matricula
    WHERE co.id_conductor = id;
RETURN info;
END$$

DELIMITER ;
;


/*SELECT `driver_info`(8);*/





/*FUNCION PARA DETERMINAR EL TOTAL DE KM RECORRIDO X DRIVER SEGUN SU DRIVER ID*/



USE `tellevo`;
DROP function IF EXISTS `total_km_recorrido_driver`;

USE `tellevo`;
DROP function IF EXISTS `tellevo`.`total_km_recorrido_driver`;
;

DELIMITER $$
USE `tellevo`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `total_km_recorrido_driver`(id_km INT) RETURNS varchar(50) CHARSET utf8mb4
    READS SQL DATA
BEGIN
	DECLARE km VARCHAR(50);
    SET km = '';
    SELECT 
    SUM(r.kilometraje) INTO km
FROM recorridos AS r
JOIN (SELECT
co.id_conductor,
co.id_ciudad,
ci.costo_kilometraje AS costo_km
FROM conductores AS co
JOIN ciudades AS ci ON co.id_ciudad = ci.id_ciudad) AS t ON r.id_conductor = t.id_conductor
WHERE t.id_conductor = id_km;
RETURN km;
END$$

DELIMITER ;
;


/*SELECT `total_km_recorrido_driver` (2)*/





/* ACA SE ENCUENTRAN LOS STORED PROCEDURES CON SU COMENTARIO DE QUE REALIZA CADA UNO */



/*ESTE SP CARGA LA TABLA DE CLIENTES, CONTIENE 2 PARAMETROS EL PRIMERO PONE ENTRE '' LA COLUMNA QUE DESEA ORDENAR Y EL SEGUNDO PONE ENTRE '' DE QUE MANERA SI 'ASC' O 'DESC'*/


USE `tellevo`;
DROP procedure IF EXISTS `lista_clientes`;

USE `tellevo`;
DROP procedure IF EXISTS `tellevo`.`lista_clientes`;
;

DELIMITER $$
USE `tellevo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lista_clientes`(IN campo CHAR(50), orden CHAR(30))
BEGIN
	SELECT 
	id_cliente,
    nombre,
    apellido
FROM tellevo.clientes
ORDER BY
	CASE WHEN campo ='id_cliente' AND orden ='ASC' THEN id_cliente END ASC,
	CASE WHEN campo ='id_cliente' AND orden ='DESC' THEN id_cliente END DESC,
    CASE WHEN campo ='nombre' AND orden ='ASC' THEN nombre END ASC,
	CASE WHEN campo ='nombre' AND orden ='DESC' THEN nombre END DESC,
    CASE WHEN campo ='apellido' AND orden ='ASC' THEN apellido END ASC,
	CASE WHEN campo ='apellido' AND orden ='DESC' THEN apellido END DESC;
    
END$$

DELIMITER ;
;

/* REALIZAMOS ESTE CALL PARA LLAMAR LA COLUMNA "APELLIDO" Y ORDENARLA DE MANERA ASC
call `lista_clientes` ('apellido','ASC');*/


/*STORED PROCEDURE QUE NOS AYUDA A INSERTAR Y ELIMINAR FILAS EN LA TABLA DE "VEHICULOS" */
USE `tellevo`;
DROP procedure IF EXISTS `insert_delete_vehiculos`;

DELIMITER $$
USE `tellevo`$$
CREATE PROCEDURE `insert_delete_vehiculos`( IN
	  accion VARCHAR(30)
      ,spmatricula INT
      ,spmarca VARCHAR(50)
      ,spmodelo VARCHAR(50)
      ,sptipo VARCHAR(50)
      ,spcolor VARCHAR(50)
)
BEGIN
    -- INSERT
    IF accion = "INSERT" THEN
        INSERT INTO vehiculos(matricula ,marca ,modelo ,tipo ,color )
        VALUES (spmatricula ,spmarca ,spmodelo ,sptipo ,spcolor );
    END IF;
     
    -- DELETE
    IF accion ="DELETE" THEN
        DELETE FROM vehiculos
        WHERE matricula = spmatricula;
    END IF;
END$$

DELIMITER ;



/* PARA ELIMINAR FILAS REALIZAMOS EL SIGUIENTE CALL 
call insert_delete_vehiculos ("DELETE",51,"","","","");*/

/* PARA INSERTAR UN REGISTRO REALIZAMOS EL SIGUIENTE CALL
call insert_delete_vehiculos ("INSERT",51,"Toyota","Hilux","Camioneta","Blanca");*/





/* FINALMENTE TENEMOS LOS TRIGGERS CON SU CREACION DE TABLAS*/

/* Empezamos con la creacion de las tablas para los triggers */

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
 
 
 /* Aqui podemos ir viendo los codigos de los triggers en si y con su comentario de la funcion que realizan cada uno de ellos */
 
 /*TRIGGERS PARA LAS TABLAS "CONDUCTORES"*/

/*trigger para registro de los conductores, cada vez que ingresa un conductor nuevo al sistema y la fecha en que fue ingresado*/
DELIMITER //
CREATE TRIGGER tr_registro_conductor
AFTER INSERT ON conductores
FOR EACH ROW 
INSERT INTO registro_conductores (id_conductor, nombre, apellido, fecha_registro)
VALUES (NEW.id_conductor, NEW.nombre, NEW.apellido, current_date());

 END;//



/*trigger para ver antes de que se ingrese un conductor nuevo a la tabla de conductores, si aplica el bono de su ciudad*/

DELIMITER //
CREATE TRIGGER tr_before_bonus_conductor
 BEFORE INSERT ON conductores   
   FOR EACH ROW BEGIN  
   /* Bono para los conductores nuevos de estas 2 ciudades*/
     IF (new.id_ciudad = 5) 
     THEN 
       INSERT INTO city_conductores_bonus (id_conductor, id_ciudad, bono) VALUES (NEW.id_conductor, NEW.id_ciudad, 1000);
    ELSEIF
      (new.id_ciudad = 3)
     THEN 
        INSERT INTO city_conductores_bonus (id_conductor, id_ciudad, bono) VALUES (NEW.id_conductor, NEW.id_ciudad, 2000);
   END IF;  
 END;//
 
  /*PRUEBA DEL TRIGGER
 INSERT INTO conductores (id_conductor, matricula, nombre, apellido, fecha_nacimiento, telefono, sexo, domicilio, estado_contrato, id_ciudad
)
VALUES ('60','40','MANUEL','SANCHEZ','1990-04-26','52-3519685','MASCULINO','Estatua de Montoya 2C. Sur 1 1/2 Oeste','ACTIVO','5'),*/
 
 
 /*TRIGGERS PARA LAS TABLAS "RECORRIDOS"*/
 
 
 /*trigger para llevar los registros de los recorridos, que fecha y a que hora ingresa 1 recorrido nuevo*/
DELIMITER //
CREATE TRIGGER tr_registro_recorridos
AFTER INSERT ON recorridos
FOR EACH ROW 
INSERT INTO registro_recorrido (id_recorrido, id_conductor, fechahora)
VALUES (NEW.id_recorrido, NEW.id_conductor, CURRENT_TIMESTAMP());

 END;//
 
 /* Trigger para agregar el respectivo descuento del 15% a los clientes que tienen mas de 10 recorridos*/
 DELIMITER //
CREATE TRIGGER tr_before_descuento_recorrido
 BEFORE INSERT ON recorridos
   FOR EACH ROW BEGIN  
   /* Bono para los clientes que tengan mas de 10 recorridos*/
     IF (new.id_cliente IN (SELECT id_cliente
							FROM tellevo.recorridos
							GROUP BY 1
							HAVING COUNT(distinct id_recorrido)  > 10))
     THEN 
       INSERT INTO descuento_recorrido (id_recorrido, id_cliente, descuento_porcentual) VALUES (NEW.id_recorrido, NEW.id_cliente, 15);
   END IF;  
 END;//
 
 /* PRUEBA DEL TRIGGER
 INSERT INTO recorridos (id_recorrido, id_conductor, id_cliente, fecha, kilometraje)
VALUES ('1003','29','55','2022-08-10','5.87')
;*/