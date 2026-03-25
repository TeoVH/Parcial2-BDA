-- =========================
-- TABLAS MAESTRAS
-- =========================

CREATE TABLE sedes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL
);

CREATE TABLE zonas (
    id SERIAL PRIMARY KEY,
    sede_id INT NOT NULL REFERENCES sedes(id),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE tipos_sensor (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL
);

CREATE TABLE sensores (
    id SERIAL PRIMARY KEY,
    zona_id INT NOT NULL REFERENCES zonas(id),
    tipo_sensor_id INT NOT NULL REFERENCES tipos_sensor(id),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    fecha_instalacion DATE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo'
);

-- =========================
-- TABLA TRANSACCIONAL PARTICIONADA
-- =========================

CREATE TABLE lecturas (
    id BIGSERIAL NOT NULL,
    sensor_id INT NOT NULL REFERENCES sensores(id),
    fecha_hora TIMESTAMP NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    bateria NUMERIC(5,2),
    PRIMARY KEY (id, fecha_hora)
) PARTITION BY RANGE (fecha_hora);

CREATE TABLE lecturas_2026_02 PARTITION OF lecturas
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE lecturas_2026_03 PARTITION OF lecturas
FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE TABLE lecturas_2026_04 PARTITION OF lecturas
FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

-- =========================
-- OTRA TABLA TRANSACCIONAL
-- =========================

CREATE TABLE alertas (
    id SERIAL PRIMARY KEY,
    sensor_id INT NOT NULL REFERENCES sensores(id),
    fecha_hora TIMESTAMP NOT NULL,
    tipo_alerta VARCHAR(50) NOT NULL,
    severidad VARCHAR(20) NOT NULL,
    descripcion TEXT
);

-- =========================
-- ÍNDICES
-- =========================

CREATE INDEX idx_zonas_sede_id ON zonas(sede_id);
CREATE INDEX idx_sensores_zona_id ON sensores(zona_id);
CREATE INDEX idx_sensores_tipo_sensor_id ON sensores(tipo_sensor_id);
CREATE INDEX idx_alertas_sensor_id ON alertas(sensor_id);
CREATE INDEX idx_alertas_fecha_hora ON alertas(fecha_hora);

-- =========================
-- POBLACIÓN
-- =========================

INSERT INTO sedes (nombre, ciudad) VALUES
('Campus Norte', 'Medellin'),
('Campus Sur', 'Envigado'),
('Centro de Investigacion', 'Rionegro');

INSERT INTO zonas (sede_id, nombre) VALUES
(1, 'Laboratorio A'),
(1, 'Laboratorio B'),
(1, 'Zona de Servidores'),
(2, 'Bloque Administrativo'),
(2, 'Sala de Equipos'),
(3, 'Invernadero 1');

INSERT INTO tipos_sensor (nombre, unidad_medida) VALUES
('Temperatura', 'C'),
('Humedad', '%'),
('CO2', 'ppm'),
('Ruido', 'dB');

INSERT INTO sensores (zona_id, tipo_sensor_id, codigo, fecha_instalacion, estado) VALUES
(1, 1, 'TEMP-LAB-A-01', '2025-01-10', 'activo'),
(1, 2, 'HUM-LAB-A-01',  '2025-01-10', 'activo'),
(2, 3, 'CO2-LAB-B-01',  '2025-02-01', 'activo'),
(3, 1, 'TEMP-SRV-01',   '2025-02-15', 'activo'),
(4, 2, 'HUM-ADM-01',    '2025-02-20', 'activo'),
(5, 4, 'RUIDO-EQP-01',  '2025-03-01', 'activo'),
(6, 1, 'TEMP-INV-01',   '2025-03-05', 'activo');

INSERT INTO lecturas (sensor_id, fecha_hora, valor, bateria) VALUES
(1, '2026-02-10 08:00:00', 23.50, 95.00),
(2, '2026-02-10 08:05:00', 61.20, 92.50),
(3, '2026-02-11 09:00:00', 710.00, 88.00),
(4, '2026-02-12 10:00:00', 21.70, 90.00),

(1, '2026-03-10 08:00:00', 24.50, 92.50),
(1, '2026-03-10 09:00:00', 25.10, 91.00),
(2, '2026-03-10 08:00:00', 60.20, 88.00),
(3, '2026-03-11 10:00:00', 780.00, 79.00),
(4, '2026-03-12 11:00:00', 22.60, 86.00),
(5, '2026-03-13 12:30:00', 58.50, 84.00),
(6, '2026-03-14 13:00:00', 72.00, 82.00),
(7, '2026-03-15 14:00:00', 26.10, 87.00),

(1, '2026-04-01 11:00:00', 27.30, 85.40),
(2, '2026-04-01 11:05:00', 63.00, 84.20),
(3, '2026-04-02 12:00:00', 820.00, 76.50),
(4, '2026-04-03 12:30:00', 23.40, 80.00);

INSERT INTO alertas (sensor_id, fecha_hora, tipo_alerta, severidad, descripcion) VALUES
(3, '2026-03-11 10:05:00', 'CO2_ALTO', 'media', 'Nivel de CO2 por encima del umbral definido'),
(1, '2026-04-01 11:10:00', 'TEMP_ALTA', 'baja', 'Temperatura superior al promedio esperado'),
(6, '2026-03-13 12:35:00', 'RUIDO_ALTO', 'alta', 'Ruido anormal en sala de equipos'),
(7, '2026-03-15 14:05:00', 'TEMP_CRITICA', 'alta', 'Temperatura alta en invernadero');
