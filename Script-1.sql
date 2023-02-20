-- desde consola sqlite3 keepcoding.db

-- ATTACH DATABASE IF NOT EXISTS 'keepcoding.db' AS keepcoding;


/*
 * Eliminamos cuatro tablas diferentes: "marcas", 
 * "grupos_empresariales", "coches" y "revisiones". 
 * Si estas tablas existen en la base de datos, se eliminarán con estas instrucciones.
 *	Si alguna de ellas no existe, la instrucción simplemente se saltará esa tabla y continuará con la siguiente. 
 * */

DROP TABLE IF EXISTS marcas;
DROP TABLE IF EXISTS grupos_empresariales;
DROP TABLE IF EXISTS coches;
DROP TABLE IF EXISTS revisiones;

/*
 * crea una tabla "marcas" que puede ser
 *  utilizada para almacenar información sobre marcas,
 *  incluyendo su nombre, país de origen, año de fundación y sitio web, 
 * con la restricción de que cada combinación de nombre y país de origen 
 * debe ser única en la tabla.
*/
CREATE TABLE marcas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(50) NOT NULL,
    pais_origen VARCHAR(50) NOT NULL,
    anio_fundacion INTEGER,
    sitio_web VARCHAR(100) NOT NULL,
    grupo_empresarial_id INTEGER,
    UNIQUE(nombre, pais_origen),
    FOREIGN KEY (grupo_empresarial_id) REFERENCES grupos_empresariales(id)
);

/*Este trigger tiene como objetivo asegurarse de que las fechas de fundación de las marcas sean coherentes y razonables.
 *  Si se intenta insertar una marca con una fecha de fundación que está fuera de los límites especificados, 
 * se producirá un error y la inserción será rechazada.
 * */
CREATE TRIGGER tr_marca_anio_fundacion
BEFORE INSERT ON marcas
FOR EACH ROW
WHEN NEW.anio_fundacion < 1800 OR NEW.anio_fundacion > strftime('%Y', 'now')
BEGIN
    SELECT RAISE(FAIL, 'Anio de fundacion incorrecto');
END;

CREATE TRIGGER tr_marca_sitio_web
BEFORE INSERT ON marcas
FOR EACH ROW
WHEN NEW.sitio_web NOT LIKE 'https://%'
BEGIN
    SELECT RAISE(FAIL, 'Sitio web incorrecto');
END;



-- Cargar datos de prueba en la tabla de marcas
INSERT INTO marcas (nombre, pais_origen, anio_fundacion, sitio_web, grupo_empresarial_id)
VALUES 
    ('SEAT', 'España', 1950, 'https://www.seat.es/', 1),
    ('VW', 'Alemania', 1937, 'https://www.volkswagen.de/',5),
    ('Audi', 'Alemania', 1909, 'https://www.audi.com/', 5),
    ('Toyota', 'Japón', 1937, 'https://www.toyota.com/',6),
    ('Ford', 'Estados Unidos', 1903, 'https://www.ford.com/', 3),
    ('Renault', 'Francia', 1899, 'https://www.renault.es/',7),
    ('Fiat', 'Italia', 1899, 'https://www.fiat.es/',2),
    ('Mercedes-Benz', 'Alemania', 1926, 'https://www.mercedes-benz.com/',2),
    ('BMW', 'Alemania', 1916, 'https://www.bmw.com/',5),
    ('Nissan', 'Japón', 1933, 'https://www.nissan.es/',7),
    ('Honda', 'Japón', 1948, 'https://www.honda.com/',2);





-- Crear tabla de grupos empresariales
CREATE TABLE grupos_empresariales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    facturacion_anual NUMERIC(10,2) NOT NULL,
    fecha_fundacion DATE NOT NULL
);


-- Cargar datos de prueba en la tabla de grupos empresariales
INSERT INTO grupos_empresariales (nombre, pais, facturacion_anual, fecha_fundacion)
VALUES ('VAN', 'España', 5000000.00, '1990-01-01'),
('Otro', 'Alemania', 7500000.00, '1985-05-15'),
('Ford Motor Company', 'Estados Unidos', 100000000.00, '1903-06-16'),
('General Motors', 'Estados Unidos', 120000000.00, '1908-09-16'),
('Volkswagen Group', 'Alemania', 150000000.00, '1937-05-28'),
('Toyota Motor Corporation', 'Japón', 180000000.00, '1937-08-28'),
('Renault-Nissan-Mitsubishi Alliance', 'Multiples', 423000000.00, '1997-08-28')
;

-- Crear tabla de coches
CREATE TABLE coches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre_modelo VARCHAR(50) NOT NULL,
    marca_id INTEGER NOT NULL REFERENCES marcas(id) ON DELETE CASCADE,
    color VARCHAR(50) NOT NULL,
    matricula VARCHAR(10) NOT NULL UNIQUE,
    total_kilometros NUMERIC(10,2) NOT NULL CHECK(total_kilometros >= 0),
    compania_aseguradora VARCHAR(50) NOT NULL,
    numero_poliza VARCHAR(50) NOT NULL,
    fecha_compra DATE NOT NULL,
    CONSTRAINT ck_nombre_modelo CHECK(length(nombre_modelo) <= 50),
    CONSTRAINT ck_color CHECK(length(color) <= 50),
    CONSTRAINT ck_compania_aseguradora CHECK(length(compania_aseguradora) <= 50),
    CONSTRAINT ck_numero_poliza CHECK(length(numero_poliza) <= 50),
    CONSTRAINT uk_coches_nombre_modelo_marca_id UNIQUE(nombre_modelo, marca_id)
);



