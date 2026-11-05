-- HELPDESK PRO | DOCENTE - SOLUCIONARIO DQL
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: helpdesk_pro
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE helpdesk_pro;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    t.status AS estado
FROM tickets AS t;


-- ------------------------------------------------------------
-- 01. Mostrar el código, asunto, prioridad y estado de todos los tickets, ordenados por código.
-- Resultado de referencia: 8 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto,
    priority AS prioridad,
    status AS estado
FROM tickets
ORDER BY id;


-- ------------------------------------------------------------
-- 02. Listar los tickets con prioridad ALTA o CRITICA que estén ABIERTO o EN_PROCESO. Usar AND, OR y paréntesis.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto,
    priority AS prioridad,
    status AS estado
FROM tickets
WHERE (priority = 'ALTA' OR priority = 'CRITICA')
    AND (status = 'ABIERTO' OR status = 'EN_PROCESO')
ORDER BY id;


-- ------------------------------------------------------------
-- 03. Buscar los clientes ACTIVOS cuya razón social contenga SAS. Usar LIKE.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_cliente,
    company_name AS empresa, 
    status AS estado
FROM clients
WHERE status = 'ACTIVO' AND company_name LIKE '%SAS%'
ORDER BY company_name;


-- ------------------------------------------------------------
-- 04. Obtener los tres tickets más recientes según su fecha de apertura. Usar ORDER BY y LIMIT.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto,
    opened_at AS fecha_apertura
FROM tickets
ORDER BY opened_at DESC
LIMIT 3;


-- ------------------------------------------------------------
-- 05. Mostrar tickets cuyo asunto contenga la palabra Red o Servidor. Usar LIKE y OR.
-- Resultado de referencia: 2 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto
FROM tickets
WHERE subject LIKE '%Red%' OR subject LIKE '%Servidor%'
ORDER BY id;


-- ------------------------------------------------------------
-- 06. Mostrar el código y asunto de cada ticket junto con el nombre de su contacto. Usar JOIN.
-- Resultado de referencia: 8 fila(s), con las semillas sin modificar.
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    c.name AS contacto
FROM tickets AS t
JOIN contacts AS c ON t.contact_id = c.id
ORDER BY t.id;


-- ------------------------------------------------------------
-- 07. Mostrar cada ticket con el cliente que lo reportó y la categoría de soporte. Usar varios JOIN.
-- Resultado de referencia: 8 fila(s), con las semillas sin modificar.
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    cl.company_name AS empresa,
    ca.name AS categoria
FROM tickets AS t
JOIN contacts AS co ON t.contact_id = co.id
JOIN clients AS cl ON co.client_id = cl.id
JOIN categories AS ca ON t.category_id = ca.id
ORDER BY t.id;


-- ------------------------------------------------------------
-- 08. Listar todos los técnicos y cuántas asignaciones han recibido, incluso si nunca han sido asignados. Usar LEFT JOIN.
-- Resultado de referencia: 5 fila(s), con las semillas sin modificar.
SELECT
    te.id AS codigo_tecnico,
    te.name AS tecnico,
    COUNT(a.id) AS total_asignaciones
FROM technicians AS te
LEFT JOIN assignments AS a ON te.id = a.technician_id
GROUP BY te.id, te.name
ORDER BY total_asignaciones DESC, te.name;


-- ------------------------------------------------------------
-- 09. Contar cuántos tickets existen por prioridad. Usar GROUP BY.
-- Resultado de referencia: 4 fila(s), con las semillas sin modificar.
SELECT
    priority AS prioridad,
    COUNT(*) AS total_tickets
FROM tickets
GROUP BY priority
ORDER BY total_tickets DESC, priority;


-- ------------------------------------------------------------
-- 10. Mostrar cuántos tickets se registraron en cada estado, ordenados del más frecuente al menos frecuente.
-- Resultado de referencia: 4 fila(s), con las semillas sin modificar.
SELECT
    status AS estado,
    COUNT(*) AS total_tickets
FROM tickets
GROUP BY status
ORDER BY total_tickets DESC, status;


-- ------------------------------------------------------------
-- 11. Mostrar los tickets con asignación todavía abierta y el técnico responsable. Usar IS NULL.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    te.name AS tecnico
FROM assignments AS a
JOIN tickets AS t ON a.ticket_id = t.id
JOIN technicians AS te ON a.technician_id = te.id
WHERE a.ended_at IS NULL
ORDER BY t.id;


