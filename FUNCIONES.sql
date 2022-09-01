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
