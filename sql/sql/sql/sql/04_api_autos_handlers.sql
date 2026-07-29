
-- RentaCar - Handlers PL/SQL del modulo REST api.autos
-- Modulo: api.autos | Base Path: /autos/
-- Estos bloques se configuran dentro de RESTful Services en
-- APEX (SQL Workshop > RESTful Services), no se ejecutan
-- directamente como script.

-- ------------------------------------------------------------
-- Template: disponibles
-- ------------------------------------------------------------

-- GET  (Source Type: Collection Query)
SELECT id_placa, marca, modelo, anio, disponibilidad
FROM Auto;

-- POST (Source Type: PL/SQL)
-- Soporta un objeto individual o un arreglo (insercion en lote)
DECLARE
  l_body CLOB := :body_text;
BEGIN
  APEX_JSON.parse(l_body);

  FOR i IN 1 .. APEX_JSON.get_count(p_path => '.') LOOP
    INSERT INTO Auto (id_placa, marca, modelo, anio, disponibilidad)
    VALUES (
      APEX_JSON.get_varchar2(p_path => '[%d].id_placa', p0 => i),
      APEX_JSON.get_varchar2(p_path => '[%d].marca', p0 => i),
      APEX_JSON.get_varchar2(p_path => '[%d].modelo', p0 => i),
      APEX_JSON.get_number(p_path => '[%d].anio', p0 => i),
      'S'
    );
  END LOOP;
END;

-- ------------------------------------------------------------
-- Template: {id_placa}
-- ------------------------------------------------------------

-- GET (Source Type: Feed)
SELECT id_placa, marca, modelo, anio, disponibilidad
FROM Auto
WHERE id_placa = :id_placa;

-- PUT (Source Type: PL/SQL)
BEGIN
  UPDATE Auto
  SET marca = :marca,
      modelo = :modelo,
      anio = :anio,
      disponibilidad = :disponibilidad
  WHERE id_placa = :id_placa;
END;

-- DELETE (Source Type: PL/SQL)
BEGIN
  DELETE FROM Auto WHERE id_placa = :id_placa;
END;
