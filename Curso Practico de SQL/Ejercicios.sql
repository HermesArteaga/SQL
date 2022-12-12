-- 1 --
--Traer las primeras 5 filas
select *
from platzi.alumnos as st
-- fetch first 5 rows only --hace lo mismo que limit, fetch significa traeme
limit 5;
--------------------------------------------------------
-- 2 --
--agrega otra columna con el numero de indice y trae la primera fila
select *
from (
	select row_number() over() as row_id, *
	from platzi.alumnos
) as alumnos_with_row_num
where row_id = 1;
--------------------------------------------------------
-- El segundo mas alto --
select DISTINCT(colegiatura)
from platzi.alumnos
order by colegiatura desc
offset 1
limit 1;

-- otra forma de hacer el ejercicio de arriba, con subquery --
select DISTINCT colegiatura
from platzi.alumnos as a1
where 2 = (
	select count (DISTINCT colegiatura)
	from platzi.alumnos as a2
	where a1.colegiatura <= a2.colegiatura
);
--------------------------------------------------------------------------------
-- trae todos los datos de los alumnos que tengan la segunda mayor colegiatura--
select *
from platzi.alumnos as datos_alumnos
inner join (
	select distinct colegiatura
	from platzi.alumnos
	order by colegiatura desc
	offset 1
	limit 1
)as segunda_mayor_colegiatura
on datos_alumnos.colegiatura = segunda_mayor_colegiatura.colegiatura;

--lo mismo que el ejercicio de arriba--
select *
from platzi.alumnos as datos_alumnos
where colegiatura = (
	select distinct colegiatura
	from platzi.alumnos
	order by colegiatura desc
	offset 1
	limit 1
);

--lo mismo que el de arriba pero conociendo el valor exacto de la segunda colegiatura mas alta--
select * 
from platzi.alumnos
where colegiatura = 4800;
-------------------------------------------------------------------------------
--traer segunda mitad de la tabla--
select *
from platzi.alumnos
offset (
	select (count(id)/2)
	from platzi.alumnos
)
--otra forma--
select *
from platzi.alumnos
where id >(
	select count(id)/2
	from platzi.alumnos
)
-------------------------------------------------------------------------------
--seleccionar de un set de opciones--
select *
from platzi.alumnos
where tutor_id = 30;

--otra forma con subquery, se usa subquery porque podemos meter mas instrucciones que necesitemos--
select *
from platzi.alumnos
where id IN (
	select id
	from platzi.alumnos
	where tutor_id = 30
);

--alumnos que no se encuentren en el subquery--
select *
from platzi.alumnos
where id not IN (
	select id
	from platzi.alumnos
	where tutor_id = 30
);
-------------------------------------------------------------------------------
--Uso de los campos de fecha y hora, extraer datos--
select EXTRACT (year from fecha_incorporacion) as anio_incorporacion
from platzi.alumnos;

--otra forma--
select DATE_PART('year', fecha_incorporacion) as anio_incorporacion
from platzi.alumnos;

--mas datos de fecha--
select fecha_incorporacion, DATE_PART('year', fecha_incorporacion) as anio_incorporacion,
	DATE_PART('month', fecha_incorporacion) as mes_incorporacion,
	DATE_PART('day', fecha_incorporacion) as dia_incorporacion
from platzi.alumnos;

--extraer hora--
select extract (hour from fecha_incorporacion) as hora
from platzi.alumnos;

--otra forma--
select fecha_incorporacion, DATE_PART('hour', fecha_incorporacion) as hora,
	DATE_PART('minute', fecha_incorporacion) as minutos,
	DATE_PART('second', fecha_incorporacion) as segundos
from platzi.alumnos;
--------------------------------------------------------------------------------------
--Uso de las fechas como filtros--
select *
from platzi.alumnos
where (extract (year from fecha_incorporacion) = 2018);

--otra forma--
select *
from platzi.alumnos
where (date_part ('year', fecha_incorporacion) = 2019);

