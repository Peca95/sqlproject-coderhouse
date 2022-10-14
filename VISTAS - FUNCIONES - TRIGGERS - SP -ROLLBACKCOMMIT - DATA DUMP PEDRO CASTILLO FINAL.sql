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



-- FUNCIONES 


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


-- TRIGGERS


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





-- STORED PROCEDURES

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




















-- SENTENCIAS ROLLBACK Y COMMIT


/* Eliminando los registros del 1000 al 997 en la tabla de recorridos*/

START TRANSACTION;
DELETE FROM tellevo.recorridos
WHERE 
id_recorrido IN (1000,999,998,997);

-- ROLLBACK;
-- COMMIT;
/* DEJO COMENTADO LOS VALORES ELIMINADOS*/
/* INSERT INTO recorridos (id_recorrido, id_conductor, id_cliente, fecha, kilometraje)
VALUES ('997','26','112','2022-07-01','12.48'),
('998','27','113','2022-06-15','6.68'),
('999','28','114','2022-08-05','5.43'),
('1000','29','115','2022-08-10','5.87')
;*/

-- Inicio la transaccion para insertar 8 clientes nuevos en mi tabla de clientes
START TRANSACTION;
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('251','MARTHA','RUIZ TABOADA','938265580','FEMENINO','1997-06-25');
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('252','CARLOS','CASTILLO MOLINA','938234580','MASCULINO','1993-02-28');
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('253','MARIANA','LOPEZ CABRERA','938205576','FEMENINO','1998-05-28');
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('254','ALEJANDRA','MOLINA CARBALLO','938355580','FEMENINO','1990-02-28');

savepoint primer_lote;
-- Se guarda el primer lote de 4 clientes

INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('255','MARTHA','CASTELLON MARTINEZ','955265580','FEMENINO','1992-06-25');
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('256','CARLOS','ALVAREZ BRAVO','938234770','MASCULINO','1993-03-22');
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('257','ALBERTO','LOPEZ LACAYO','938203276','MASCULINO','1998-09-28');
INSERT INTO clientes (id_cliente, nombre, apellido, telefono, sexo, fecha_nacimiento)
VALUES ('258','JOAQUIN','GUZMAN CARBALLO','932255580','MASCULINO','1990-02-28');

savepoint segundo_lote;
-- Se guarda el segundo lote de 4 clientes y se deja comentado un rollback al primer lote para mostrar los 4 primeros clientes.

-- ROLLBACK TO primer_lote;









-- DUMP DATA ONLY 


/*Tablas en el BACKUP*/
-- city_conductores_bonus
-- ciudades
-- clientes
-- conductores
-- descuento_recorrido
-- recorridos
-- registro_conductores
-- registro_recorrido


CREATE DATABASE  IF NOT EXISTS `tellevo` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `tellevo`;
-- MySQL dump 10.13  Distrib 8.0.27, for Win64 (x86_64)
--
-- Host: localhost    Database: tellevo
-- ------------------------------------------------------
-- Server version	8.0.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `city_conductores_bonus`
--

