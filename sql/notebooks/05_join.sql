-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Notebook 05: JOIN
-- MAGIC 
-- MAGIC ## 1. Bienvenida
-- MAGIC 
-- MAGIC Bienvenido al Notebook 05 del curso **SQL para Ciencia de Datos usando Databricks**.
-- MAGIC 
-- MAGIC En esta sesión aprenderás a **combinar información distribuida en varias tablas** para responder preguntas reales del negocio. En el contexto de **DataCorp Analytics**, la dirección comercial necesita un reporte consolidado que conecte clientes, pedidos, productos, proveedores y geografía.
-- MAGIC 
-- MAGIC Los `JOIN` son la pieza que hace posible ese análisis integrado.
-- MAGIC 
-- MAGIC > **📝 Nota:** En ciencia de datos aplicada al negocio, rara vez toda la información vive en una sola tabla. Dominar `JOIN` es esencial para construir datasets analíticos confiables.
-- MAGIC 
-- MAGIC ### Ruta de trabajo
-- MAGIC 
-- MAGIC 1. Entender qué es un `JOIN`.
-- MAGIC 2. Diferenciar tipos de `JOIN`.
-- MAGIC 3. Aplicarlos con el esquema TPCH de Databricks.
-- MAGIC 4. Evitar errores comunes.
-- MAGIC 5. Resolver preguntas empresariales reales.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC 
-- MAGIC Al finalizar este notebook serás capaz de:
-- MAGIC 
-- MAGIC - Explicar **qué es un `JOIN`** y por qué se utiliza en análisis de datos.
-- MAGIC - Aplicar correctamente `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`, `CROSS JOIN` y `SELF JOIN`.
-- MAGIC - Construir consultas con **múltiples tablas** usando alias legibles.
-- MAGIC - Combinar `JOIN` con `WHERE`, agregaciones y manejo de `NULL`.
-- MAGIC - Detectar y corregir errores frecuentes en uniones.
-- MAGIC - Traducir necesidades de negocio a consultas SQL reproducibles en Databricks.
-- MAGIC 
-- MAGIC | Resultado esperado | Evidencia |
-- MAGIC |---|---|
-- MAGIC | Identificar la clave de unión correcta | Consulta con `ON` bien definida |
-- MAGIC | Seleccionar el tipo de `JOIN` adecuado | Resultado coherente con la pregunta de negocio |
-- MAGIC | Integrar 3 o más tablas | Reporte consolidado y trazable |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias
-- MAGIC 
-- MAGIC ### Competencias técnicas
-- MAGIC 
-- MAGIC - Modelar relaciones entre tablas.
-- MAGIC - Interpretar claves primarias y foráneas.
-- MAGIC - Diseñar consultas analíticas escalables.
-- MAGIC - Validar resultados para evitar duplicados o pérdidas de registros.
-- MAGIC 
-- MAGIC ### Competencias analíticas
-- MAGIC 
-- MAGIC - Formular preguntas de negocio en términos de datos.
-- MAGIC - Elegir el nivel correcto de granularidad.
-- MAGIC - Explicar resultados a áreas no técnicas.
-- MAGIC 
-- MAGIC ### Competencias profesionales
-- MAGIC 
-- MAGIC - Documentar consultas con claridad.
-- MAGIC - Razonar sobre impacto de decisiones técnicas.
-- MAGIC - Construir reportes consistentes y auditables.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC 
-- MAGIC Eres **Data Analyst** en **DataCorp Analytics**. El director comercial solicita un tablero donde pueda responder preguntas como:
-- MAGIC 
-- MAGIC - ¿Qué clientes generan más pedidos?
-- MAGIC - ¿Qué proveedores participan en más ventas?
-- MAGIC - ¿Qué regiones concentran más actividad comercial?
-- MAGIC - ¿Qué pedidos no tienen detalle asociado o qué clientes no han comprado?
-- MAGIC 
-- MAGIC El reto es que la información está repartida en varias tablas del esquema TPCH:
-- MAGIC 
-- MAGIC | Tabla | Rol de negocio | Clave relevante |
-- MAGIC |---|---|---|
-- MAGIC | `customer` | Clientes | `c_custkey`, `c_nationkey` |
-- MAGIC | `orders` | Pedidos | `o_orderkey`, `o_custkey` |
-- MAGIC | `lineitem` | Detalle del pedido | `l_orderkey`, `l_partkey`, `l_suppkey` |
-- MAGIC | `part` | Productos | `p_partkey` |
-- MAGIC | `supplier` | Proveedores | `s_suppkey`, `s_nationkey` |
-- MAGIC | `nation` | Países | `n_nationkey`, `n_regionkey` |
-- MAGIC | `region` | Regiones | `r_regionkey` |
-- MAGIC 
-- MAGIC > **📝 Nota:** Un reporte consolidado requiere navegar estas relaciones sin perder el significado de cada nivel: cliente, pedido, línea, producto y proveedor.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos
-- MAGIC 
-- MAGIC Un `JOIN` permite **combinar filas de dos o más tablas** usando una condición de relación lógica, normalmente una clave.
-- MAGIC 
-- MAGIC ### ¿Por qué se necesita?
-- MAGIC 
-- MAGIC Porque en un modelo relacional:
-- MAGIC 
-- MAGIC - la información se normaliza,
-- MAGIC - cada tabla representa una entidad diferente,
-- MAGIC - y el análisis real exige verlas en conjunto.
-- MAGIC 
-- MAGIC ### Relación TPCH del notebook
-- MAGIC 
-- MAGIC ```text
-- MAGIC customer.c_custkey  -> orders.o_custkey
-- MAGIC orders.o_orderkey   -> lineitem.l_orderkey
-- MAGIC lineitem.l_partkey  -> part.p_partkey
-- MAGIC lineitem.l_suppkey  -> supplier.s_suppkey
-- MAGIC supplier.s_nationkey -> nation.n_nationkey
-- MAGIC nation.n_regionkey  -> region.r_regionkey
-- MAGIC customer.c_nationkey -> nation.n_nationkey
-- MAGIC ```
-- MAGIC 
-- MAGIC ### Regla práctica
-- MAGIC 
-- MAGIC Antes de escribir un `JOIN`, responde tres preguntas:
-- MAGIC 
-- MAGIC 1. ¿Cuál es la **tabla base**?
-- MAGIC 2. ¿Cuál es la **clave de relación**?
-- MAGIC 3. ¿Quiero solo coincidencias o también registros sin coincidencia?
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos (continuación)
-- MAGIC 
-- MAGIC ### Diagramas ASCII tipo Venn
-- MAGIC 
-- MAGIC #### `INNER JOIN`
-- MAGIC ```text
-- MAGIC   (A) ∩ (B)
-- MAGIC Solo la intersección
-- MAGIC ```
-- MAGIC 
-- MAGIC #### `LEFT JOIN`
-- MAGIC ```text
-- MAGIC   (A) + (A ∩ B)
-- MAGIC Todo A, coincida o no con B
-- MAGIC ```
-- MAGIC 
-- MAGIC #### `RIGHT JOIN`
-- MAGIC ```text
-- MAGIC   (B) + (A ∩ B)
-- MAGIC Todo B, coincida o no con A
-- MAGIC ```
-- MAGIC 
-- MAGIC #### `FULL OUTER JOIN`
-- MAGIC ```text
-- MAGIC   (A) ∪ (B)
-- MAGIC Todo A y todo B
-- MAGIC ```
-- MAGIC 
-- MAGIC #### `CROSS JOIN`
-- MAGIC ```text
-- MAGIC   A × B
-- MAGIC Todas las combinaciones posibles
-- MAGIC ```
-- MAGIC 
-- MAGIC #### `SELF JOIN`
-- MAGIC ```text
-- MAGIC   A JOIN A
-- MAGIC La tabla se relaciona consigo misma
-- MAGIC ```
-- MAGIC 
-- MAGIC > **📝 Nota:** `CROSS JOIN` no usa condición `ON`; por eso debe usarse con extremo cuidado.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos (continuación)
-- MAGIC 
-- MAGIC ### Errores comunes en `JOIN`
-- MAGIC 
-- MAGIC | Error | Qué ocurre | Cómo evitarlo |
-- MAGIC |---|---|---|
-- MAGIC | Unir con clave incorrecta | Resultados absurdos o inflados | Revisar cardinalidad y diccionario de datos |
-- MAGIC | Omitir la condición `ON` | Producto cartesiano involuntario | Verificar siempre la lógica de unión |
-- MAGIC | Filtrar una tabla derecha en `WHERE` tras un `LEFT JOIN` | Se convierte de hecho en `INNER JOIN` | Mover filtros al `ON` si quieres preservar nulos |
-- MAGIC | No usar alias | Consulta difícil de leer y mantener | Definir alias cortos y consistentes |
-- MAGIC | Ignorar duplicados naturales | Métricas infladas | Comprender la granularidad de cada tabla |
-- MAGIC | No tratar `NULL` | Interpretación ambigua | Usar `COALESCE`, `IS NULL` o etiquetas descriptivas |
-- MAGIC 
-- MAGIC ### Manejo de `NULL`
-- MAGIC 
-- MAGIC Cuando una fila no encuentra pareja en un `OUTER JOIN`, Databricks devuelve `NULL` en las columnas de la tabla faltante.
-- MAGIC 
-- MAGIC > **📝 Nota:** `NULL` no significa “cero”; significa “sin dato disponible por la lógica de la unión”.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso
-- MAGIC 
-- MAGIC ### Método recomendado para construir un `JOIN`
-- MAGIC 
-- MAGIC 1. **Define la pregunta de negocio.** Ejemplo: “¿Qué clientes tienen pedidos?”
-- MAGIC 2. **Elige la tabla base.** Si la pregunta gira alrededor del cliente, empieza con `customer`.
-- MAGIC 3. **Identifica la relación.** `customer.c_custkey = orders.o_custkey`.
-- MAGIC 4. **Escoge el tipo de `JOIN`.**
-- MAGIC    - `INNER` si solo quieres coincidencias.
-- MAGIC    - `LEFT` si quieres todos los clientes, incluso sin pedidos.
-- MAGIC 5. **Selecciona columnas claras.** Evita `SELECT *` cuando el objetivo sea pedagógico o analítico.
-- MAGIC 6. **Valida la granularidad.** Un cliente puede tener muchos pedidos; un pedido puede tener muchas líneas.
-- MAGIC 7. **Aplica filtros y agregaciones al final**, asegurando que no rompan el sentido del `JOIN`.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso (continuación)
-- MAGIC 
-- MAGIC ### Convenciones usadas en este notebook
-- MAGIC 
-- MAGIC | Alias | Tabla |
-- MAGIC |---|---|
-- MAGIC | `c` | `samples.tpch.customer` |
-- MAGIC | `o` | `samples.tpch.orders` |
-- MAGIC | `l` | `samples.tpch.lineitem` |
-- MAGIC | `p` | `samples.tpch.part` |
-- MAGIC | `s` | `samples.tpch.supplier` |
-- MAGIC | `n` | `samples.tpch.nation` |
-- MAGIC | `r` | `samples.tpch.region` |
-- MAGIC 
-- MAGIC ### Buenas prácticas
-- MAGIC 
-- MAGIC - Usa alias para evitar ambigüedad.
-- MAGIC - Ordena las columnas según la historia de negocio.
-- MAGIC - Limita filas con `LIMIT` cuando el objetivo sea exploratorio.
-- MAGIC - Si hay varias tablas, une de forma incremental y verifica resultados parciales.
-- MAGIC 
-- MAGIC > **📝 Nota:** En análisis reales, una consulta correcta no es solo la que “ejecuta”, sino la que responde exactamente la pregunta planteada.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 1 de 5
-- MAGIC 
-- MAGIC ### `INNER JOIN`: clientes que sí tienen pedidos
-- MAGIC 
-- MAGIC **Por qué esta consulta está escrita así:**
-- MAGIC 
-- MAGIC - La tabla base es `customer` porque queremos comenzar en el cliente.
-- MAGIC - Se usa `INNER JOIN` porque queremos **solo coincidencias** entre clientes y pedidos.
-- MAGIC - Se limita la salida para inspección inicial.
-- MAGIC 
-- MAGIC **Qué hace cada cláusula:**
-- MAGIC 
-- MAGIC - `SELECT`: define las columnas visibles.
-- MAGIC - `FROM`: fija la tabla principal.
-- MAGIC - `INNER JOIN`: añade solo filas con clave coincidente.
-- MAGIC - `ON`: especifica la regla de relación.
-- MAGIC - `LIMIT`: reduce el tamaño del resultado para lectura.
-- MAGIC 
-- MAGIC **Resultado esperado:** verás clientes acompañados por uno o más pedidos.
-- MAGIC 
-- MAGIC **Error común:** unir `c_custkey` con `o_orderkey` en lugar de `o_custkey`.
-- COMMAND ----------
SELECT                                                      -- Selecciona las columnas que permiten identificar al cliente y al pedido.
  c.c_custkey,                                              -- Muestra la clave del cliente para reconocer la entidad principal.
  c.c_name,                                                 -- Muestra el nombre del cliente para interpretar el resultado en lenguaje de negocio.
  o.o_orderkey,                                             -- Muestra la clave del pedido asociado al cliente.
  o.o_orderdate                                             -- Muestra la fecha del pedido para agregar contexto temporal.
