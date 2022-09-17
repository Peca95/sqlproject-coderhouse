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

