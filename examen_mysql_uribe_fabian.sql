
-- Caso 1. HelpDesk Pro — Mesa de ayuda empresarial

-- ### 01. ¿Qué clientes requieren atención prioritaria? — 10 puntos

-- La gerencia de HelpDesk Pro observa que algunos clientes generan numerosos reportes y quiere decidir a cuáles asignará primero recursos de soporte. Para su reunión de seguimiento solo le interesan los **clientes activos** que hayan registrado **al menos dos tickets** y todavía tengan **algún ticket sin resolver**. Para este análisis, considera pendientes los casos en estado `ABIERTO` o `EN_PROCESO`.

-- Prepara un informe de una fila por cliente. La gerencia necesita ver su nombre comercial, el número total de tickets de cualquier estado, el número de pendientes, cuántos de estos pendientes son de prioridad `CRITICA` y la fecha en que ese cliente abrió su ticket más reciente, incluso si ya fue cerrado. Los clientes con más pendientes deben aparecer primero; cuando exista empate, ordénalos alfabéticamente.

-- **Columnas que debe recibir la gerencia, en este orden:** `cliente`, `total_tickets`, `tickets_pendientes`, `criticos_pendientes`, `ultima_apertura`.

USE helpdesk_pro;

-- 01. Solución
-- Unidad del resultado: Un cliente activo con al menos dos tickets y algun pendiente.
-- Se cuentan todos los tickets; los pendientes se identifican dentro de cada grupo.
SELECT
    cl.company_name AS cliente,
    COUNT(t.id) AS total_tickets,
    SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') THEN 1 ELSE 0 END) AS tickets_pendientes,
    SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO')
        AND t.priority = 'CRITICA' THEN 1 ELSE 0 END) AS criticos_pendientes,
    MAX(t.opened_at) AS ultima_apertura
FROM clients AS cl
JOIN contacts AS co
    ON co.client_id = cl.id
JOIN tickets AS t
    ON t.contact_id = co.id
WHERE cl.status = 'ACTIVO'
GROUP BY cl.id, cl.company_name
HAVING COUNT(t.id) >= 2
    AND SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') THEN 1 ELSE 0 END) > 0
ORDER BY tickets_pendientes DESC, cliente;


-- ### 02. ¿Qué responsables no han respondido a sus tickets? — 10 puntos

-- El coordinador de soporte detectó que algunos incidentes están asignados, pero su responsable actual aún no ha escrito una respuesta. Quiere enviarles un recordatorio sin responsabilizar a técnicos que ya terminaron su asignación ni confundir los comentarios de un cliente o de otro técnico con los del responsable vigente.

-- Entrégale los tickets que sigan `ABIERTO` o `EN_PROCESO`, tengan una asignación **sin fecha de finalización** y no registren **ningún comentario escrito por el técnico de esa asignación en ese mismo ticket**. Para cada caso deben aparecer el código del ticket, asunto, empresa cliente, técnico responsable, prioridad y fecha de inicio de la asignación. Presenta primero los tickets abiertos hace más tiempo y utiliza su código para desempatar.

-- **Columnas esperadas:** `codigo_ticket`, `asunto`, `cliente`, `tecnico`, `prioridad`, `asignado_desde`.

USE helpdesk_pro;

-- 02. Solución
-- Unidad del resultado: Un ticket pendiente cuyo tecnico vigente no ha comentado en ese ticket.
-- La ausencia de comentarios se comprueba para la pareja ticket y tecnico vigente.
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    cl.company_name AS cliente,
    te.name AS tecnico,
    t.priority AS prioridad,
    a.started_at AS asignado_desde
FROM tickets AS t
JOIN assignments AS a
    ON a.ticket_id = t.id
JOIN technicians AS te
    ON te.id = a.technician_id
JOIN contacts AS co
    ON co.id = t.contact_id
JOIN clients AS cl
    ON cl.id = co.client_id
WHERE t.status IN ('ABIERTO', 'EN_PROCESO')
    AND a.ended_at IS NULL
    AND NOT EXISTS (
        SELECT 1
        FROM comments AS cm
        WHERE cm.ticket_id = t.id
            AND cm.technician_id = a.technician_id
    )
ORDER BY t.opened_at, t.id;