FROM samples.tpch.customer AS c                             -- Define a customer como tabla base porque la pregunta parte del cliente.
INNER JOIN samples.tpch.orders AS o                         -- Conserva solo filas donde exista correspondencia entre clientes y pedidos.
  ON c.c_custkey = o.o_custkey                              -- Relaciona cada cliente con sus pedidos usando la clave correcta.
LIMIT 20                                                    -- Limita la salida para revisión pedagógica sin perder el patrón del resultado.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 2 de 5
-- MAGIC 
-- MAGIC ### `LEFT JOIN`: todos los clientes, tengan o no pedidos
-- MAGIC 
-- MAGIC **Por qué esta consulta está escrita así:**
-- MAGIC 
-- MAGIC - El director comercial puede querer detectar **clientes inactivos**.
-- MAGIC - Por eso preservamos todas las filas de `customer`.
-- MAGIC - Los pedidos faltantes aparecen como `NULL`.
-- MAGIC 
-- MAGIC **Resultado esperado:** algunos clientes pueden mostrar `NULL` en columnas de `orders`.
-- MAGIC 
-- MAGIC **Error común:** filtrar luego `o.o_orderkey IS NOT NULL` y perder el sentido del `LEFT JOIN`.
-- COMMAND ----------
SELECT                                                      -- Selecciona columnas de cliente y pedido para comparar actividad versus ausencia de actividad.
  c.c_custkey,                                              -- Incluye la clave del cliente para identificar unívocamente cada fila base.
  c.c_name,                                                 -- Incluye el nombre del cliente para lectura de negocio.
  o.o_orderkey,                                             -- Muestra la clave del pedido cuando existe coincidencia.
  o.o_totalprice                                            -- Muestra el valor total del pedido cuando el cliente sí ha comprado.
