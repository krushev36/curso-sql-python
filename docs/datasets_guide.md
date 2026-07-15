# 📊 Guía de Datasets — SQL para Ciencia de Datos usando Databricks

Este documento describe en detalle los datasets disponibles en Databricks que se utilizan a lo largo del curso.

---

## 🗄️ Catálogo: `samples`

Databricks incluye un catálogo llamado `samples` con datasets de ejemplo listos para usar. No se necesita cargar ningún archivo externo.

Para acceder:
```sql
USE CATALOG samples;
```

---

## 📦 Schema: `samples.tpch`

El dataset **TPC-H** es un benchmark estándar de la industria para sistemas de soporte a decisiones (DSS). Modela una empresa de comercio internacional con clientes, órdenes, productos y proveedores a escala global.

### 🔗 Diagrama de Relaciones (ERD simplificado)

```
REGION (5 filas)
  └── NATION (25 filas)
        ├── CUSTOMER (150,000 filas)
        │     └── ORDERS (1,500,000 filas)
        │           └── LINEITEM (6,000,000 filas)
        │                 ├── PART (200,000 filas)
        │                 └── SUPPLIER (10,000 filas)
        └── SUPPLIER (10,000 filas)
```

---

### Tabla: `samples.tpch.customer`

Contiene información de los clientes de la empresa.

```sql
DESCRIBE samples.tpch.customer;
```

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `c_custkey` | BIGINT | Identificador único del cliente (PK) |
| `c_name` | STRING | Nombre del cliente |
| `c_address` | STRING | Dirección |
| `c_nationkey` | BIGINT | Clave de nación (FK → nation) |
| `c_phone` | STRING | Teléfono |
| `c_acctbal` | DOUBLE | Balance de cuenta |
| `c_mktsegment` | STRING | Segmento de mercado (AUTOMOBILE, BUILDING, FURNITURE, MACHINERY, HOUSEHOLD) |
| `c_comment` | STRING | Comentarios |

**Ejemplo de consulta:**
```sql
SELECT c_custkey, c_name, c_mktsegment, c_acctbal
FROM samples.tpch.customer
LIMIT 10;
```

---

### Tabla: `samples.tpch.orders`

Contiene las órdenes de compra realizadas por los clientes.

```sql
DESCRIBE samples.tpch.orders;
```

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `o_orderkey` | BIGINT | Identificador único de la orden (PK) |
| `o_custkey` | BIGINT | Clave del cliente (FK → customer) |
| `o_orderstatus` | STRING | Estado: F (Finalizada), O (Abierta), P (Pendiente) |
| `o_totalprice` | DOUBLE | Precio total de la orden |
| `o_orderdate` | DATE | Fecha de la orden |
| `o_orderpriority` | STRING | Prioridad: 1-URGENT, 2-HIGH, 3-MEDIUM, 4-NOT SPECIFIED, 5-LOW |
| `o_clerk` | STRING | Empleado que procesó la orden |
| `o_shippriority` | INT | Prioridad de envío |
| `o_comment` | STRING | Comentarios |

**Ejemplo de consulta:**
```sql
SELECT o_orderkey, o_custkey, o_orderstatus, o_totalprice, o_orderdate
FROM samples.tpch.orders
WHERE o_orderstatus = 'F'
LIMIT 10;
```

---

### Tabla: `samples.tpch.lineitem`

Es la tabla más grande. Contiene cada línea individual de cada orden.

```sql
DESCRIBE samples.tpch.lineitem;
```

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `l_orderkey` | BIGINT | Clave de la orden (FK → orders) |
| `l_partkey` | BIGINT | Clave del producto (FK → part) |
| `l_suppkey` | BIGINT | Clave del proveedor (FK → supplier) |
| `l_linenumber` | INT | Número de línea en la orden |
| `l_quantity` | DOUBLE | Cantidad |
| `l_extendedprice` | DOUBLE | Precio extendido (cantidad × precio unitario) |
| `l_discount` | DOUBLE | Descuento (0.00 – 0.10) |
| `l_tax` | DOUBLE | Impuesto (0.00 – 0.08) |
| `l_returnflag` | STRING | R (devuelto), A (aceptado), N (ninguno) |
| `l_linestatus` | STRING | O (abierto), F (finalizado) |
| `l_shipdate` | DATE | Fecha de envío |
| `l_commitdate` | DATE | Fecha comprometida |
| `l_receiptdate` | DATE | Fecha de recepción |
| `l_shipinstruct` | STRING | Instrucciones de envío |
| `l_shipmode` | STRING | Modo: AIR, SHIP, RAIL, TRUCK, MAIL, FOB, REG AIR |
| `l_comment` | STRING | Comentarios |

**Métrica clave — Ingresos netos:**
```sql
-- Ingresos = precio_extendido × (1 - descuento) × (1 + impuesto)
SELECT
  l_orderkey,
  l_extendedprice * (1 - l_discount) * (1 + l_tax) AS ingresos_netos
FROM samples.tpch.lineitem
LIMIT 10;
```

