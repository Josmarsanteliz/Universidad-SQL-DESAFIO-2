

CREATE DATABASE IF NOT EXISTS tienda_db;
USE tienda_db;

-- Limpiar tablas si ya existen previamente
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

-- 1. Creación de Tablas con Claves Primarias y Foráneas
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha DATETIME NOT NULL,
    estado VARCHAR(20) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id),
    CONSTRAINT fk_producto FOREIGN KEY (id_producto) REFERENCES productos(id)
);

-- 2. Inserción de Registros de Prueba
INSERT INTO clientes (nombre, apellido, direccion, correo, telefono) VALUES 
('Carlos', 'Perez', 'Av. Bolivar', 'carlos@email.com', '04141234567'),
('Ana', 'Gomez', 'Calle 24', 'ana@email.com', '04129876543');

INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES 
('Camisa Casual', 'Algodon', 20.00, 'Camisetas', 15),
('Jeans Azul', 'Denim', 40.00, 'Pantalones', 10);

INSERT INTO pedidos (id_cliente, fecha, estado, total) VALUES 
(1, '2026-10-20 10:00:00', 'Completado', 20.00), -- Pedido reciente
(2, '2026-09-10 10:00:00', 'Completado', 40.00), -- Pedido antiguo
(1, '2026-10-25 10:00:00', 'Pendiente', 20.00);  -- Pedido sin ventas para el DELETE

INSERT INTO ventas (id_pedido, id_producto, cantidad, precio_venta) VALUES 
(1, 1, 1, 20.00),
(2, 2, 1, 40.00);


-- PARTE 2: Consultas Avanzadas, Actualizaciones, Eliminaciones y Vistas

-- a) Consultas avanzadas con SELECT
-- Consulta 1: Obtener nombre completo, dirección y correo de clientes con pedidos en los últimos 30 días
SELECT DISTINCT c.nombre, c.apellido, c.direccion, c.correo 
FROM clientes c 
JOIN pedidos p ON c.id = p.id_cliente 
WHERE p.fecha >= '2026-10-01 00:00:00';

-- Consulta 2: Productos con mayor cantidad de ventas en el último mes, junto con el total vendido
SELECT pr.nombre, SUM(v.cantidad) AS total_vendido, SUM(v.cantidad * v.precio_venta) AS ingresos 
FROM ventas v 
JOIN pedidos p ON v.id_pedido = p.id 
JOIN productos pr ON v.id_producto = pr.id 
WHERE p.fecha >= '2026-10-01 00:00:00' 
GROUP BY pr.id, pr.nombre 
ORDER BY total_vendido DESC;

-- Consulta 3: Listar clientes que han realizado más pedidos en el último año, ordenados por mayor cantidad
SELECT c.nombre, c.apellido, COUNT(p.id) AS total_pedidos 
FROM clientes c 
JOIN pedidos p ON c.id = p.id_cliente 
WHERE p.fecha >= '2026-01-01 00:00:00' 
GROUP BY c.id, c.nombre, c.apellido 
ORDER BY total_pedidos DESC;


-- b) Actualizaciones con UPDATE
-- Actualización 1: Aumentar el precio de todos los productos de la categoría "Camisetas" en un 10%
UPDATE productos 
SET precio = precio * 1.10 
WHERE categoria = 'Camisetas';


-- c) Eliminaciones con DELETE
-- Eliminación 2: Eliminar los pedidos que no tengan ventas asociadas
DELETE FROM pedidos 
WHERE id NOT IN (SELECT id_pedido FROM ventas);


-- d) Creación de vistas
-- Vista 1: Crear una vista llamada "vista_clientes_pedidos" con nombre completo, fecha y total del pedido
CREATE OR REPLACE VIEW vista_clientes_pedidos AS 
SELECT CONCAT(c.nombre, ' ', c.apellido) AS cliente, p.fecha, p.total 
FROM clientes c 
JOIN pedidos p ON c.id = p.id_cliente;

-- Para verificar la vista creada, puedes ejecutar:
-- SELECT * FROM vista_clientes_pedidos;