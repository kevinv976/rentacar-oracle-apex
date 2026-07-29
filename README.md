# RentaCar — Sistema de Gestión para Empresa de Alquiler de Autos

![Oracle](https://img.shields.io/badge/Oracle-000000?style=for-the-badge&logo=oracle&logoColor=white)
![PLSQL](https://img.shields.io/badge/PL%2FSQL-000000?style=for-the-badge&logo=oracle&logoColor=white)
![Oracle APEX](https://img.shields.io/badge/Oracle%20APEX-000000?style=for-the-badge&logo=oracle&logoColor=white)
![REST API](https://img.shields.io/badge/REST%20API-000000?style=for-the-badge&logo=json&logoColor=white)
![Postman](https://img.shields.io/badge/Postman-000000?style=for-the-badge&logo=postman&logoColor=white)

Sistema construido sobre Oracle Database y Oracle APEX que resuelve el flujo real de una empresa de alquiler de vehículos: un cliente llega, un cajero lo atiende, se elige un auto disponible, se registra un pago, y se genera una reserva que queda trazable en el sistema. El proyecto cubre las tres capas de una aplicación empresarial construidas de punta a punta: modelo de datos relacional, API REST protegida, e interfaz web de gestión (CRUD).

Este proyecto fue desarrollado como práctica integral de modelado de bases de datos, PL/SQL, ORDS (Oracle REST Data Services) y Oracle APEX, priorizando decisiones de diseño con criterio de negocio real (no solo cumplir un checklist técnico) y seguridad de acceso a los datos.

---

## Tabla de contenido

- [Descripción general](#descripción-general)
- [Instalación](#instalación)
- [Modelo de datos](#modelo-de-datos)
- [Tecnologías utilizadas](#tecnologías-utilizadas)
- [Seguridad](#seguridad)
- [API REST](#api-rest)
- [Aplicación APEX](#aplicación-apex)
- [Aprendizajes clave](#aprendizajes-clave)
- [Posibles mejoras futuras](#posibles-mejoras-futuras)

---

## Descripción general

RentaCar modela el flujo de negocio de una empresa de alquiler de vehículos, donde un cliente alquila un auto, es atendido por un cajero, y asocia un pago a la transacción. El proyecto se construyó siguiendo el proceso real de desarrollo:

1. Modelado conceptual y lógico — identificación de entidades, relaciones y normalización
2. Modelo físico — definición de tipos de datos, claves primarias/foráneas, y restricciones (`CHECK`, `NOT NULL`)
3. API REST — exposición de los datos vía ORDS con operaciones CRUD completas
4. Aplicación web — interfaz de gestión construida en Oracle APEX

---

## Instalación

Los scripts necesarios para reproducir este proyecto están en la carpeta [`/sql`](./sql):

| Archivo | Contenido |
|---|---|
| `01_create_tables.sql` | Creación de las 5 tablas con sus constraints |
| `02_sample_data.sql` | Datos de prueba (autos, cliente, cajero, pagos, reserva) |
| `03_alter_pagos_monto.sql` | Migración: agrega la columna `monto` a `Pagos` |
| `04_api_autos_handlers.sql` | Bloques PL/SQL de los handlers REST del módulo `api.autos` |
| `05_apex_lov_reservas.sql` | Consultas LOV usadas en el formulario de Reservas en APEX |
| `06_api_reservas_handlers.sql` | Bloques PL/SQL de los handlers REST del módulo `api.reservas` |

### Pasos para levantar el proyecto

1. Ejecutar `01_create_tables.sql` en un esquema de Oracle Database (probado en Oracle APEX / Autonomous Database).
2. Ejecutar `02_sample_data.sql` para cargar datos de prueba.
3. En **SQL Workshop → RESTful Services**, crear el módulo `api.autos` con Base Path `/autos/` y configurar los handlers según `04_api_autos_handlers.sql`.
4. Crear el módulo `api.reservas` con Base Path `/reservas/` siguiendo el mismo patrón (ver sección [API REST](#api-rest)).
5. En **App Builder**, crear una aplicación nueva y generar páginas tipo *Form* (con *Include Report*) para cada tabla.
6. En el formulario de Reserva, configurar los 4 ítems de tipo *Select List* usando las consultas de `05_apex_lov_reservas.sql` como *List of Values*.

---

## Modelo de datos

### Entidades

| Tabla | Descripción |
|---|---|
| Auto | Vehículos disponibles para alquiler |
| Client | Clientes de la empresa (identificados por cédula/pasaporte) |
| Cajero | Empleados que atienden las reservas |
| Pagos | Registro de pagos (método, tipo de tarjeta, monto) |
| Reserva | Entidad central: conecta Cliente, Auto, Cajero y Pago en una transacción de alquiler |

### Diagrama entidad-relación (resumen)

```
Client (1) ──────< (N) Reserva (N) >────── (1) Auto
                        │
                        ├──< (N:1) Cajero
                        │
                        └──< (N:1) Pagos
```

### Estructura de tablas

**Auto**
```sql
CREATE TABLE Auto (
    id_placa        VARCHAR2(6)  PRIMARY KEY,
    marca           VARCHAR2(40) NOT NULL,
    modelo          VARCHAR2(40) NOT NULL,
    anio            NUMBER(4)    NOT NULL,
    disponibilidad  CHAR(1)      NOT NULL
                    CHECK (disponibilidad IN ('S','N'))
);
```

**Client**
```sql
CREATE TABLE Client (
    cliente_id           VARCHAR2(20)  PRIMARY KEY, -- cédula o pasaporte
    nombre               VARCHAR2(50)  NOT NULL,
    apellido             VARCHAR2(50)  NOT NULL,
    telefono_celular     VARCHAR2(20)  NOT NULL,
    correo_electronico   VARCHAR2(320) NOT NULL
);
```

**Cajero**
```sql
CREATE TABLE Cajero (
    id_cajero   VARCHAR2(20) PRIMARY KEY, -- cédula o pasaporte
    nombre      VARCHAR2(50) NOT NULL,
    apellido    VARCHAR2(50) NOT NULL
);
```

**Pagos**
```sql
CREATE TABLE Pagos (
    pagos_id       NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    metodo_pago    VARCHAR2(20) NOT NULL
                   CHECK (metodo_pago IN ('TARJETA','EFECTIVO','ACH')),
    tipo_tarjeta   VARCHAR2(30) NULL, -- solo aplica si metodo_pago = 'TARJETA'
    monto          NUMBER(7,2)  NOT NULL
);
```

**Reserva** (entidad central)
```sql
CREATE TABLE Reserva (
    reserva_id       NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    pagos_id         NUMBER        NOT NULL,
    id_placa         VARCHAR2(6)   NOT NULL,
    id_cajero        VARCHAR2(20)  NOT NULL,
    cliente_id       VARCHAR2(20)  NOT NULL,
    fecha_salida     DATE          NOT NULL,
    fecha_entrega    DATE          NOT NULL,
    cargo_tardanza   NUMBER(5,2)   NOT NULL,

    CONSTRAINT fk_reserva_pago    FOREIGN KEY (pagos_id)   REFERENCES Pagos(pagos_id),
    CONSTRAINT fk_reserva_auto    FOREIGN KEY (id_placa)   REFERENCES Auto(id_placa),
    CONSTRAINT fk_reserva_cajero  FOREIGN KEY (id_cajero)  REFERENCES Cajero(id_cajero),
    CONSTRAINT fk_reserva_client  FOREIGN KEY (cliente_id) REFERENCES Client(cliente_id)
);
```

### Decisiones de diseño relevantes

- `cliente_id` e `id_cajero` como VARCHAR2(20): se usó la cédula/pasaporte como clave primaria en vez de un ID interno autoincremental, para reflejar el documento de identidad real de la persona (soporta tanto formatos nacionales como extranjeros).
- `disponibilidad` con CHECK: restringido a `'S'`/`'N'` para evitar inconsistencias de datos libres.
- `metodo_pago` con CHECK: limitado a `'TARJETA'`, `'EFECTIVO'`, `'ACH'`.
- `tipo_tarjeta` nullable: es el único campo opcional del modelo, ya que solo aplica cuando el método de pago es tarjeta.
- IDs autoincrementales (Reserva, Pagos): usando `GENERATED BY DEFAULT AS IDENTITY` (Oracle 12c+), ya que son identificadores puramente internos sin significado en el mundo real.

---

## Tecnologías utilizadas

- Oracle Database — motor de base de datos
- PL/SQL — lógica de negocio en los handlers de la API
- ORDS (Oracle REST Data Services) — exposición de la API REST, con módulos `api.autos` y `api.reservas`
- Oracle APEX — interfaz web de administración (low-code)
- Postman — pruebas de la API

---

## Seguridad

La API está protegida mediante un **Privilege Group** de ORDS (`rentacar_priv`), configurado en RESTful Services:

- El módulo `api.autos` requiere autenticación — cualquier solicitud sin credenciales válidas recibe `401 Unauthorized`.
- El privilegio está asociado a los roles `SQL Developer` y `RESTful Services` del esquema.
- Esto evita que cualquiera con la URL pueda leer, modificar o eliminar datos sin autenticarse primero.

### Decisión de diseño: DELETE en Reserva

El endpoint de Reserva **no implementa `DELETE`** de forma intencional. En un negocio de alquiler real, una reserva no debería eliminarse por completo — se cancela o se marca con un estado, para preservar el historial de transacciones con fines de auditoría y reportes. Eliminar el registro por completo generaría inconsistencias en reportes históricos (ingresos, ocupación de flota, etc.).

> Mejora futura relacionada: agregar una columna `estado` (`ACTIVA`, `CANCELADA`, `COMPLETADA`) en vez de depender de operaciones destructivas.

---

## API REST

Construida con RESTful Services de Oracle APEX / ORDS. Todos los endpoints de `api.autos` requieren autenticación (ver [Seguridad](#seguridad)).

### Endpoints — Autos

| Método | Ruta | Descripción |
|---|---|---|
| GET | /autos/disponibles | Lista todos los autos |
| POST | /autos/disponibles | Crea un auto nuevo (soporta objeto único o arreglo para inserción en lote) |
| GET | /autos/{id_placa} | Consulta un auto específico |
| PUT | /autos/{id_placa} | Actualiza un auto |
| DELETE | /autos/{id_placa} | Elimina un auto |

### Endpoints — Reservas

Expone el flujo central del negocio: la transacción de alquiler que conecta Cliente, Auto, Cajero y Pago.

| Método | Ruta | Descripción |
|---|---|---|
| GET | /reservas/todas | Lista todas las reservas |
| POST | /reservas/todas | Crea una reserva nueva |
| GET | /reservas/{reserva_id} | Consulta una reserva específica |
| PUT | /reservas/{reserva_id} | Actualiza una reserva |

### Ejemplo — Crear una reserva

```http
POST /ords/{workspace}/reservas/todas
Content-Type: application/json

{
  "pagos_id": 4,
  "id_placa": "AB1111",
  "id_cajero": "8-999-1111",
  "cliente_id": "8-123-4567",
  "fecha_salida": "2026-08-01",
  "fecha_entrega": "2026-08-05",
  "cargo_tardanza": 0
}
```

### Ejemplo — Crear un auto

```http
POST /ords/{workspace}/autos/disponibles
Content-Type: application/json

{
  "id_placa": "EF9999",
  "marca": "Kia",
  "modelo": "Rio",
  "anio": 2023
}
```

### Ejemplo — Inserción en lote

El handler POST también soporta recibir un arreglo de autos, procesado con `APEX_JSON` en PL/SQL:

```http
POST /ords/{workspace}/autos/disponibles
Content-Type: application/json

[
  { "id_placa": "AB1111", "marca": "Toyota", "modelo": "Yaris", "anio": 2021 },
  { "id_placa": "AB2222", "marca": "Honda", "modelo": "Civic", "anio": 2022 }
]
```

```sql
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
```

---

## Aplicación APEX

Aplicación RentaCar con 5 módulos de gestión, generados sobre el modelo de datos y personalizados manualmente:

| Módulo | Funcionalidad |
|---|---|
| Autos | CRUD completo, con formato de año corregido (sin separador de miles) |
| Clientes | CRUD completo, con ID (cédula/pasaporte) editable manualmente |
| Cajeros | CRUD completo, con ID (cédula/pasaporte) editable manualmente |
| Pagos | CRUD completo, incluyendo campo `monto` agregado post-creación |
| Reservas | Formulario con 4 listas desplegables (LOV) que traducen IDs técnicos en información legible |

### Selectores inteligentes en Reservas

En vez de escribir manualmente los IDs de Auto, Cliente, Cajero y Pago, el formulario de Reserva usa listas desplegables basadas en consultas SQL dinámicas:

```sql
-- Selector de Auto (solo autos disponibles)
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

-- Selector de Pago
SELECT metodo_pago || ' - $' || monto || ' (ID ' || pagos_id || ')' AS d,
       pagos_id AS r
FROM Pagos
ORDER BY pagos_id DESC;
```

---

## Aprendizajes clave

- Modelado de datos de principio a fin: desde identificar entidades hasta decidir tipos de datos, precisión numérica, y restricciones de integridad.
- Normalización aplicada: eliminar redundancia (por ejemplo, separar tipo de tarjeta de método de pago) y resolver relaciones N:M correctamente mediante una tabla central.
- PL/SQL en contexto de API: bind variables, `APEX_JSON` para procesar arreglos, y manejo de excepciones.
- ALTER TABLE en un modelo ya en producción: agregar una columna (`monto`), rellenar datos existentes, y aplicar `NOT NULL` sin romper integridad.
- Sincronización de metadatos en APEX: cuando el modelo de datos cambia después de crear las páginas, hay que sincronizar las columnas de la región para que la UI las reconozca.
- Debugging metódico: diagnosticar errores como `ORA-01400` (NULL en columna obligatoria) verificando primero la base de datos directamente antes de asumir que el problema está en la capa de API o UI.
- UX en formularios de datos relacionales: convertir claves foráneas en selectores legibles (LOV) en vez de exponer IDs técnicos al usuario final.
- Seguridad de acceso: configurar un Privilege Group en ORDS para exigir autenticación antes de exponer datos sensibles vía API.
- Criterio de negocio sobre completitud técnica: decidir conscientemente omitir una operación (DELETE en Reserva) cuando no tiene sentido para el dominio del problema, en vez de implementarla solo por seguir un patrón CRUD estándar.

---

## Posibles mejoras futuras

- Dashboard de KPIs (autos más rentados, ingresos por mes, ocupación de flota)
- Validación de fechas de reserva (que `fecha_entrega` sea posterior a `fecha_salida`)
- Cálculo automático de `cargo_tardanza` mediante trigger
- Columna `estado` en Reserva para manejar cancelaciones sin borrar registros
- Extender la protección del Privilege Group al módulo `api.reservas`
- Roles diferenciados por tipo de usuario (cajero vs. administrador)
- Historial de mantenimiento de autos como tabla adicional

---

## Autor

Proyecto desarrollado como práctica de preparación técnica para roles de Desarrollador Oracle / PL/SQL.
