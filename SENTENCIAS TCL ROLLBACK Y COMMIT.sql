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