-- * * *

-- ## Caso 2. AssetControl — Inventario tecnológico

-- ### 03. ¿En qué sedes se está invirtiendo más en mantenimiento? — 10 puntos

-- La dirección de tecnología debe distribuir su presupuesto del próximo trimestre. Antes de hacerlo necesita comparar las sedes que tienen **dos o más equipos en inventario**, incluidos los disponibles, asignados o dados de baja. También quiere distinguir entre tener muchos equipos y tener muchos mantenimientos sobre un mismo equipo.

-- El informe debe contener una fila por sede con su nombre y ciudad, cuántos **equipos distintos** tiene registrados, cuántos de ellos han recibido alguna intervención, cuánto suman los costos de **todos** sus mantenimientos y cuál es el costo promedio por equipo de inventario. Este último indicador se calcula dividiendo el gasto acumulado entre todos los equipos registrados en la sede, no entre los mantenimientos realizados. Si no existe ningún mantenimiento, el gasto y el promedio deberán mostrarse como cero. Organiza las sedes por gasto total descendente y usa el nombre como desempate.

-- **Columnas esperadas:** `sede`, `ciudad`, `total_equipos`, `equipos_intervenidos`, `costo_total`, `promedio_por_equipo`.

USE assetcontrol;

-- 03. Solución
-- Unidad del resultado: Una sede con al menos dos equipos registrados.
-- Primero se acumula el gasto por activo para conservar una fila por equipo.
WITH maintenance_by_asset AS (
    SELECT
        asset_id,
        SUM(cost) AS total_cost
    FROM maintenance
    GROUP BY asset_id
)
SELECT
    s.name AS sede,
    s.city AS ciudad,
    COUNT(DISTINCT a.id) AS total_equipos,
    COUNT(DISTINCT m.asset_id) AS equipos_intervenidos,
    ROUND(COALESCE(SUM(m.total_cost), 0), 2) AS costo_total,
    ROUND(COALESCE(SUM(m.total_cost), 0) / COUNT(DISTINCT a.id), 2) AS promedio_por_equipo
FROM sites AS s
JOIN assets AS a
    ON a.site_id = s.id
LEFT JOIN maintenance_by_asset AS m
    ON m.asset_id = a.id
GROUP BY s.id, s.name, s.city
HAVING COUNT(DISTINCT a.id) >= 2
ORDER BY costo_total DESC, sede;


-- ### 04. ¿Qué equipos están bajo custodia de otra sede? — 10 puntos

-- Durante una auditoría, el área administrativa descubrió que algunos activos pueden estar asignados a colaboradores cuyo departamento pertenece a una sede diferente de la sede responsable del inventario. Esto no es necesariamente un error, pero debe revisarse porque puede afectar los controles de custodia.

-- Identifica exclusivamente las asignaciones **que todavía no tienen fecha de devolución** y en las que las dos sedes no coincidan. Auditoría necesita el identificador patrimonial, la marca del equipo, el nombre del colaborador, su departamento, el nombre de la sede responsable del activo, el nombre de la sede a la que pertenece el departamento y la fecha de asignación. Presenta los equipos ordenados por su identificador patrimonial.

-- **Columnas esperadas:** `codigo_activo`, `marca`, `empleado`, `departamento`, `sede_inventario`, `sede_departamento`, `fecha_asignacion`.

USE assetcontrol;

-- 04. Solución
-- Unidad del resultado: Una asignacion vigente entre sedes diferentes.
SELECT
    a.patrimonial_identifier AS codigo_activo,
    a.brand AS marca,
    e.name AS empleado,
    d.name AS departamento,
    inventory_site.name AS sede_inventario,
    department_site.name AS sede_departamento,
    ag.started_at AS fecha_asignacion
FROM assignments AS ag
JOIN assets AS a
    ON a.id = ag.asset_id
JOIN employees AS e
    ON e.id = ag.employee_id
JOIN departments AS d
    ON d.id = e.department_id
JOIN sites AS inventory_site
    ON inventory_site.id = a.site_id
JOIN sites AS department_site
    ON department_site.id = d.site_id
WHERE ag.return_date IS NULL
    AND a.site_id <> d.site_id
ORDER BY a.patrimonial_identifier;


