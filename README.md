# Examen práctico final de MySQL — Fabián Uribe

Solución de diez solicitudes de análisis de información sobre HelpDesk Pro, AssetControl, CompraFácil, TalentTrack y SpaceBook. Cada respuesta contiene una consulta de lectura y su correspondiente `USE`.

## Archivos del desarrollo

| Archivo                                                        | Propósito                                                                                      |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [examen_mysql_uribe_fabian.sql](examen_mysql_uribe_fabian.sql) | Enunciados conservados como comentarios y diez soluciones ejecutables, numeradas del 01 al 10. |


## Entorno y bases de datos

- Sintaxis diseñada para MySQL 8.0.16 o superior; utiliza expresiones de tabla comunes (`WITH`, también llamadas CTE).
- Servidor local: `127.0.0.1`, puerto `3306`.
- Las cinco bases deben contener los esquemas y las semillas originales de los archivos `01_base_datos.sql` suministrados.
- El archivo del examen no inserta, actualiza ni elimina registros.

| Consultas | Base utilizada |
| --------- | -------------- |
| 01–02     | `helpdesk_pro` |
| 03–04     | `assetcontrol` |
| 05–06     | `comprafacil`  |
| 07–08     | `talenttrack`  |
| 09–10     | `spacebook`    |

Los scripts originales se recibieron en cinco archivos ZIP en `D:\Campusland\Bases de datos Script`. Su script de HelpDesk crea **`helpdesk_pro`**. La base antigua llamada `helpdesk` tiene otro esquema y no se utiliza en este examen. El nombre correcto de la base de formación es `talenttrack`.

Las bases originales ya se cargaron para la validación. Si se necesita reconstruirlas, se debe ejecutar el `01_base_datos.sql` de cada proyecto en un entorno de laboratorio: esos archivos recrean las bases. Los ejemplos opcionales de `UPDATE`, `DELETE` y `TRUNCATE` deben permanecer comentados.

## Nomenclatura y presentación

Se aplican las convenciones del documento proporcionado `00_Orden_logico_MySQL.md`:

| Elemento                              | Convención                                  | Ejemplo                              |
| ------------------------------------- | ------------------------------------------- | ------------------------------------ |
| Palabras SQL y funciones              | Mayúsculas                                  | `SELECT`, `LEFT JOIN`, `COUNT`       |
| Bases, tablas y atributos reales      | Inglés, minúsculas y `snake_case`           | `request_items`, `ordered_quantity`  |
| Nombres de CTE y columnas intermedias | Inglés, minúsculas y `snake_case`           | `receipts_by_item`, `received_value` |
| Alias de tabla                        | Explícitos mediante `AS`                    | `employees AS e`                     |
| Alias visibles del informe            | Español, minúsculas y `snake_case`          | `AS cantidad_no_ordenada`            |
| Datos comerciales                     | Valores exactos definidos en las semillas   | `'ACTIVO'`, `'CONFIRMADA'`           |
| Relaciones                            | `JOIN` y condición `ON` en líneas separadas | `ON a.site_id = s.id`                |
| Dinero, promedios y porcentajes       | Dos decimales                               | `ROUND(expresion, 2)`                |

Se conserva el **orden de escritura** de SQL. El **orden lógico de lectura**, usado en la guía para explicar cada resultado, es:

```text
FROM → JOIN ... ON → WHERE → GROUP BY → HAVING
     → SELECT → DISTINCT → ORDER BY → LIMIT
```

Solo se consideran las cláusulas presentes en cada consulta. Las CTE y subconsultas tienen su propio bloque de análisis. Esta secuencia sirve para razonar; no describe necesariamente el plan físico elegido por el optimizador. Ninguna situación pide limitar filas, por lo que las soluciones no añaden `LIMIT`.

## Cómo ejecutar el examen

### Desde MySQL Workbench

1. Abrir la conexión local al puerto `3306`.
2. Abrir `examen_mysql_uribe_fabian.sql` como script SQL.
3. Ejecutar el archivo completo, sin dejar seleccionado únicamente un fragmento.
4. Revisar los diez conjuntos de resultados en su orden. Para ejecutar un solo ejercicio, seleccionar también su `USE`.

### Desde el cliente MySQL

Si el ejecutable `mysql` está disponible en la consola:

```console
mysql --host=127.0.0.1 --port=3306 --user=root --password --default-character-set=utf8mb4
```

Introducir la contraseña cuando el cliente la solicite. Dentro del cliente:

```sql
SOURCE D:/Campusland/examen_mysql/examen_mysql_uribe_fabian.sql;
```

Las credenciales no se guardan en los archivos de estudio.

## Desarrollo y verificación

El trabajo partió de identificar qué representa una fila de cada informe. Después se trazaron las relaciones por claves, se separaron filtros de filas y de grupos, y se revisaron los cálculos donde una relación de uno a muchos podía repetir información.

Se cargaron las semillas originales, se ejecutaron las diez consultas en orden y se contrastaron sus columnas, valores y orden. También se comprobaron casos límite mediante consultas de lectura: entregas parciales, registros de otra edición, ausencia de asistencia, límites exactos de horarios y múltiples invitados y recursos.

La revisión de nomenclatura conserva la lógica de las soluciones. Se volvieron a ejecutar las diez consultas reformateadas y se verificó que sus resultados coinciden exactamente con la validación anterior. Con esas mismas semillas se obtienen:

| N.º | Informe                         | Filas esperadas | Comprobación destacada                      |
| --- | ------------------------------- | ---------------:| ------------------------------------------- |
| 01  | Clientes prioritarios           | 2               | Andes Digital SAS y Clínica Norte SAS.      |
| 02  | Responsables sin respuesta      | 1               | Ticket 2, asignado actualmente a Elena Paz. |
| 03  | Mantenimiento por sede          | 3               | Sede Bogotá: gasto `840000.00`.             |
| 04  | Custodia en otra sede           | 1               | Activo `ACT-007`.                           |
| 05  | Saldo por recibir               | 4               | Orden 3: saldo `2820000.00`.                |
| 06  | Productos pendientes de ordenar | 1               | `PAP-003`: faltan `12.00` unidades.         |
| 07  | Aptitud para certificado        | 8               | Matrículas 1 y 2 aptas.                     |
| 08  | Certificación por empresa       | 3               | Innovación Delta SAS: `66.67` %.            |
| 09  | Salas disponibles               | 3               | Capital, Sur y Verde.                       |
| 10  | Aforo de reservas confirmadas   | 4               | Reserva 1: `50.00` %.                       |

Estos conteos son una referencia de las semillas suministradas, no valores fijados en el SQL. Si los datos cambian, los resultados pueden cambiar legítimamente. La guía de estudio presenta el detalle necesario para revisar los cálculos, no solo el número de filas.

## Ruta de estudio

1. Leer las convenciones y conceptos comunes de la [guía](GUIA_ESTUDIO_EXAMEN.md).
2. Abrir el SQL junto con la explicación del mismo número de ejercicio.
3. Explicar qué representa una fila, qué tablas se relacionan y por qué se conserva o descarta cada caso.
4. Recalcular un resultado de las semillas a mano.
5. Responder las preguntas de sustentación sin leer la explicación y luego contrastar la respuesta.

## Referencia de nomenclatura

Documento suministrado: `C:\Users\fabian.uribe\Downloads\00_Orden_logico_MySQL.md`, «Orden lógico de ejecución de una consulta SELECT en MySQL». Sus convenciones se aplican a este desarrollo; los enunciados del examen determinan las reglas del negocio.