FROM samples.tpch.customer AS c                             -- Usa customer como tabla izquierda porque queremos conservar todos los clientes.
LEFT JOIN samples.tpch.orders AS o                          -- Devuelve todas las filas de customer y solo los pedidos que coinciden.
  ON c.c_custkey = o.o_custkey                              -- Establece la relación cliente-pedido mediante la clave foránea del pedido.
LIMIT 20                                                    -- Restringe la muestra para revisar visualmente la presencia de valores nulos.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 3 de 5
-- MAGIC 
-- MAGIC ### `RIGHT JOIN`: todos los pedidos, incluso si faltara información del cliente
-- MAGIC 
-- MAGIC **Por qué esta consulta está escrita así:**
-- MAGIC 
-- MAGIC - Aunque en TPCH normalmente todo pedido tiene cliente, conceptualmente `RIGHT JOIN` sirve para priorizar la tabla derecha.
-- MAGIC - Aquí preservamos la tabla `orders`.
-- MAGIC 
-- MAGIC **Resultado esperado:** todos los pedidos estarán presentes; si faltara el cliente, sus columnas aparecerían en `NULL`.
-- MAGIC 
-- MAGIC **Error común:** creer que `RIGHT JOIN` hace algo distinto a un `LEFT JOIN` invertido; lógicamente son equivalentes si intercambias el orden de tablas.
-- COMMAND ----------
SELECT                                                      -- Selecciona columnas del cliente y del pedido para demostrar la prioridad de la tabla derecha.
  c.c_custkey,                                              -- Muestra la clave del cliente cuando exista correspondencia.
  c.c_name,                                                 -- Muestra el nombre del cliente cuando esté disponible.
  o.o_orderkey,                                             -- Garantiza que cada pedido de la tabla derecha aparezca en la salida.
  o.o_orderstatus                                           -- Añade el estado del pedido para enriquecer la interpretación.
