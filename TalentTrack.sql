-- ============================================================
-- TALENTTRACK | SOLUCIONARIO DQL
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: talenttrack
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE talenttrack;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    c.id AS codigo_curso,
    c.name AS curso,
    c.duration_hours AS horas
FROM courses AS c;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre y duración en horas de todos los cursos.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_curso,
    name AS curso,
    duration_hours AS horas
FROM courses
ORDER BY id;


-- ------------------------------------------------------------
-- 02. Listar ediciones en estado ABIERTA o EN_CURSO cuya fecha de inicio sea desde septiembre de 2026.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_edicion,
    code AS edicion,
    start_date AS fecha_inicio,
    status AS estado
FROM editions
WHERE (status = 'ABIERTA' OR status = 'EN_CURSO')
    AND start_date >= '2026-09-01'
ORDER BY start_date, id;


-- ------------------------------------------------------------
-- 03. Mostrar colaboradores ACTIVO de empresas cuyo nombre contenga SAS. Usar JOIN y LIKE.
-- Resultado de referencia: 6 fila(s), con los datos actuales sin modificar.
SELECT
    co.id AS codigo_colaborador,
    co.name AS colaborador,
    c.company_name AS empresa,
    co.status AS estado
FROM collaborators AS co
JOIN companies AS c ON co.company_id = c.id
WHERE co.status = 'ACTIVO' AND c.company_name LIKE '%SAS%'
ORDER BY co.id;


-- ------------------------------------------------------------
-- 04. Mostrar las tres ediciones con fecha de inicio más reciente. Usar LIMIT.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_edicion,
    code AS edicion,
    start_date AS fecha_inicio
FROM editions
ORDER BY start_date DESC, id
LIMIT 3;


-- ------------------------------------------------------------
-- 05. Buscar cursos cuyo nombre incluya IA o datos. Usar LIKE y OR.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_curso,
    name AS curso
FROM courses
WHERE name LIKE '%IA%' OR name LIKE '%datos%'
ORDER BY id;


-- ------------------------------------------------------------
-- 06. Mostrar cada edición junto con el nombre del curso y el instructor que la imparte.
-- Resultado de referencia: 5 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_edicion,
    e.code AS edicion,
    c.name AS curso,
    i.name AS instructor
FROM editions AS e
JOIN courses AS c ON e.course_id = c.id
JOIN instructors AS i ON e.instructor_id = i.id
ORDER BY e.id;


-- ------------------------------------------------------------
-- 07. Relacionar cada matrícula con colaborador, empresa y edición.
-- Resultado de referencia: 8 fila(s), con los datos actuales sin modificar.
SELECT
    en.id AS codigo_matricula,
    co.name AS colaborador,
    c.company_name AS empresa,
    e.code AS edicion
FROM enrollments AS en
JOIN collaborators AS co ON en.collaborator_id = co.id
JOIN companies AS c ON co.company_id = c.id
JOIN editions AS e ON en.edition_id = e.id
ORDER BY en.id;


-- ------------------------------------------------------------
-- 08. Contar los matriculados por edición, incluyendo ediciones sin inscritos. Usar LEFT JOIN.
-- Resultado de referencia: 5 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_edicion,
    e.code AS edicion,
    COUNT(en.id) AS total_matriculados
FROM editions AS e
LEFT JOIN enrollments AS en ON e.id = en.edition_id
GROUP BY e.id, e.code
ORDER BY e.id;


-- ------------------------------------------------------------
-- 09. Contar matrículas agrupadas por su estado.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    status AS estado,
    COUNT(*) AS total_matriculas
FROM enrollments
GROUP BY status
ORDER BY total_matriculas DESC, status;


-- ------------------------------------------------------------
-- 10. Encontrar los cursos que se han ofrecido en dos o más ediciones. Usar HAVING.
-- Resultado de referencia: 1 fila(s), con los datos actuales sin modificar.
SELECT
    c.id AS codigo_curso,
    c.name AS curso,
    COUNT(e.id) AS total_ediciones
FROM courses AS c
JOIN editions AS e ON c.id = e.course_id
GROUP BY c.id, c.name
HAVING COUNT(e.id) >= 2
ORDER BY total_ediciones DESC, c.id;


-- ------------------------------------------------------------
-- 11. Contar las sesiones programadas en cada edición.
-- Resultado de referencia: 5 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_edicion,
    e.code AS edicion,
    COUNT(s.id) AS total_sesiones
FROM editions AS e
LEFT JOIN sessions AS s ON e.id = s.edition_id
GROUP BY e.id, e.code
ORDER BY e.id;


