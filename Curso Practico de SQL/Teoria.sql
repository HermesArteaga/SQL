-- SELECT id, nombre, apellido, colegiatura,
-- case
-- when colegiatura > 3000 then 'caro'
-- when colegiatura <= 3000 then 'barato'
-- end as costo
-- 	FROM platzi.alumnos;
--------------------------------------------------------------
-- SELECT st.id, nombre, apellido, carrera_id, carrera
-- FROM platzi.alumnos as st
-- join platzi.carreras as ca on st.carrera_id = ca.id;
--------------------------------------------------------------
-- SELECT st.id, nombre, apellido, carrera_id, carrera
-- FROM platzi.alumnos as st
-- inner join platzi.carreras as ca on st.carrera_id = ca.id;
-------------------------------------------------------------
-- SELECT st.id, nombre, apellido, colegiatura
-- FROM platzi.alumnos as st
-- where colegiatura = 5000 or colegiatura = 2000
-- where colegiatura > 3000
-- where colegiatura between 2000 and 3000;
------------------------------------------------------------
-- SELECT st.id, nombre, apellido, colegiatura
-- FROM platzi.alumnos as st
-- -- where nombre like 'B%'
-- -- where nombre like 'B_ayne'
-- -- where nombre not like 'B%'
-- where nombre in ('Dew','Rasia','Pepito')
------------------------------------------------------------
-- Ordenamiento --
-- SELECT st.id, nombre, apellido, colegiatura
-- FROM platzi.alumnos as st
-- -- order by colegiatura desc
-- order by nombre
------------------------------------------------------------
-- Agrupar y limitar--
SELECT  count(id) as numero, colegiatura
FROM platzi.alumnos as st
group by colegiatura
order by colegiatura
-- offset 1
limit 5
------------------------------------------------------------