FROM samples.tpch.customer AS c                             -- Coloca customer a la izquierda solo para ilustrar el uso explícito de RIGHT JOIN.
RIGHT JOIN samples.tpch.orders AS o                         -- Conserva todas las filas de orders aunque no encuentren cliente coincidente.
  ON c.c_custkey = o.o_custkey                              -- Usa la relación natural entre cliente y pedido.
LIMIT 20                                                    -- Limita el resultado para inspección controlada.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 4 de 5
-- MAGIC 
-- MAGIC ### `FULL OUTER JOIN`: coincidencias y no coincidencias de ambos lados
-- MAGIC 
-- MAGIC **Por qué esta consulta está escrita así:**
-- MAGIC 
-- MAGIC - Es útil para auditoría y control de calidad de datos.
-- MAGIC - Permite ver registros huérfanos en cualquiera de las dos tablas.
-- MAGIC 
-- MAGIC **Resultado esperado:** una vista unificada donde pueden aparecer `NULL` del lado cliente, del lado pedido o de ninguno.
-- MAGIC 
-- MAGIC **Error común:** interpretar `FULL OUTER JOIN` como una unión deduplicada; en realidad respeta la granularidad existente.
-- COMMAND ----------
SELECT                                                      -- Selecciona identificadores de ambos lados para detectar coincidencias y ausencias.
  c.c_custkey,                                              -- Muestra la clave del cliente cuando exista en la tabla customer.
  c.c_name,                                                 -- Muestra el nombre del cliente para facilitar auditoría humana.
  o.o_orderkey,                                             -- Muestra la clave del pedido cuando exista en la tabla orders.
  o.o_custkey                                               -- Muestra la clave de cliente almacenada en orders para comparar ambos lados.