--otra forma, con subquery, por si queremos agregar mas campos--
select *
from (
	select *, date_part('year', fecha_incorporacion) as anio_incorporacion
	from platzi.alumnos
)as alumnos_con_anio
where anio_incorporacion = 2020

--Reto -> alumnos que se incorporacion en mayo del 2018--
select *
from platzi.alumnos
where (date_part ('year', fecha_incorporacion)) = 2018 and (date_part ('month', fecha_incorporacion)) = 5

--otra forma--
SELECT *
FROM platzi.alumnos
WHERE fecha_incorporacion::text like '2018-05%'; --fecha_incorpracion se cambia a text
--------------------------------------------------------------------------------------
--Eliminar duplicados, como la tabla no tiene duplicados agregamos uno para hacer la dinamica--
insert into platzi.alumnos (id, nombre, apellido, email, colegiatura, fecha_incorporacion, carrera_id, tutor_id) 
values (1001, 'Pamelina', null, 'pmylchreestrr@salon.com', 4800, '2020-04-26 10:18:51', 12, 16);

--buscamos los duplicados--
--Comparamos id y si se repite nos muestra que datos, en este caso no muestra ninguno ya que no hay id repetidos--
select *
from platzi.alumnos as ou
where (
	select count(*)
	from platzi.alumnos as inr
	where ou.id = inr.id
) > 1;

--otra forma--
/*aqui convertimos todo a texto y lo agrupamos buscando que campos se repiten, nuevamente no nos sale nada ya que al tener la
columna id que es diferente para todos los datos, pero no se encuentran duplicados, esto no quiere decir que no los haya*/
select (platzi.alumnos.*)::text, count(*) --transforma a text
from platzi.alumnos
group by platzi.alumnos.* --agrupar por la combinacion de todos los campos
having count(*) > 1

--otra forma--
/*para solucionar lo anterior debemos seleccionar un campo a la vez, sin inlcuir la columna id, ahora si podemos ver que
hay un campo que se repite*/
select (
		platzi.alumnos.nombre,
	    platzi.alumnos.apellido,
	    platzi.alumnos.email,
		platzi.alumnos.colegiatura,
		platzi.alumnos.fecha_incorporacion,
		platzi.alumnos.carrera_id,
	    platzi.alumnos.tutor_id)::text, count(*) --transforma a text
from platzi.alumnos
group by platzi.alumnos.nombre,
	    platzi.alumnos.apellido,
	    platzi.alumnos.email,
		platzi.alumnos.colegiatura,
		platzi.alumnos.fecha_incorporacion,
		platzi.alumnos.carrera_id,
	    platzi.alumnos.tutor_id
having count(*) > 1

--otra forma, con subquery--
select *
from (
	select *, id, 
		   row_number() over( partition by nombre,apellido,email,colegiatura,fecha_incorporacion,carrera_id,tutor_id
							  order by id asc
							)as row
	from platzi.alumnos
)as duplicados
where duplicados.row > 1;
/*En el ejercicio de encontrar un DUPLICADO, se está haciendo una partición de la tabla de todos los valores en filas de cada
una de las variables o columnas de la tabla a excepción del id, el cual no puede ser igual y no se repite al ser una primary key.
Cuando se aplica esta partición en cada valor se hace único los valores, es decir, cada row viene siendo una partición, y 
al utilizar la función agregada que en este caso es ROW_NUMBER() va a contar los valores de cada una de las particiones haciendo
que se reinicie los “números de fila” cuando salta de partición en partición. por eso, cuando encuentra dos valores iguales, 
enumera los dos valores, dejando como valor en su row un 2.*/

--Borrado de duplicados--
delete from platzi.alumnos
where id IN (
select id
from (
	select id, 
		   row_number() over( partition by nombre,apellido,email,colegiatura,fecha_incorporacion,carrera_id,tutor_id
							  order by id asc
							)as row
	from platzi.alumnos
)as duplicados
where duplicados.row > 1);
--------------------------------------------------------------------------------------
--Selectores de rango--
select *
from platzi.alumnos
where tutor_id in (1,2,3,4)

