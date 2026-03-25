-- =========================================
-- 2. CONSULTA BÁSICA DE DATOS
-- =========================================
SELECT * FROM sedes;
SELECT * FROM zonas;
SELECT * FROM sensores;
SELECT * FROM lecturas;
SELECT * FROM alertas;

-- =========================================
-- 3. CONSULTAS ANALÍTICAS
-- =========================================

-- Promedio de lecturas por sensor
SELECT s.codigo, AVG(l.valor) AS promedio
FROM lecturas l
JOIN sensores s ON s.id = l.sensor_id
GROUP BY s.codigo
ORDER BY promedio DESC;

-- Promedio por tipo de sensor
SELECT ts.nombre AS tipo_sensor, AVG(l.valor) AS promedio
FROM lecturas l
JOIN sensores s ON s.id = l.sensor_id
JOIN tipos_sensor ts ON ts.id = s.tipo_sensor_id
GROUP BY ts.nombre
ORDER BY promedio DESC;

-- Cantidad de alertas por severidad
SELECT severidad, COUNT(*) AS total
FROM alertas
GROUP BY severidad
ORDER BY total DESC;

-- Promedio de lecturas por sede
SELECT se.nombre AS sede, AVG(l.valor) AS promedio_lectura
FROM lecturas l
JOIN sensores s ON s.id = l.sensor_id
JOIN zonas z ON z.id = s.zona_id
JOIN sedes se ON se.id = z.sede_id
GROUP BY se.nombre
ORDER BY promedio_lectura DESC;

-- Últimas lecturas registradas
SELECT s.codigo, l.fecha_hora, l.valor, l.bateria
FROM lecturas l
JOIN sensores s ON s.id = l.sensor_id
ORDER BY l.fecha_hora DESC;

-- Sensores con alertas altas
SELECT s.codigo, a.tipo_alerta, a.severidad, a.fecha_hora
FROM alertas a
JOIN sensores s ON s.id = a.sensor_id
WHERE a.severidad = 'alta'
ORDER BY a.fecha_hora DESC;

-- =========================================
-- 4. PRUEBAS DE PARTICIONAMIENTO
-- =========================================

EXPLAIN SELECT *
FROM lecturas
WHERE fecha_hora >= '2026-03-01'
  AND fecha_hora < '2026-04-01';

EXPLAIN ANALYZE SELECT *
FROM lecturas
WHERE fecha_hora >= '2026-03-10 00:00:00'
  AND fecha_hora < '2026-03-16 00:00:00';

EXPLAIN ANALYZE
SELECT s.codigo, l.fecha_hora, l.valor
FROM lecturas l
JOIN sensores s ON s.id = l.sensor_id
WHERE l.fecha_hora >= '2026-03-01'
  AND l.fecha_hora < '2026-04-01';

-- =========================================
-- 5. PRUEBAS DE REPLICACIÓN
-- =========================================

-- En primario:
INSERT INTO lecturas (sensor_id, fecha_hora, valor, bateria)
VALUES (1, '2026-03-25 16:35:00', 27.80, 89.50);

-- Luego verificar:
SELECT * FROM lecturas
WHERE fecha_hora = '2026-03-25 16:35:00';

-- En réplica:
SELECT pg_is_in_recovery();

SELECT * FROM lecturas
WHERE fecha_hora = '2026-03-25 16:35:00';
