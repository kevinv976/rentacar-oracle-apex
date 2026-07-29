
-- RentaCar - Datos de prueba


INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB1234', 'Toyota', 'Corolla', 2022, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('CD5678', 'Hyundai', 'Tucson', 2021, 'N');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB1111', 'Toyota', 'Yaris', 2021, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB2222', 'Honda', 'Civic', 2022, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB3333', 'Nissan', 'Sentra', 2020, 'N');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB4444', 'Chevrolet', 'Onix', 2023, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB5555', 'Hyundai', 'Elantra', 2021, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB6666', 'Kia', 'Forte', 2022, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB7777', 'Mazda', 'Mazda3', 2023, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB8888', 'Volkswagen', 'Jetta', 2020, 'S');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AB9999', 'Ford', 'Focus', 2019, 'N');
INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad) VALUES ('AC1010', 'Suzuki', 'Swift', 2022, 'S');

INSERT INTO Client (cliente_id, nombre, apellido, telefono_celular, correo_electronico)
VALUES ('8-123-4567', 'Kevin', 'Vergara', '+507 6123-4567', 'kevinvergara926@gmail.com');

INSERT INTO Cajero (id_cajero, nombre, apellido)
VALUES ('8-999-1111', 'Carlos', 'Rios');

INSERT INTO Pagos (metodo_pago, tipo_tarjeta, monto) VALUES ('TARJETA', 'MASTERCARD', 0);
INSERT INTO Pagos (metodo_pago, tipo_tarjeta, monto) VALUES ('EFECTIVO', NULL, 50);
INSERT INTO Pagos (metodo_pago, tipo_tarjeta, monto) VALUES ('EFECTIVO', NULL, 600);
INSERT INTO Pagos (metodo_pago, tipo_tarjeta, monto) VALUES ('TARJETA', 'CLAVE', 122.5);

INSERT INTO Reserva (pagos_id, id_placa, id_cajero, cliente_id, fecha_salida, fecha_entrega, cargo_tardanza)
VALUES (2, 'AB1234', '8-999-1111', '8-123-4567', DATE '2026-07-20', DATE '2026-07-25', 0);

COMMIT;