--otra forma--
select * 
from platzi.alumnos
where tutor_id between 1 and 10

--generar rangos--
select int4range(1,10) @>3 --evalua si en el rango creado hay valores mayores a tres, responde con un true o false

--coincidencias entre rangos--
select numrange(11.1, 19.9) && numrange(20.0, 30.0) --evalua coincidencia entre los rangos, responde con un true o flase

--seleccionar el mayor y menor de un rango--
select upper(int8range(15,26)) --mayor
select lower(int8range(10,22)) --menor

--interseccion entre rangos--
select int4range(10,20) * int4range(15,25) --retorna los limites superior e inferior de los valores que tienen en comun

--saber si un rango esta vacio--
select isempty (numrange(1,5)) --retorna true si esta vacio, de lo contrario false

--uso practico--
select *
from platzi.alumnos
where int4range(10,20) @> tutor_id --si tutor_id se encuentra en el rango de 10 a 20 lo muestre

--Reto -> interseccion entre los id de tutores y de carreras--

--Saca el rango en el que se intersectan--
SELECT INT4RANGE(MIN(tutor_id), MAX(tutor_id)) * INT4RANGE(MIN(carrera_id), MAX(carrera_id))
FROM platzi.alumnos

--Muestra los datos que se encuentran en la interseccion--
select *
from platzi.alumnos
where (
	SELECT INT4RANGE(MIN(tutor_id), MAX(tutor_id)) * INT4RANGE(MIN(carrera_id), MAX(carrera_id))
	FROM platzi.alumnos
) @> tutor_id and 
	(SELECT INT4RANGE(MIN(tutor_id), MAX(tutor_id)) * INT4RANGE(MIN(carrera_id), MAX(carrera_id))
	FROM platzi.alumnos) @> carrera_id

--Muestra los datos que tienen igual id en tutor y carrera--
SELECT *
FROM platzi.alumnos
WHERE tutor_id = carrera_id;
--------------------------------------------------------------------------------------
--Maximos en una tabla--
select fecha_incorporacion
from platzi.alumnos
order by fecha_incorporacion desc
limit 1

--Fecha de incorporacion mas reciente pero por carrera_id--
select carrera_id, MAX(fecha_incorporacion) --MAX es como limit pero para usar en grupos
from platzi.alumnos
group by carrera_id
order by carrera_id

--Reto -> Minimo nombre alfabeticamente de toda la tabla y el minimo por id de tutor
select nombre
from platzi.alumnos
order by nombre 
limit 1

--Minimo por tutor_id
select tutor_id, MIN(nombre)
from platzi.alumnos
group by tutor_id
order by tutor_id

--Trae el minimo nombre alfabeticamente por tutor_id pero con todos los datos
select nombre, apellido, a1.tutor_id, minnombre
from platzi.alumnos as a1
inner join(
	select tutor_id, MIN(nombre) as minnombre
	from platzi.alumnos
	group by tutor_id
)as consulta
on a1.tutor_id = consulta.tutor_id
where a1.nombre = consulta.minnombre
order by a1.tutor_id
--------------------------------------------------------------------------------------
--Self joins -> esto es hacer un join con la propia tabla--
--Se usa el id del tutor y se le da el nombre
select concat(a.nombre, ' ', a.apellido) as alumno,
	   concat(t.nombre, ' ', t.apellido) as tutor
from platzi.alumnos as a
inner join platzi.alumnos as t on a.tutor_id = t.id

--Numero de alumnos por tutor--
select concat(t.nombre, ' ', t.apellido) as tutor,
		count(*) as alumnos_por_tutor
from platzi.alumnos as a
	inner join platzi.alumnos as t on a.tutor_id = t.id
group by tutor
order by alumnos_por_tutor desc
limit 10