---

### Tabla: `samples.tpch.part`

Catálogo de partes/productos.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `p_partkey` | BIGINT | Identificador único del producto (PK) |
| `p_name` | STRING | Nombre del producto |
| `p_mfgr` | STRING | Fabricante |
| `p_brand` | STRING | Marca (Brand#11 … Brand#55) |
| `p_type` | STRING | Tipo (ej: STANDARD ANODIZED BRASS) |
| `p_size` | INT | Tamaño (1–50) |
| `p_container` | STRING | Tipo de empaque |
| `p_retailprice` | DOUBLE | Precio minorista |
| `p_comment` | STRING | Comentarios |

---

### Tabla: `samples.tpch.supplier`

Información de los proveedores.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `s_suppkey` | BIGINT | Identificador único del proveedor (PK) |
| `s_name` | STRING | Nombre del proveedor |
| `s_address` | STRING | Dirección |
| `s_nationkey` | BIGINT | Clave de nación (FK → nation) |
| `s_phone` | STRING | Teléfono |
| `s_acctbal` | DOUBLE | Balance de cuenta |
| `s_comment` | STRING | Comentarios |

---

### Tabla: `samples.tpch.nation`

Lista de 25 naciones.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `n_nationkey` | BIGINT | Identificador único (PK) |
| `n_name` | STRING | Nombre del país |
| `n_regionkey` | BIGINT | Clave de región (FK → region) |
| `n_comment` | STRING | Comentarios |

---

### Tabla: `samples.tpch.region`

5 regiones del mundo.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `r_regionkey` | BIGINT | Identificador único (PK) |
| `r_name` | STRING | Nombre: AFRICA, AMERICA, ASIA, EUROPE, MIDDLE EAST |
| `r_comment` | STRING | Comentarios |

---

## 🚕 Schema: `samples.nyctaxi`

Dataset de viajes de taxi en la ciudad de Nueva York (NYC Taxi & Limousine Commission).

### Tabla: `samples.nyctaxi.trips`

```sql
DESCRIBE samples.nyctaxi.trips;
```

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `tpep_pickup_datetime` | TIMESTAMP | Fecha/hora de recogida |
| `tpep_dropoff_datetime` | TIMESTAMP | Fecha/hora de llegada |
| `passenger_count` | INT | Número de pasajeros |
| `trip_distance` | DOUBLE | Distancia del viaje (millas) |
| `pickup_zip` | INT | Código postal de recogida |
| `dropoff_zip` | INT | Código postal de llegada |
| `rate_code_id` | INT | Código de tarifa |
| `store_and_fwd_flag` | STRING | Bandera store-and-forward |
| `payment_type` | INT | Tipo de pago (1=tarjeta, 2=efectivo, etc.) |
| `fare_amount` | DOUBLE | Tarifa base |
| `extra` | DOUBLE | Cargos extra |
| `mta_tax` | DOUBLE | Impuesto MTA |
| `tip_amount` | DOUBLE | Propina |
| `tolls_amount` | DOUBLE | Peajes |
| `total_amount` | DOUBLE | Total pagado |

**Ejemplo de consulta:**
```sql
SELECT
  YEAR(tpep_pickup_datetime)  AS anio,
  MONTH(tpep_pickup_datetime) AS mes,
  COUNT(*)                    AS total_viajes,
  ROUND(AVG(trip_distance),2) AS distancia_promedio,
  ROUND(AVG(total_amount),2)  AS tarifa_promedio
FROM samples.nyctaxi.trips
GROUP BY 1, 2
ORDER BY 1, 2;
```

---

## 🔍 Comandos de Exploración Útiles

```sql
-- Ver todos los catálogos disponibles
SHOW CATALOGS;

-- Ver schemas dentro del catálogo samples
SHOW SCHEMAS IN samples;

-- Ver tablas dentro de un schema
SHOW TABLES IN samples.tpch;

-- Ver la estructura de una tabla
DESCRIBE samples.tpch.customer;

-- Ver estructura detallada con metadatos
DESCRIBE EXTENDED samples.tpch.orders;

-- Contar filas de una tabla
SELECT COUNT(*) FROM samples.tpch.lineitem;

-- Ver una muestra de datos
SELECT * FROM samples.tpch.customer LIMIT 5;
```

---

## 📈 Relaciones Clave para Análisis

### Join más frecuente en el curso
```sql
-- Unión básica cliente → orden → línea → producto
SELECT
  c.c_name,
  o.o_orderdate,
  p.p_name,
  l.l_quantity,
  l.l_extendedprice
FROM samples.tpch.customer  c
JOIN samples.tpch.orders    o ON c.c_custkey = o.o_custkey
JOIN samples.tpch.lineitem  l ON o.o_orderkey = l.l_orderkey
JOIN samples.tpch.part      p ON l.l_partkey  = p.p_partkey
LIMIT 10;
```

---

*Guía actualizada para Databricks Runtime 13.x+*