LOCK TABLES `city_conductores_bonus` WRITE;
/*!40000 ALTER TABLE `city_conductores_bonus` DISABLE KEYS */;
INSERT INTO `city_conductores_bonus` VALUES (56,5,1000);
/*!40000 ALTER TABLE `city_conductores_bonus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `ciudades`
--

LOCK TABLES `ciudades` WRITE;
/*!40000 ALTER TABLE `ciudades` DISABLE KEYS */;
INSERT INTO `ciudades` VALUES (1,'MANAGUA',10),(2,'MASAYA',6),(3,'LEON',4),(4,'CHINANDEGA',8),(5,'GRANADA',4);
/*!40000 ALTER TABLE `ciudades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'ESTEFANIA','AROCAS PASADAS','938205580','FEMENINO','1997-02-28'),(2,'QUERALT','VISO GILABERT','936545115','FEMENINO','1992-07-21'),(3,'ESTHER','PASCUAL ALOY','938202768','FEMENINO','2000-07-24'),(4,'LAURA','VALLÉS GIRVENT','938727844','FEMENINO','2002-06-11'),(5,'RAQUEL','RAYA GARCIA','938350521','FEMENINO','1994-08-02'),(6,'MARIA ISABEL','BARALDÉS COMAS','938755645','FEMENINO','1991-05-14'),(7,'LAURA','BIDAULT CULLERÉS','936520547','FEMENINO','1992-04-28'),(8,'DOUNYA','ZAFRA FIGULS','936565656','FEMENINO','2002-12-07'),(9,'GEMMA','GARCIA ALMOGUERA','936752156','FEMENINO','2000-09-16'),(10,'GEMMA','LISTAN FIGUERAS','938300025','FEMENINO','1989-08-25'),(11,'SILVIA','RASERO GAVILAN','938385567','FEMENINO','1985-06-22'),(12,'MARIA','MOLINER GARRIDO','937809812','FEMENINO','1994-08-02'),(13,'BERTA','GALOBART GARCIA','936520741','FEMENINO','1978-02-16'),(14,'BERTA','LÓPEZ GARRIGASSAIT','938202456','FEMENINO','1990-11-06'),(15,'MIREIA','SÁNCHEZ GÓMEZ','938754554','FEMENINO','1979-07-04'),(16,'GEMMA','ALAVEDRA SUNYÉ','936875544','FEMENINO','1995-06-30'),(17,'MARIA ISABEL','ALIGUÉ BONVEHÍ','935880712','FEMENINO','1988-03-21'),(18,'INGRID','BIDAULT PÉREZ','936875255','FEMENINO','2002-12-18'),(19,'SANDRA','ALTIMIRAS ARMENTEROS','936542775','FEMENINO','1999-06-19'),(20,'JORDINA','AGUILAR RODRIGUEZ','938773545','FEMENINO','2002-11-18'),(21,'MARIA JOSÉ','BARRIGA SOTO','938200022','FEMENINO','2000-04-08'),(22,'RAQUEL','AVILA MASJUAN','936512545','FEMENINO','2003-01-03'),(23,'MARTA','AGUILAR RAMOS','937785655','FEMENINO','1998-12-16'),(24,'CARLA','AYALA ALSINA','938300385','FEMENINO','2001-10-27'),(25,'MARIA NOELIA','ALVAREZ TROYANO','936520471','FEMENINO','1997-11-10'),(26,'CRISTINA','ALINS GONZÁLEZ','936012445','FEMENINO','1988-03-01'),(27,'VERÒNICA','ARMENCOT PUIG','934500611','FEMENINO','1990-09-20'),(28,'MARIONA','ALIGUÉ RIVERA','937885544','FEMENINO','1997-07-16'),(29,'GEMMA','PORTELLA GISPETS','936512105','FEMENINO','2000-08-17'),(30,'MARTA','AGUILAR SUNYÉ','938202200','FEMENINO','2001-06-11'),(31,'NATÀLIA','BARRIGA TARDÀ','939965585','FEMENINO','1993-03-19'),(32,'MARTA','BARCONS LARA','936541235','FEMENINO','1992-08-14'),(33,'LAURA','AGUILERA TATJÉ','938204054','FEMENINO','1992-05-08'),(34,'ALEXIA','VALLÉS GIRVENT','936584541','FEMENINO','1997-03-02'),(35,'CRISTINA','ARISSA HERMOSO','934111475','FEMENINO','1999-11-29'),(36,'BEGONYA','ARPA MORENO','935687444','FEMENINO','1996-12-16'),(37,'INGRID','ALOY FARRANDO','936658711','FEMENINO','1999-03-05'),(38,'MÒNICA','ARTIGAS MATURANO','938773941','FEMENINO','2002-10-04'),(39,'GEMMA','ALTIMIRAS SERAROLS','938305295','FEMENINO','2000-06-28'),(40,'MARIA','TORRESCASANA GARCIA','936524446','FEMENINO','1994-12-07'),(41,'VIRGINIA','ALVAREZ ARMENTEROS','938305551','FEMENINO','1999-04-22'),(42,'AINA','AROCA GÓMEZ','938206097','FEMENINO','1997-04-10'),(43,'MARTA','ALCAIDE MOLINA','934500644','FEMENINO','1997-08-25'),(44,'MIREIA','AGUILERA PRAT','938305594','FEMENINO','1998-12-08'),(45,'ANNA','RIVERO FLORIDO','938300422','FEMENINO','1996-11-05'),(46,'ALBA','AVILA MASJUAN','938350511','FEMENINO','1994-05-01'),(47,'SANDRA','GRANADOS ANDRÉS','938727589','FEMENINO','1983-02-06'),(48,'ANA INÉS','BASTARDAS FRANCH','938208488','FEMENINO','1995-01-13'),(49,'IVET','ABADIAS MASANA','938320587','FEMENINO','1985-06-29'),(50,'JÚLIA','AREVALO SANCHEZ','938203095','FEMENINO','1990-03-25'),(51,'IRENE','ALVAREZ PARCERISA','934555455','FEMENINO','1983-05-30'),(52,'CRISTINA','BARALDÉS MARTORELL','938208502','FEMENINO','1999-06-18'),(53,'LUCIA','ALVAREZ DOMENECH','938205245','FEMENINO','1997-09-20'),(54,'CARLA','BOIX GONZÁLEZ','938300374','FEMENINO','2000-03-19'),(55,'MARTA','AGUILERA MERINO','938305576','FEMENINO','1996-12-27'),(56,'FRANKLIN','LARA','938208614','MASCULINO','1992-05-08'),(57,'DAVID','BONILLA','938770077','MASCULINO','1992-11-25'),(58,'RONALD','GARCIA','938200713','MASCULINO','1996-02-16'),(59,'CARLOS','AYERDIS','938270685','MASCULINO','1996-01-19'),(60,'JAIRO','DARCE','936021048','MASCULINO','1987-09-17'),(61,'LEOPOLDO','GUTIERREZ','938773933','MASCULINO','1998-01-12'),(62,'DAVID','PALACIOS','938206766','MASCULINO','1992-06-03'),(63,'CARLOS','BERMUDEZ','938305223','MASCULINO','1997-03-11'),(64,'RAFAEL','AGUILAR','938325565','MASCULINO','1988-11-28'),(65,'MIGUEL','CRUZ','936565448','MASCULINO','1997-05-13'),(66,'PEDRO','VELASQUEZ','938208360','MASCULINO','1996-10-29'),(67,'IVAN','CUAREZMA','936549889','MASCULINO','1981-09-24'),(68,'NORLAN','RODRIGUEZ','938208677','MASCULINO','1995-11-22'),(69,'MIGUEL','LANUZA','938325558','MASCULINO','1994-12-18'),(70,'CARLOS','GARCIA','938360281','MASCULINO','1998-06-15'),(71,'ANDREW','MARTINEZ','938208380','MASCULINO','1995-07-20'),(72,'CRISTIAN','SOZA','938770878','MASCULINO','2000-09-03'),(73,'JUNIOR','GUTIERREZ','936874511','MASCULINO','1990-03-05'),(74,'KESLER','RODRÃ­GUEZ','936548745','MASCULINO','1998-08-25'),(75,'LARRY','GONZALEZ','938755512','MASCULINO','1996-09-23'),(76,'MARLON','LOPEZ','938722096','MASCULINO','1986-01-27'),(77,'ROY','SOZA','934512544','MASCULINO','1996-10-07'),(78,'LEONARDO','BUSCHTING','938205011','MASCULINO','1992-02-14'),(79,'JHOSTIN','GUTIERREZ','938300864','MASCULINO','2000-07-22'),(80,'MICHAEL','EUGARRIOS','933256844','MASCULINO','1977-03-24'),(81,'EDWIN','SILVA','936528779','MASCULINO','1985-05-13'),(82,'IAN','GARCIA','931021886','MASCULINO','1998-10-12'),(83,'JOSETH','GUEVARA','936201457','MASCULINO','2000-10-05'),(84,'FREDY','HERNANDEZ','938207515','MASCULINO','1991-06-22'),(85,'JEYNER','GARCIA','938208558','MASCULINO','2002-09-16'),(86,'ELIEZER','CENTENO','938300496','MASCULINO','1998-09-15'),(87,'KRISTABELL','MENDIETA','930120545','MASCULINO','1996-11-26'),(88,'CARLOS','MANZANARES','938207095','MASCULINO','1992-04-20'),(89,'EMILIO','FLORES','938300214','MASCULINO','1991-10-02'),(90,'BRYAN','ESCORCIA','938727244','MASCULINO','1996-02-03'),(91,'CRISTIAN','ARAUZ','936565874','MASCULINO','1976-08-01'),(92,'JORGE','ARBUROLA','938205782','MASCULINO','1994-02-23'),(93,'TEDDY','CUADRA','936577225','MASCULINO','1985-11-10'),(94,'GERSSON','JESUS','938773647','MASCULINO','2000-07-19'),(95,'KEVIN','SALGADO','938208054','MASCULINO','1999-02-27'),(96,'JOAQUIN','ALFARO','930712563','MASCULINO','1994-04-13'),(97,'LEVIS','GOMEZ','938204078','MASCULINO','1987-01-05'),(98,'VICTOR','REYES','936871045','MASCULINO','1989-02-10'),(99,'ALVARO','PRADO','938745211','MASCULINO','1990-05-13'),(100,'RONALD','LUGO','938300065','MASCULINO','1984-03-03'),(101,'MAURIEL','PICADO','938208674','MASCULINO','1989-12-10'),(102,'LUIS','MENDOZA','930214054','MASCULINO','1992-07-09'),(103,'JOSE','ORDOÑEZ','936521404','MASCULINO','1996-11-27'),(104,'HOLMAN','LOPEZ','938350593','MASCULINO','1996-06-18'),(105,'RODOLFO','MONTIEL','939962045','MASCULINO','1998-09-12'),(106,'LESTER','LARA','938755603','MASCULINO','1987-08-18'),(107,'JONATHAN','ARROLIGA','938305524','MASCULINO','2000-04-05'),(108,'KEVIN','CASTILLO','936571974','MASCULINO','1998-01-14'),(109,'RIDER','ARAUZ','938300036','MASCULINO','1992-07-26'),(110,'CRISTHIAN','GUTIERREZ','936505455','MASCULINO','2001-06-23'),(111,'FERNANDO','LOPEZ','936587454','MASCULINO','1992-10-12'),(112,'DARWIN','ROQUE','938725845','MASCULINO','1984-02-11'),(113,'MARIO','BLANDINO','938205730','MASCULINO','1987-11-07'),(114,'OSCAR','AREVALO','936828258','MASCULINO','1991-05-25'),(115,'MIGUEL','BLANDON','938300045','MASCULINO','1997-01-15'),(116,'HENRYS','JOAQUIN','936521452','MASCULINO','1981-08-02'),(117,'JOSUE','FIGUEROA','938725885','MASCULINO','1983-04-18'),(118,'OLIVER','LOPEZ','938208303','MASCULINO','1981-03-27'),(119,'CARLOS','OSORNO','938360213','MASCULINO','1999-02-14'),(120,'ROBERTO','BARRERA','938320537','MASCULINO','1981-10-20'),(121,'NOEL','GARCIA','890029201','MASCULINO','1989-08-24'),(122,'JHONNY','GOMEZ','890029202','MASCULINO','1997-12-10'),(123,'MARVIN','GAMEZ','890029203','MASCULINO','1993-07-16'),(124,'YESTER','HERNANDEZ','890029204','MASCULINO','1984-01-16'),(125,'ROBERTO','SIRIAS','890029205','MASCULINO','2000-12-19'),(126,'HENRY','ALVAREZ','890029206','MASCULINO','1998-04-18'),(127,'ROGER','ROJAS','890029207','MASCULINO','1986-06-10'),(128,'ERICK','JARQUIN','890029208','MASCULINO','1994-11-12'),(129,'HOLMER','RODRIGUEZ','890029209','MASCULINO','1991-07-13'),(130,'ANDY','CERDA','890029210','MASCULINO','1991-09-15'),(131,'DAVID','CERDA','890029211','MASCULINO','1997-08-19'),(132,'JUAN','SANCHEZ','890029212','MASCULINO','1999-06-16'),(133,'EDUARDO','HERRERA','890029213','MASCULINO','1980-12-12'),(134,'DANIEL','OSORIO','890029214','MASCULINO','1997-02-16'),(135,'ROGER','ROSALES','890029215','MASCULINO','1992-05-12'),(136,'NEVYL','GOMEZ','890029216','MASCULINO','1988-03-18'),(137,'JIMMY','ROJAS','890029217','MASCULINO','1995-07-06'),(138,'JAIME','SIRIAS','890029218','MASCULINO','2000-10-28'),(139,'DAVID','ICABALCETA','890029219','MASCULINO','1998-08-28'),(140,'JORGE','NUÑEZ','890029220','MASCULINO','1995-04-24'),(141,'RIGOBERTO','MOLINA','890029221','MASCULINO','1993-06-23'),(142,'LENIN','ALVAREZ','890029222','MASCULINO','2001-09-16'),(143,'ABRAHAM','GUZMAN','890029223','MASCULINO','1990-12-27'),(144,'NORMAN','AGUIRRE','890029224','MASCULINO','1999-11-11'),(145,'AYRAM','ARCE','890029225','MASCULINO','1996-05-27'),(146,'LESTER','JESUS','890029226','MASCULINO','2000-12-12'),(147,'CARLOS','RUIZ','890029227','MASCULINO','1999-12-26'),(148,'FRANKLIN','LOPEZ','890029228','MASCULINO','2000-06-28'),(149,'SERGIO','RUIZ','890029229','MASCULINO','1983-01-26'),(150,'JOSEPH','BRICEÑO','890029230','MASCULINO','1980-05-23'),(151,'ERICK','CASTILLO','890029231','MASCULINO','1997-09-16'),(152,'KEYLER','QUINTANA','890029232','MASCULINO','1989-03-20'),(153,'JUAN','LOPEZ','890029233','MASCULINO','1992-11-26'),(154,'LUIS','GARCIA','890029234','MASCULINO','1995-05-11'),(155,'JUAN','DUARTE','890029235','MASCULINO','1997-02-07'),(156,'JOSE','TREMINIO','890029236','MASCULINO','1991-08-06'),(157,'YASBY','ARTOLA','890029237','MASCULINO','1991-10-20'),(158,'JOSE','JESUS','890029238','MASCULINO','1976-12-16'),(159,'LUIS','JIMENEZ','890029239','MASCULINO','1990-10-10'),(160,'JOSE','MAIRENA','890029240','MASCULINO','1997-07-22'),(161,'EDUARDO','TORRES','890029241','MASCULINO','1997-11-14'),(162,'ENGEL','GONZALEZ','890029242','MASCULINO','1995-05-13'),(163,'ANTONY','ALTAMIRANO','890029243','MASCULINO','1981-11-06'),(164,'LESTER','GARCIA','890029244','MASCULINO','1998-12-10'),(165,'FELIX','SANCHEZ','890029245','MASCULINO','1986-08-06'),(166,'VICTOR','CASTELLON','890029246','MASCULINO','1994-12-02'),(167,'JONATHAN','MENDOZA','890029247','MASCULINO','1987-01-17'),(168,'KEVIN','CANTILLANO','890029248','MASCULINO','2002-12-08'),(169,'MARIO','CABRERA','890029249','MASCULINO','1993-03-18'),(170,'JAVIER','CANTON','890029250','MASCULINO','1989-11-17'),(171,'ASLHEY','ESTRADA','890029251','MASCULINO','1986-08-25'),(172,'JONATHAN','MAIRENA','890029252','MASCULINO','2000-07-12'),(173,'NORLAN','LOAISIGA','890029253','MASCULINO','1998-09-11'),(174,'ERICK','LOPEZ','890029254','MASCULINO','1998-11-25'),(175,'LEONID','CHAVEZ','890029255','MASCULINO','1997-11-15'),(176,'JUAN','SELVA','890029256','MASCULINO','1990-03-31'),(177,'DARWIN','ZAMORAN','890029257','MASCULINO','1980-05-27'),(178,'ROGER','ZAPATA','890029258','MASCULINO','1995-09-16'),(179,'ERASMO','CARCACHE','890029259','MASCULINO','1985-01-06'),(180,'ARMANDO','UBEDA','890029260','MASCULINO','1991-03-18'),(181,'JOHNNY','PADILLA','890029261','MASCULINO','1988-08-24'),(182,'ADAN','SOTELO','890029262','MASCULINO','1996-10-03'),(183,'SAMUEL','RAYO','890029263','MASCULINO','1994-12-11'),(184,'AXEL','FERNANDEZ','890029264','MASCULINO','1997-10-29'),(185,'VÃ­CTOR','RODRIGUEZ','890029265','MASCULINO','1995-05-22'),(186,'HANIEL','HERNANDEZ','890029266','MASCULINO','1998-07-03'),(187,'MARCO','DAVILA','890029267','MASCULINO','1994-06-27'),(188,'OSCAR','GARCIA','890029268','MASCULINO','1988-11-15'),(189,'PEDRO','MEMBREÑO','890029269','MASCULINO','1992-09-29'),(190,'DOUGLAS','NICARAGUA','890029270','MASCULINO','2004-04-30'),(191,'FERNANDO','ZAMURIA','890029271','MASCULINO','1996-01-10'),(192,'WILBER','TAPIA','890029272','MASCULINO','2000-01-30'),(193,'RUBEN','PAIZANO','890029273','MASCULINO','2002-06-25'),(194,'JOSE','CRUZ','890029274','MASCULINO','1994-12-22'),(195,'LUIS','JIMENEZ','890029275','MASCULINO','1997-03-04'),(196,'ARIEL','NICARAGUA','890029276','MASCULINO','2000-06-22'),(197,'ANGELICA','CANO','890029277','MASCULINO','1991-04-14'),(198,'BYRON','MORALES','890029278','MASCULINO','1996-01-08'),(199,'ALVARO','RIVAS','890029279','MASCULINO','1983-02-03'),(200,'JOSE','LUNA','890029280','MASCULINO','1994-08-07'),(201,'GERARDO','MANZANAREZ','890029281','MASCULINO','1989-04-09'),(202,'ALAN','JESUS','890029282','MASCULINO','1999-03-19'),(203,'LEONTE','ORTEGA','890029283','MASCULINO','1999-05-10'),(204,'JORGE','ESPINOZA','890029284','MASCULINO','1992-11-15'),(205,'HUMBERTO','BONE','890029285','MASCULINO','2000-06-25'),(206,'BAYARDO','THOMPSON','890029286','MASCULINO','2001-08-01'),(207,'ELDER','RUIZ','890029287','MASCULINO','1995-05-01'),(208,'JUAN','PRADO','890029288','MASCULINO','2001-06-25'),(209,'PABLO','FONSECA','890029289','MASCULINO','2001-04-07'),(210,'ROBERTO','JESUS','890029290','MASCULINO','1992-06-21'),(211,'LUIS','MATUS','890029291','MASCULINO','1991-10-06'),(212,'YASER','LOPEZ','890029292','MASCULINO','1979-11-20'),(213,'GABRIEL','RODRIGUEZ','890029293','MASCULINO','1984-07-08'),(214,'KEVIN','COREA','890029294','MASCULINO','1989-02-06'),(215,'JORGE','CASTAÑEDA','890029295','MASCULINO','1997-08-04'),(216,'ELVIN','BRAVO','890029296','MASCULINO','2003-03-01'),(217,'BRYAN','HERNANDEZ','890029297','MASCULINO','1997-11-29'),(218,'JIMMY','ORTEGA','890029298','MASCULINO','1983-08-26'),(219,'OMAR','SILVA','890029299','MASCULINO','1990-07-01'),(220,'LESTER','LARA','890029300','MASCULINO','1986-11-03'),(221,'JUAN','MEJIA','890029301','MASCULINO','1996-11-11'),(222,'NORLAN','SEVILLA','890029302','MASCULINO','1993-11-22'),(223,'WESLIE','RODRIGUEZ','890029303','MASCULINO','2002-09-06'),(224,'EDGARD','JIMENEZ','890029304','MASCULINO','1992-04-08'),(225,'ERICK','LOHLOFFTZ','890029305','MASCULINO','1994-07-14'),(226,'ANDRES','BLASS','890029306','MASCULINO','2000-05-03'),(227,'MAYNOR','SOTELO','890029307','MASCULINO','1992-02-09'),(228,'JUAN','QUINTANA','890029308','MASCULINO','1984-12-26'),(229,'JARETH','RAMIREZ','890029309','MASCULINO','1997-08-01'),(230,'EDUARDO','RIVAS','890029310','MASCULINO','1988-10-31'),(231,'CRISTOPHER','CALDERON','890029311','MASCULINO','1989-04-05'),(232,'MARLON','CACERES','890029312','MASCULINO','1984-07-10'),(233,'JORGE','RIOS','890029313','MASCULINO','1990-08-28'),(234,'DANNY','LOHLOFFTZ','890029314','MASCULINO','1991-01-24'),(235,'JOSUE','HERNANDEZ','890029315','MASCULINO','1993-11-28'),(236,'BRYAN','CARDOBA','890029316','MASCULINO','1989-03-17'),(237,'LUAR','SALGADO','890029317','MASCULINO','1996-03-14'),(238,'ROBERTO','MIRANDA','890029318','MASCULINO','1991-09-17'),(239,'ELIETH','HERNANDEZ','890029319','MASCULINO','2000-11-15'),(240,'FRANCISCO','VALLEJOS','890029320','MASCULINO','1989-09-19'),(241,'CRISTIAN','GALEANO','890029321','MASCULINO','1987-10-25'),(242,'LESTER','FONSECA','890029322','MASCULINO','1992-10-22'),(243,'JENER','SANCHEZ','890029323','MASCULINO','1995-06-23'),(244,'LENIN','ZAYAS','890029324','MASCULINO','2001-04-01'),(245,'MARLON','ESPINOZA','890029325','MASCULINO','1998-04-03'),(246,'NORMAN','URIARTE','890029326','MASCULINO','1991-06-24'),(247,'HARRY','PICADO','890029327','MASCULINO','2000-01-13'),(248,'ROBERTO','JESUS','890029328','MASCULINO','2000-06-17'),(249,'NELSON','PALACIOS','890029329','MASCULINO','2003-12-08'),(250,'JOSE','MARTINEZ','890029330','MASCULINO','1986-09-17');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `conductores`
--

LOCK TABLES `conductores` WRITE;
/*!40000 ALTER TABLE `conductores` DISABLE KEYS */;
INSERT INTO `conductores` VALUES (1,40,'ANTONIO','SANCHEZ','1990-04-26','52-3519683','MASCULINO','Estatua de Montoya 2C. Sur 1 1/2 Oeste','ACTIVO',1),(2,41,'MANUEL','ADELA','2000-01-01','52-6505990','MASCULINO','Balcones Sto Domingo Lote No.57 de la aguja 1 Km al sur','ACTIVO',2),(3,42,'JOSE','MARTINEZ','1989-11-25','52-3499058','MASCULINO',NULL,'ACTIVO',3),(4,43,'FRANCISCO','CARRASCO','1995-02-11','52-9555367','MASCULINO','Semáforo de la subasta 300mts al sur','ACTIVO',4),(5,44,'DAVID','CUEVAS','1980-02-01','52-3519737','MASCULINO',NULL,'ACTIVO',5),(6,45,'JUAN','FERRERO','1994-07-06','52-4517685','MASCULINO','Km 11 carretera Norte Aeropuerto','ACTIVO',1),(7,46,'JOSE ANTONIO','MADERO','1976-09-25','52-6564888','MASCULINO',NULL,'ACTIVO',1),(8,47,'JAVIER','LEON','1993-07-26','52-8874444','MASCULINO','Del Club Terraza Villa Fontana 100 vrs','ACTIVO',1),(9,48,'DANIEL','HERNANDEZ','1996-12-11','52-5565477','MASCULINO','Pista Jean Paul Genie','ACTIVO',1),(10,49,'JOSE LUIS','MARTINEZ','1998-12-27','52-8018628','MASCULINO',NULL,'ACTIVO',1),(11,50,'FRANCISCO JAVIER','GARCIA','1976-12-22','52-6934824','MASCULINO',NULL,'ACTIVO',1),(12,19,'CARLOS','FERNANDEZ','1986-06-30','52-7116464','MASCULINO',NULL,'ACTIVO',1),(13,20,'JESUS','PEREZ','1990-01-04','52-6594876','MASCULINO','Km 8.5 C/N de los semáforos de la subasta 800mts al norte','ACTIVO',1),(14,21,'ALEJANDRO','JIMENEZ','1989-01-11','52-7854595','MASCULINO',NULL,'ACTIVO',2),(15,22,'MIGUEL','RUIZ','1990-11-28','52-4680206','MASCULINO','Clínica Santa María, 1 cuadra al Sur, 20 varas abajo','ACTIVO',2),(16,23,'MARIA DOLORES','SAENZ','1982-08-09','52-6736893','FEMENINO','Semáforos de Enitel Villa Fontana, 30 mts al Norte','ACTIVO',2),(17,24,'LAURA','GONZALEZ','1996-03-16','52-7180322','FEMENINO','De la catedral, 1 cuadra al Este, 1/2 cuadra al Sur','ACTIVO',2),(18,25,'MARIA TERESA','LOPEZ','1990-06-05','52-5697896','FEMENINO',NULL,'ACTIVO',2),(19,26,'ANA','GOMEZ','1988-02-25','52-5074633','FEMENINO',NULL,'INACTIVO',2),(20,27,'CRISTINA','RODRIGUEZ','1987-11-12','52-5686768','FEMENINO','De la Parroquia, 3 1/2 cuadras al Sur','INACTIVO',3),(21,28,'MARTA','MORENO','1987-10-24','52-8947068','FEMENINO','Plaza Inter, 1 cuadra al Sur, 1 cuadra al Oeste','INACTIVO',3),(22,29,'MARIA ANGELES','ALONSO','1998-05-03','52-6002934','FEMENINO','Casa de los Mejia Godoy, 1 cuadra al lago','ACTIVO',3),(23,30,'FRANCISCA','PASCUAL','1987-09-28','52-9055637','FEMENINO',NULL,'ACTIVO',3),(24,31,'LUCIA','GUTIERREZ','1993-11-09','52-7974272','FEMENINO',NULL,'ACTIVO',4),(25,32,'MARIA ISABEL','GIL','1998-06-03','52-7343501','FEMENINO',NULL,'ACTIVO',4),(26,33,'MARIA JOSE','DIAZ','1991-02-01','52-8700147','FEMENINO',NULL,'ACTIVO',4),(27,34,'ANTONIA','MARIN','2000-08-18','52-7486806','FEMENINO',NULL,'ACTIVO',4),(28,35,'DOLORES','EZQUERRO','1999-10-24','52-7313181','FEMENINO','Parque Darío, 1/2 cuadra arriba','ACTIVO',4),(29,36,'ALVARO','RUBIO','1997-12-14','52-6616580','MASCULINO','Del Reloj, 1 cuadra abajo','ACTIVO',5),(30,37,'ADRIAN','SANCHEZ','1984-11-04','52-9113674','MASCULINO','Esquina Sureste del Parque Central','ACTIVO',5),(31,38,'JUAN JOSE','CALVO','1992-01-28','52-6487633','MASCULINO','Km 19 Carretera a Ticuantepe','ACTIVO',5),(32,39,'DIEGO','SAEZ','1990-09-29','52-4355342','MASCULINO','Parque Sandino, 500 varas al Esta','INACTIVO',5),(33,1,'MARIA VICTORIA','IBANEZ','1998-05-06','52-4389266','FEMENINO','Puente León 2 cuadras abajo','INACTIVO',5),(34,2,'EVA MARIA','BLANCO','1998-03-30','52-8364603','FEMENINO','Semáforos del Zumen, 50 varas al Sur','INACTIVO',1),(35,3,'INES','GARRIDO','1991-12-12','52-5023604','FEMENINO',NULL,'ACTIVO',1),(36,4,'MIRIAM','GUTIERREZ','1998-07-07','52-4159394','FEMENINO',NULL,'ACTIVO',1),(37,5,'MARIA ROSA','ALVAREZ','1987-12-30','52-5591171','FEMENINO','Pista Juan Pablo II, contiguo a Union Fenosa','ACTIVO',1),(38,6,'DANIELA','PALACIOS','1992-12-26','52-4612412','FEMENINO','De la Subasta 10 vrs al lago, frente a Café Soluble','ACTIVO',1),(39,7,'LORENA','MUNOZ','1993-05-07','52-9453091','FEMENINO',NULL,'ACTIVO',3),(40,8,'ANA BELEN','SANTAMARIA','1994-12-08','52-8331445','FEMENINO',NULL,'ACTIVO',3),(41,9,'MARIA ELENA','BENITO','1993-02-16','52-7174212','FEMENINO','Entrada a reparto Cailagua, 20 varas al Sur','ACTIVO',3),(42,10,'JUAN MANUEL','RAMIREZ','1983-06-16','52-8754064','MASCULINO','De donde fue el cine Cabrera 1 cuadra al Norte','ACTIVO',3),(43,11,'JOAQUIN','OCHOA','1992-04-22','52-7913645','MASCULINO',NULL,'ACTIVO',5),(44,12,'SANTIAGO','DIAZ','1992-07-01','52-4165349','MASCULINO',NULL,'INACTIVO',5),(45,13,'VICTOR','ORTEGA','2000-04-24','52-8199111','MASCULINO',NULL,'ACTIVO',5),(46,14,'EDUARDO','HERCE','1992-11-09','52-6554714','MASCULINO','Frente a Iglesie Santa Ana','ACTIVO',2),(47,15,'MARIO','LEON','1990-06-01','52-7467787','MASCULINO','Calle Principal de San Juan del Sur','ACTIVO',2),(48,16,'ROBERTO','MARTIN','1989-05-27','52-5893946','MASCULINO','Costado oeste del parque central','ACTIVO',2),(49,17,'JAIME','GABARRI','1991-08-10','52-8454005','MASCULINO','Barrio San Judas, Los Cocos, 3 cuadras arriba','ACTIVO',2),(50,18,'PEDRO','GUTIERREZ','1994-07-24','52-8454058','MASCULINO','Contiguo a Escuela Salvador Mendieta','ACTIVO',2),(55,40,'ANTONIO','SANCHEZ','1990-04-26','52-3519683','MASCULINO','Estatua de Montoya 2C. Sur 1 1/2 Oeste','ACTIVO',1),(56,40,'ANTONIO','SANCHEZ','1990-04-26','52-3519683','MASCULINO','Estatua de Montoya 2C. Sur 1 1/2 Oeste','ACTIVO',5);
/*!40000 ALTER TABLE `conductores` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_before_bonus_conductor` BEFORE INSERT ON `conductores` FOR EACH ROW BEGIN  
   /* Bonus for Sales Assistant */
     IF (new.id_ciudad = 5) 
     THEN 
       INSERT INTO city_conductores_bonus (id_conductor, id_ciudad, bono) VALUES (NEW.id_conductor, NEW.id_ciudad, 1000);
    ELSEIF
      (new.id_ciudad = 3)
     THEN 
        INSERT INTO city_conductores_bonus (id_conductor, id_ciudad, bono) VALUES (NEW.id_conductor, NEW.id_ciudad, 2000);
   END IF;  
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_registro_conductor` AFTER INSERT ON `conductores` FOR EACH ROW INSERT INTO registro_conductores (id_conductor, nombre, apellido, fecha_registro)
VALUES (NEW.id_conductor, NEW.nombre, NEW.apellido, current_date()) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping data for table `descuento_recorrido`
--

LOCK TABLES `descuento_recorrido` WRITE;
/*!40000 ALTER TABLE `descuento_recorrido` DISABLE KEYS */;
INSERT INTO `descuento_recorrido` VALUES (1003,55,15);
/*!40000 ALTER TABLE `descuento_recorrido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `recorridos`
--