--Reto -> promedio de alumnos--
select avg(alumnos_por_tutor) as promedio_alumnos_por_tutor
from(
	select count(*) as alumnos_por_tutor
	from platzi.alumnos
	group by tutor_id
) as promedio
--------------------------------------------------------------------------------------
--Diferencias -> datos que se encuentran en una sola tabla--
select carrera_id, count(*) as cuenta
from platzi.alumnos
group by carrera_id
order by cuenta desc

--Como la tabla de carrera tiene todos los elementos, debemos borrar unos para asi ver la diferencia--
-- delete from platzi.carreras
-- where id between 30 and 40

--Left Join exclusive - entre las tablas alumnos y carreras--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
left join platzi.carreras as c
	on a.carrera_id = c.id
where c.id is null --trae los datos nulos en id de carrera
order by carrera_id desc

--Reto -> todos los datos que haya en la tablas esten o no en la otra--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
full outer join platzi.carreras as c
	on a.carrera_id = c.id
order by a.carrera_id
--------------------------------------------------------------------------------------
--Todas las uniones - todos los join--	
--LEFT JOIN exclusivo ya que solo trae los datos null--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
left join platzi.carreras as c
	on a.carrera_id = c.id
where c.id is null

--LEFT JOIN normal o inclusivo--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
left join platzi.carreras as c
	on a.carrera_id = c.id	

--RIGHT JOIN exclusivo--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
right join platzi.carreras as c
	on a.carrera_id = c.id
where a.carrera_id is null
order by c.id desc

--RIGHT JOIN--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
right join platzi.carreras as c
	on a.carrera_id = c.id
order by c.id desc

--INNER JOIN - join mas comun y por default--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
inner join platzi.carreras as c
	on a.carrera_id = c.id
order by c.id desc

--Diferencia simetrica - se encuentra en alumnos o se encuentra en carreras pero no en ambas--
select a.nombre, a.apellido, a.carrera_id, c.id, c.carrera
from platzi.alumnos as a
full outer join platzi.carreras as c
	on a.carrera_id = c.id
where a.id is null or c.id is null
order by a.carrera_id desc, c.id desc

--------------------------------------------------------------------------------------
--lpad y rpad -> rellenar a la izquierda, rellenar a la derecha--
select lpad ('sql', 15, '*')

--Rellenar usando el id--
select lpad('sql', id, '*')
from platzi.alumnos
where id < 10

--Generando triangulo
select lpad('*', id, '*')
from platzi.alumnos
where id < 10

--   --
select lpad('*', CAST(row_id as int), '*')
from (
	select row_number() over(order by carrera_id) as row_id, *
	from platzi.alumnos
)as alumnos_with_row_id
where row_id <= 5
order by carrera_id

-- TOKENIZANDO --
SELECT rpad(SUBSTR(nombre, 1, 2),LENGTH(nombre),'*'), nombre,
       rpad(SUBSTR(apellido, 1, 2),LENGTH(apellido),'*'), apellido,
	   rpad(SUBSTR(email, 1, 2),LENGTH(email),'*'), email
FROM platzi.alumnos

--------------------------------------------------------------------------------------
--Generando series--
select *
--from generate_series(1, 5)
--from generate_series(5, 1, -1)
from generate_series(1, 5, 2)

--Generando serie de fechas--
select current_date + s.a as dates --current_date es la fecha actual
from generate_series (0, 14, 7) as s(a) /*se le da un nombre a la tabla y a la columna que se genera con generate_series
en este caso s es la tabla y a la columna */

--Generando serie de horas--
select *
from generate_series('2022-12-10 00:00:00'::timestamp, '2022-12-14 00:00:00', '10 hours') /*los dos puntos :: se usan para
cambiar el tipo de dato es lo mismo que usar CAST*/

--Uniendo tablas con series generadas - solo se puede usar en postgreSQl--
select a.id, a.nombre, a.carrera_id, s.a
from platzi.alumnos as a
inner join generate_series(0, 10) as s(a)
on s.a = a.carrera_id
order by a.carrera_id