FROM samples.tpch.customer AS c                             -- Usa customer como una de las dos tablas a auditar.
FULL OUTER JOIN samples.tpch.orders AS o                    -- Conserva todas las filas de customer y todas las de orders.
  ON c.c_custkey = o.o_custkey                              -- Vincula ambos conjuntos mediante la relación cliente-pedido.
LIMIT 20                                                    -- Reduce la salida para inspeccionar rápidamente combinaciones con y sin match.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 5 de 5
-- MAGIC 
-- MAGIC ### `SELF JOIN`: clientes del mismo país
-- MAGIC 
-- MAGIC **Por qué esta consulta está escrita así:**
-- MAGIC 
-- MAGIC - Un `SELF JOIN` compara filas de la misma tabla.
-- MAGIC - Aquí buscamos pares de clientes que comparten `nation`.
-- MAGIC - Se usa la condición `c1.c_custkey < c2.c_custkey` para evitar duplicados espejo.
-- MAGIC 
-- MAGIC **Resultado esperado:** pares de clientes ubicados en la misma nación.
-- MAGIC 
-- MAGIC **Error común:** olvidar una condición adicional y generar duplicados o emparejar cada fila consigo misma.
-- COMMAND ----------
SELECT                                                      -- Selecciona dos clientes distintos para comparar registros dentro de la misma tabla.
  c1.c_name AS cliente_1,                                   -- Asigna un alias descriptivo al primer cliente del par.
  c2.c_name AS cliente_2,                                   -- Asigna un alias descriptivo al segundo cliente del par.
  c1.c_nationkey                                            -- Muestra la nación compartida que justifica la unión.
FROM samples.tpch.customer AS c1                            -- Usa la primera instancia de customer como primer conjunto de comparación.
INNER JOIN samples.tpch.customer AS c2                      -- Une la tabla consigo misma para encontrar relaciones internas.
  ON c1.c_nationkey = c2.c_nationkey                        -- Relaciona clientes que pertenecen a la misma nación.
 AND c1.c_custkey < c2.c_custkey                            -- Evita emparejar una fila consigo misma y elimina duplicados simétricos.
