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