LOCK TABLES `recorridos` WRITE;
/*!40000 ALTER TABLE `recorridos` DISABLE KEYS */;
INSERT INTO `recorridos` VALUES (1,1,1,'2022-08-02',10),(2,2,2,'2022-05-02',8),(3,3,3,'2022-05-30',2),(4,4,4,'2022-07-18',15),(5,5,5,'2022-05-17',11),(6,6,6,'2022-07-12',3),(7,7,7,'2022-06-26',9),(8,8,8,'2022-05-21',3),(9,9,9,'2022-06-21',4),(10,10,10,'2022-07-07',3),(11,11,11,'2022-06-26',3),(12,12,12,'2022-05-06',3),(13,13,13,'2022-05-24',3),(14,14,14,'2022-05-22',9),(15,15,15,'2022-06-10',3),(16,16,16,'2022-07-30',3),(17,17,17,'2022-07-12',9),(18,18,18,'2022-05-05',3),(19,19,19,'2022-06-20',4),(20,20,20,'2022-07-02',6),(21,21,21,'2022-07-25',3),(22,22,22,'2022-06-16',9),(23,23,23,'2022-07-27',6),(24,24,24,'2022-06-19',10),(25,25,25,'2022-08-10',11),(26,26,26,'2022-07-14',6),(27,27,27,'2022-07-20',10),(28,28,28,'2022-05-11',8),(29,29,29,'2022-07-31',1),(30,30,30,'2022-07-22',8),(31,31,31,'2022-06-09',3),(32,32,32,'2022-06-19',2),(33,33,33,'2022-07-06',8),(34,34,34,'2022-06-26',7),(35,35,35,'2022-06-03',5),(36,36,36,'2022-06-18',8),(37,37,37,'2022-05-14',8),(38,38,38,'2022-05-27',3),(39,39,39,'2022-07-09',10),(40,40,40,'2022-05-30',11),(41,41,41,'2022-06-15',5),(42,42,42,'2022-08-10',10),(43,43,43,'2022-07-14',9),(44,44,44,'2022-06-26',3),(45,45,45,'2022-07-29',3),(46,46,46,'2022-05-19',11),(47,47,47,'2022-07-20',12),(48,48,48,'2022-07-19',6),(49,49,49,'2022-05-12',7),(50,50,50,'2022-05-02',11),(51,1,51,'2022-05-30',5),(52,2,52,'2022-07-15',10),(53,3,53,'2022-06-25',3),(54,4,54,'2022-05-03',12),(55,5,55,'2022-06-11',3),(56,6,56,'2022-08-11',9),(57,7,57,'2022-08-01',3),(58,8,58,'2022-07-30',4),(59,9,59,'2022-07-25',6),(60,10,60,'2022-07-15',9),(61,11,61,'2022-05-27',9),(62,12,62,'2022-05-09',6),(63,13,63,'2022-07-16',2),(64,14,64,'2022-05-20',6),(65,15,65,'2022-07-03',10),(66,16,66,'2022-07-03',7),(67,17,67,'2022-07-01',4),(68,18,68,'2022-06-18',5),(69,19,69,'2022-08-02',6),(70,20,70,'2022-06-03',3),(71,21,71,'2022-05-02',4),(72,22,72,'2022-05-01',10),(73,23,73,'2022-07-30',13),(74,24,74,'2022-08-09',10),(75,25,75,'2022-06-28',9),(76,26,76,'2022-08-06',12),(77,27,77,'2022-07-08',3),(78,28,78,'2022-06-02',4),(79,29,79,'2022-07-19',3),(80,30,80,'2022-05-14',5),(81,31,81,'2022-07-14',7),(82,32,82,'2022-05-30',10),(83,33,83,'2022-07-08',9),(84,34,84,'2022-07-16',7),(85,35,85,'2022-05-16',11),(86,36,86,'2022-05-31',11),(87,37,87,'2022-07-30',11),(88,38,88,'2022-06-12',5),(89,39,89,'2022-05-27',5),(90,40,90,'2022-07-17',7),(91,41,91,'2022-07-10',8),(92,42,92,'2022-07-23',5),(93,43,93,'2022-05-31',3),(94,44,94,'2022-07-22',7),(95,45,95,'2022-06-25',12),(96,46,96,'2022-07-19',3),(97,47,97,'2022-05-27',7),(98,48,98,'2022-08-07',9),(99,49,99,'2022-06-18',13),(100,50,100,'2022-06-04',6),(101,1,101,'2022-05-20',9),(102,2,102,'2022-05-02',9),(103,1,103,'2022-07-16',3),(104,2,104,'2022-06-16',2),(105,1,105,'2022-06-14',12),(106,2,106,'2022-07-20',7),(107,1,107,'2022-07-30',10),(108,2,108,'2022-06-19',9),(109,1,109,'2022-05-27',4),(110,2,110,'2022-05-14',9),(111,1,111,'2022-07-17',7),(112,2,112,'2022-07-30',6),(113,1,113,'2022-06-02',8),(114,2,114,'2022-05-04',6),(115,3,115,'2022-07-24',4),(116,3,116,'2022-06-01',5),(117,3,117,'2022-05-13',11),(118,3,118,'2022-07-20',3),(119,3,119,'2022-05-07',10),(120,3,120,'2022-06-11',4),(121,3,121,'2022-08-07',4),(122,3,122,'2022-06-15',4),(123,3,123,'2022-07-28',11),(124,3,124,'2022-05-15',6),(125,3,125,'2022-05-10',5),(126,3,126,'2022-06-23',8),(127,3,127,'2022-08-10',4),(128,3,128,'2022-05-25',4),(129,3,129,'2022-08-09',6),(130,3,130,'2022-06-22',6),(131,3,131,'2022-05-22',5),(132,3,132,'2022-05-17',3),(133,3,133,'2022-05-28',8),(134,3,134,'2022-07-13',3),(135,3,135,'2022-06-16',3),(136,3,136,'2022-07-18',3),(137,3,137,'2022-08-10',3),(138,3,138,'2022-05-27',6),(139,3,139,'2022-08-02',7),(140,3,140,'2022-07-20',9),(141,3,141,'2022-07-10',3),(142,3,142,'2022-06-04',7),(143,3,143,'2022-07-17',12),(144,3,144,'2022-07-26',7),(145,47,145,'2022-08-06',10),(146,47,146,'2022-07-01',4),(147,47,147,'2022-07-17',6),(148,47,148,'2022-06-23',6),(149,47,149,'2022-06-14',5),(150,47,150,'2022-08-09',6),(151,47,151,'2022-05-26',3),(152,47,152,'2022-05-27',12),(153,47,153,'2022-06-03',5),(154,47,154,'2022-05-26',6),(155,47,155,'2022-05-09',7),(156,47,156,'2022-05-27',7),(157,47,157,'2022-07-17',5),(158,47,158,'2022-07-26',7),(159,32,159,'2022-05-28',8),(160,33,160,'2022-07-10',10),(161,34,161,'2022-06-18',3),(162,35,162,'2022-08-04',3),(163,36,163,'2022-06-14',8),(164,37,164,'2022-08-08',3),(165,38,165,'2022-06-10',3),(166,39,166,'2022-06-26',3),(167,40,167,'2022-05-17',3),(168,41,168,'2022-05-04',6),(169,42,169,'2022-07-14',7),(170,43,170,'2022-05-07',9),(171,44,171,'2022-05-11',3),(172,45,172,'2022-05-30',9),(173,46,173,'2022-06-13',3),(174,47,174,'2022-07-15',7),(175,48,175,'2022-05-20',12),(176,49,176,'2022-05-29',7),(177,50,177,'2022-08-06',10),(178,32,178,'2022-05-14',4),(179,33,179,'2022-05-03',6),(180,34,180,'2022-07-30',6),(181,35,181,'2022-05-13',14),(182,36,182,'2022-05-19',9),(183,37,183,'2022-07-15',6),(184,38,184,'2022-06-13',3),(185,39,185,'2022-07-12',9),(186,40,186,'2022-06-11',3),(187,41,187,'2022-06-04',7),(188,42,188,'2022-08-11',12),(189,43,189,'2022-05-01',7),(190,44,190,'2022-05-20',10),(191,45,191,'2022-08-05',4),(192,46,192,'2022-08-01',6),(193,47,193,'2022-06-16',6),(194,48,194,'2022-05-02',6),(195,49,195,'2022-08-05',10),(196,50,196,'2022-07-30',8),(197,32,197,'2022-07-31',9),(198,33,198,'2022-05-17',9),(199,34,199,'2022-05-29',3),(200,35,200,'2022-06-26',7),(201,36,201,'2022-08-05',12),(202,37,202,'2022-07-14',7),(203,38,203,'2022-06-12',10),(204,39,204,'2022-05-29',4),(205,40,205,'2022-06-18',6),(206,41,206,'2022-07-09',6),(207,42,207,'2022-05-29',8),(208,43,208,'2022-07-13',8),(209,44,209,'2022-08-06',10),(210,45,210,'2022-07-03',3),(211,46,211,'2022-08-01',6),(212,47,212,'2022-05-21',3),(213,48,213,'2022-07-08',9),(214,49,214,'2022-05-17',4),(215,50,215,'2022-05-14',7),(216,5,216,'2022-06-09',4),(217,6,217,'2022-07-03',8),(218,7,218,'2022-05-21',3),(219,8,219,'2022-07-06',7),(220,9,220,'2022-05-07',9),(221,10,221,'2022-08-02',3),(222,11,222,'2022-07-18',7),(223,12,223,'2022-06-18',12),(224,13,224,'2022-07-17',7),(225,14,225,'2022-07-23',10),(226,15,226,'2022-06-30',4),(227,16,227,'2022-07-15',6),(228,17,228,'2022-07-22',6),(229,18,229,'2022-05-15',10),(230,19,230,'2022-06-13',4),(231,20,231,'2022-05-17',6),(232,21,232,'2022-06-10',9),(233,22,233,'2022-05-13',3),(234,23,234,'2022-05-14',7),(235,24,235,'2022-05-18',12),(236,25,236,'2022-06-18',7),(237,26,237,'2022-07-16',10),(238,27,238,'2022-07-31',4),(239,28,239,'2022-06-19',6),(240,29,240,'2022-06-14',6),(241,5,241,'2022-06-07',4),(242,6,242,'2022-07-09',5),(243,7,243,'2022-07-31',10),(244,8,244,'2022-07-04',8),(245,9,245,'2022-07-10',3),(246,10,246,'2022-06-22',9),(247,11,247,'2022-07-30',10),(248,12,248,'2022-07-19',6),(249,13,249,'2022-05-27',3),(250,14,250,'2022-07-25',3),(251,15,1,'2022-07-31',10),(252,16,2,'2022-06-26',9),(253,17,3,'2022-06-17',6),(254,18,4,'2022-06-29',8),(255,19,5,'2022-06-17',9),(256,20,6,'2022-08-02',6),(257,21,7,'2022-05-21',8),(258,22,8,'2022-07-18',10),(259,23,9,'2022-05-26',3),(260,24,10,'2022-05-20',3),(261,25,52,'2022-07-27',4),(262,26,53,'2022-05-24',7),(263,27,54,'2022-07-09',2),(264,28,55,'2022-08-01',8),(265,29,56,'2022-05-20',4),(266,5,57,'2022-08-03',3),(267,6,58,'2022-08-10',7),(268,7,59,'2022-07-08',12),(269,8,60,'2022-06-05',9),(270,9,61,'2022-07-14',10),(271,10,62,'2022-05-15',7),(272,11,63,'2022-05-21',7),(273,12,64,'2022-07-23',9),(274,13,65,'2022-07-29',7),(275,14,66,'2022-08-06',3),(276,15,67,'2022-05-22',4),(277,16,68,'2022-06-03',6),(278,17,69,'2022-05-25',10),(279,18,70,'2022-05-02',5),(280,19,71,'2022-06-05',7),(281,20,72,'2022-07-18',5),(282,21,226,'2022-05-27',12),(283,22,227,'2022-05-15',5),(284,23,228,'2022-06-25',16),(285,24,229,'2022-07-24',8),(286,25,230,'2022-07-17',11),(287,26,231,'2022-05-30',5),(288,27,232,'2022-06-27',4),(289,28,233,'2022-06-12',8),(290,29,234,'2022-05-23',6),(291,5,235,'2022-07-20',7),(292,6,236,'2022-07-24',3),(293,7,237,'2022-07-02',9),(294,8,238,'2022-05-27',3),(295,9,239,'2022-05-13',7),(296,10,240,'2022-08-06',4),(297,11,241,'2022-08-05',11),(298,12,242,'2022-07-24',11),(299,13,243,'2022-07-26',7),(300,14,244,'2022-07-10',5),(301,5,245,'2022-06-06',6),(302,6,246,'2022-05-27',3),(303,7,247,'2022-07-07',5),(304,8,248,'2022-07-16',4),(305,9,27,'2022-07-30',9),(306,10,28,'2022-08-02',4),(307,11,29,'2022-07-30',2),(308,12,30,'2022-07-01',5),(309,13,31,'2022-07-09',6),(310,14,32,'2022-07-07',2),(311,5,33,'2022-05-29',6),(312,6,34,'2022-05-02',3),(313,7,35,'2022-05-27',10),(314,8,36,'2022-05-09',4),(315,9,37,'2022-06-27',12),(316,10,38,'2022-07-20',7),(317,11,39,'2022-06-26',9),(318,12,40,'2022-05-14',4),(319,13,41,'2022-06-08',3),(320,14,42,'2022-07-13',7),(321,26,43,'2022-07-03',7),(322,27,44,'2022-06-11',6),(323,28,45,'2022-07-15',2),(324,29,46,'2022-05-20',9),(325,30,47,'2022-07-22',3),(326,31,48,'2022-05-06',7),(327,32,49,'2022-05-24',3),(328,33,50,'2022-07-11',1),(329,34,51,'2022-05-19',3),(330,35,52,'2022-06-17',7),(331,36,53,'2022-07-09',7),(332,37,54,'2022-05-07',3),(333,38,55,'2022-07-24',6),(334,39,56,'2022-07-24',9),(335,40,57,'2022-05-22',5),(336,26,42,'2022-05-01',3),(337,27,43,'2022-05-29',2),(338,28,44,'2022-05-30',11),(339,29,45,'2022-07-20',9),(340,30,46,'2022-05-27',5),(341,31,47,'2022-05-15',8),(342,32,48,'2022-05-28',3),(343,33,49,'2022-06-18',4),(344,34,50,'2022-05-19',5),(345,35,51,'2022-08-06',7),(346,36,52,'2022-07-12',3),(347,37,53,'2022-05-24',8),(348,38,54,'2022-07-13',6),(349,39,55,'2022-06-21',3),(350,40,56,'2022-05-15',5),(351,26,57,'2022-07-19',7),(352,27,42,'2022-07-22',6),(353,28,43,'2022-05-25',4),(354,29,44,'2022-05-15',5),(355,30,45,'2022-05-14',6),(356,31,46,'2022-07-04',8),(357,32,47,'2022-07-29',5),(358,33,48,'2022-05-10',11),(359,34,49,'2022-05-27',10),(360,35,50,'2022-06-07',8),(361,36,51,'2022-05-29',9),(362,37,52,'2022-06-19',11),(363,38,53,'2022-05-09',7),(364,39,54,'2022-05-12',5),(365,40,55,'2022-06-29',5),(366,26,56,'2022-06-30',11),(367,27,57,'2022-07-17',2),(368,28,86,'2022-05-28',11),(369,29,87,'2022-05-27',4),(370,30,88,'2022-06-17',7),(371,31,89,'2022-07-19',7),(372,32,90,'2022-05-06',6),(373,33,91,'2022-06-23',5),(374,34,92,'2022-05-21',6),(375,35,93,'2022-07-09',2),(376,36,94,'2022-05-07',7),(377,37,95,'2022-07-01',4),(378,38,96,'2022-05-27',5),(379,39,97,'2022-07-16',14),(380,40,98,'2022-08-01',5),(381,1,99,'2022-08-06',7),(382,2,100,'2022-05-16',10),(383,3,101,'2022-07-19',5),(384,4,102,'2022-06-05',5),(385,5,103,'2022-05-02',3),(386,6,104,'2022-07-09',5),(387,7,105,'2022-07-25',5),(388,8,106,'2022-06-20',5),(389,9,107,'2022-07-17',8),(390,10,108,'2022-07-24',5),(391,11,109,'2022-06-15',5),(392,12,110,'2022-07-24',9),(393,13,111,'2022-07-21',6),(394,14,112,'2022-06-14',3),(395,15,113,'2022-07-09',3),(396,16,114,'2022-05-28',9),(397,17,115,'2022-07-29',7),(398,18,116,'2022-05-29',14),(399,19,117,'2022-07-23',3),(400,20,118,'2022-07-09',9),(401,21,119,'2022-07-13',7),(402,22,120,'2022-08-05',7),(403,23,121,'2022-07-28',13),(404,24,122,'2022-06-26',6),(405,25,123,'2022-07-12',8),(406,26,124,'2022-06-29',3),(407,27,125,'2022-07-30',3),(408,28,126,'2022-06-24',3),(409,29,127,'2022-07-09',1),(410,30,128,'2022-06-24',13),(411,31,129,'2022-06-19',11),(412,32,130,'2022-08-05',9),(413,33,131,'2022-06-23',4),(414,34,132,'2022-05-29',6),(415,35,133,'2022-07-13',8),(416,36,134,'2022-05-11',8),(417,37,135,'2022-05-14',6),(418,38,136,'2022-07-18',8),(419,39,137,'2022-06-23',11),(420,40,138,'2022-05-27',6),(421,41,139,'2022-07-18',3),(422,42,140,'2022-07-16',11),(423,43,141,'2022-05-25',5),(424,44,142,'2022-07-28',5),(425,45,52,'2022-06-21',12),(426,46,53,'2022-07-09',9),(427,47,54,'2022-07-17',5),(428,48,55,'2022-07-02',3),(429,49,56,'2022-06-16',10),(430,50,57,'2022-06-16',4),(431,1,86,'2022-06-27',2),(432,2,87,'2022-05-02',12),(433,3,88,'2022-06-13',8),(434,4,89,'2022-07-21',3),(435,5,90,'2022-06-23',7),(436,6,91,'2022-05-21',3),(437,7,92,'2022-08-01',6),(438,8,93,'2022-08-06',13),(439,9,94,'2022-07-14',7),(440,10,95,'2022-06-05',3),(441,11,96,'2022-07-24',5),(442,12,97,'2022-07-10',2),(443,13,98,'2022-05-07',9),(444,14,1,'2022-05-15',9),(445,15,2,'2022-07-12',2),(446,16,3,'2022-07-23',8),(447,17,4,'2022-05-27',5),(448,18,5,'2022-05-09',4),(449,19,6,'2022-07-18',7),(450,20,7,'2022-06-03',3),(451,21,8,'2022-05-03',6),(452,22,9,'2022-05-30',8),(453,23,10,'2022-06-09',9),(454,24,11,'2022-08-07',7),(455,25,12,'2022-05-28',3),(456,26,13,'2022-05-07',9),(457,27,14,'2022-05-17',5),(458,28,15,'2022-07-23',7),(459,29,16,'2022-05-03',9),(460,30,17,'2022-05-10',7),(461,31,18,'2022-08-07',14),(462,32,19,'2022-07-19',4),(463,33,20,'2022-05-21',8),(464,34,21,'2022-05-13',8),(465,35,22,'2022-08-02',5),(466,36,23,'2022-07-31',2),(467,37,24,'2022-06-24',6),(468,38,25,'2022-06-29',6),(469,39,26,'2022-07-07',7),(470,40,27,'2022-05-15',5),(471,41,28,'2022-07-15',9),(472,42,29,'2022-06-04',5),(473,43,30,'2022-07-09',3),(474,44,31,'2022-07-09',8),(475,45,32,'2022-06-08',4),(476,46,33,'2022-05-15',11),(477,47,34,'2022-05-05',3),(478,48,35,'2022-07-20',9),(479,49,36,'2022-07-16',5),(480,50,37,'2022-06-11',12),(481,1,38,'2022-05-27',8),(482,2,39,'2022-07-11',5),(483,1,40,'2022-05-01',1),(484,2,41,'2022-05-15',6),(485,1,42,'2022-07-01',9),(486,2,43,'2022-07-25',3),(487,1,44,'2022-08-02',3),(488,2,45,'2022-08-04',5),(489,1,46,'2022-07-24',7),(490,2,47,'2022-05-15',11),(491,1,48,'2022-07-10',10),(492,2,49,'2022-05-01',3),(493,1,50,'2022-07-09',3),(494,2,51,'2022-07-13',5),(495,3,52,'2022-08-10',2),(496,3,53,'2022-07-22',5),(497,3,54,'2022-06-10',7),(498,3,55,'2022-07-08',3),(499,3,56,'2022-08-06',7),(500,3,57,'2022-05-07',7),(501,3,58,'2022-06-05',7),(502,3,59,'2022-06-26',11),(503,3,60,'2022-06-26',5),(504,3,61,'2022-07-17',10),(505,3,62,'2022-05-03',5),(506,3,63,'2022-07-23',8),(507,3,64,'2022-05-21',2),(508,3,65,'2022-07-22',4),(509,3,66,'2022-07-20',4),(510,3,67,'2022-07-10',3),(511,3,68,'2022-07-04',7),(512,3,69,'2022-07-15',6),(513,3,70,'2022-07-19',10),(514,3,71,'2022-06-18',4),(515,3,72,'2022-07-09',8),(516,3,73,'2022-07-18',4),(517,3,74,'2022-05-15',3),(518,3,75,'2022-05-24',8),(519,3,76,'2022-07-09',5),(520,3,77,'2022-06-01',5),(521,3,78,'2022-05-12',2),(522,3,79,'2022-07-21',5),(523,3,80,'2022-06-12',8),(524,3,81,'2022-07-03',3),(525,47,82,'2022-05-29',4),(526,47,83,'2022-05-07',6),(527,47,84,'2022-07-20',9),(528,47,85,'2022-06-28',7),(529,47,86,'2022-06-23',6),(530,47,87,'2022-05-01',8),(531,47,88,'2022-07-15',10),(532,47,89,'2022-07-29',6),(533,47,90,'2022-05-01',4),(534,47,91,'2022-06-01',10),(535,47,92,'2022-05-31',13),(536,47,93,'2022-06-02',7),(537,47,94,'2022-05-21',3),(538,47,95,'2022-06-18',7),(539,32,96,'2022-07-18',5),(540,33,97,'2022-07-18',13),(541,34,98,'2022-05-04',8),(542,35,99,'2022-05-31',3),(543,36,100,'2022-05-04',1),(544,37,101,'2022-07-03',8),(545,38,102,'2022-08-08',10),(546,39,103,'2022-05-12',10),(547,40,104,'2022-08-07',10),(548,41,105,'2022-07-02',8),(549,42,106,'2022-07-01',6),(550,43,107,'2022-07-13',3),(551,44,108,'2022-07-20',7),(552,45,109,'2022-07-09',9),(553,46,110,'2022-06-01',7),(554,47,111,'2022-07-17',3),(555,48,112,'2022-07-31',8),(556,49,113,'2022-05-21',14),(557,50,114,'2022-07-07',10),(558,32,115,'2022-06-10',3),(559,33,116,'2022-05-31',3),(560,34,117,'2022-06-19',2),(561,35,118,'2022-06-25',7),(562,36,119,'2022-05-04',8),(563,37,120,'2022-07-17',5),(564,38,121,'2022-07-11',2),(565,39,122,'2022-07-13',10),(566,40,123,'2022-08-05',6),(567,41,124,'2022-05-09',10),(568,42,125,'2022-06-28',6),(569,43,126,'2022-07-18',9),(570,44,127,'2022-07-01',5),(571,45,128,'2022-05-22',11),(572,46,129,'2022-06-01',5),(573,47,130,'2022-05-19',9),(574,48,131,'2022-07-20',11),(575,49,132,'2022-06-16',6),(576,50,133,'2022-06-25',7),(577,32,134,'2022-07-23',3),(578,33,135,'2022-08-02',3),(579,34,136,'2022-06-13',4),(580,35,137,'2022-07-24',5),(581,36,138,'2022-06-29',5),(582,37,139,'2022-08-02',6),(583,38,140,'2022-06-21',3),(584,39,141,'2022-07-14',3),(585,40,142,'2022-07-21',2),(586,41,143,'2022-05-13',5),(587,42,144,'2022-06-18',8),(588,43,145,'2022-05-02',10),(589,44,146,'2022-05-01',7),(590,45,147,'2022-05-14',7),(591,46,148,'2022-05-29',9),(592,47,149,'2022-06-18',7),(593,48,150,'2022-06-25',7),(594,49,151,'2022-07-25',1),(595,50,152,'2022-05-22',8),(596,5,153,'2022-06-04',7),(597,6,154,'2022-07-06',11),(598,7,155,'2022-07-19',3),(599,8,156,'2022-06-01',10),(600,9,157,'2022-06-02',5),(601,10,158,'2022-05-03',5),(602,11,159,'2022-07-04',13),(603,12,160,'2022-07-10',3),(604,13,161,'2022-07-12',5),(605,14,162,'2022-05-23',8),(606,15,163,'2022-07-02',8),(607,16,164,'2022-07-19',9),(608,17,165,'2022-07-20',5),(609,18,166,'2022-07-18',11),(610,19,167,'2022-05-27',10),(611,20,168,'2022-07-16',4),(612,21,169,'2022-06-18',9),(613,22,170,'2022-07-20',9),(614,23,171,'2022-07-25',3),(615,24,172,'2022-06-29',7),(616,25,173,'2022-06-10',3),(617,26,174,'2022-05-30',7),(618,27,175,'2022-05-19',7),(619,28,176,'2022-05-17',3),(620,29,177,'2022-05-06',8),(621,5,178,'2022-07-06',5),(622,6,179,'2022-07-20',5),(623,7,180,'2022-07-19',11),(624,8,181,'2022-08-02',4),(625,9,182,'2022-08-01',5),(626,10,183,'2022-07-10',10),(627,11,184,'2022-07-09',10),(628,12,185,'2022-05-31',3),(629,13,186,'2022-07-30',3),(630,14,187,'2022-07-24',7),(631,15,188,'2022-08-07',6),(632,16,189,'2022-07-19',10),(633,17,190,'2022-05-03',3),(634,18,191,'2022-07-23',6),(635,19,192,'2022-08-11',2),(636,20,193,'2022-07-06',11),(637,21,194,'2022-07-27',5),(638,22,195,'2022-08-01',7),(639,23,196,'2022-07-07',3),(640,24,197,'2022-07-07',6),(641,25,198,'2022-07-19',4),(642,26,199,'2022-06-15',5),(643,27,200,'2022-05-28',7),(644,28,201,'2022-07-23',3),(645,29,202,'2022-06-26',6),(646,5,203,'2022-05-27',5),(647,6,204,'2022-07-15',5),(648,7,205,'2022-06-07',9),(649,8,206,'2022-05-18',8),(650,9,207,'2022-07-23',2),(651,10,208,'2022-07-17',10),(652,11,209,'2022-07-16',4),(653,12,210,'2022-07-15',4),(654,13,211,'2022-07-02',8),(655,14,212,'2022-06-25',11),(656,15,213,'2022-08-02',8),(657,16,214,'2022-05-08',5),(658,17,215,'2022-06-18',4),(659,18,216,'2022-07-17',9),(660,19,217,'2022-07-02',10),(661,20,218,'2022-07-30',11),(662,21,219,'2022-05-09',10),(663,22,220,'2022-05-19',10),(664,23,221,'2022-06-02',8),(665,24,222,'2022-07-24',3),(666,25,223,'2022-07-17',8),(667,26,224,'2022-07-08',6),(668,27,225,'2022-07-15',11),(669,28,226,'2022-05-30',7),(670,29,227,'2022-07-18',14),(671,5,228,'2022-05-22',5),(672,6,229,'2022-07-27',1),(673,7,230,'2022-06-13',3),(674,8,231,'2022-07-24',10),(675,9,232,'2022-05-07',4),(676,10,233,'2022-06-06',10),(677,11,234,'2022-05-09',5),(678,12,235,'2022-08-06',5),(679,13,236,'2022-08-04',2),(680,14,237,'2022-07-19',10),(681,5,238,'2022-07-09',10),(682,6,239,'2022-07-18',13),(683,7,240,'2022-07-31',7),(684,8,241,'2022-08-05',6),(685,9,242,'2022-07-30',7),(686,10,243,'2022-06-03',6),(687,11,244,'2022-07-21',3),(688,12,245,'2022-07-25',2),(689,13,246,'2022-06-05',7),(690,14,247,'2022-08-10',9),(691,5,248,'2022-06-12',2),(692,6,249,'2022-07-12',8),(693,7,250,'2022-08-05',11),(694,8,1,'2022-08-10',10),(695,9,2,'2022-07-25',4),(696,10,3,'2022-05-28',13),(697,11,4,'2022-07-27',4),(698,12,5,'2022-05-21',5),(699,13,6,'2022-06-04',5),(700,14,7,'2022-06-17',3),(701,26,8,'2022-07-08',2),(702,27,9,'2022-06-01',3),(703,28,10,'2022-06-15',5),(704,29,52,'2022-06-28',5),(705,30,53,'2022-06-05',3),(706,31,54,'2022-06-29',10),(707,32,55,'2022-06-24',9),(708,33,56,'2022-05-25',9),(709,34,57,'2022-05-21',4),(710,35,58,'2022-05-30',5),(711,36,59,'2022-06-02',1),(712,37,60,'2022-07-26',3),(713,38,61,'2022-05-25',8),(714,39,62,'2022-06-24',3),(715,40,63,'2022-05-28',10),(716,26,64,'2022-05-27',8),(717,27,65,'2022-07-03',6),(718,28,66,'2022-07-24',3),(719,29,67,'2022-06-10',2),(720,30,68,'2022-06-03',2),(721,31,69,'2022-05-23',4),(722,32,70,'2022-05-16',9),(723,33,71,'2022-07-19',11),(724,34,72,'2022-07-21',7),(725,35,226,'2022-06-12',11),(726,36,227,'2022-07-30',5),(727,37,228,'2022-08-01',7),(728,38,229,'2022-06-16',7),(729,39,230,'2022-06-04',8),(730,40,231,'2022-07-28',4),(731,26,232,'2022-05-31',10),(732,27,233,'2022-06-16',10),(733,28,234,'2022-08-01',6),(734,29,235,'2022-08-06',3),(735,30,236,'2022-05-19',6),(736,31,237,'2022-06-03',9),(737,32,238,'2022-06-06',9),(738,33,239,'2022-08-05',4),(739,34,240,'2022-07-17',10),(740,35,241,'2022-07-16',4),(741,36,242,'2022-05-31',8),(742,37,243,'2022-07-03',2),(743,38,244,'2022-06-11',3),(744,39,245,'2022-06-07',2),(745,40,246,'2022-05-01',10),(746,26,247,'2022-05-31',3),(747,27,248,'2022-06-23',7),(748,28,27,'2022-07-17',10),(749,29,28,'2022-05-20',7),(750,30,29,'2022-07-30',5),(751,31,30,'2022-05-29',8),(752,32,31,'2022-05-24',10),(753,33,32,'2022-05-17',8),(754,34,33,'2022-05-21',7),(755,35,34,'2022-05-27',9),(756,36,35,'2022-08-08',4),(757,37,36,'2022-07-17',10),(758,38,37,'2022-05-15',5),(759,39,38,'2022-05-21',7),(760,40,39,'2022-05-30',3),(761,1,40,'2022-07-23',11),(762,2,41,'2022-05-17',13),(763,3,42,'2022-07-07',5),(764,4,43,'2022-05-01',8),(765,5,44,'2022-05-23',6),(766,6,45,'2022-07-12',3),(767,7,46,'2022-07-19',7),(768,8,47,'2022-07-15',10),(769,9,48,'2022-05-01',3),(770,10,49,'2022-05-04',9),(771,11,50,'2022-06-18',8),(772,12,51,'2022-06-10',5),(773,13,52,'2022-05-07',4),(774,14,53,'2022-05-27',2),(775,15,54,'2022-07-24',6),(776,16,55,'2022-06-18',8),(777,17,56,'2022-07-20',3),(778,18,57,'2022-05-13',5),(779,19,42,'2022-05-24',7),(780,20,43,'2022-08-05',6),(781,21,44,'2022-05-29',8),(782,22,45,'2022-06-17',9),(783,23,46,'2022-06-11',6),(784,24,47,'2022-05-22',9),(785,25,48,'2022-05-27',9),(786,26,49,'2022-06-21',9),(787,27,50,'2022-08-10',5),(788,28,51,'2022-07-09',8),(789,29,52,'2022-08-08',7),(790,30,53,'2022-06-29',3),(791,31,54,'2022-08-01',2),(792,32,55,'2022-05-29',6),(793,33,56,'2022-08-05',3),(794,34,57,'2022-05-06',3),(795,35,42,'2022-06-15',11),(796,36,43,'2022-05-29',6),(797,37,44,'2022-06-12',10),(798,38,45,'2022-08-10',3),(799,39,46,'2022-05-07',3),(800,40,47,'2022-05-23',6),(801,41,48,'2022-05-22',1),(802,42,49,'2022-05-08',10),(803,43,50,'2022-05-25',9),(804,44,51,'2022-06-12',13),(805,45,52,'2022-07-26',5),(806,46,53,'2022-07-19',3),(807,47,54,'2022-07-18',3),(808,48,55,'2022-08-05',6),(809,49,56,'2022-08-05',2),(810,50,57,'2022-06-05',10),(811,1,86,'2022-07-09',8),(812,2,87,'2022-06-23',9),(813,3,88,'2022-05-03',3),(814,4,89,'2022-05-29',8),(815,5,90,'2022-08-09',9),(816,6,91,'2022-07-28',5),(817,7,92,'2022-05-22',12),(818,8,93,'2022-07-30',5),(819,9,94,'2022-05-14',7),(820,10,95,'2022-06-08',8),(821,11,96,'2022-05-27',9),(822,12,97,'2022-05-27',7),(823,13,98,'2022-08-06',4),(824,14,99,'2022-07-23',4),(825,15,100,'2022-05-31',8),(826,16,101,'2022-06-23',3),(827,17,102,'2022-07-01',9),(828,18,103,'2022-05-28',2),(829,19,104,'2022-05-14',7),(830,20,105,'2022-05-10',4),(831,21,106,'2022-06-16',3),(832,22,107,'2022-07-31',3),(833,23,108,'2022-07-22',8),(834,24,109,'2022-05-02',7),(835,25,110,'2022-05-12',3),(836,26,111,'2022-05-16',9),(837,27,112,'2022-06-24',3),(838,28,113,'2022-07-19',5),(839,29,114,'2022-06-11',8),(840,30,115,'2022-08-03',5),(841,31,116,'2022-05-29',2),(842,32,117,'2022-07-16',7),(843,33,118,'2022-06-10',4),(844,34,119,'2022-06-16',11),(845,35,120,'2022-05-27',7),(846,36,121,'2022-05-02',7),(847,37,122,'2022-07-14',6),(848,38,123,'2022-07-15',7),(849,39,124,'2022-07-09',10),(850,40,125,'2022-07-31',10),(851,41,126,'2022-07-19',3),(852,42,127,'2022-07-15',10),(853,43,128,'2022-07-12',1),(854,44,129,'2022-07-20',7),(855,45,130,'2022-07-12',3),(856,46,131,'2022-05-21',9),(857,47,132,'2022-06-12',14),(858,48,133,'2022-06-02',4),(859,49,134,'2022-06-18',7),(860,50,135,'2022-08-06',12),(861,1,136,'2022-05-22',10),(862,2,137,'2022-06-01',9),(863,1,138,'2022-07-24',12),(864,2,139,'2022-06-19',5),(865,1,140,'2022-07-07',7),(866,2,141,'2022-07-10',5),(867,1,142,'2022-05-30',9),(868,2,52,'2022-06-23',2),(869,1,53,'2022-07-19',3),(870,2,54,'2022-07-20',13),(871,1,55,'2022-06-30',9),(872,2,56,'2022-05-07',3),(873,1,57,'2022-08-10',7),(874,2,86,'2022-07-24',7),(875,3,87,'2022-07-20',2),(876,3,88,'2022-06-18',6),(877,3,89,'2022-06-11',1),(878,3,90,'2022-06-18',8),(879,3,91,'2022-07-08',12),(880,3,92,'2022-07-21',8),(881,3,93,'2022-07-30',4),(882,3,94,'2022-08-01',8),(883,3,95,'2022-06-15',6),(884,3,96,'2022-05-19',3),(885,3,97,'2022-07-06',4),(886,3,98,'2022-06-25',8),(887,3,54,'2022-06-19',4),(888,3,55,'2022-07-19',4),(889,3,56,'2022-07-24',7),(890,3,57,'2022-08-02',8),(891,3,86,'2022-06-06',10),(892,3,87,'2022-07-20',9),(893,3,88,'2022-06-15',9),(894,3,89,'2022-06-28',10),(895,3,90,'2022-05-15',5),(896,3,91,'2022-06-26',2),(897,3,92,'2022-05-19',4),(898,3,93,'2022-08-01',11),(899,3,94,'2022-06-23',5),(900,3,95,'2022-07-28',5),(901,3,96,'2022-05-27',6),(902,3,97,'2022-06-25',9),(903,3,98,'2022-07-17',8),(904,3,99,'2022-06-26',3),(905,47,100,'2022-07-13',5),(906,47,101,'2022-06-26',11),(907,47,102,'2022-07-16',7),(908,47,103,'2022-08-03',5),(909,47,104,'2022-07-23',11),(910,47,105,'2022-05-26',11),(911,47,106,'2022-07-04',3),(912,47,107,'2022-05-27',7),(913,47,108,'2022-07-19',3),(914,47,109,'2022-06-19',8),(915,47,110,'2022-08-07',8),(916,47,111,'2022-07-15',7),(917,47,112,'2022-07-31',7),(918,47,113,'2022-07-25',1),(919,32,114,'2022-07-18',4),(920,33,115,'2022-07-12',14),(921,34,116,'2022-07-18',3),(922,35,117,'2022-07-17',9),(923,36,118,'2022-05-10',3),(924,37,119,'2022-06-03',7),(925,38,120,'2022-07-12',12),(926,39,121,'2022-06-14',7),(927,40,122,'2022-07-07',10),(928,41,123,'2022-06-23',4),(929,42,124,'2022-05-29',6),(930,43,125,'2022-06-30',6),(931,44,126,'2022-07-24',7),(932,45,127,'2022-05-27',5),(933,46,128,'2022-06-05',9),(934,47,129,'2022-07-16',9),(935,48,130,'2022-05-06',3),(936,49,131,'2022-08-05',7),(937,50,132,'2022-07-15',12),(938,32,133,'2022-05-12',7),(939,33,134,'2022-08-06',10),(940,34,135,'2022-06-23',4),(941,35,136,'2022-05-18',6),(942,36,137,'2022-07-24',6),(943,37,138,'2022-06-15',7),(944,38,139,'2022-06-18',7),(945,39,140,'2022-07-23',9),(946,40,141,'2022-07-22',3),(947,41,142,'2022-05-17',7),(948,42,52,'2022-06-23',12),(949,43,53,'2022-06-17',7),(950,44,54,'2022-06-09',10),(951,45,55,'2022-06-03',4),(952,46,56,'2022-07-25',6),(953,47,57,'2022-05-20',6),(954,48,86,'2022-07-31',8),(955,49,87,'2022-08-03',12),(956,50,88,'2022-08-05',5),(957,32,89,'2022-08-02',10),(958,33,90,'2022-05-04',5),(959,34,91,'2022-06-03',9),(960,35,92,'2022-07-19',3),(961,36,93,'2022-06-21',7),(962,37,94,'2022-05-21',12),(963,38,95,'2022-07-12',7),(964,39,96,'2022-08-07',10),(965,40,97,'2022-06-12',4),(966,41,98,'2022-07-24',6),(967,42,54,'2022-07-06',6),(968,43,55,'2022-07-31',9),(969,44,56,'2022-08-06',6),(970,45,57,'2022-05-31',9),(971,46,86,'2022-05-29',5),(972,47,87,'2022-07-19',9),(973,48,88,'2022-06-04',9),(974,49,89,'2022-07-27',3),(975,50,90,'2022-07-30',7),(976,5,91,'2022-05-28',12),(977,6,92,'2022-07-25',7),(978,7,93,'2022-06-16',10),(979,8,94,'2022-07-13',4),(980,9,95,'2022-08-05',6),(981,10,96,'2022-07-14',6),(982,11,97,'2022-06-15',8),(983,12,98,'2022-05-20',3),(984,13,99,'2022-05-08',3),(985,14,100,'2022-05-28',2),(986,15,101,'2022-07-30',6),(987,16,102,'2022-06-17',8),(988,17,103,'2022-06-30',13),(989,18,104,'2022-08-06',5),(990,19,105,'2022-05-27',9),(991,20,106,'2022-06-23',3),(992,21,107,'2022-07-13',4),(993,22,108,'2022-07-13',12),(994,23,109,'2022-06-22',6),(995,24,110,'2022-05-15',6),(996,25,111,'2022-07-21',12),(997,26,112,'2022-07-01',12),(998,27,113,'2022-06-15',7),(999,28,114,'2022-08-05',5),(1000,29,115,'2022-08-10',6),(1001,29,115,'2022-08-10',6),(1002,29,115,'2022-08-10',6),(1003,29,55,'2022-08-10',6);
/*!40000 ALTER TABLE `recorridos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_before_descuento_recorrido` BEFORE INSERT ON `recorridos` FOR EACH ROW BEGIN  
   /* Bono para los clientes que tengan mas de 10 recorridos*/
     IF (new.id_cliente IN (SELECT id_cliente
							FROM tellevo.recorridos
							GROUP BY 1
							HAVING COUNT(distinct id_recorrido)  > 10))
     THEN 
       INSERT INTO descuento_recorrido (id_recorrido, id_cliente, descuento_porcentual) VALUES (NEW.id_recorrido, NEW.id_cliente, 15);
   END IF;  
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_registro_recorridos` AFTER INSERT ON `recorridos` FOR EACH ROW INSERT INTO registro_recorrido (id_recorrido, id_conductor, fechahora)
VALUES (NEW.id_recorrido, NEW.id_conductor, CURRENT_TIMESTAMP()) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping data for table `registro_conductores`
--

LOCK TABLES `registro_conductores` WRITE;
/*!40000 ALTER TABLE `registro_conductores` DISABLE KEYS */;
INSERT INTO `registro_conductores` VALUES (55,'ANTONIO','SANCHEZ','2022-09-09'),(56,'ANTONIO','SANCHEZ','2022-09-09');
/*!40000 ALTER TABLE `registro_conductores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `registro_recorrido`
--