-- ------------------------------------------------------------
-- 12. Mostrar los certificados emitidos junto al nombre del colaborador y el curso.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    ce.code AS codigo_certificado,
    co.name AS colaborador,
    c.name AS curso,
    ce.issued_at AS fecha_emision
FROM certificates AS ce
JOIN enrollments AS en ON ce.enrollment_id = en.id
JOIN collaborators AS co ON en.collaborator_id = co.id
JOIN editions AS e ON en.edition_id = e.id
JOIN courses AS c ON e.course_id = c.id
ORDER BY ce.id;


-- ------------------------------------------------------------
-- 13. Mostrar las sesiones realizadas durante septiembre de 2026, junto a su edición.
-- Resultado de referencia: 6 fila(s), con los datos actuales sin modificar.
SELECT
    s.id AS codigo_sesion,
    s.topic AS tema,
    e.code AS edicion,
    s.started_at AS fecha_inicio,
    s.ended_at AS fecha_fin
FROM sessions AS s
JOIN editions AS e ON s.edition_id = e.id
WHERE s.started_at >= '2026-09-01 00:00:00'
    AND s.started_at < '2026-10-01 00:00:00'
ORDER BY s.started_at, s.id;


-- ------------------------------------------------------------
-- 14. Mostrar todas las asistencias registradas con el colaborador, tema de la sesión y estado.
-- Resultado de referencia: 10 fila(s), con los datos actuales sin modificar.
SELECT
    a.id AS codigo_asistencia,
    co.name AS colaborador,
    s.topic AS tema,
    a.status AS estado
FROM attendance AS a
JOIN enrollments AS en ON a.enrollment_id = en.id
JOIN collaborators AS co ON en.collaborator_id = co.id
JOIN sessions AS s ON a.session_id = s.id
ORDER BY a.id;


-- ------------------------------------------------------------
-- 15. Contar cuántas asistencias PRESENTE registra cada matrícula con registros de asistencia.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    en.id AS codigo_matricula,
    co.name AS colaborador,
    SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS total_presentes
FROM enrollments AS en
JOIN collaborators AS co ON en.collaborator_id = co.id
JOIN attendance AS a ON en.id = a.enrollment_id
GROUP BY en.id, co.id, co.name
ORDER BY en.id;


-- ------------------------------------------------------------
-- 16. Mostrar ediciones con al menos dos matriculados e indicar su capacidad. Usar HAVING.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_edicion,
    e.code AS edicion,
    e.capacity AS capacidad,
    COUNT(en.id) AS total_matriculados
FROM editions AS e
JOIN enrollments AS en ON e.id = en.edition_id
GROUP BY e.id, e.code, e.capacity
HAVING COUNT(en.id) >= 2
ORDER BY e.id;


-- ------------------------------------------------------------
-- 17. Mostrar matrículas cuya asistencia registrada tenga al menos 80% PRESENTE. Usar GROUP BY y HAVING.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    en.id AS codigo_matricula,
    co.name AS colaborador,
    COUNT(a.id) AS registros_asistencia,
    SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS total_presentes,
    ROUND(100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END)
        / COUNT(a.id), 2) AS porcentaje_presente
FROM enrollments AS en
JOIN collaborators AS co ON en.collaborator_id = co.id
JOIN attendance AS a ON en.id = a.enrollment_id
GROUP BY en.id, co.id, co.name
HAVING 100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END)
    / COUNT(a.id) >= 80
ORDER BY en.id;


-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar colaboradores que todavía no se han matriculado en ninguna edición. Usar NOT EXISTS.
-- Resultado de referencia: 1 fila(s), con los datos actuales sin modificar.
SELECT
    co.id AS codigo_colaborador,
    co.name AS colaborador
FROM collaborators AS co
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments AS en
    WHERE en.collaborator_id = co.id
)
ORDER BY co.id;


-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar ediciones cuya capacidad sea mayor al promedio de capacidades de las ediciones.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_edicion,
    code AS edicion,
    capacity AS capacidad
FROM editions
WHERE capacity > (SELECT AVG(capacity) FROM editions)
ORDER BY id;


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: mostrar colaboradores que estén matriculados en alguna edición del curso con código CUR-IA. Usar IN.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    co.id AS codigo_colaborador,
    co.name AS colaborador
FROM collaborators AS co
WHERE co.id IN (
    SELECT en.collaborator_id
    FROM enrollments AS en
    JOIN editions AS e ON en.edition_id = e.id
    JOIN courses AS c ON e.course_id = c.id
    WHERE c.code = 'CUR-IA'
)
ORDER BY co.id;
