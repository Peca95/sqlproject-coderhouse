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