LIMIT 20                                                    -- Limita la cantidad de pares para revisión didáctica.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 1 de 5
-- MAGIC 
-- MAGIC ### `CROSS JOIN`: todas las combinaciones posibles
-- MAGIC 
-- MAGIC **Objetivo guiado:** comprender el producto cartesiano de forma segura.
-- MAGIC 
-- MAGIC **Por qué lo hacemos con subconjuntos:** un `CROSS JOIN` entre tablas grandes crece muy rápido. Por eso primero limitamos a 3 regiones y 3 naciones.
-- MAGIC 
-- MAGIC **Resultado esperado:** `3 x 3 = 9` combinaciones.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 2 de 5
-- MAGIC 
-- MAGIC ### `JOIN` con `WHERE`: pedidos de alto valor de clientes europeos
-- MAGIC 
-- MAGIC **Idea:** primero unimos cliente → nación → región → pedidos; luego filtramos.
-- MAGIC 
-- MAGIC **Por qué el filtro está en `WHERE`:** aquí sí queremos restringir el resultado final a Europa y a pedidos de alto valor.
-- MAGIC 
-- MAGIC **Resultado esperado:** pedidos de clientes cuya nación pertenece a la región `EUROPE`.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 3 de 5
-- MAGIC 
-- MAGIC ### `JOIN` con agregaciones: número de pedidos por cliente
-- MAGIC 
-- MAGIC **Idea:** unir y luego resumir.
-- MAGIC 
-- MAGIC **Por qué se agrupa por cliente:** queremos pasar de granularidad “pedido” a granularidad “cliente”.
-- MAGIC 
-- MAGIC **Resultado esperado:** un ranking de clientes por cantidad de pedidos y valor acumulado.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 4 de 5
-- MAGIC 
-- MAGIC ### Múltiples `JOIN` (3+ tablas): cliente, pedido, producto, proveedor y región
-- MAGIC 
-- MAGIC **Idea:** construir una vista transversal de la cadena comercial completa.
-- MAGIC 
-- MAGIC **Por qué esta consulta importa:** en un escenario real, la dirección quiere ver en una misma fila quién compró, qué compró, quién lo suministró y desde qué región opera el proveedor.
-- MAGIC 
-- MAGIC **Resultado esperado:** una muestra de líneas de pedido enriquecidas de extremo a extremo.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 5 de 5
-- MAGIC 
-- MAGIC ### Manejo de `NULL` tras un `LEFT JOIN`
-- MAGIC 
-- MAGIC **Idea:** etiquetar clientes con o sin pedido.
-- MAGIC 
-- MAGIC **Por qué usamos `COALESCE`:** transforma un `NULL` técnico en una categoría legible para negocio.
-- MAGIC 
-- MAGIC **Resultado esperado:** clientes marcados como `Con pedidos` o `Sin pedidos`.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 1 de 5
-- MAGIC 
-- MAGIC ### Muy Fácil
-- MAGIC 
-- MAGIC **Consigna:** listar pedidos con el nombre del cliente y la fecha del pedido.
-- MAGIC 
-- MAGIC **Pistas:**
-- MAGIC 
-- MAGIC - Tabla base sugerida: `orders`.
-- MAGIC - Relación: `o.o_custkey = c.c_custkey`.
-- MAGIC - Tipo de unión: `INNER JOIN`.
-- MAGIC 
-- MAGIC **Qué debes observar:** cada fila representa un pedido enriquecido con el cliente.
-- COMMAND ----------
SELECT                                                      -- Selecciona el identificador del pedido, su fecha y el nombre del cliente asociado.
  o.o_orderkey AS pedido,                                  -- Muestra la clave del pedido para trazabilidad.
  o.o_orderdate AS fecha_pedido,                           -- Muestra la fecha en que fue registrado el pedido.
  c.c_name AS cliente                                      -- Muestra el nombre del cliente que realizó el pedido.
FROM samples.tpch.orders AS o                               -- Usa orders como tabla base porque la consigna está enfocada en pedidos.
INNER JOIN samples.tpch.customer AS c                       -- Añade la información del cliente solo cuando existe correspondencia.
  ON o.o_custkey = c.c_custkey                              -- Relaciona cada pedido con su cliente mediante la clave correcta.
LIMIT 20                                                    -- Limita la salida para revisar rápidamente el patrón correcto del resultado.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 2 de 5
-- MAGIC 
-- MAGIC ### Fácil
-- MAGIC 
-- MAGIC **Consigna:** mostrar todos los proveedores y, cuando exista, su región.
-- MAGIC 
-- MAGIC **Pistas:**
-- MAGIC 
-- MAGIC - Se necesitan `supplier`, `nation` y `region`.
-- MAGIC - El proveedor siempre debe conservarse.
-- MAGIC - Usa alias para evitar ambigüedad.
-- MAGIC 
-- MAGIC **Qué debes observar:** una fila por proveedor con geografía enriquecida.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 3 de 5
-- MAGIC 
-- MAGIC ### Intermedio
-- MAGIC 
-- MAGIC **Consigna:** contar cuántas líneas de pedido tiene cada pedido.
-- MAGIC 
-- MAGIC **Pistas:**
-- MAGIC 
-- MAGIC - Relación principal: `orders` con `lineitem`.
-- MAGIC - Usa `COUNT`.
-- MAGIC - Agrupa por la clave del pedido.
-- MAGIC 
-- MAGIC **Qué debes observar:** el pedido es la unidad de resumen.
-- COMMAND ----------
SELECT                                                      -- Inicia una consulta de resumen para contar líneas por pedido.
  o.o_orderkey AS pedido,                                  -- Conserva la clave del pedido como identificador del grupo.
  COUNT(l.l_orderkey) AS cantidad_lineas                   -- Cuenta cuántas filas de lineitem están asociadas a cada pedido.
FROM samples.tpch.orders AS o                               -- Usa orders como tabla base porque el resultado deseado es por pedido.
INNER JOIN samples.tpch.lineitem AS l                       -- Añade las líneas de detalle que pertenecen a cada pedido.
  ON o.o_orderkey = l.l_orderkey                            -- Relaciona el pedido con sus líneas mediante la clave del pedido.