-- * * *

-- ## Caso 3. CompraFácil — Gestión de compras

-- ### 05. ¿Cuánto dinero comprometido falta por recibir? — 10 puntos

-- El departamento financiero revisará las órdenes de compra para saber cuánto dinero se comprometió con los proveedores y qué parte de los productos ya fue recibida. Algunas órdenes contienen varios renglones; otras tienen entregas parciales y un mismo renglón puede aparecer en varias recepciones. También existen órdenes que aún no han recibido nada.

-- Construye un estado por **cada orden que no esté `ANULADA`**, incluidas las que no registran recepciones. El valor ordenado es la suma de las cantidades compradas multiplicadas por sus precios unitarios acordados; el valor recibido se obtiene de las cantidades efectivamente recibidas en todas las entregas, valoradas a esos mismos precios. La diferencia corresponde al saldo pendiente. Una entrega parcial no debe hacer que se cuente dos veces el valor original de la orden. Las órdenes con mayor saldo pendiente aparecerán primero; resuelve los empates por código de orden.

-- **Columnas esperadas:** `codigo_orden`, `proveedor`, `estado`, `valor_ordenado`, `valor_recibido`, `saldo_pendiente`.

USE comprafacil;

-- 05. Solución
-- Unidad del resultado: Una orden de compra no anulada.
-- Se suman todas las entregas por renglon antes de calcular los valores de la orden.
WITH receipts_by_item AS (
    SELECT
        order_item_id,
        SUM(received_quantity) AS received_quantity
    FROM receipt_items
    GROUP BY order_item_id
), order_totals AS (
    SELECT
        oi.order_id,
        SUM(oi.ordered_quantity * oi.unit_price) AS ordered_value,
        SUM(COALESCE(ri.received_quantity, 0) * oi.unit_price) AS received_value
    FROM order_items AS oi
    LEFT JOIN receipts_by_item AS ri
        ON ri.order_item_id = oi.id
    GROUP BY oi.order_id
)
SELECT
    po.id AS codigo_orden,
    s.company_name AS proveedor,
    po.status AS estado,
    ROUND(COALESCE(ot.ordered_value, 0), 2) AS valor_ordenado,
    ROUND(COALESCE(ot.received_value, 0), 2) AS valor_recibido,
    ROUND(COALESCE(ot.ordered_value, 0) - COALESCE(ot.received_value, 0), 2) AS saldo_pendiente
FROM purchase_orders AS po
JOIN suppliers AS s
    ON s.id = po.supplier_id
LEFT JOIN order_totals AS ot
    ON ot.order_id = po.id
WHERE po.status <> 'ANULADA'
ORDER BY COALESCE(ot.ordered_value, 0) - COALESCE(ot.received_value, 0) DESC, po.id;


-- ### 06. ¿Qué productos se piden reiteradamente y aún no se compran en su totalidad? — 10 puntos

-- Compras sospecha que hay productos que aparecen de manera recurrente en las solicitudes internas, pero que siguen pendientes de ordenar. Para determinarlo, revisará **todas las solicitudes registradas**, independientemente de su estado, y prestará especial atención a productos presentes en **dos o más solicitudes diferentes**.

-- Para cada producto que cumpla esa condición, compara el total solicitado con el total efectivamente incluido en los renglones de las órdenes de compra vinculadas a esas solicitudes. Cuando una solicitud todavía no tenga orden, debe seguir contando como cantidad solicitada y aportar cero a la cantidad ordenada. El área solo quiere conocer los productos cuya cantidad solicitada **supere** a la ordenada. Incluye su SKU, nombre, número de solicitudes distintas, cantidades solicitadas y ordenadas, y cantidad restante por ordenar. Muestra primero el mayor faltante y usa el SKU para desempatar.

-- **Columnas esperadas:** `sku`, `producto`, `solicitudes`, `cantidad_solicitada`, `cantidad_ordenada`, `cantidad_no_ordenada`.

USE comprafacil;

