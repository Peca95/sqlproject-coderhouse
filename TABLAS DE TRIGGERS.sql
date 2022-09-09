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