-- Crear tabla de revisiones
CREATE TABLE revisiones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    coche_id INTEGER NOT NULL REFERENCES coches(id),
    fecha_revision DATE NOT NULL,
    kilometros_revision NUMERIC(10,2) NOT NULL,
    importe_revision NUMERIC(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL CHECK(moneda IN ('EUR', 'USD', 'GBP')),
    CONSTRAINT uc_revision UNIQUE(coche_id, fecha_revision),
    CONSTRAINT ck_importe_revision CHECK(importe_revision > 0),
    CONSTRAINT ck_kilometros_revision CHECK(kilometros_revision > 0),
    CONSTRAINT fk_revisiones_coche_id FOREIGN KEY(coche_id) REFERENCES coches(id) ON DELETE CASCADE
);



-- Cargar algunos datos de prueba en la tabla de coches

INSERT INTO coches (nombre_modelo, marca_id, color, matricula, total_kilometros, compania_aseguradora, numero_poliza, fecha_compra)
VALUES
('Corsa', 4, 'Gris', '3456JKL', 20000, 'Allianz', '135790', '2022-01-10'),
('Fiesta', 5, 'Azul', '7890MNO', 35000, 'Aegon', '246801', '2020-11-12'),
('Civic', 13, 'Blanco', '2345PQR', 45000, 'Aviva', '369852', '2021-07-01'),
('Yaris', 4, 'Rojo', '6789STU', 55000, 'Direct Seguros', '258963', '2019-04-22'),
('A1', 3, 'Negro', '1357VWX', 80000, 'Línea Directa', '753159', '2018-09-01'),
('Polo', 2, 'Gris', '2468YZA', 60000, 'AXA', '951357', '2020-06-30'),
('Kona', 8, 'Blanco', '8642BCD', 15000, 'Mutua Madrileña', '579314', '2021-03-15'),
('Model S', 9, 'Rojo', '7913EFG', 2000, 'Mapfre', '468013', '2022-02-01'),
('Q5', 3, 'Negro', '2460HIJ', 40000, 'MMT', '580136', '2019-10-20'),
('Megane', 10, 'Gris', '8024KLM', 50000, 'Aegon', '642580', '2018-12-05'),
('208', 11, 'Rojo', '1357NOP', 30000, 'Direct Seguros', '753159', '2020-08-10'),
('Clio', 10, 'Blanco', '4680QRS', 55000, 'Mutua Madrileña', '159753', '2021-05-11');



-- Cargar algunos datos de prueba en la tabla de revisiones
INSERT INTO revisiones (coche_id, fecha_revision, kilometros_revision, importe_revision, moneda)
VALUES (1, '2022-03-01', 70000, 1800.40, 'USD'),
       (2, '2022-04-15', 85000, 2100.43, 'EUR'),
       (3, '2022-05-30', 115000, 2700.96, 'GBP'),
       (1, '2022-08-01', 80000, 2000.12, 'EUR'),
       (2, '2022-09-15', 95000, 2300.09, 'EUR'),
       (3, '2022-10-30', 120000, 2900.60, 'EUR'),
       (1, '2023-01-01', 90000, 2200.50, 'EUR'),
       (2, '2023-02-15', 105000, 2600.65, 'GBP'),
       (3, '2023-03-30', 130000, 3200.10, 'USD'),
       (1, '2023-06-01', 100000, 2400.34, 'EUR'),
       (4, '2022-09-15', 95000, 2300.94, 'EUR'),
       (5, '2022-10-30', 120000, 2900.62, 'EUR'),
       (6, '2023-01-01', 90000, 2200.01, 'USD'),
       (7, '2023-02-15', 105000, 2600.04, 'EUR'),
       (8, '2023-03-30', 130000, 3200.39, 'EUR'),
       (9, '2023-06-01', 100000, 2400.97, 'GBP'),
       (10, '2023-06-01', 100000, 2400.23, 'EUR'),
       (11, '2022-09-15', 95000, 2300.53, 'USD'),
       (12, '2022-10-30', 120000, 2900.50, 'GBP');

-- La consulta devuelve información detallada de los coches, incluyendo información de la marca, 
-- grupo empresarial y la última revisión realizada (si la hubo) para aquellos coches que no tengan revisiones o 
-- que tengan la última revisión.
SELECT c.nombre_modelo, m.nombre AS marca, 
       g.nombre AS grupo_empresarial, 
       c.fecha_compra, c.matricula, c.color, 
       c.total_kilometros, c.compania_aseguradora, 
       c.numero_poliza
FROM coches c
JOIN marcas m ON c.marca_id = m.id
JOIN grupos_empresariales g ON m.grupo_empresarial_id = g.id;