GROUP BY o.o_orderkey                                       -- Agrupa por pedido para obtener una fila resumen por cada uno.
ORDER BY cantidad_lineas DESC                               -- Ordena de mayor a menor para detectar pedidos con más detalle.
LIMIT 20                                                    -- Muestra solo una muestra inicial del ranking.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 4 de 5
-- MAGIC 
-- MAGIC ### Intermedio Alto
-- MAGIC 
-- MAGIC **Consigna:** obtener productos y proveedores que aparecen juntos en las líneas de pedido.
-- MAGIC 
-- MAGIC **Pistas:**
-- MAGIC 
-- MAGIC - Usa `lineitem` como puente.
-- MAGIC - Relaciona con `part` y `supplier`.
-- MAGIC - Observa que la granularidad es la línea del pedido.
-- MAGIC 
-- MAGIC **Qué debes observar:** un mismo producto puede aparecer con múltiples proveedores según la línea.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 5 de 5
-- MAGIC 
-- MAGIC ### Desafío guiado
-- MAGIC 
-- MAGIC **Consigna:** calcular el valor total vendido por región del proveedor.
-- MAGIC 
-- MAGIC **Pistas:**
-- MAGIC 
-- MAGIC - Debes recorrer `lineitem -> supplier -> nation -> region`.
-- MAGIC - La medida es `l_extendedprice`.
-- MAGIC - La agregación final es por región.
-- MAGIC 
-- MAGIC **Qué debes observar:** la región del proveedor resume la oferta en la cadena comercial.
-- COMMAND ----------
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
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Ejercicio individual
-- MAGIC 
-- MAGIC Resuelve de forma autónoma los siguientes ejercicios. Avanzan de **Muy Fácil** a **Desafío**.
-- MAGIC 
-- MAGIC ### 1. Muy Fácil
-- MAGIC Lista `c_name` y `o_orderstatus` uniendo clientes con pedidos.
-- MAGIC 
-- MAGIC ### 2. Fácil
-- MAGIC Obtén todos los países y la cantidad de proveedores por país usando `supplier` y `nation`.
-- MAGIC 
-- MAGIC ### 3. Intermedio
-- MAGIC Muestra los pedidos, sus líneas y el nombre del producto usando `orders`, `lineitem` y `part`.
-- MAGIC 
-- MAGIC ### 4. Intermedio Alto
-- MAGIC Identifica clientes de la región `ASIA` y calcula cuántos pedidos tiene cada uno.
-- MAGIC 
-- MAGIC ### 5. Desafío
-- MAGIC Encuentra clientes que no tengan pedidos usando un `LEFT JOIN` y filtrando correctamente los `NULL`.
-- MAGIC 
-- MAGIC > **📝 Nota:** Antes de escribir SQL, anota la **tabla base**, la **clave de unión** y la **granularidad final**.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Desafío
-- MAGIC 
-- MAGIC Construye soluciones completas para los siguientes retos avanzados.
-- MAGIC 
-- MAGIC ### 1. Muy Fácil
-- MAGIC Explica con tus palabras cuándo `LEFT JOIN` es mejor que `INNER JOIN` en un tablero comercial.
-- MAGIC 
-- MAGIC ### 2. Fácil
-- MAGIC Diseña una consulta que compare el país del cliente con el país del proveedor en una misma línea de pedido.
-- MAGIC 
-- MAGIC ### 3. Intermedio
-- MAGIC Calcula el ticket promedio por cliente combinando `customer` y `orders`.
-- MAGIC 
-- MAGIC ### 4. Intermedio Alto
-- MAGIC Detecta posibles pérdidas de integridad listando filas huérfanas con `FULL OUTER JOIN` entre `orders` y `customer`.
-- MAGIC 
-- MAGIC ### 5. Desafío
-- MAGIC Construye un dataset analítico que incluya cliente, pedido, producto, proveedor, país del cliente, país del proveedor y región del proveedor.
-- MAGIC 
-- MAGIC > **📝 Nota:** Si tu resultado tiene más filas de las esperadas, probablemente el problema sea de granularidad y no del motor SQL.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## Checklist de depuración de `JOIN`
-- MAGIC 
-- MAGIC Antes de dar por buena una consulta con múltiples tablas, verifica:
-- MAGIC 
-- MAGIC - ¿El número de filas final tiene sentido respecto a la granularidad?
-- MAGIC - ¿La clave usada en `ON` corresponde realmente a la relación del modelo?
-- MAGIC - ¿Los `NULL` observados son esperados o revelan faltantes?
-- MAGIC - ¿El filtro debe ir en `ON` o en `WHERE`?
-- MAGIC - ¿Hay duplicados naturales que exijan agregación previa o posterior?
-- MAGIC 
-- MAGIC > **📝 Nota:** Esta lista evita dos errores muy costosos en analítica: inflar métricas y excluir registros válidos sin darte cuenta.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Resumen
-- MAGIC 
-- MAGIC En este notebook aprendiste que:
-- MAGIC 
-- MAGIC - `JOIN` permite integrar entidades distribuidas en distintas tablas.
-- MAGIC - `INNER JOIN` conserva solo coincidencias.
-- MAGIC - `LEFT JOIN` y `RIGHT JOIN` preservan uno de los dos lados.
-- MAGIC - `FULL OUTER JOIN` sirve para auditoría y conciliación.
-- MAGIC - `CROSS JOIN` genera todas las combinaciones y debe usarse con cuidado.
-- MAGIC - `SELF JOIN` compara filas de una misma tabla.
-- MAGIC - Los alias mejoran legibilidad y mantenimiento.
-- MAGIC - `WHERE`, agregaciones y `COALESCE` cambian el significado analítico del resultado.
-- MAGIC 
-- MAGIC ### Idea clave
-- MAGIC 
-- MAGIC Un `JOIN` correcto no depende solo de la sintaxis, sino de entender **qué representa cada tabla y a qué nivel se está analizando el negocio**.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Laboratorio
-- MAGIC 
-- MAGIC Responde estas preguntas empresariales reales para DataCorp Analytics.
-- MAGIC 
-- MAGIC 1. ¿Cuáles son los **20 clientes** con mayor valor acumulado de pedidos?
-- MAGIC 2. ¿Qué **regiones de proveedores** concentran más valor vendido?
-- MAGIC 3. ¿Qué **países de clientes** generan más pedidos?
-- MAGIC 4. ¿Qué **productos** aparecen con mayor frecuencia en las líneas de pedido?
-- MAGIC 5. ¿Existen **clientes sin pedidos** que requieran reactivación comercial?
-- MAGIC 6. ¿Existen **pedidos sin detalle** o anomalías de integridad entre `orders` y `lineitem`?
-- MAGIC 7. ¿Qué combinación de **cliente + proveedor + región** produce mayor facturación?
-- MAGIC 8. Usa `samples.nyctaxi.trips` para plantear una analogía: ¿qué columnas podrían requerir un `JOIN` si el catálogo de zonas estuviera en otra tabla?
-- MAGIC 
-- MAGIC ### Entregable sugerido
-- MAGIC 
-- MAGIC | Paso | Evidencia |
-- MAGIC |---|---|
-- MAGIC | Definición del problema | Pregunta de negocio reescrita en lenguaje de datos |
-- MAGIC | Diseño del `JOIN` | Tabla base, claves y tipo de unión |
-- MAGIC | Validación | Recuento de filas y revisión de `NULL` |
-- MAGIC | Interpretación | Insight accionable para la dirección |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 14. Autoevaluación
-- MAGIC 
-- MAGIC Responde sin ejecutar SQL y luego valida tus respuestas:
-- MAGIC 
-- MAGIC 1. ¿Qué diferencia conceptual hay entre `INNER JOIN` y `LEFT JOIN`?
-- MAGIC 2. ¿Por qué un `LEFT JOIN` puede devolver `NULL`?
-- MAGIC 3. ¿Qué riesgo existe si omites la condición `ON`?
-- MAGIC 4. ¿Cuándo usarías `FULL OUTER JOIN` en control de calidad de datos?
-- MAGIC 5. ¿Por qué `lineitem` suele aumentar fuertemente el número de filas?
-- MAGIC 6. ¿Qué problema resuelven los alias en consultas con muchas tablas?
-- MAGIC 7. ¿Por qué un filtro en `WHERE` puede cambiar el comportamiento de un `LEFT JOIN`?
-- MAGIC 8. ¿Qué diferencia hay entre granularidad de pedido y granularidad de línea de pedido?
-- MAGIC 9. ¿Qué hace `COALESCE` en el contexto de `JOIN`?
-- MAGIC 10. ¿Qué validación rápida harías para saber si un `JOIN` duplicó filas inesperadamente?
-- MAGIC 
-- MAGIC > **📝 Nota:** Si puedes justificar el tipo de `JOIN`, la clave usada y la granularidad final, entonces ya estás pensando como analista de datos relacional.
