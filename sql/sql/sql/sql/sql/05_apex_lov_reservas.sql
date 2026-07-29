
-- RentaCar - Listas de Valores (LOV) usadas en el formulario
-- de Reservas en Oracle APEX. Patron display (d) / return (r).


-- Selector de Auto: solo autos disponibles
SELECT marca || ' ' || modelo || ' (' || id_placa || ')' AS d,
       id_placa AS r
FROM Auto
WHERE disponibilidad = 'S'
ORDER BY marca;

-- Selector de Cliente
SELECT nombre || ' ' || apellido || ' (' || cliente_id || ')' AS d,
       cliente_id AS r
FROM Client
ORDER BY nombre;

-- Selector de Cajero
SELECT nombre || ' ' || apellido || ' (' || id_cajero || ')' AS d,
       id_cajero AS r
FROM Cajero
ORDER BY nombre;

-- Selector de Pago: ordenado del mas reciente al mas antiguo
SELECT metodo_pago || ' - $' || monto || ' (ID ' || pagos_id || ')' AS d,
       pagos_id AS r
FROM Pagos
ORDER BY pagos_id DESC;