-- 06. Solución
-- Unidad del resultado: Un producto presente en dos o mas solicitudes diferentes y pendiente de ordenar.
-- Se incluyen todas las solicitudes y sus ordenes vinculadas, sin filtrar estados.
-- La agrupacion previa evita repetir la cantidad solicitada por renglon.
WITH ordered_by_request_item AS (
    SELECT
        request_item_id,
        SUM(ordered_quantity) AS ordered_quantity
    FROM order_items
    GROUP BY request_item_id
)
SELECT
    p.sku AS sku,
    p.name AS producto,
    COUNT(DISTINCT ri.request_id) AS solicitudes,
    SUM(ri.requested_quantity) AS cantidad_solicitada,
    SUM(COALESCE(oi.ordered_quantity, 0)) AS cantidad_ordenada,
    SUM(ri.requested_quantity) - SUM(COALESCE(oi.ordered_quantity, 0)) AS cantidad_no_ordenada
FROM products AS p
JOIN request_items AS ri
    ON ri.product_id = p.id
LEFT JOIN ordered_by_request_item AS oi
    ON oi.request_item_id = ri.id
GROUP BY p.id, p.sku, p.name
HAVING COUNT(DISTINCT ri.request_id) >= 2
    AND SUM(ri.requested_quantity) > SUM(COALESCE(oi.ordered_quantity, 0))
ORDER BY cantidad_no_ordenada DESC, p.sku;


-- * * *

-- ## Caso 4. TalentTrack — Formación corporativa

-- ### 07. ¿Quiénes reúnen las condiciones para certificarse? — 10 puntos

-- La coordinación académica va a auditar la emisión de certificados. Quiere revisar **todas las matrículas**, incluso aquellas cuyos estudiantes aún no tienen asistencias registradas. Para este ejercicio, una matrícula es **apta para certificarse** únicamente cuando su edición está `FINALIZADA`, existe un registro de asistencia para **cada sesión programada de esa misma edición** y se asistió en estado `PRESENTE` a por lo menos el **80 %** de esas sesiones. Tener un certificado registrado no reemplaza estas condiciones.

-- Construye un reporte que muestre el código de cada matrícula, el colaborador, el código de edición, cuántas sesiones están programadas, en cuántas se registró asistencia y cuántas figuran como `PRESENTE`. Calcula el porcentaje de presencias sobre las sesiones programadas. Añade una respuesta `SI` o `NO` para señalar si es apta y otra para señalar si **ya tiene certificado emitido**. Una matrícula sin presencias debe mostrar cero por ciento cuando tenga sesiones programadas. Ordena por código de edición y nombre del colaborador.

-- **Columnas esperadas:** `codigo_matricula`, `colaborador`, `edicion`, `sesiones_programadas`, `asistencias_registradas`, `presencias`, `porcentaje_asistencia`, `apto_para_certificado`, `certificado_emitido`.

USE talenttrack;

-- 07. Solución
-- Unidad del resultado: Una matricula, incluso sin registros de asistencia.
-- Solo cuentan asistencias a sesiones de la misma edicion de la matricula.
-- Sin sesiones programadas el porcentaje es NULL (no calculable) y la matricula no es apta.
WITH attendance_by_enrollment AS (
    SELECT
        en.id AS enrollment_id,
        COUNT(DISTINCT se.id) AS scheduled_sessions,
        COUNT(DISTINCT a.session_id) AS recorded_sessions,
        COUNT(DISTINCT CASE WHEN a.status = 'PRESENTE' THEN se.id END) AS present_sessions
    FROM enrollments AS en
    LEFT JOIN sessions AS se
        ON se.edition_id = en.edition_id
    LEFT JOIN attendance AS a
        ON a.enrollment_id = en.id
        AND a.session_id = se.id
    GROUP BY en.id
)
SELECT
    en.id AS codigo_matricula,
    co.name AS colaborador,
    ed.code AS edicion,
    ae.scheduled_sessions AS sesiones_programadas,
    ae.recorded_sessions AS asistencias_registradas,
    ae.present_sessions AS presencias,
    ROUND(100.0 * ae.present_sessions / NULLIF(ae.scheduled_sessions, 0), 2) AS porcentaje_asistencia,
    CASE
        WHEN ed.status = 'FINALIZADA'
            AND ae.scheduled_sessions > 0
            AND ae.recorded_sessions = ae.scheduled_sessions
            AND ae.present_sessions * 100 >= ae.scheduled_sessions * 80
        THEN 'SI'
        ELSE 'NO'
    END AS apto_para_certificado,
    CASE WHEN EXISTS (
        SELECT 1
        FROM certificates AS ce
        WHERE ce.enrollment_id = en.id
    ) THEN 'SI' ELSE 'NO' END AS certificado_emitido