-- ------------------------------------------------------------
-- 12. Buscar tickets abiertos desde el 1 hasta el 5 de septiembre de 2026, incluyendo todo el día 5. Usar BETWEEN.
-- Resultado de referencia: 5 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto,
    opened_at AS fecha_apertura
FROM tickets
WHERE opened_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-05 23:59:59'
ORDER BY opened_at;


-- ------------------------------------------------------------
-- 13. Mostrar los comentarios escritos por técnicos con el nombre del autor y el asunto del ticket.
-- Resultado de referencia: 5 fila(s), con las semillas sin modificar.
SELECT
    co.id AS codigo_comentario,
    te.name AS tecnico,
    t.subject AS asunto,
    co.content AS comentario
FROM comments AS co
JOIN technicians AS te ON co.technician_id = te.id
JOIN tickets AS t ON co.ticket_id = t.id
ORDER BY co.id;


-- ------------------------------------------------------------
-- 14. Contar los comentarios por ticket, incluyendo tickets sin comentarios.
-- Resultado de referencia: 8 fila(s), con las semillas sin modificar.
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    COUNT(co.id) AS total_comentarios
FROM tickets AS t
LEFT JOIN comments AS co ON t.id = co.ticket_id
GROUP BY t.id, t.subject
ORDER BY total_comentarios DESC, t.id;


-- ------------------------------------------------------------
-- 15. Mostrar las empresas que hayan reportado dos o más tickets. Usar GROUP BY y HAVING.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    cl.company_name AS empresa,
    COUNT(t.id) AS total_tickets
FROM clients AS cl
JOIN contacts AS co ON cl.id = co.client_id
JOIN tickets AS t ON co.id = t.contact_id
GROUP BY cl.id, cl.company_name
HAVING COUNT(t.id) >= 2
ORDER BY total_tickets DESC, empresa;


-- ------------------------------------------------------------
-- 16. Encontrar las categorías con al menos dos tickets registrados. Usar HAVING.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    ca.name AS categoria,
    COUNT(t.id) AS total_tickets
FROM categories AS ca
JOIN tickets AS t ON ca.id = t.category_id
GROUP BY ca.id, ca.name
HAVING COUNT(t.id) >= 2
ORDER BY total_tickets DESC, categoria;


-- ------------------------------------------------------------
-- 17. Mostrar cada cambio de estado con el asunto del ticket y el nombre del técnico, incluyendo cambios automáticos.
-- Resultado de referencia: 8 fila(s), con las semillas sin modificar.
SELECT
    h.id AS codigo_cambio,
    t.subject AS asunto,
    h.previous_status AS estado_anterior,
    h.new_status AS estado_nuevo,
    IFNULL(te.name, 'Automatización') AS responsable
FROM status_history AS h
JOIN tickets AS t ON h.ticket_id = t.id
LEFT JOIN technicians AS te ON h.technician_id = te.id
ORDER BY h.id;


-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar los tickets abiertos después de la fecha de apertura del ticket con id 4.
-- Resultado de referencia: 4 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto,
    opened_at AS fecha_apertura
FROM tickets
WHERE opened_at > (SELECT opened_at FROM tickets WHERE id = 4)
ORDER BY opened_at;


-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar los técnicos que no han escrito ningún comentario. Usar NOT EXISTS.
-- Resultado de referencia: 1 fila(s), con las semillas sin modificar.
SELECT
    te.id AS codigo_tecnico,
    te.name AS tecnico
FROM technicians AS te
WHERE NOT EXISTS (
    SELECT 1 FROM comments AS c WHERE c.technician_id = te.id
)
ORDER BY te.id;


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: consultar los tickets que tengan una prioridad igual a la de los tickets 1 o 2, excluyendo esos dos tickets. Usar IN.
-- Resultado de referencia: 3 fila(s), con las semillas sin modificar.
SELECT
    id AS codigo_ticket,
    subject AS asunto,
    priority AS prioridad
FROM tickets
WHERE priority IN (SELECT priority FROM tickets WHERE id IN (1, 2))
    AND id NOT IN (1, 2)
ORDER BY id;