-- ============================================================
-- COMPRAFÁCIL | SOLUCIONARIO DQL
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: comprafacil
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

-- Nota: al verificar, products, request_items, order_items y receipt_items estaban vacias.
-- Los resultados de referencia corresponden a esa carga parcial de datos.

USE comprafacil;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    p.id AS codigo_producto,
    p.name AS producto,
    p.active AS activo
FROM products AS p;


-- ------------------------------------------------------------
-- 01. Mostrar el código, nombre y correo de los empleados que pueden solicitar compras.
-- Resultado de referencia: 5 fila(s), con los datos actuales sin modificar.
SELECT
    code AS codigo_empleado,
    name AS empleado,
    email AS correo
FROM employees
ORDER BY code;


-- ------------------------------------------------------------
-- 02. Mostrar los productos activos y su unidad de medida. Usar WHERE.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_producto,
    name AS producto,
    unit_of_measure AS unidad_medida
FROM products
WHERE active = 1
ORDER BY id;


-- ------------------------------------------------------------
-- 03. Listar órdenes con estado PARCIAL o EMITIDA. Usar OR.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_orden,
    request_id AS codigo_solicitud,
    issued_at AS fecha_emision,
    status AS estado
FROM purchase_orders
WHERE status = 'PARCIAL' OR status = 'EMITIDA'
ORDER BY id;


-- ------------------------------------------------------------
-- 04. Mostrar las solicitudes creadas entre el 1 y el 5 de septiembre de 2026. Usar BETWEEN.
-- Resultado de referencia: 5 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_solicitud,
    created_at AS fecha_creacion,
    justification AS justificacion,
    status AS estado
FROM requests
WHERE created_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-05 23:59:59'
ORDER BY created_at, id;


-- ------------------------------------------------------------
-- 05. Buscar productos cuyo nombre contenga Cable o Teclado. Usar LIKE.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_producto,
    name AS producto
FROM products
WHERE name LIKE '%Cable%' OR name LIKE '%Teclado%'
ORDER BY id;


-- ------------------------------------------------------------
-- 06. Mostrar cada solicitud con el empleado que la creó, su fecha y estado.
-- Resultado de referencia: 7 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_solicitud,
    e.name AS empleado,
    r.created_at AS fecha_creacion,
    r.status AS estado
FROM requests AS r
JOIN employees AS e ON r.employee_id = e.id
ORDER BY r.id;


-- ------------------------------------------------------------
-- 07. Mostrar cada orden de compra junto con el proveedor y la justificación de la solicitud que originó la orden.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    po.id AS codigo_orden,
    s.company_name AS proveedor,
    r.justification AS justificacion
FROM purchase_orders AS po
JOIN suppliers AS s ON po.supplier_id = s.id
JOIN requests AS r ON po.request_id = r.id
ORDER BY po.id;


-- ------------------------------------------------------------
-- 08. Mostrar productos y cantidades requeridas de cada solicitud. Usar JOIN.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_solicitud,
    p.name AS producto,
    ri.requested_quantity AS cantidad_requerida
FROM requests AS r
JOIN request_items AS ri ON r.id = ri.request_id
JOIN products AS p ON ri.product_id = p.id
ORDER BY r.id, ri.id;


-- ------------------------------------------------------------
-- 09. Contar las solicitudes por estado.
-- Resultado de referencia: 3 fila(s), con los datos actuales sin modificar.
SELECT
    status AS estado,
    COUNT(*) AS total_solicitudes
FROM requests
GROUP BY status
ORDER BY total_solicitudes DESC, status;


-- ------------------------------------------------------------
-- 10. Calcular el valor total de cada orden sumando cantidad ordenada multiplicada por precio unitario.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    po.id AS codigo_orden,
    IFNULL(SUM(oi.ordered_quantity * oi.unit_price), 0) AS valor_total
FROM purchase_orders AS po
LEFT JOIN order_items AS oi ON po.id = oi.order_id
GROUP BY po.id
ORDER BY po.id;


-- ------------------------------------------------------------
-- 11. Mostrar cada recepción con su número de remisión y proveedor.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    r.id AS codigo_recepcion,
    r.delivery_note AS remision,
    s.company_name AS proveedor
FROM receipts AS r
JOIN purchase_orders AS po ON r.order_id = po.id
JOIN suppliers AS s ON po.supplier_id = s.id
ORDER BY r.id;