FROM enrollments AS en
JOIN collaborators AS co
    ON co.id = en.collaborator_id
JOIN editions AS ed
    ON ed.id = en.edition_id
JOIN attendance_by_enrollment AS ae
    ON ae.enrollment_id = en.id
ORDER BY ed.code, co.name;


-- ### 08. ¿Qué empresas obtienen mejores resultados de certificación? — 10 puntos

-- La dirección comercial desea comparar la efectividad de su oferta de formación entre las empresas clientes **activas** que hayan acumulado **dos o más matrículas**. Una misma persona puede matricularse en varias ediciones; en ese caso, representa un solo colaborador, pero varias matrículas. Igualmente, dos ediciones de un mismo curso representan un solo curso distinto.

-- Para cada empresa incluida en el análisis, informa cuántos colaboradores diferentes se han matriculado, el total de matrículas, la cantidad de cursos distintos cursados, el total de certificados efectivamente emitidos y la tasa de certificación calculada como **certificados emitidos dividido entre matrículas, multiplicado por 100**. Presenta primero las empresas con la tasa más alta; en caso de empate, utiliza el nombre de la empresa en orden alfabético.

-- **Columnas esperadas:** `empresa`, `colaboradores_matriculados`, `total_matriculas`, `cursos_distintos`, `certificados_emitidos`, `tasa_certificacion`.

USE talenttrack;

-- 08. Solución
-- Unidad del resultado: Una empresa activa con al menos dos matriculas.
-- Cada entidad se cuenta por su identificador para distinguir personas, matriculas y cursos.
SELECT
    c.company_name AS empresa,
    COUNT(DISTINCT co.id) AS colaboradores_matriculados,
    COUNT(DISTINCT en.id) AS total_matriculas,
    COUNT(DISTINCT ed.course_id) AS cursos_distintos,
    COUNT(DISTINCT ce.id) AS certificados_emitidos,
    ROUND(100.0 * COUNT(DISTINCT ce.id) / COUNT(DISTINCT en.id), 2) AS tasa_certificacion
FROM companies AS c
JOIN collaborators AS co
    ON co.company_id = c.id
JOIN enrollments AS en
    ON en.collaborator_id = co.id
JOIN editions AS ed
    ON ed.id = en.edition_id
LEFT JOIN certificates AS ce
    ON ce.enrollment_id = en.id
WHERE c.status = 'ACTIVA'
GROUP BY c.id, c.company_name
HAVING COUNT(DISTINCT en.id) >= 2
ORDER BY 100.0 * COUNT(DISTINCT ce.id) / COUNT(DISTINCT en.id) DESC, empresa;


-- * * *

-- ## Caso 5. SpaceBook — Reservas de salas

-- ### 09. ¿Qué salas se pueden reservar en el horario solicitado? — 10 puntos

-- Un empleado necesita una sala para una reunión el **3 de noviembre de 2026**, desde las **8:30 a. m. hasta las 9:30 a. m.** Puede desplazarse a cualquiera de las sedes y desea conocer todas las salas activas realmente disponibles.

-- Para considerar una sala disponible, no debe existir ninguna reserva en estado `CONFIRMADA` que ocupe **alguna parte** de ese intervalo, ni un bloqueo de sala por mantenimiento o limpieza que se cruce con él. Las reservas `SOLICITADA`, `CANCELADA` o `FINALIZADA` no deben impedir la selección. Si una ocupación termina exactamente al comenzar la reunión, o empieza exactamente cuando esta termina, no representa un conflicto. Prepara la relación de salas disponibles con su código, nombre, sede, ciudad y capacidad. Ordénalas alfabéticamente por sede y después por sala.

-- **Columnas esperadas:** `codigo_sala`, `sala`, `sede`, `ciudad`, `capacidad`.

USE spacebook;

