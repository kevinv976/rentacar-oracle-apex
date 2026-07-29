-- RentaCar - Migracion: agregar columna monto a Pagos
-- Ejecutar solo si la tabla Pagos ya existe sin esta columna

-- Paso 1: agregar columna permitiendo NULL temporalmente
ALTER TABLE Pagos ADD monto NUMBER(7,2);

-- Paso 2: rellenar registros existentes con valor provisional
UPDATE Pagos SET monto = 0 WHERE monto IS NULL;
COMMIT;

-- Paso 3: aplicar restriccion NOT NULL
ALTER TABLE Pagos MODIFY monto NUMBER(7,2) NOT NULL;
