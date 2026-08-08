---
title: Notebook 05: JOIN
---

Fuente original: [03_join.sql](https://github.com/krushev36/curso-sql-python/blob/main/sql/notebooks/03_join.sql)

# Notebook 05: JOIN
## Fundamentos de Programación
### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia
## 1. Bienvenida
Bienvenido al Notebook 05 del curso **Fundamentos de Programación** de la **Maestría en Ciencia de Datos e Inteligencia de Negocios** de la **Universidad de Antioquia**.
En esta sesión aprenderás a **combinar información distribuida en varias tablas** para responder preguntas reales del negocio. En el contexto de **DataCorp Analytics**, la dirección comercial necesita un reporte consolidado que conecte clientes, pedidos, productos, proveedores y geografía.
Los `JOIN` son la pieza que hace posible ese análisis integrado.
> **📝 Nota:** En ciencia de datos aplicada al negocio, rara vez toda la información vive en una sola tabla. Dominar `JOIN` es esencial para construir datasets analíticos confiables.
### Ruta de trabajo
1. Entender qué es un `JOIN`.
2. Diferenciar tipos de `JOIN`.
3. Aplicarlos con el esquema TPCH de Databricks.
4. Evitar errores comunes.
5. Resolver preguntas empresariales reales.

## 2. Objetivos de aprendizaje
Al finalizar este notebook serás capaz de:
- Explicar **qué es un `JOIN`** y por qué se utiliza en análisis de datos.
- Aplicar correctamente `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`, `CROSS JOIN` y `SELF JOIN`.
- Construir consultas con **múltiples tablas** usando alias legibles.
- Combinar `JOIN` con `WHERE`, agregaciones y manejo de `NULL`.
- Detectar y corregir errores frecuentes en uniones.
- Traducir necesidades de negocio a consultas SQL reproducibles en Databricks.
| Resultado esperado | Evidencia |
|---|---|
| Identificar la clave de unión correcta | Consulta con `ON` bien definida |
| Seleccionar el tipo de `JOIN` adecuado | Resultado coherente con la pregunta de negocio |
| Integrar 3 o más tablas | Reporte consolidado y trazable |

## 3. Competencias
### Competencias técnicas
- Modelar relaciones entre tablas.
- Interpretar claves primarias y foráneas.
- Diseñar consultas analíticas escalables.
- Validar resultados para evitar duplicados o pérdidas de registros.
### Competencias analíticas
- Formular preguntas de negocio en términos de datos.
- Elegir el nivel correcto de granularidad.
- Explicar resultados a áreas no técnicas.
### Competencias profesionales
- Documentar consultas con claridad.
- Razonar sobre impacto de decisiones técnicas.
- Construir reportes consistentes y auditables.

## 4. Contexto empresarial
Eres **Data Analyst** en **DataCorp Analytics**. El director comercial solicita un tablero donde pueda responder preguntas como:
- ¿Qué clientes generan más pedidos?
- ¿Qué proveedores participan en más ventas?
- ¿Qué regiones concentran más actividad comercial?
- ¿Qué pedidos no tienen detalle asociado o qué clientes no han comprado?
El reto es que la información está repartida en varias tablas del esquema TPCH:
| Tabla | Rol de negocio | Clave relevante |
|---|---|---|
| `customer` | Clientes | `c_custkey`, `c_nationkey` |
| `orders` | Pedidos | `o_orderkey`, `o_custkey` |
| `lineitem` | Detalle del pedido | `l_orderkey`, `l_partkey`, `l_suppkey` |
| `part` | Productos | `p_partkey` |
| `supplier` | Proveedores | `s_suppkey`, `s_nationkey` |
| `nation` | Países | `n_nationkey`, `n_regionkey` |
| `region` | Regiones | `r_regionkey` |
> **📝 Nota:** Un reporte consolidado requiere navegar estas relaciones sin perder el significado de cada nivel: cliente, pedido, línea, producto y proveedor.

## 5. Conceptos
Un `JOIN` permite **combinar filas de dos o más tablas** usando una condición de relación lógica, normalmente una clave.
### ¿Por qué se necesita?
Porque en un modelo relacional:
- la información se normaliza,
- cada tabla representa una entidad diferente,
- y el análisis real exige verlas en conjunto.
### Diagrama de relaciones – esquema `samples.tpch`
El siguiente diagrama muestra las siete tablas del esquema y cómo se conectan mediante llaves primarias (PK) y llaves foráneas (FK).
```text
          ┌────────────────────────────┐
          │           region           │
          │────────────────────────────│
          │ r_regionkey          (PK)  │
          └──────────────┬─────────────┘
                         │ 1:N
          ┌──────────────▼─────────────┐
          │           nation           │
          │────────────────────────────│
          │ n_nationkey          (PK)  │
          │ n_regionkey          (FK)  │
          └───────┬────────────┬───────┘
                  │ 1:N        │ 1:N
     ┌────────────▼──────┐  ┌──▼────────────────────┐
     │      customer     │  │       supplier        │
     │───────────────────│  │───────────────────────│
     │ c_custkey   (PK)  │  │ s_suppkey      (PK)   │
     │ c_nationkey (FK)  │  │ s_nationkey    (FK)   │
     └──────────┬────────┘  └────────────┬──────────┘
                │ 1:N                     │ 1:N
     ┌──────────▼────────┐                │
     │       orders      │                │
     │───────────────────│                │
     │ o_orderkey  (PK)  │                │
     │ o_custkey   (FK)  │                │
     └──────────┬────────┘                │
                │ 1:N                     │
     ┌──────────▼────────────────────────▼─────┐
     │                 lineitem                │
     │─────────────────────────────────────────│
     │ l_orderkey   (FK → orders)              │
     │ l_suppkey    (FK → supplier)            │
     │ l_partkey    (FK → part)                │
     └──────────────────┬──────────────────────┘
                        │ N:1
             ┌──────────▼──────────┐
             │         part        │
             │─────────────────────│
             │ p_partkey     (PK)  │
             └─────────────────────┘
```
**Lectura del diagrama:**
- Una línea `1:N` indica que una fila de la tabla superior puede relacionarse con muchas filas de la tabla inferior.
- `lineitem` es la tabla de mayor granularidad: conecta pedidos, proveedores y productos en una sola fila de detalle.
### Regla práctica
Antes de escribir un `JOIN`, responde tres preguntas:
1. ¿Cuál es la **tabla base**?
2. ¿Cuál es la **clave de relación**?
3. ¿Quiero solo coincidencias o también registros sin coincidencia?

## 5. Conceptos (continuación)
### Diagramas ASCII tipo Venn
#### `INNER JOIN`
```text
  (A) ∩ (B)
Solo la intersección
```
#### `LEFT JOIN`
```text
  (A) + (A ∩ B)
Todo A, coincida o no con B
```
#### `RIGHT JOIN`
```text
  (B) + (A ∩ B)
Todo B, coincida o no con A
```
#### `FULL OUTER JOIN`
```text
  (A) ∪ (B)
Todo A y todo B
```
#### `CROSS JOIN`
```text
  A × B
Todas las combinaciones posibles
```
#### `SELF JOIN`
```text
  A JOIN A
La tabla se relaciona consigo misma
```
> **📝 Nota:** `CROSS JOIN` no usa condición `ON`; por eso debe usarse con extremo cuidado.

## 5. Conceptos (continuación)
### Errores comunes en `JOIN`
| Error | Qué ocurre | Cómo evitarlo |
|---|---|---|
| Unir con clave incorrecta | Resultados absurdos o inflados | Revisar cardinalidad y diccionario de datos |
| Omitir la condición `ON` | Producto cartesiano involuntario | Verificar siempre la lógica de unión |
| Filtrar una tabla derecha en `WHERE` tras un `LEFT JOIN` | Se convierte de hecho en `INNER JOIN` | Mover filtros al `ON` si quieres preservar nulos |
| No usar alias | Consulta difícil de leer y mantener | Definir alias cortos y consistentes |
| Ignorar duplicados naturales | Métricas infladas | Comprender la granularidad de cada tabla |
| No tratar `NULL` | Interpretación ambigua | Usar `COALESCE`, `IS NULL` o etiquetas descriptivas |
### Manejo de `NULL`
Cuando una fila no encuentra pareja en un `OUTER JOIN`, Databricks devuelve `NULL` en las columnas de la tabla faltante.
> **📝 Nota:** `NULL` no significa “cero”; significa “sin dato disponible por la lógica de la unión”.

## 6. Explicación paso a paso
### Método recomendado para construir un `JOIN`
1. **Define la pregunta de negocio.** Ejemplo: “¿Qué clientes tienen pedidos?”
2. **Elige la tabla base.** Si la pregunta gira alrededor del cliente, empieza con `customer`.
3. **Identifica la relación.** `customer.c_custkey = orders.o_custkey`.
4. **Escoge el tipo de `JOIN`.**
   - `INNER` si solo quieres coincidencias.
   - `LEFT` si quieres todos los clientes, incluso sin pedidos.
5. **Selecciona columnas claras.** Evita `SELECT *` cuando el objetivo sea pedagógico o analítico.
6. **Valida la granularidad.** Un cliente puede tener muchos pedidos; un pedido puede tener muchas líneas.
7. **Aplica filtros y agregaciones al final**, asegurando que no rompan el sentido del `JOIN`.

## 6. Explicación paso a paso (continuación)
### Convenciones usadas en este notebook
| Alias | Tabla |
|---|---|
| `c` | `samples.tpch.customer` |
| `o` | `samples.tpch.orders` |
| `l` | `samples.tpch.lineitem` |
| `p` | `samples.tpch.part` |
| `s` | `samples.tpch.supplier` |
| `n` | `samples.tpch.nation` |
| `r` | `samples.tpch.region` |
### Buenas prácticas
- Usa alias para evitar ambigüedad.
- Ordena las columnas según la historia de negocio.
- Limita filas con `LIMIT` cuando el objetivo sea exploratorio.
- Si hay varias tablas, une de forma incremental y verifica resultados parciales.
> **📝 Nota:** En análisis reales, una consulta correcta no es solo la que “ejecuta”, sino la que responde exactamente la pregunta planteada.

## 7. Ejemplo completamente explicado 1 de 5
### `INNER JOIN`: clientes que sí tienen pedidos
**Por qué esta consulta está escrita así:**
- La tabla base es `customer` porque queremos comenzar en el cliente.
- Se usa `INNER JOIN` porque queremos **solo coincidencias** entre clientes y pedidos.
- Se limita la salida para inspección inicial.
**Qué hace cada cláusula:**
- `SELECT`: define las columnas visibles.
- `FROM`: fija la tabla principal.
- `INNER JOIN`: añade solo filas con clave coincidente.
- `ON`: especifica la regla de relación.
- `LIMIT`: reduce el tamaño del resultado para lectura.
**Resultado esperado:** verás clientes acompañados por uno o más pedidos.
**Error común:** unir `c_custkey` con `o_orderkey` en lugar de `o_custkey`.

```sql
SELECT                                                      -- Selecciona las columnas que permiten identificar al cliente y al pedido.
  c.c_custkey,                                              -- Muestra la clave del cliente para reconocer la entidad principal.
  c.c_name,                                                 -- Muestra el nombre del cliente para interpretar el resultado en lenguaje de negocio.
  o.o_orderkey,                                             -- Muestra la clave del pedido asociado al cliente.
  o.o_orderdate                                             -- Muestra la fecha del pedido para agregar contexto temporal.
FROM samples.tpch.customer AS c                             -- Define a customer como tabla base porque la pregunta parte del cliente.
INNER JOIN samples.tpch.orders AS o                         -- Conserva solo filas donde exista correspondencia entre clientes y pedidos.
  ON c.c_custkey = o.o_custkey                              -- Relaciona cada cliente con sus pedidos usando la clave correcta.
LIMIT 20                                                    -- Limita la salida para revisión pedagógica sin perder el patrón del resultado.
```

## 7. Ejemplo completamente explicado 2 de 5
### `LEFT JOIN`: todos los clientes, tengan o no pedidos
**Por qué esta consulta está escrita así:**
- El director comercial puede querer detectar **clientes inactivos**.
- Por eso preservamos todas las filas de `customer`.
- Los pedidos faltantes aparecen como `NULL`.
**Resultado esperado:** algunos clientes pueden mostrar `NULL` en columnas de `orders`.
**Error común:** filtrar luego `o.o_orderkey IS NOT NULL` y perder el sentido del `LEFT JOIN`.

```sql
SELECT                                                      -- Selecciona columnas de cliente y pedido para comparar actividad versus ausencia de actividad.
  c.c_custkey,                                              -- Incluye la clave del cliente para identificar unívocamente cada fila base.
  c.c_name,                                                 -- Incluye el nombre del cliente para lectura de negocio.
  o.o_orderkey,                                             -- Muestra la clave del pedido cuando existe coincidencia.
  o.o_totalprice                                            -- Muestra el valor total del pedido cuando el cliente sí ha comprado.
FROM samples.tpch.customer AS c                             -- Usa customer como tabla izquierda porque queremos conservar todos los clientes.
LEFT JOIN samples.tpch.orders AS o                          -- Devuelve todas las filas de customer y solo los pedidos que coinciden.
  ON c.c_custkey = o.o_custkey                              -- Establece la relación cliente-pedido mediante la clave foránea del pedido.
LIMIT 20                                                    -- Restringe la muestra para revisar visualmente la presencia de valores nulos.
```

## 7. Ejemplo completamente explicado 3 de 5
### `RIGHT JOIN`: todos los pedidos, incluso si faltara información del cliente
**Por qué esta consulta está escrita así:**
- Aunque en TPCH normalmente todo pedido tiene cliente, conceptualmente `RIGHT JOIN` sirve para priorizar la tabla derecha.
- Aquí preservamos la tabla `orders`.
**Resultado esperado:** todos los pedidos estarán presentes; si faltara el cliente, sus columnas aparecerían en `NULL`.
**Error común:** creer que `RIGHT JOIN` hace algo distinto a un `LEFT JOIN` invertido; lógicamente son equivalentes si intercambias el orden de tablas.

```sql
SELECT                                                      -- Selecciona columnas del cliente y del pedido para demostrar la prioridad de la tabla derecha.
  c.c_custkey,                                              -- Muestra la clave del cliente cuando exista correspondencia.
  c.c_name,                                                 -- Muestra el nombre del cliente cuando esté disponible.
  o.o_orderkey,                                             -- Garantiza que cada pedido de la tabla derecha aparezca en la salida.
  o.o_orderstatus                                           -- Añade el estado del pedido para enriquecer la interpretación.
FROM samples.tpch.customer AS c                             -- Coloca customer a la izquierda solo para ilustrar el uso explícito de RIGHT JOIN.
RIGHT JOIN samples.tpch.orders AS o                         -- Conserva todas las filas de orders aunque no encuentren cliente coincidente.
  ON c.c_custkey = o.o_custkey                              -- Usa la relación natural entre cliente y pedido.
LIMIT 20                                                    -- Limita el resultado para inspección controlada.
```

## 7. Ejemplo completamente explicado 4 de 5
### `FULL OUTER JOIN`: coincidencias y no coincidencias de ambos lados
**Por qué esta consulta está escrita así:**
- Es útil para auditoría y control de calidad de datos.
- Permite ver registros huérfanos en cualquiera de las dos tablas.
**Resultado esperado:** una vista unificada donde pueden aparecer `NULL` del lado cliente, del lado pedido o de ninguno.
**Error común:** interpretar `FULL OUTER JOIN` como una unión deduplicada; en realidad respeta la granularidad existente.

```sql
SELECT                                                      -- Selecciona identificadores de ambos lados para detectar coincidencias y ausencias.
  c.c_custkey,                                              -- Muestra la clave del cliente cuando exista en la tabla customer.
  c.c_name,                                                 -- Muestra el nombre del cliente para facilitar auditoría humana.
  o.o_orderkey,                                             -- Muestra la clave del pedido cuando exista en la tabla orders.
  o.o_custkey                                               -- Muestra la clave de cliente almacenada en orders para comparar ambos lados.
FROM samples.tpch.customer AS c                             -- Usa customer como una de las dos tablas a auditar.
FULL OUTER JOIN samples.tpch.orders AS o                    -- Conserva todas las filas de customer y todas las de orders.
  ON c.c_custkey = o.o_custkey                              -- Vincula ambos conjuntos mediante la relación cliente-pedido.
LIMIT 20                                                    -- Reduce la salida para inspeccionar rápidamente combinaciones con y sin match.
```

## 7. Ejemplo completamente explicado 5 de 5
### `SELF JOIN`: clientes del mismo país
**Por qué esta consulta está escrita así:**
- Un `SELF JOIN` compara filas de la misma tabla.
- Aquí buscamos pares de clientes que comparten `nation`.
- Se usa la condición `c1.c_custkey < c2.c_custkey` para evitar duplicados espejo.
**Resultado esperado:** pares de clientes ubicados en la misma nación.
**Error común:** olvidar una condición adicional y generar duplicados o emparejar cada fila consigo misma.

```sql
SELECT                                                      -- Selecciona dos clientes distintos para comparar registros dentro de la misma tabla.
  c1.c_name AS cliente_1,                                   -- Asigna un alias descriptivo al primer cliente del par.
  c2.c_name AS cliente_2,                                   -- Asigna un alias descriptivo al segundo cliente del par.
  c1.c_nationkey                                            -- Muestra la nación compartida que justifica la unión.
FROM samples.tpch.customer AS c1                            -- Usa la primera instancia de customer como primer conjunto de comparación.
INNER JOIN samples.tpch.customer AS c2                      -- Une la tabla consigo misma para encontrar relaciones internas.
  ON c1.c_nationkey = c2.c_nationkey                        -- Relaciona clientes que pertenecen a la misma nación.
 AND c1.c_custkey < c2.c_custkey                            -- Evita emparejar una fila consigo misma y elimina duplicados simétricos.
LIMIT 20                                                    -- Limita la cantidad de pares para revisión didáctica.
```

## 8. Ejemplo guiado 1 de 5
### `CROSS JOIN`: todas las combinaciones posibles
**Objetivo guiado:** comprender el producto cartesiano de forma segura.
**Por qué lo hacemos con subconjuntos:** un `CROSS JOIN` entre tablas grandes crece muy rápido. Por eso primero limitamos a 3 regiones y 3 naciones.
**Resultado esperado:** `3 x 3 = 9` combinaciones.

```sql
WITH regiones AS (                                           -- Crea una tabla temporal pequeña para controlar el tamaño del producto cartesiano.
  SELECT                                                     -- Inicia la subconsulta que obtiene unas pocas regiones.
    r_regionkey,                                             -- Conserva la clave de la región para referencia técnica.
    r_name                                                   -- Conserva el nombre de la región para interpretación de negocio.
  FROM samples.tpch.region                                   -- Toma los datos desde la tabla de regiones del esquema TPCH.
  LIMIT 3                                                    -- Reduce la submuestra a tres filas para mantener la salida manejable.
),                                                           -- Cierra la primera subconsulta común.
naciones AS (                                                -- Crea una segunda tabla temporal pequeña para combinarla con regiones.
  SELECT                                                     -- Inicia la subconsulta que obtiene unas pocas naciones.
    n_nationkey,                                             -- Conserva la clave de nación como identificador técnico.
    n_name                                                   -- Conserva el nombre de nación como atributo descriptivo.
  FROM samples.tpch.nation                                   -- Toma los datos desde la tabla de naciones.
  LIMIT 3                                                    -- Reduce la submuestra a tres filas para controlar el crecimiento del resultado.
)                                                            -- Cierra la segunda subconsulta común.
SELECT                                                       -- Inicia la consulta final que combinará ambos subconjuntos.
  r.r_name AS region,                                        -- Presenta el nombre de la región en una columna legible.
  n.n_name AS nation                                         -- Presenta el nombre de la nación en una segunda columna legible.
FROM regiones AS r                                           -- Define el primer subconjunto como base de combinación.
CROSS JOIN naciones AS n                                     -- Genera todas las combinaciones posibles entre regiones y naciones.
ORDER BY region, nation                                      -- Ordena el resultado para que el patrón cartesiano sea fácil de observar.
LIMIT 9                                                      -- Muestra exactamente las nueve combinaciones esperadas.
```

## 8. Ejemplo guiado 2 de 5
### `JOIN` con `WHERE`: pedidos de alto valor de clientes europeos
**Idea:** primero unimos cliente → nación → región → pedidos; luego filtramos.
**Por qué el filtro está en `WHERE`:** aquí sí queremos restringir el resultado final a Europa y a pedidos de alto valor.
**Resultado esperado:** pedidos de clientes cuya nación pertenece a la región `EUROPE`.

```sql
SELECT                                                      -- Selecciona atributos de cliente, región y pedido para responder una pregunta comercial concreta.
  c.c_name AS cliente,                                      -- Devuelve el nombre del cliente para identificar quién compra.
  n.n_name AS pais,                                         -- Devuelve el país del cliente para contexto geográfico.
  r.r_name AS region,                                       -- Devuelve la región para análisis territorial.
  o.o_orderkey AS pedido,                                  -- Devuelve el identificador del pedido para trazabilidad.
  o.o_totalprice AS valor_pedido                           -- Devuelve el valor monetario del pedido para priorización comercial.
FROM samples.tpch.customer AS c                             -- Toma customer como punto de partida porque el análisis está centrado en clientes.
INNER JOIN samples.tpch.nation AS n                         -- Une la nación del cliente para añadir geografía de nivel país.
  ON c.c_nationkey = n.n_nationkey                          -- Relaciona cada cliente con su nación correspondiente.
INNER JOIN samples.tpch.region AS r                         -- Une la región a partir de la nación para completar la jerarquía geográfica.
  ON n.n_regionkey = r.r_regionkey                          -- Relaciona cada nación con su región.
INNER JOIN samples.tpch.orders AS o                         -- Une los pedidos del cliente para medir actividad comercial.
  ON c.c_custkey = o.o_custkey                              -- Relaciona cliente con pedido mediante la clave correcta.
WHERE r.r_name = 'EUROPE'                                   -- Filtra el resultado final para conservar solo clientes ubicados en Europa.
  AND o.o_totalprice > 300000                               -- Conserva únicamente pedidos de alto valor económico.
ORDER BY valor_pedido DESC                                  -- Ordena de mayor a menor para priorizar los casos más relevantes.
LIMIT 20                                                    -- Limita la salida para revisión inicial del patrón observado.
```

## 8. Ejemplo guiado 3 de 5
### `JOIN` con agregaciones: número de pedidos por cliente
**Idea:** unir y luego resumir.
**Por qué se agrupa por cliente:** queremos pasar de granularidad “pedido” a granularidad “cliente”.
**Resultado esperado:** un ranking de clientes por cantidad de pedidos y valor acumulado.

```sql
SELECT                                                      -- Inicia una consulta agregada para resumir actividad de pedidos a nivel de cliente.
  c.c_custkey,                                              -- Conserva la clave del cliente como identificador del grupo.
  c.c_name,                                                 -- Conserva el nombre del cliente para lectura de negocio del ranking.
  COUNT(o.o_orderkey) AS cantidad_pedidos,                  -- Cuenta cuántos pedidos tiene cada cliente después de la unión.
  SUM(o.o_totalprice) AS valor_total_pedidos                -- Suma el valor monetario total de los pedidos de cada cliente.
FROM samples.tpch.customer AS c                             -- Define customer como tabla base porque el resumen será por cliente.
INNER JOIN samples.tpch.orders AS o                         -- Añade los pedidos que pertenecen a cada cliente.
  ON c.c_custkey = o.o_custkey                              -- Relaciona cliente y pedido usando la clave de cliente en orders.
GROUP BY c.c_custkey, c.c_name                              -- Agrupa por las columnas no agregadas para producir una fila por cliente.
ORDER BY cantidad_pedidos DESC, valor_total_pedidos DESC    -- Ordena por volumen y luego por valor para identificar clientes prioritarios.
LIMIT 20                                                    -- Muestra solo las primeras filas del ranking para facilitar su lectura.
```

## 8. Ejemplo guiado 4 de 5
### Múltiples `JOIN` (3+ tablas): cliente, pedido, producto, proveedor y región
**Idea:** construir una vista transversal de la cadena comercial completa.
**Por qué esta consulta importa:** en un escenario real, la dirección quiere ver en una misma fila quién compró, qué compró, quién lo suministró y desde qué región opera el proveedor.
**Resultado esperado:** una muestra de líneas de pedido enriquecidas de extremo a extremo.

```sql
SELECT                                                      -- Selecciona columnas de varias entidades para construir una vista integral del negocio.
  c.c_name AS cliente,                                      -- Muestra el cliente que realizó el pedido.
  o.o_orderkey AS pedido,                                  -- Muestra el pedido al que pertenece la línea.
  p.p_name AS producto,                                    -- Muestra el producto vendido en la línea del pedido.
  s.s_name AS proveedor,                                   -- Muestra el proveedor que suministra el producto de la línea.
  n.n_name AS pais_proveedor,                              -- Muestra el país del proveedor para análisis geográfico.
  r.r_name AS region_proveedor,                            -- Muestra la región del proveedor para análisis agregado.
  l.l_extendedprice AS valor_linea                         -- Muestra el valor monetario de la línea para medir contribución.
FROM samples.tpch.customer AS c                             -- Parte del cliente para contar la historia desde la demanda.
INNER JOIN samples.tpch.orders AS o                         -- Añade el pedido realizado por el cliente.
  ON c.c_custkey = o.o_custkey                              -- Relaciona cliente con pedido usando la clave de cliente.
INNER JOIN samples.tpch.lineitem AS l                       -- Añade el detalle del pedido para llegar al nivel de línea.
  ON o.o_orderkey = l.l_orderkey                            -- Relaciona pedido con líneas de pedido mediante la clave del pedido.
INNER JOIN samples.tpch.part AS p                           -- Añade el producto asociado a cada línea.
  ON l.l_partkey = p.p_partkey                              -- Relaciona la línea con el catálogo de productos.
INNER JOIN samples.tpch.supplier AS s                       -- Añade el proveedor asociado a la línea.
  ON l.l_suppkey = s.s_suppkey                              -- Relaciona la línea con el proveedor que la abastece.
INNER JOIN samples.tpch.nation AS n                         -- Añade el país del proveedor.
  ON s.s_nationkey = n.n_nationkey                          -- Relaciona proveedor con nación.
INNER JOIN samples.tpch.region AS r                         -- Añade la región del proveedor.
  ON n.n_regionkey = r.r_regionkey                          -- Relaciona nación con región.
LIMIT 20                                                    -- Limita el resultado para inspección educativa de la cadena completa.
```

## 8. Ejemplo guiado 5 de 5
### Manejo de `NULL` tras un `LEFT JOIN`
**Idea:** etiquetar clientes con o sin pedido.
**Por qué usamos `COALESCE`:** transforma un `NULL` técnico en una categoría legible para negocio.
**Resultado esperado:** clientes marcados como `Con pedidos` o `Sin pedidos`.

```sql
SELECT                                                      -- Selecciona atributos del cliente y una etiqueta derivada para interpretación sencilla.
  c.c_custkey,                                              -- Devuelve la clave del cliente para identificación exacta.
  c.c_name,                                                 -- Devuelve el nombre del cliente para uso de negocio.
  COALESCE(CAST(o.o_orderkey AS STRING), 'Sin pedido') AS pedido_referencia, -- Reemplaza un pedido nulo por una etiqueta legible para negocio.
  CASE                                                      -- Inicia una expresión condicional para clasificar la actividad del cliente.
    WHEN o.o_orderkey IS NULL THEN 'Sin pedidos'            -- Marca al cliente como inactivo cuando no existe coincidencia en orders.
    ELSE 'Con pedidos'                                      -- Marca al cliente como activo cuando sí existe al menos un pedido asociado.
  END AS estado_cliente                                     -- Asigna un nombre descriptivo a la clasificación resultante.
FROM samples.tpch.customer AS c                             -- Usa customer como tabla base porque queremos evaluar a todos los clientes.
LEFT JOIN samples.tpch.orders AS o                          -- Mantiene todos los clientes y añade pedidos solo cuando existen.
  ON c.c_custkey = o.o_custkey                              -- Relaciona la clave del cliente con la clave foránea presente en orders.
LIMIT 20                                                    -- Limita la muestra para inspeccionar ambas categorías en pocas filas.
```

## 9. Ejercicio guiado 1 de 5
### Muy Fácil
**Consigna:** listar pedidos con el nombre del cliente y la fecha del pedido.
**Pistas:**
- Tabla base sugerida: `orders`.
- Relación: `o.o_custkey = c.c_custkey`.
- Tipo de unión: `INNER JOIN`.
**Qué debes observar:** cada fila representa un pedido enriquecido con el cliente.

```sql
SELECT                                                      -- Selecciona el identificador del pedido, su fecha y el nombre del cliente asociado.
  o.o_orderkey AS pedido,                                  -- Muestra la clave del pedido para trazabilidad.
  o.o_orderdate AS fecha_pedido,                           -- Muestra la fecha en que fue registrado el pedido.
  c.c_name AS cliente                                      -- Muestra el nombre del cliente que realizó el pedido.
FROM samples.tpch.orders AS o                               -- Usa orders como tabla base porque la consigna está enfocada en pedidos.
INNER JOIN samples.tpch.customer AS c                       -- Añade la información del cliente solo cuando existe correspondencia.
  ON o.o_custkey = c.c_custkey                              -- Relaciona cada pedido con su cliente mediante la clave correcta.
LIMIT 20                                                    -- Limita la salida para revisar rápidamente el patrón correcto del resultado.
```

## 9. Ejercicio guiado 2 de 5
### Fácil
**Consigna:** mostrar todos los proveedores y, cuando exista, su región.
**Pistas:**
- Se necesitan `supplier`, `nation` y `region`.
- El proveedor siempre debe conservarse.
- Usa alias para evitar ambigüedad.
**Qué debes observar:** una fila por proveedor con geografía enriquecida.

```sql
SELECT                                                      -- Selecciona proveedor, país y región para construir un perfil geográfico del proveedor.
  s.s_name AS proveedor,                                   -- Muestra el nombre del proveedor como entidad principal del ejercicio.
  n.n_name AS pais,                                        -- Muestra el país del proveedor cuando existe coincidencia.
  r.r_name AS region                                       -- Muestra la región del proveedor cuando puede derivarse desde la nación.
FROM samples.tpch.supplier AS s                             -- Usa supplier como tabla base porque se deben mostrar todos los proveedores.
LEFT JOIN samples.tpch.nation AS n                          -- Conserva todos los proveedores y añade su país cuando la clave coincide.
  ON s.s_nationkey = n.n_nationkey                          -- Relaciona proveedor con nación a través de la clave de nación.
LEFT JOIN samples.tpch.region AS r                          -- Conserva el resultado previo y añade la región correspondiente.
  ON n.n_regionkey = r.r_regionkey                          -- Relaciona la nación obtenida con su región.
LIMIT 20                                                    -- Restringe la salida a una muestra de lectura rápida.
```

## 9. Ejercicio guiado 3 de 5
### Intermedio
**Consigna:** contar cuántas líneas de pedido tiene cada pedido.
**Pistas:**
- Relación principal: `orders` con `lineitem`.
- Usa `COUNT`.
- Agrupa por la clave del pedido.
**Qué debes observar:** el pedido es la unidad de resumen.

```sql
SELECT                                                      -- Inicia una consulta de resumen para contar líneas por pedido.
  o.o_orderkey AS pedido,                                  -- Conserva la clave del pedido como identificador del grupo.
  COUNT(l.l_orderkey) AS cantidad_lineas                   -- Cuenta cuántas filas de lineitem están asociadas a cada pedido.
FROM samples.tpch.orders AS o                               -- Usa orders como tabla base porque el resultado deseado es por pedido.
INNER JOIN samples.tpch.lineitem AS l                       -- Añade las líneas de detalle que pertenecen a cada pedido.
  ON o.o_orderkey = l.l_orderkey                            -- Relaciona el pedido con sus líneas mediante la clave del pedido.
GROUP BY o.o_orderkey                                       -- Agrupa por pedido para obtener una fila resumen por cada uno.
ORDER BY cantidad_lineas DESC                               -- Ordena de mayor a menor para detectar pedidos con más detalle.
LIMIT 20                                                    -- Muestra solo una muestra inicial del ranking.
```

## 9. Ejercicio guiado 4 de 5
### Intermedio Alto
**Consigna:** obtener productos y proveedores que aparecen juntos en las líneas de pedido.
**Pistas:**
- Usa `lineitem` como puente.
- Relaciona con `part` y `supplier`.
- Observa que la granularidad es la línea del pedido.
**Qué debes observar:** un mismo producto puede aparecer con múltiples proveedores según la línea.

```sql
SELECT                                                      -- Selecciona producto, proveedor y valor de línea para describir la relación comercial observada.
  p.p_name AS producto,                                    -- Muestra el nombre del producto presente en la línea.
  s.s_name AS proveedor,                                   -- Muestra el proveedor asociado a esa misma línea.
  l.l_extendedprice AS valor_linea                         -- Muestra el valor monetario de la línea como medida transaccional.
FROM samples.tpch.lineitem AS l                             -- Usa lineitem como tabla puente porque conecta producto y proveedor.
INNER JOIN samples.tpch.part AS p                           -- Añade el catálogo de productos para traducir la clave de producto a un nombre legible.
  ON l.l_partkey = p.p_partkey                              -- Relaciona cada línea con el producto correspondiente.
INNER JOIN samples.tpch.supplier AS s                       -- Añade el proveedor relacionado con la línea del pedido.
  ON l.l_suppkey = s.s_suppkey                              -- Relaciona la línea con el proveedor usando la clave del proveedor.
LIMIT 20                                                    -- Limita la salida para exploración rápida del patrón de combinación.
```

## 9. Ejercicio guiado 5 de 5
### Desafío guiado
**Consigna:** calcular el valor total vendido por región del proveedor.
**Pistas:**
- Debes recorrer `lineitem -> supplier -> nation -> region`.
- La medida es `l_extendedprice`.
- La agregación final es por región.
**Qué debes observar:** la región del proveedor resume la oferta en la cadena comercial.

```sql
SELECT                                                      -- Inicia una consulta agregada para resumir ventas según la región del proveedor.
  r.r_name AS region_proveedor,                            -- Devuelve el nombre de la región que será la unidad final de análisis.
  SUM(l.l_extendedprice) AS valor_total_vendido            -- Suma el valor de todas las líneas asociadas a proveedores de esa región.
FROM samples.tpch.lineitem AS l                             -- Usa lineitem como fuente de las transacciones monetarias.
INNER JOIN samples.tpch.supplier AS s                       -- Añade el proveedor que participa en cada línea de venta.
  ON l.l_suppkey = s.s_suppkey                              -- Relaciona la línea con su proveedor mediante la clave del proveedor.
INNER JOIN samples.tpch.nation AS n                         -- Añade el país del proveedor para poder llegar a la región.
  ON s.s_nationkey = n.n_nationkey                          -- Relaciona proveedor con nación usando la clave de nación.
INNER JOIN samples.tpch.region AS r                         -- Añade la región que agrupa varios países.
  ON n.n_regionkey = r.r_regionkey                          -- Relaciona nación con región mediante la jerarquía geográfica.
GROUP BY r.r_name                                           -- Agrupa por región para producir un total por cada una.
ORDER BY valor_total_vendido DESC                           -- Ordena de mayor a menor para priorizar las regiones con más ventas.
LIMIT 20                                                    -- Muestra una cantidad pequeña de filas, suficiente para analizar el ranking completo.
```

## 10. Ejercicio individual
Resuelve de forma autónoma los siguientes ejercicios. Avanzan de **Muy Fácil** a **Desafío**.
### 1. Muy Fácil
Lista `c_name` y `o_orderstatus` uniendo clientes con pedidos.
### 2. Fácil
Obtén todos los países y la cantidad de proveedores por país usando `supplier` y `nation`.
### 3. Intermedio
Muestra los pedidos, sus líneas y el nombre del producto usando `orders`, `lineitem` y `part`.
### 4. Intermedio Alto
Identifica clientes de la región `ASIA` y calcula cuántos pedidos tiene cada uno.
### 5. Desafío
Encuentra clientes que no tengan pedidos usando un `LEFT JOIN` y filtrando correctamente los `NULL`.
> **📝 Nota:** Antes de escribir SQL, anota la **tabla base**, la **clave de unión** y la **granularidad final**.

## 11. Desafío
Construye soluciones completas para los siguientes retos avanzados.
### 1. Muy Fácil
Explica con tus palabras cuándo `LEFT JOIN` es mejor que `INNER JOIN` en un tablero comercial.
### 2. Fácil
Diseña una consulta que compare el país del cliente con el país del proveedor en una misma línea de pedido.
### 3. Intermedio
Calcula el ticket promedio por cliente combinando `customer` y `orders`.
### 4. Intermedio Alto
Detecta posibles pérdidas de integridad listando filas huérfanas con `FULL OUTER JOIN` entre `orders` y `customer`.
### 5. Desafío
Construye un dataset analítico que incluya cliente, pedido, producto, proveedor, país del cliente, país del proveedor y región del proveedor.
> **📝 Nota:** Si tu resultado tiene más filas de las esperadas, probablemente el problema sea de granularidad y no del motor SQL.

## Checklist de depuración de `JOIN`
Antes de dar por buena una consulta con múltiples tablas, verifica:
- ¿El número de filas final tiene sentido respecto a la granularidad?
- ¿La clave usada en `ON` corresponde realmente a la relación del modelo?
- ¿Los `NULL` observados son esperados o revelan faltantes?
- ¿El filtro debe ir en `ON` o en `WHERE`?
- ¿Hay duplicados naturales que exijan agregación previa o posterior?
> **📝 Nota:** Esta lista evita dos errores muy costosos en analítica: inflar métricas y excluir registros válidos sin darte cuenta.

## 12. Resumen
En este notebook aprendiste que:
- `JOIN` permite integrar entidades distribuidas en distintas tablas.
- `INNER JOIN` conserva solo coincidencias.
- `LEFT JOIN` y `RIGHT JOIN` preservan uno de los dos lados.
- `FULL OUTER JOIN` sirve para auditoría y conciliación.
- `CROSS JOIN` genera todas las combinaciones y debe usarse con cuidado.
- `SELF JOIN` compara filas de una misma tabla.
- Los alias mejoran legibilidad y mantenimiento.
- `WHERE`, agregaciones y `COALESCE` cambian el significado analítico del resultado.
### Idea clave
Un `JOIN` correcto no depende solo de la sintaxis, sino de entender **qué representa cada tabla y a qué nivel se está analizando el negocio**.

## 13. Laboratorio
Responde estas preguntas empresariales reales para DataCorp Analytics.
1. ¿Cuáles son los **20 clientes** con mayor valor acumulado de pedidos?
2. ¿Qué **regiones de proveedores** concentran más valor vendido?
3. ¿Qué **países de clientes** generan más pedidos?
4. ¿Qué **productos** aparecen con mayor frecuencia en las líneas de pedido?
5. ¿Existen **clientes sin pedidos** que requieran reactivación comercial?
6. ¿Existen **pedidos sin detalle** o anomalías de integridad entre `orders` y `lineitem`?
7. ¿Qué combinación de **cliente + proveedor + región** produce mayor facturación?
8. Usa `samples.nyctaxi.trips` para plantear una analogía: ¿qué columnas podrían requerir un `JOIN` si el catálogo de zonas estuviera en otra tabla?
### Entregable sugerido
| Paso | Evidencia |
|---|---|
| Definición del problema | Pregunta de negocio reescrita en lenguaje de datos |
| Diseño del `JOIN` | Tabla base, claves y tipo de unión |
| Validación | Recuento de filas y revisión de `NULL` |
| Interpretación | Insight accionable para la dirección |

## 14. Autoevaluación
Responde sin ejecutar SQL y luego valida tus respuestas:
1. ¿Qué diferencia conceptual hay entre `INNER JOIN` y `LEFT JOIN`?
2. ¿Por qué un `LEFT JOIN` puede devolver `NULL`?
3. ¿Qué riesgo existe si omites la condición `ON`?
4. ¿Cuándo usarías `FULL OUTER JOIN` en control de calidad de datos?
5. ¿Por qué `lineitem` suele aumentar fuertemente el número de filas?
6. ¿Qué problema resuelven los alias en consultas con muchas tablas?
7. ¿Por qué un filtro en `WHERE` puede cambiar el comportamiento de un `LEFT JOIN`?
8. ¿Qué diferencia hay entre granularidad de pedido y granularidad de línea de pedido?
9. ¿Qué hace `COALESCE` en el contexto de `JOIN`?
10. ¿Qué validación rápida harías para saber si un `JOIN` duplicó filas inesperadamente?
> **📝 Nota:** Si puedes justificar el tipo de `JOIN`, la clave usada y la granularidad final, entonces ya estás pensando como analista de datos relacional.