-- 09. Solución
-- Unidad del resultado: Una sala activa disponible en todo el intervalo solicitado.
-- Hay cruce cuando la ocupacion empieza antes del fin solicitado y termina despues del inicio.
-- Las desigualdades estrictas permiten reuniones consecutivas sin conflicto.
SELECT
    ro.code AS codigo_sala,
    ro.name AS sala,
    s.name AS sede,
    s.city AS ciudad,
    ro.capacity AS capacidad
FROM rooms AS ro
JOIN sites AS s
    ON s.id = ro.site_id
WHERE ro.status = 'ACTIVA'
    AND NOT EXISTS (
        SELECT 1
        FROM reservations AS r
        WHERE r.room_id = ro.id
            AND r.status = 'CONFIRMADA'
            AND r.started_at < '2026-11-03 09:30:00'
            AND r.ended_at > '2026-11-03 08:30:00'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM room_blocks AS rb
        WHERE rb.room_id = ro.id
            AND rb.started_at < '2026-11-03 09:30:00'
            AND rb.ended_at > '2026-11-03 08:30:00'
    )
ORDER BY s.name, ro.name;


-- ### 10. ¿Cómo se está utilizando el aforo de las reuniones confirmadas? — 10 puntos

-- La administración necesita comparar las reuniones en estado `CONFIRMADA` para conocer sus participantes y recursos reservados. En una reunión puede haber varios invitados y también varios recursos, por lo que no debe repetirse una persona o un dispositivo al calcular los totales.

-- Por cada reserva confirmada, presenta el código, la sala, el organizador y la capacidad. Indica cuántas personas fueron invitadas en total, cuántas respondieron `ACEPTADA`, cuántas `RECHAZADA` y cuántos recursos diferentes están asociados a la reunión. Para este informe, el número de asistentes confirmados será **el organizador más todos los invitados que aceptaron**; cuenta al organizador como una persona adicional, conforme a la regla del examen. Calcula qué porcentaje de la capacidad representa ese número. Organiza las reuniones de mayor a menor porcentaje de aforo, con el código de reserva como desempate.

-- **Columnas esperadas:** `codigo_reserva`, `sala`, `organizador`, `capacidad`, `invitados`, `aceptados`, `rechazados`, `recursos`, `asistentes_confirmados`, `porcentaje_aforo`.

USE spacebook;

-- 10. Solución
-- Unidad del resultado: Una reserva confirmada, incluso sin invitados o recursos.
-- Invitados y recursos se cuentan por separado para evitar multiplicar sus registros.
WITH participants_by_reservation AS (
    SELECT
        reservation_id,
        COUNT(DISTINCT employee_id) AS invited_count,
        COUNT(DISTINCT CASE WHEN response = 'ACEPTADA' THEN employee_id END) AS accepted_count,
        COUNT(DISTINCT CASE WHEN response = 'RECHAZADA' THEN employee_id END) AS rejected_count
    FROM reservation_participants
    GROUP BY reservation_id
), resources_by_reservation AS (
    SELECT
        reservation_id,
        COUNT(DISTINCT resource_id) AS resource_count
    FROM reservation_resources
    GROUP BY reservation_id
)
SELECT
    r.id AS codigo_reserva,
    ro.name AS sala,
    e.name AS organizador,
    ro.capacity AS capacidad,
    COALESCE(p.invited_count, 0) AS invitados,
    COALESCE(p.accepted_count, 0) AS aceptados,
    COALESCE(p.rejected_count, 0) AS rechazados,
    COALESCE(rr.resource_count, 0) AS recursos,
    1 + COALESCE(p.accepted_count, 0) AS asistentes_confirmados,
    ROUND(100.0 * (1 + COALESCE(p.accepted_count, 0)) / ro.capacity, 2) AS porcentaje_aforo
FROM reservations AS r
JOIN rooms AS ro
    ON ro.id = r.room_id
JOIN employees AS e
    ON e.id = r.organizer_id
LEFT JOIN participants_by_reservation AS p
    ON p.reservation_id = r.id
LEFT JOIN resources_by_reservation AS rr
    ON rr.reservation_id = r.id
WHERE r.status = 'CONFIRMADA'
ORDER BY 100.0 * (1 + COALESCE(p.accepted_count, 0)) / ro.capacity DESC, r.id;