LOCK TABLES `registro_recorrido` WRITE;
/*!40000 ALTER TABLE `registro_recorrido` DISABLE KEYS */;
INSERT INTO `registro_recorrido` VALUES (1001,29,'2022-09-09 12:17:14'),(1002,29,'2022-09-09 12:23:16'),(1003,29,'2022-09-09 12:25:13');
/*!40000 ALTER TABLE `registro_recorrido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `vehiculos`
--

LOCK TABLES `vehiculos` WRITE;
/*!40000 ALTER TABLE `vehiculos` DISABLE KEYS */;
INSERT INTO `vehiculos` VALUES (1,'Toyota','Corolla','Sedan','Negro'),(2,'Toyota','Land Cruiser','Camioneta','Blanco'),(3,'Toyota','Camry','Sedan','Azul'),(4,'Toyota','Yaris','Sedan','Rojo'),(5,'Ford','Fiesta','Sedan','Gris'),(6,'Ford','Explorer','Camioneta','Negro'),(7,'Honda','Accord','Sedan','Blanco'),(8,'Honda','Civic','Sedan','Negro'),(9,'Hyundai','Accent','Sedan','Blanco'),(10,'Hyundai','I10','Sedan','Negro'),(11,'Hyundai','Tucson','Camioneta','Blanco'),(12,'Kia','Picanto','Sedan','Negro'),(13,'Kia','Rio','Sedan','Blanco'),(14,'Mitsubishi','L200','Camioneta','Rojo'),(15,'Mitsubishi','Montero','Camioneta','Gris'),(16,'Toyota','Corolla','Sedan','Rojo'),(17,'Toyota','Land Cruiser','Camioneta','Gris'),(18,'Toyota','Camry','Sedan','Azul'),(19,'Toyota','Yaris','Sedan','Azul'),(20,'Ford','Fiesta','Sedan','Azul'),(21,'Toyota','Corolla','Sedan','Azul'),(22,'Toyota','Corolla','Sedan','Azul'),(23,'Toyota','Corolla','Sedan','Gris'),(24,'Toyota','Corolla','Sedan','Gris'),(25,'Toyota','Corolla','Sedan','Gris'),(26,'Kia','Picanto','Sedan','Gris'),(27,'Kia','Rio','Sedan','Gris'),(28,'Kia','Picanto','Sedan','Gris'),(29,'Kia','Rio','Sedan','Gris'),(30,'Kia','Picanto','Sedan','Negro'),(31,'Kia','Rio','Sedan','Negro'),(32,'Kia','Picanto','Sedan','Negro'),(33,'Kia','Rio','Sedan','Negro'),(34,'Honda','Accord','Sedan','Blanco'),(35,'Honda','Civic','Sedan','Blanco'),(36,'Honda','Accord','Sedan','Blanco'),(37,'Honda','Civic','Sedan','Blanco'),(38,'Mitsubishi','L200','Camioneta','Blanco'),(39,'Mitsubishi','Montero','Camioneta','Blanco'),(40,'Toyota','Corolla','Sedan','Rojo'),(41,'Toyota','Land Cruiser','Camioneta','Rojo'),(42,'Hyundai','Accent','Sedan','Rojo'),(43,'Hyundai','I10','Sedan','Blanco'),(44,'Hyundai','Accent','Sedan','Blanco'),(45,'Hyundai','I10','Sedan','Blanco'),(46,'Hyundai','Accent','Sedan','Blanco'),(47,'Hyundai','I10','Sedan','Blanco'),(48,'Honda','Civic','Sedan','Rojo'),(49,'Toyota','Land Cruiser','Camioneta','Negro'),(50,'Honda','Accord','Sedan','Negro');
/*!40000 ALTER TABLE `vehiculos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'tellevo'
--

--
-- Dumping routines for database 'tellevo'
--
/*!50003 DROP FUNCTION IF EXISTS `calculo_viajes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `calculo_viajes`(capacidad INT, pasajeros INT) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE resultado INT;
    SET resultado = pasajeros / capacidad;
RETURN resultado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `driver_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `total_km_recorrido_driver` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_delete_vehiculos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_delete_vehiculos`( IN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `lista_clientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-24 15:41:33



-- DUMP STRUCTURE ONLY

/*Tablas en el BACKUP*/
-- city_conductores_bonus
-- ciudades
-- clientes
-- conductores
-- descuento_recorrido
-- recorridos
-- registro_conductores
-- registro_recorrido