--Reto -> triangulo generado con series--
select lpad('*', generate_series(1,10), '*')

--otra forma--
select lpad('*', CAST(ordinality as int), '*')
from generate_series(10, 2, -2) WITH ordinality

--------------------------------------------------------------------------------------
--Regularizando expresiones - Expresiones Regulares --
select email
from platzi.alumnos
where email ~*'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' -- ~* esto se usa al inicio de una expresion regular

--Escoger solo las que tengan como dominio google--
select email
from platzi.alumnos
where email ~*'[A-Z0-9._%+-]+@google[A-Z0-9.-]+\.[A-Z]{2,4}' 

--------------------------------------------------------------------------------------
--Window functions--
--Promedio toda la tabla
select *, avg(colegiatura) over()
from platzi.alumnos

--Promedio por carrera
select *, avg(colegiatura) over(partition by carrera_id)
from platzi.alumnos

--Suma colegiatura por carrera
select *, SUM(colegiatura) OVER(partition by carrera_id order by colegiatura)
from platzi.alumnos

--Ranking - que lugar ocupa algo en la tabla
select *, RANK() OVER(partition by carrera_id order by colegiatura desc)
from platzi.alumnos

--ordenado por carrera_id
select *, RANK() OVER(partition by carrera_id order by colegiatura desc) as brand_rank
from platzi.alumnos
order by carrera_id, brand_rank

--Agregando una condicion con where
select *
from (
	select *,
	RANK() OVER(partition by carrera_id order by colegiatura desc) as brand_rank /*las window function corren al final
de todo por eso debemos meterla en un subquery si queremos usar un where para filtrarla */
	from platzi.alumnos
) as ranked_colegiaturas_por_carrera
where brand_rank < 3
order by carrera_id, brand_rank

--Ordenar por fecha
SELECT *, ROW_NUMBER() OVER(ORDER BY fecha_incorporacion desc) 
FROM platzi.alumnos;

--------------------------------------------------------------------------------------
--Particiones y Agregacion - Window Function--
SELECT *, ROW_NUMBER() OVER(ORDER BY fecha_incorporacion desc) as row_id
FROM platzi.alumnos;

--FIRST_VALUE--
SELECT *, FIRST_VALUE(colegiatura) OVER() as row_id
FROM platzi.alumnos;

--Agregando una particion en OVER()--
SELECT *, FIRST_VALUE(colegiatura) OVER(PARTITION BY carrera_id) as primera_colegiatura
FROM platzi.alumnos;

--LAST_VALUE--
SELECT *, LAST_VALUE(colegiatura) OVER(PARTITION BY carrera_id) as ultima_colegiatura
FROM platzi.alumnos;

--Enecimo valor - NTH_VALUE
SELECT *, NTH_VALUE(colegiatura, 3) OVER(PARTITION BY carrera_id) as ultima_colegiatura /*toma el valor en la tercera
posicion particionado por carrera_id */
FROM platzi.alumnos;

--Funcion RANK() - deja gaps por eso pasa del 1 al 5 -- 
SELECT *, 
	RANK() OVER(PARTITION BY carrera_id order by colegiatura desc) as colegiatura_rank 
FROM platzi.alumnos
order by carrera_id, colegiatura_rank;

--Funcion DENSE_RANK() - no deja gaps -- 
SELECT *, 
	DENSE_RANK() OVER(PARTITION BY carrera_id order by colegiatura desc) as colegiatura_rank 
FROM platzi.alumnos
order by carrera_id, colegiatura_rank;

--Funcion PERCENT_RANK() - rango pero con porcentajes -- 
SELECT *, 
	PERCENT_RANK() OVER(PARTITION BY carrera_id order by colegiatura desc) as colegiatura_rank 
FROM platzi.alumnos
order by carrera_id, colegiatura_rank;
