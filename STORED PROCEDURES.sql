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