CREATE DATABASE  IF NOT EXISTS `tellevo` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `tellevo`;
-- MySQL dump 10.13  Distrib 8.0.27, for Win64 (x86_64)
--
-- Host: localhost    Database: tellevo
-- ------------------------------------------------------
-- Server version	8.0.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `city_conductores_bonus`
--

DROP TABLE IF EXISTS `city_conductores_bonus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `city_conductores_bonus` (
  `id_conductor` int NOT NULL AUTO_INCREMENT,
  `id_ciudad` int NOT NULL,
  `bono` int NOT NULL,
  PRIMARY KEY (`id_conductor`),
  UNIQUE KEY `id_conductor` (`id_conductor`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ciudades`
--

DROP TABLE IF EXISTS `ciudades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ciudades` (
  `id_ciudad` int NOT NULL AUTO_INCREMENT,
  `nombre_ciudad` varchar(50) NOT NULL,
  `costo_kilometraje` int NOT NULL,
  PRIMARY KEY (`id_ciudad`),
  UNIQUE KEY `id_ciudad` (`id_ciudad`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `sexo` varchar(30) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `id_cliente` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=259 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conductores`
--

DROP TABLE IF EXISTS `conductores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conductores` (
  `id_conductor` int NOT NULL AUTO_INCREMENT,
  `matricula` int NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `sexo` varchar(30) NOT NULL,
  `domicilio` varchar(100) DEFAULT NULL,
  `estado_contrato` varchar(30) NOT NULL,
  `id_ciudad` int NOT NULL,
  PRIMARY KEY (`id_conductor`),
  UNIQUE KEY `id_conductor` (`id_conductor`),
  KEY `matricula` (`matricula`),
  KEY `id_ciudad` (`id_ciudad`),
  CONSTRAINT `conductores_ibfk_1` FOREIGN KEY (`matricula`) REFERENCES `vehiculos` (`matricula`),
  CONSTRAINT `conductores_ibfk_2` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudades` (`id_ciudad`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_before_bonus_conductor` BEFORE INSERT ON `conductores` FOR EACH ROW BEGIN  
   /* Bonus for Sales Assistant */
     IF (new.id_ciudad = 5) 
     THEN 
       INSERT INTO city_conductores_bonus (id_conductor, id_ciudad, bono) VALUES (NEW.id_conductor, NEW.id_ciudad, 1000);
    ELSEIF
      (new.id_ciudad = 3)
     THEN 
        INSERT INTO city_conductores_bonus (id_conductor, id_ciudad, bono) VALUES (NEW.id_conductor, NEW.id_ciudad, 2000);
   END IF;  
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_registro_conductor` AFTER INSERT ON `conductores` FOR EACH ROW INSERT INTO registro_conductores (id_conductor, nombre, apellido, fecha_registro)
VALUES (NEW.id_conductor, NEW.nombre, NEW.apellido, current_date()) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `descuento_recorrido`
--

DROP TABLE IF EXISTS `descuento_recorrido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `descuento_recorrido` (
  `id_recorrido` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `descuento_porcentual` int NOT NULL,
  PRIMARY KEY (`id_recorrido`),
  UNIQUE KEY `id_recorrido` (`id_recorrido`)
) ENGINE=InnoDB AUTO_INCREMENT=1004 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recorridos`
--

DROP TABLE IF EXISTS `recorridos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recorridos` (
  `id_recorrido` int NOT NULL AUTO_INCREMENT,
  `id_conductor` int NOT NULL,
  `id_cliente` int NOT NULL,
  `fecha` date NOT NULL DEFAULT (curdate()),
  `kilometraje` int NOT NULL,
  PRIMARY KEY (`id_recorrido`),
  UNIQUE KEY `id_recorrido` (`id_recorrido`),
  KEY `id_conductor` (`id_conductor`),
  KEY `id_cliente` (`id_cliente`),
  CONSTRAINT `recorridos_ibfk_1` FOREIGN KEY (`id_conductor`) REFERENCES `conductores` (`id_conductor`),
  CONSTRAINT `recorridos_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=1004 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_before_descuento_recorrido` BEFORE INSERT ON `recorridos` FOR EACH ROW BEGIN  
   /* Bono para los clientes que tengan mas de 10 recorridos*/
     IF (new.id_cliente IN (SELECT id_cliente
							FROM tellevo.recorridos
							GROUP BY 1
							HAVING COUNT(distinct id_recorrido)  > 10))
     THEN 
       INSERT INTO descuento_recorrido (id_recorrido, id_cliente, descuento_porcentual) VALUES (NEW.id_recorrido, NEW.id_cliente, 15);
   END IF;  
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_registro_recorridos` AFTER INSERT ON `recorridos` FOR EACH ROW INSERT INTO registro_recorrido (id_recorrido, id_conductor, fechahora)
VALUES (NEW.id_recorrido, NEW.id_conductor, CURRENT_TIMESTAMP()) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `registro_conductores`
--

DROP TABLE IF EXISTS `registro_conductores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registro_conductores` (
  `id_conductor` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `fecha_registro` date DEFAULT NULL,
  PRIMARY KEY (`id_conductor`),
  UNIQUE KEY `id_conductor` (`id_conductor`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registro_recorrido`
--

DROP TABLE IF EXISTS `registro_recorrido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registro_recorrido` (
  `id_recorrido` int NOT NULL AUTO_INCREMENT,
  `id_conductor` int NOT NULL,
  `fechahora` datetime DEFAULT NULL,
  PRIMARY KEY (`id_recorrido`),
  UNIQUE KEY `id_recorrido` (`id_recorrido`)
) ENGINE=InnoDB AUTO_INCREMENT=1004 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehiculos`
--

DROP TABLE IF EXISTS `vehiculos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehiculos` (
  `matricula` int NOT NULL AUTO_INCREMENT,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `tipo` varchar(50) DEFAULT NULL,
  `color` varchar(50) NOT NULL,
  PRIMARY KEY (`matricula`),
  UNIQUE KEY `matricula` (`matricula`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'tellevo'
--

--
-- Dumping routines for database 'tellevo'
--
/*!50003 DROP FUNCTION IF EXISTS `calculo_viajes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `calculo_viajes`(capacidad INT, pasajeros INT) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE resultado INT;
    SET resultado = pasajeros / capacidad;
RETURN resultado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `driver_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `total_km_recorrido_driver` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_delete_vehiculos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_delete_vehiculos`( IN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `lista_clientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-09-24 15:40:50