-- ------------------------------------------------------------
-- 12. Mostrar los productos recibidos, su cantidad recibida y la remisión correspondiente.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    p.name AS producto,
    ri.received_quantity AS cantidad_recibida,
    r.delivery_note AS remision
FROM receipt_items AS ri
JOIN receipts AS r ON ri.receipt_id = r.id
JOIN order_items AS oi ON ri.order_item_id = oi.id
JOIN request_items AS qi ON oi.request_item_id = qi.id
JOIN products AS p ON qi.product_id = p.id
ORDER BY r.id, ri.id;


-- ------------------------------------------------------------
-- 13. Calcular la cantidad pendiente por renglón de orden: cantidad ordenada menos lo recibido. Mostrar también los renglones sin recepción.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    oi.id AS codigo_renglon,
    oi.order_id AS codigo_orden,
    p.name AS producto,
    oi.ordered_quantity AS cantidad_ordenada,
    IFNULL(SUM(ri.received_quantity), 0) AS cantidad_recibida,
    oi.ordered_quantity - IFNULL(SUM(ri.received_quantity), 0) AS cantidad_pendiente
FROM order_items AS oi
JOIN request_items AS qi ON oi.request_item_id = qi.id
JOIN products AS p ON qi.product_id = p.id
LEFT JOIN receipt_items AS ri ON oi.id = ri.order_item_id
GROUP BY oi.id, oi.order_id, p.id, p.name, oi.ordered_quantity
ORDER BY oi.order_id, oi.id;


-- ------------------------------------------------------------
-- 14. Contar las órdenes por proveedor, incluyendo proveedores que todavía no tienen órdenes.
-- Resultado de referencia: 4 fila(s), con los datos actuales sin modificar.
SELECT
    s.id AS codigo_proveedor,
    s.company_name AS proveedor,
    COUNT(po.id) AS total_ordenes
FROM suppliers AS s
LEFT JOIN purchase_orders AS po ON s.id = po.supplier_id
GROUP BY s.id, s.company_name
ORDER BY total_ordenes DESC, s.id;


-- ------------------------------------------------------------
-- 15. Mostrar empleados que hayan realizado dos o más solicitudes. Usar HAVING.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    e.id AS codigo_empleado,
    e.name AS empleado,
    COUNT(r.id) AS total_solicitudes
FROM employees AS e
JOIN requests AS r ON e.id = r.employee_id
GROUP BY e.id, e.name
HAVING COUNT(r.id) >= 2
ORDER BY total_solicitudes DESC, e.id;


-- ------------------------------------------------------------
-- 16. Mostrar productos presentes en dos o más renglones de órdenes de compra.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    p.id AS codigo_producto,
    p.name AS producto,
    COUNT(oi.id) AS total_renglones
FROM products AS p
JOIN request_items AS ri ON p.id = ri.product_id
JOIN order_items AS oi ON ri.id = oi.request_item_id
GROUP BY p.id, p.name
HAVING COUNT(oi.id) >= 2
ORDER BY total_renglones DESC, p.id;


-- ------------------------------------------------------------
-- 17. Mostrar los tres renglones de órdenes con mayor valor total (cantidad por precio). Usar LIMIT.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_renglon,
    order_id AS codigo_orden,
    ordered_quantity AS cantidad_ordenada,
    unit_price AS precio_unitario,
    ordered_quantity * unit_price AS valor_total
FROM order_items
ORDER BY valor_total DESC, id
LIMIT 3;


-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar renglones cuyo precio unitario sea superior al precio unitario promedio.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_renglon,
    order_id AS codigo_orden,
    unit_price AS precio_unitario
FROM order_items
WHERE unit_price > (SELECT AVG(unit_price) FROM order_items)
ORDER BY id;


-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: listar productos que nunca han aparecido en una orden de compra. Usar NOT EXISTS.
-- Resultado de referencia: 0 fila(s), con los datos actuales sin modificar.
SELECT
    p.id AS codigo_producto,
    p.name AS producto
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM request_items AS ri
    JOIN order_items AS oi ON ri.id = oi.request_item_id
    WHERE ri.product_id = p.id
)
ORDER BY p.id;


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar proveedores que tengan al menos una orden PARCIAL. Usar IN.
-- Resultado de referencia: 2 fila(s), con los datos actuales sin modificar.
SELECT
    id AS codigo_proveedor,
    company_name AS proveedor
FROM suppliers
WHERE id IN (
    SELECT supplier_id
    FROM purchase_orders
    WHERE status = 'PARCIAL'
)
ORDER BY id;
