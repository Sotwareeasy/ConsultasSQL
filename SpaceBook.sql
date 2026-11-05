-- ============================================================
-- SPACEBOOK | SOLUCIONARIO DQL
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: spacebook
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE spacebook;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    r.id AS codigo_sala,
    r.name AS sala,
    r.capacity AS capacidad
FROM rooms AS r;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre, capacidad y estado de todas las salas.
-- Resultado de referencia: 6 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_sala,
    name AS sala,
    capacity AS capacidad,
    status AS estado
FROM rooms
ORDER BY id;


-- ------------------------------------------------------------
-- 02. Buscar salas ACTIVAS con capacidad entre 6 y 12 personas.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_sala,
    name AS sala,
    capacity AS capacidad,
    status AS estado
FROM rooms
WHERE status = 'ACTIVA' AND capacity BETWEEN 6 AND 12
ORDER BY id;


-- ------------------------------------------------------------
-- 03. Mostrar los recursos DISPONIBLES de tipo PROYECTOR o AUDIO. Usar IN.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_recurso,
    name AS recurso,
    type AS tipo,
    status AS estado
FROM resources
WHERE status = 'DISPONIBLE' AND type IN ('PROYECTOR', 'AUDIO')
ORDER BY id;


-- ------------------------------------------------------------
-- 04. Mostrar las tres reservas que comienzan primero según la fecha y hora de inicio.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_reserva,
    reason AS motivo,
    started_at AS fecha_inicio,
    ended_at AS fecha_fin
FROM reservations
ORDER BY started_at, id
LIMIT 3;


-- ------------------------------------------------------------
-- 05. Buscar salas cuyo nombre contenga Sur o Ágora. Usar LIKE y OR.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_sala,
    name AS sala
FROM rooms
WHERE name LIKE '%Sur%' OR name LIKE '%Ágora%'
ORDER BY id;


-- ------------------------------------------------------------
-- 06. Mostrar cada sala con su sede y ciudad.
-- Resultado de referencia: 6 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_sala,
    r.name AS sala,
    s.name AS sede,
    s.city AS ciudad
FROM rooms AS r
JOIN sites AS s ON r.site_id = s.id
ORDER BY r.id;


-- ------------------------------------------------------------
-- 07. Mostrar cada reserva con el nombre de la sala y del organizador.
-- Resultado de referencia: 8 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_reserva,
    ro.name AS sala,
    e.name AS organizador
FROM reservations AS r
JOIN rooms AS ro ON r.room_id = ro.id
JOIN employees AS e ON r.organizer_id = e.id
ORDER BY r.id;


-- ------------------------------------------------------------
-- 08. Contar reservas por sala, incluyendo salas sin ninguna reserva. Usar LEFT JOIN.
-- Resultado de referencia: 6 fila(s), con los datos actuales sin modificar.
SELECT
    ro.id AS codigo_sala,
    ro.name AS sala,
    COUNT(r.id) AS total_reservas
FROM rooms AS ro
LEFT JOIN reservations AS r ON ro.id = r.room_id
GROUP BY ro.id, ro.name
ORDER BY total_reservas DESC, ro.id;


-- ------------------------------------------------------------
-- 09. Contar las reservas por estado.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    status AS estado,
    COUNT(*) AS total_reservas
FROM reservations
GROUP BY status
ORDER BY total_reservas DESC, status;


-- ------------------------------------------------------------
-- 10. Encontrar salas que tengan al menos dos reservas registradas. Usar HAVING.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    ro.id AS codigo_sala,
    ro.name AS sala,
    COUNT(r.id) AS total_reservas
FROM rooms AS ro
JOIN reservations AS r ON ro.id = r.room_id
GROUP BY ro.id, ro.name
HAVING COUNT(r.id) >= 2
ORDER BY total_reservas DESC, ro.id;


-- ------------------------------------------------------------
-- 11. Mostrar el número de reservas CONFIRMADAS por sala, sin incluir los demás estados.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    ro.id AS codigo_sala,
    ro.name AS sala,
    COUNT(r.id) AS reservas_confirmadas
