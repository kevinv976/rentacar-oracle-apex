-- RentaCar - Handlers PL/SQL del modulo REST api.reservas
-- Modulo: api.reservas | Base Path: /reservas/
-- Estos bloques se configuran dentro de RESTful Services en
-- APEX (SQL Workshop > RESTful Services), no se ejecutan
-- directamente como script.
--
-- Nota de diseno: este modulo NO implementa DELETE de forma
-- intencional. Ver seccion "Seguridad" del README para el
-- razonamiento de negocio detras de esta decision.


-- ------------------------------------------------------------
-- Template: todas
-- ------------------------------------------------------------

-- GET (Source Type: Collection Query)
SELECT reserva_id, cliente_id, id_placa, id_cajero, pagos_id,
       fecha_salida, fecha_entrega, cargo_tardanza
FROM Reserva;

-- POST (Source Type: PL/SQL)
BEGIN
  INSERT INTO Reserva (pagos_id, id_placa, id_cajero, cliente_id, fecha_salida, fecha_entrega, cargo_tardanza)
  VALUES (:pagos_id, :id_placa, :id_cajero, :cliente_id,
          TO_DATE(:fecha_salida, 'YYYY-MM-DD'),
          TO_DATE(:fecha_entrega, 'YYYY-MM-DD'),
          :cargo_tardanza);
END;

-- ------------------------------------------------------------
-- Template: {reserva_id}
-- ------------------------------------------------------------

-- GET (Source Type: Feed)
SELECT reserva_id, cliente_id, id_placa, id_cajero, pagos_id,
       fecha_salida, fecha_entrega, cargo_tardanza
FROM Reserva
WHERE reserva_id = :reserva_id;

-- PUT (Source Type: PL/SQL)
BEGIN
  UPDATE Reserva
  SET pagos_id = :pagos_id,
      id_placa = :id_placa,
      id_cajero = :id_cajero,
      cliente_id = :cliente_id,
      fecha_salida = TO_DATE(:fecha_salida, 'YYYY-MM-DD'),
      fecha_entrega = TO_DATE(:fecha_entrega, 'YYYY-MM-DD'),
      cargo_tardanza = :cargo_tardanza
  WHERE reserva_id = :reserva_id;
END;