FROM rooms AS ro
JOIN reservations AS r ON ro.id = r.room_id
WHERE r.status = 'CONFIRMADA'
GROUP BY ro.id, ro.name
ORDER BY reservas_confirmadas DESC, ro.id;


-- ------------------------------------------------------------
-- 12. Mostrar los empleados invitados a cada reserva, indicando motivo y respuesta.
-- Resultado de referencia: 10 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_reserva,
    r.reason AS motivo,
    e.name AS empleado,
    rp.response AS respuesta
FROM reservation_participants AS rp
JOIN reservations AS r ON rp.reservation_id = r.id
JOIN employees AS e ON rp.employee_id = e.id
ORDER BY r.id, e.id;


-- ------------------------------------------------------------
-- 13. Listar reservas CONFIRMADAS del 3 de noviembre de 2026. Usar BETWEEN.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_reserva,
    reason AS motivo,
    started_at AS fecha_inicio,
    ended_at AS fecha_fin,
    status AS estado
FROM reservations
WHERE status = 'CONFIRMADA'
    AND started_at BETWEEN '2026-11-03 00:00:00' AND '2026-11-03 23:59:59'
ORDER BY started_at, id;


-- ------------------------------------------------------------
-- 14. Mostrar recursos asociados a reservas, indicando el organizador de la reserva.
-- Resultado de referencia: 8 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_reserva,
    re.name AS recurso,
    e.name AS organizador
FROM reservation_resources AS rr
JOIN reservations AS r ON rr.reservation_id = r.id
JOIN resources AS re ON rr.resource_id = re.id
JOIN employees AS e ON r.organizer_id = e.id
ORDER BY r.id, re.id;


-- ------------------------------------------------------------
-- 15. Contar participantes invitados por reserva, incluyendo reservas sin participantes.
-- Resultado de referencia: 8 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_reserva,
    r.reason AS motivo,
    COUNT(rp.employee_id) AS total_invitados
FROM reservations AS r
LEFT JOIN reservation_participants AS rp ON r.id = rp.reservation_id
GROUP BY r.id, r.reason
ORDER BY r.id;


-- ------------------------------------------------------------
-- 16. Mostrar los bloqueos de salas junto con la sede donde ocurren.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    rb.id AS codigo_bloqueo,
    ro.name AS sala,
    s.name AS sede,
    rb.started_at AS fecha_inicio,
    rb.ended_at AS fecha_fin,
    rb.reason AS motivo
FROM room_blocks AS rb
JOIN rooms AS ro ON rb.room_id = ro.id
JOIN sites AS s ON ro.site_id = s.id
ORDER BY rb.id;


-- ------------------------------------------------------------
-- 17. Encontrar empleados con dos o más invitaciones ACEPTADA. Usar HAVING.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_empleado,
    e.name AS empleado,
    COUNT(*) AS invitaciones_aceptadas
FROM employees AS e
JOIN reservation_participants AS rp ON e.id = rp.employee_id
WHERE rp.response = 'ACEPTADA'
GROUP BY e.id, e.name
HAVING COUNT(*) >= 2
ORDER BY invitaciones_aceptadas DESC, e.id;


-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar empleados que nunca han organizado una reserva. Usar NOT EXISTS.
-- Resultado de referencia: 1 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_empleado,
    e.name AS empleado
FROM employees AS e
WHERE NOT EXISTS (
    SELECT 1
    FROM reservations AS r
    WHERE r.organizer_id = e.id
)
ORDER BY e.id;


-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar salas cuya capacidad sea mayor al promedio de capacidades de todas las salas.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_sala,
    name AS sala,
    capacity AS capacidad
FROM rooms
WHERE capacity > (SELECT AVG(capacity) FROM rooms)
ORDER BY id;


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar recursos nunca solicitados en una reserva CONFIRMADA. Usar NOT EXISTS.
-- Resultado de referencia: 1 fila(s), con los datos actuales sin modificar.
SELECT
    re.id AS codigo_recurso,
    re.name AS recurso
FROM resources AS re
WHERE NOT EXISTS (
    SELECT 1
    FROM reservation_resources AS rr
    JOIN reservations AS r ON rr.reservation_id = r.id
    WHERE rr.resource_id = re.id AND r.status = 'CONFIRMADA'
)
ORDER BY re.id;
