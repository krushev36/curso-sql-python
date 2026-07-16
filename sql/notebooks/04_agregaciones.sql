-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Notebook 04: Agregaciones
-- MAGIC ## Fundamentos de Programación
-- MAGIC ### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia
-- MAGIC ## 1. Bienvenida
-- MAGIC
-- MAGIC Bienvenidos al cuarto notebook del curso **Fundamentos de Programación** de la **Maestría en Ciencia de Datos e Inteligencia de Negocios** de la **Universidad de Antioquia**.
-- MAGIC
-- MAGIC En esta sesión aprenderás a **resumir datos** para responder preguntas de negocio reales: cuántos pedidos hubo, cuánto se vendió, qué regiones generan más ingresos y qué productos concentran el mayor volumen.
-- MAGIC
-- MAGIC ### Rol profesional del caso
-- MAGIC | Elemento | Descripción |
-- MAGIC |---|---|
-- MAGIC | Empresa | DataCorp Analytics |
-- MAGIC | Rol del estudiante | Data Analyst |
-- MAGIC | Necesidad del negocio | Resúmenes ejecutivos y reportes para BI |
-- MAGIC | Preguntas clave | Ingresos por región, ticket promedio por segmento, pedidos por mes, productos top |
-- MAGIC
-- MAGIC > **📝 Nota:** En analítica, muchas decisiones no parten de filas individuales, sino de **agregaciones** que convierten millones de registros en indicadores comprensibles.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC
-- MAGIC Al finalizar este notebook podrás:
-- MAGIC
-- MAGIC 1. Aplicar funciones de agregación como `COUNT`, `SUM`, `AVG`, `MIN` y `MAX`.
-- MAGIC 2. Construir consultas con `GROUP BY` para resumir datos por una o varias dimensiones.
-- MAGIC 3. Filtrar resultados agregados con `HAVING` y diferenciarlo correctamente de `WHERE`.
-- MAGIC 4. Manejar casos con `NULL` y entender su impacto en los cálculos.
-- MAGIC 5. Generar subtotales y vistas multidimensionales con `ROLLUP`, `CUBE` y `GROUPING SETS`.
-- MAGIC 6. Calcular porcentajes y razones usando agregaciones y expresiones `CASE WHEN`.
-- MAGIC
-- MAGIC ### Resultado esperado
-- MAGIC | Habilidad | Evidencia |
-- MAGIC |---|---|
-- MAGIC | Resumir datos | consultas con métricas claras |
-- MAGIC | Analizar negocio | indicadores útiles para BI |
-- MAGIC | Evitar errores | uso correcto de columnas agregadas y agrupadas |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias
-- MAGIC
-- MAGIC ### Competencias técnicas
-- MAGIC - Interpretar el **grano** de análisis antes de escribir una consulta.
-- MAGIC - Seleccionar métricas adecuadas según la pregunta de negocio.
-- MAGIC - Diseñar agregaciones robustas y legibles.
-- MAGIC - Validar resultados agregados para evitar dobles conteos.
-- MAGIC
-- MAGIC ### Competencias analíticas
-- MAGIC - Traducir preguntas ejecutivas a métricas SQL.
-- MAGIC - Explicar resultados resumidos a audiencias no técnicas.
-- MAGIC - Detectar patrones, concentraciones y anomalías.
-- MAGIC
-- MAGIC ### Competencias de buenas prácticas
-- MAGIC | Buena práctica | Razón |
-- MAGIC |---|---|
-- MAGIC | Definir el nivel de agrupación antes de escribir | evita errores lógicos |
-- MAGIC | Filtrar temprano con `WHERE` | mejora rendimiento y claridad |
-- MAGIC | Filtrar grupos con `HAVING` | mantiene consistencia semántica |
-- MAGIC | Etiquetar subtotales | hace más interpretable el resultado |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC
-- MAGIC El equipo de Business Intelligence de **DataCorp Analytics** necesita un notebook reutilizable para responder cuatro solicitudes frecuentes:
-- MAGIC
-- MAGIC 1. **Ingresos totales por región** para decidir dónde enfocar campañas.
-- MAGIC 2. **Valor promedio de pedido por segmento de cliente** para priorizar cuentas.
-- MAGIC 3. **Número de pedidos por mes** para analizar estacionalidad.
-- MAGIC 4. **Productos líderes por volumen de venta** para optimizar inventario.
-- MAGIC
-- MAGIC ### Flujo de decisión
-- MAGIC
-- MAGIC ```text
-- MAGIC Filas transaccionales -> Agrupar -> Calcular métricas -> Comparar -> Decidir
-- MAGIC ```
-- MAGIC
-- MAGIC ### Tablas de trabajo en este notebook
-- MAGIC | Dataset | Uso principal |
-- MAGIC |---|---|
-- MAGIC | `samples.tpch.orders` | pedidos y valor total |
-- MAGIC | `samples.tpch.customer` | segmento y cliente |
-- MAGIC | `samples.tpch.lineitem` | detalle de venta y cantidades |
-- MAGIC | `samples.tpch.part` | información de producto |
-- MAGIC | `samples.tpch.supplier` | proveedores |
-- MAGIC | `samples.tpch.nation` | país |
-- MAGIC | `samples.tpch.region` | región |
-- MAGIC | `samples.nyctaxi.trips` | ejemplo adicional de agregación temporal si se desea extender |
-- MAGIC
-- MAGIC > **📝 Nota:** Aunque el negocio es ficticio, las preguntas son idénticas a las que un analista resuelve en producción.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos
-- MAGIC
-- MAGIC ### 5.1 Funciones de agregación
-- MAGIC | Función | Qué hace | Consideración |
-- MAGIC |---|---|---|
-- MAGIC | `COUNT(*)` | cuenta filas | incluye filas con `NULL` |
-- MAGIC | `COUNT(columna)` | cuenta valores no nulos | ignora `NULL` |
-- MAGIC | `COUNT(DISTINCT columna)` | cuenta valores únicos no nulos | puede ser más costoso |
-- MAGIC | `SUM(columna)` | suma valores | ignora `NULL` |
-- MAGIC | `AVG(columna)` | promedio | ignora `NULL` |
-- MAGIC | `MIN(columna)` | mínimo | ignora `NULL` |
-- MAGIC | `MAX(columna)` | máximo | ignora `NULL` |
-- MAGIC
-- MAGIC ### 5.2 ¿Qué hace `GROUP BY`?
-- MAGIC
-- MAGIC ```text
-- MAGIC Antes del GROUP BY
-- MAGIC pedido  cliente  región   valor
-- MAGIC 1       A        AMERICA  100
-- MAGIC 2       B        AMERICA  300
-- MAGIC 3       C        EUROPE   200
-- MAGIC
-- MAGIC Después del GROUP BY región
-- MAGIC región   suma_valor
-- MAGIC AMERICA  400
-- MAGIC EUROPE   200
-- MAGIC ```
-- MAGIC
-- MAGIC ### 5.3 Errores comunes
-- MAGIC | Error | Explicación | Solución |
-- MAGIC |---|---|---|
-- MAGIC | Columna en `SELECT` no agregada | SQL no sabe qué valor mostrar por grupo | agregarla a `GROUP BY` o resumirla |
-- MAGIC | Usar `HAVING` para filtros de detalle | funciona, pero no es la intención correcta | mover el filtro a `WHERE` |
-- MAGIC | Dobles conteos por joins | una fila se replica al unir tablas detalle | revisar el grano antes de agregar |
-- MAGIC
-- MAGIC > **📝 Nota:** La regla mental es: **toda columna en `SELECT` debe estar agregada o incluida en `GROUP BY`**.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso
-- MAGIC
-- MAGIC ### Método recomendado para construir una agregación
-- MAGIC
-- MAGIC 1. **Define la pregunta**: ¿quieres contar, sumar, promediar o comparar?
-- MAGIC 2. **Define el grano**: por región, por mes, por producto, por segmento.
-- MAGIC 3. **Identifica tablas y joins**: evita mezclar niveles de detalle sin control.
-- MAGIC 4. **Aplica `WHERE`** para filtrar filas antes del resumen.
-- MAGIC 5. **Aplica `GROUP BY`** para establecer una fila por categoría.
-- MAGIC 6. **Aplica `HAVING`** si el filtro depende del resultado agregado.
-- MAGIC 7. **Ordena** con `ORDER BY` para priorizar el análisis.
-- MAGIC
-- MAGIC ### Distinguir `WHERE` vs `HAVING`
-- MAGIC | Cláusula | Momento lógico | Uso correcto |
-- MAGIC |---|---|---|
-- MAGIC | `WHERE` | antes de agrupar | filtrar filas base |
-- MAGIC | `HAVING` | después de agrupar | filtrar grupos ya resumidos |
-- MAGIC
-- MAGIC ### Regla práctica
-- MAGIC
-- MAGIC ```text
-- MAGIC FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY
-- MAGIC ```
-- MAGIC
-- MAGIC > **📝 Nota:** Si tu condición usa `SUM`, `COUNT` o `AVG`, probablemente pertenece a `HAVING`.
-- COMMAND ----------

-- Introducción práctica: funciones de agregación básicas sobre pedidos.
-- ¿Por qué esta consulta?: porque es la forma más directa de transformar filas transaccionales en KPIs ejecutivos.
-- Resultado esperado: una sola fila con volumen, ingreso total, ticket promedio y extremos del valor del pedido.
SELECT
  -- COUNT(*) cuenta todas las filas de pedidos, incluso si alguna otra columna tuviera NULL.
  COUNT(*) AS total_pedidos,
  -- COUNT(o_comment) cuenta solo pedidos donde el comentario no es NULL.
  COUNT(o_comment) AS pedidos_con_comentario,
  -- SUM(o_totalprice) suma el valor monetario de todos los pedidos.
  SUM(o_totalprice) AS ingreso_total,
  -- AVG(o_totalprice) calcula el ticket promedio por pedido.
  AVG(o_totalprice) AS ticket_promedio,
  -- MIN(o_totalprice) identifica el pedido de menor valor.
  MIN(o_totalprice) AS pedido_minimo,
  -- MAX(o_totalprice) identifica el pedido de mayor valor.
  MAX(o_totalprice) AS pedido_maximo
-- FROM define la tabla de hechos que vamos a resumir.
FROM samples.tpch.orders;

-- COMMAND ----------

-- Introducción práctica: COUNT(DISTINCT) y comportamiento de NULL en agregaciones.
-- ¿Por qué esta consulta?: porque ayuda a entender que COUNT(*) y COUNT(columna) no significan lo mismo.
-- Error común evitado: asumir que AVG incluye valores NULL; en realidad los ignora.
WITH saldos_preparados AS (
  -- Creamos una CTE para simular un escenario donde algunos saldos se consideran desconocidos.
  SELECT
    -- Conservamos la llave del cliente para referencia analítica.
    c_custkey,
    -- Conservamos el segmento de mercado para contar categorías únicas.
    c_mktsegment,
    -- Convertimos a NULL los saldos negativos para observar cómo reaccionan COUNT y AVG.
    CASE WHEN c_acctbal < 0 THEN NULL ELSE c_acctbal END AS saldo_positivo
  -- Leemos la dimensión de clientes.
  FROM samples.tpch.customer
)
-- Seleccionamos las métricas agregadas desde la CTE ya preparada.
SELECT
  -- COUNT(*) cuenta todos los clientes del conjunto, sin importar si saldo_positivo es NULL.
  COUNT(*) AS total_clientes,
  -- COUNT(saldo_positivo) cuenta solo los clientes con saldo no nulo.
  COUNT(saldo_positivo) AS clientes_con_saldo_reportable,
  -- COUNT(DISTINCT c_mktsegment) cuenta cuántos segmentos diferentes existen.
  COUNT(DISTINCT c_mktsegment) AS segmentos_distintos,
  -- AVG(saldo_positivo) promedia únicamente los saldos no nulos.
  AVG(saldo_positivo) AS saldo_promedio_reportable
-- FROM consume la CTE creada arriba.
FROM saldos_preparados;

-- COMMAND ----------

-- Introducción práctica: ingreso total por región usando GROUP BY.
-- ¿Por qué esta consulta?: responde una de las preguntas centrales del área de BI: dónde se vende más.
-- Resultado esperado: una fila por región, ordenada de mayor a menor ingreso.
WITH pedidos_region AS (
  -- Construimos una base analítica al unir pedidos con cliente, nación y región.
  SELECT
    -- Tomamos el nombre de la región como dimensión de análisis.
    r.r_name AS region,
    -- Conservamos el total del pedido como métrica base.
    o.o_totalprice AS total_pedido
  -- La tabla orders representa el hecho transaccional principal.
  FROM samples.tpch.orders AS o
  -- Unimos customer para saber a qué cliente pertenece el pedido.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Unimos nation para conectar el cliente con su país.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Unimos region para obtener la dimensión geográfica final.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
)
-- Agregamos la base al nivel de región.
SELECT
  -- Mostramos la región porque define una fila por grupo.
  region,
  -- Sumamos el valor de todos los pedidos de la región.
  ROUND(SUM(total_pedido), 2) AS ingreso_total,
  -- Contamos cuántos pedidos contribuyen al ingreso regional.
  COUNT(*) AS numero_pedidos
-- FROM indica la base ya enriquecida con región.
FROM pedidos_region
-- GROUP BY colapsa todas las filas de una misma región en una sola fila resumen.
GROUP BY region
-- ORDER BY ordena los grupos de mayor a menor ingreso para priorizar lectura ejecutiva.
ORDER BY ingreso_total DESC;

-- COMMAND ----------

-- Introducción práctica: múltiples columnas en GROUP BY.
-- ¿Por qué esta consulta?: porque el negocio no solo quiere ver región, sino también segmento de cliente dentro de cada región.
-- Error común evitado: incluir region y segmento en SELECT sin agregarlos ambos en GROUP BY.
SELECT
  -- Región del cliente como primera dimensión.
  r.r_name AS region,
  -- Segmento de mercado como segunda dimensión.
  c.c_mktsegment AS segmento,
  -- Promediamos el total del pedido para medir ticket promedio.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio,
  -- Contamos pedidos para dar contexto al promedio.
  COUNT(*) AS pedidos_en_grupo
-- FROM parte desde pedidos.
FROM samples.tpch.orders AS o
-- JOIN con customer para recuperar el segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation para llegar a región.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region para etiquetar geografía.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY define el grano final: una fila por combinación región-segmento.
GROUP BY r.r_name, c.c_mktsegment
-- ORDER BY facilita comparar los grupos más valiosos primero.
ORDER BY region, ticket_promedio DESC;

-- COMMAND ----------

-- Introducción práctica: WHERE vs HAVING en agregaciones mensuales.
-- ¿Por qué esta consulta?: para separar correctamente filtros sobre filas y filtros sobre grupos.
-- Resultado esperado: meses de 1995 con al menos 900 pedidos.
SELECT
  -- DATE_TRUNC('month', ...) redondea la fecha al primer día del mes y crea la dimensión mensual.
  DATE_TRUNC('month', o_orderdate) AS mes_pedido,
  -- COUNT(*) cuenta los pedidos de cada mes.
  COUNT(*) AS total_pedidos,
  -- SUM(o_totalprice) mide el valor agregado de cada mes.
  ROUND(SUM(o_totalprice), 2) AS ingreso_mensual
-- FROM selecciona la tabla base.
FROM samples.tpch.orders
-- WHERE filtra filas individuales antes de agrupar; aquí limitamos el análisis al año 1995.
WHERE o_orderdate >= DATE('1995-01-01')
  -- Este segundo límite mantiene solo pedidos anteriores a 1996.
  AND o_orderdate < DATE('1996-01-01')
-- GROUP BY resume al nivel mes.
GROUP BY DATE_TRUNC('month', o_orderdate)
-- HAVING filtra grupos ya resumidos; por eso puede usar COUNT(*).
HAVING COUNT(*) >= 900
-- ORDER BY presenta la serie temporal en orden cronológico.
ORDER BY mes_pedido;

-- COMMAND ----------

-- Introducción práctica: expresiones dentro de GROUP BY.
-- ¿Por qué esta consulta?: porque muchas veces la dimensión analítica no existe como columna y debe construirse.
-- Resultado esperado: una fila por combinación año-mes con su número de pedidos.
SELECT
  -- YEAR(o_orderdate) extrae el año para análisis anual.
  YEAR(o_orderdate) AS anio,
  -- MONTH(o_orderdate) extrae el mes numérico para análisis intranual.
  MONTH(o_orderdate) AS mes,
  -- COUNT(*) cuenta pedidos por combinación de año y mes.
  COUNT(*) AS total_pedidos
-- FROM usa pedidos como fuente temporal.
FROM samples.tpch.orders
-- GROUP BY repite exactamente las expresiones que queremos usar como dimensión.
GROUP BY YEAR(o_orderdate), MONTH(o_orderdate)
-- ORDER BY organiza la salida como calendario.
ORDER BY anio, mes;

-- COMMAND ----------

-- Introducción práctica: combinar agregaciones con CASE WHEN y calcular porcentajes.
-- ¿Por qué esta consulta?: porque el negocio suele clasificar pedidos en bandas de valor antes de resumirlos.
-- Resultado esperado: tres grupos de valor con su cantidad de pedidos y porcentaje sobre el total.
WITH pedidos_clasificados AS (
  -- Creamos una CTE para etiquetar cada pedido según su total.
  SELECT
    -- Conservamos la llave del pedido para trazabilidad.
    o_orderkey,
    -- Clasificamos el pedido en una banda interpretable para negocio.
    CASE
      WHEN o_totalprice < 100000 THEN 'Bajo'
      WHEN o_totalprice < 200000 THEN 'Medio'
      ELSE 'Alto'
    END AS banda_valor
  -- Leemos los pedidos originales.
  FROM samples.tpch.orders
)
-- Agregamos por banda de valor.
SELECT
  -- Mostramos la banda calculada como dimensión.
  banda_valor,
  -- COUNT(*) cuenta cuántos pedidos caen en cada banda.
  COUNT(*) AS total_pedidos,
  -- Calculamos el porcentaje dividiendo el conteo de la banda entre el total general.
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje_del_total
-- FROM toma la CTE ya clasificada.
FROM pedidos_clasificados
-- GROUP BY agrupa por la etiqueta generada con CASE.
GROUP BY banda_valor
-- ORDER BY prioriza la banda con más pedidos.
ORDER BY total_pedidos DESC;

-- COMMAND ----------

-- Introducción práctica: ROLLUP para subtotales jerárquicos.
-- ¿Por qué esta consulta?: porque un gerente suele pedir detalle por región y segmento, además de subtotales por región y total general.
-- Resultado esperado: filas detalladas, subtotales por región y una fila total.
SELECT
  -- Etiquetamos la región; si GROUPING=1 significa que la fila es subtotal o total.
  CASE WHEN GROUPING(r.r_name) = 1 THEN 'TOTAL_REGION' ELSE r.r_name END AS region,
  -- Etiquetamos el segmento; si GROUPING=1 y la región existe, la fila es subtotal regional.
  CASE WHEN GROUPING(c.c_mktsegment) = 1 THEN 'TOTAL_SEGMENTO' ELSE c.c_mktsegment END AS segmento,
  -- SUM agrega el valor de pedido para cada nivel generado por ROLLUP.
  ROUND(SUM(o.o_totalprice), 2) AS ingreso_total
-- FROM parte de pedidos.
FROM samples.tpch.orders AS o
-- JOIN con customer para obtener segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation para enlazar geografía.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region para analizar por región.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY ROLLUP genera: (region, segmento), (region), ().
GROUP BY ROLLUP (r.r_name, c.c_mktsegment)
-- ORDER BY organiza primero región y luego segmento/subtotales.
ORDER BY region, segmento;

-- COMMAND ----------

-- Introducción práctica: CUBE para tabulación cruzada completa.
-- ¿Por qué esta consulta?: porque permite ver todas las combinaciones posibles de subtotales entre dos dimensiones.
-- Diferencia clave: CUBE genera más combinaciones que ROLLUP porque no asume jerarquía.
SELECT
  -- Etiquetamos la región o el total de región según GROUPING.
  CASE WHEN GROUPING(r.r_name) = 1 THEN 'TOTAL_REGION' ELSE r.r_name END AS region,
  -- Etiquetamos el segmento o el total de segmento según GROUPING.
  CASE WHEN GROUPING(c.c_mktsegment) = 1 THEN 'TOTAL_SEGMENTO' ELSE c.c_mktsegment END AS segmento,
  -- COUNT(*) muestra cuántos pedidos hay en cada combinación del cubo.
  COUNT(*) AS total_pedidos,
  -- AVG calcula el ticket promedio para cada celda del cubo.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio
-- FROM usa la tabla de pedidos.
FROM samples.tpch.orders AS o
-- JOIN con customer para exponer el segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation para la dimensión geográfica intermedia.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region para obtener la región final.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY CUBE genera: (region, segmento), (region), (segmento), ().
GROUP BY CUBE (r.r_name, c.c_mktsegment)
-- ORDER BY facilita recorrer la matriz de resultados.
ORDER BY region, segmento;

-- COMMAND ----------

-- Introducción práctica: GROUPING SETS para controlar exactamente qué agregaciones queremos.
-- ¿Por qué esta consulta?: porque a veces queremos algunos subtotales, pero no todas las combinaciones de CUBE.
-- Resultado esperado: detalle región-segmento, total por región, total por segmento y total general.
SELECT
  -- Etiquetamos la región o el nivel total según GROUPING.
  CASE WHEN GROUPING(r.r_name) = 1 THEN 'TOTAL_REGION' ELSE r.r_name END AS region,
  -- Etiquetamos el segmento o el nivel total según GROUPING.
  CASE WHEN GROUPING(c.c_mktsegment) = 1 THEN 'TOTAL_SEGMENTO' ELSE c.c_mktsegment END AS segmento,
  -- SUM resume el valor total del pedido en cada conjunto de agrupación solicitado.
  ROUND(SUM(o.o_totalprice), 2) AS ingreso_total
-- FROM usa pedidos como hecho base.
FROM samples.tpch.orders AS o
-- JOIN con customer para segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation para conectar con región.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region para traer la dimensión geográfica.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY GROUPING SETS define explícitamente los niveles deseados.
GROUP BY GROUPING SETS ((r.r_name, c.c_mktsegment), (r.r_name), (c.c_mktsegment), ())
-- ORDER BY deja juntos los resultados comparables.
ORDER BY region, segmento;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado
-- MAGIC
-- MAGIC En esta sección resolvemos cinco consultas modelo, cada una alineada con una necesidad frecuente del negocio.
-- MAGIC
-- MAGIC | Ejemplo | Pregunta | Técnica principal |
-- MAGIC |---|---|---|
-- MAGIC | 1 | ¿Cuánto ingresa cada región? | `SUM` + `GROUP BY` |
-- MAGIC | 2 | ¿Cuál es el ticket promedio por segmento? | `AVG` + joins |
-- MAGIC | 3 | ¿Cuántos pedidos ocurren por mes? | agrupación temporal |
-- MAGIC | 4 | ¿Qué productos lideran por volumen? | `SUM` + ordenamiento |
-- MAGIC | 5 | ¿Qué países tienen suficientes proveedores para analizar? | `HAVING` |
-- MAGIC
-- MAGIC > **📝 Nota:** Lee la explicación antes de ejecutar cada consulta y compara el resultado con la expectativa indicada.
-- COMMAND ----------

-- Ejemplo 1: ingreso total por región con una definición de ingreso más cercana a ventas netas.
-- ¿Por qué así?: usamos lineitem porque permite calcular ingreso con precio extendido menos descuento.
-- Resultado esperado: una fila por región con ingreso y cantidad de líneas de venta.
SELECT
  -- La región es la dimensión final del reporte.
  r.r_name AS region,
  -- Sumamos precio extendido por (1 - descuento) para aproximar ingreso neto.
  ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS ingreso_neto,
  -- Contamos cuántas líneas de detalle contribuyen al ingreso regional.
  COUNT(*) AS lineas_vendidas
-- FROM inicia en lineitem porque allí está el detalle monetario y de cantidades.
FROM samples.tpch.lineitem AS l
-- JOIN con orders para conectar el detalle con el pedido.
INNER JOIN samples.tpch.orders AS o
  ON l.l_orderkey = o.o_orderkey
-- JOIN con customer para conocer el cliente del pedido.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation para subir un nivel geográfico.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region para llegar a la dimensión usada por negocio.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY asegura una fila resumen por región.
GROUP BY r.r_name
-- ORDER BY permite leer primero las regiones con mayor ingreso.
ORDER BY ingreso_neto DESC;

-- COMMAND ----------

-- Ejemplo 2: valor promedio del pedido por segmento de cliente.
-- ¿Por qué así?: el ticket promedio es más interpretable si se acompaña con cuántos pedidos y clientes hay detrás.
-- Resultado esperado: una fila por segmento con promedio, pedidos y clientes distintos.
SELECT
  -- El segmento de mercado es la categoría de negocio a comparar.
  c.c_mktsegment AS segmento,
  -- AVG(o_totalprice) resume el valor medio por pedido en el segmento.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio,
  -- COUNT(*) cuantifica pedidos del segmento.
  COUNT(*) AS total_pedidos,
  -- COUNT(DISTINCT) cuenta cuántos clientes únicos participaron.
  COUNT(DISTINCT c.c_custkey) AS clientes_unicos
-- FROM parte desde pedidos.
FROM samples.tpch.orders AS o
-- JOIN con customer porque el segmento vive en la tabla de clientes.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- GROUP BY segmenta el cálculo en una fila por segmento.
GROUP BY c.c_mktsegment
-- ORDER BY ordena desde el ticket promedio más alto.
ORDER BY ticket_promedio DESC;

-- COMMAND ----------

-- Ejemplo 3: número de pedidos por mes.
-- ¿Por qué así?: DATE_TRUNC crea una dimensión temporal consistente y más fácil de graficar.
-- Resultado esperado: una serie mensual con conteo de pedidos e ingreso asociado.
SELECT
  -- DATE_TRUNC('month', ...) agrupa todas las fechas del mismo mes en una sola clave temporal.
  DATE_TRUNC('month', o.o_orderdate) AS mes,
  -- COUNT(*) mide actividad operativa del mes.
  COUNT(*) AS total_pedidos,
  -- SUM(o_totalprice) aporta la métrica monetaria complementaria.
  ROUND(SUM(o.o_totalprice), 2) AS ingreso_total
-- FROM usa la tabla de pedidos.
FROM samples.tpch.orders AS o
-- GROUP BY define una fila por mes.
GROUP BY DATE_TRUNC('month', o.o_orderdate)
-- ORDER BY conserva el orden cronológico natural.
ORDER BY mes;

-- COMMAND ----------

-- Ejemplo 4: productos top por volumen de venta.
-- ¿Por qué así?: para inventario suele importar primero la cantidad movilizada y luego el ingreso que genera.
-- Resultado esperado: top 10 productos con más unidades vendidas.
SELECT
  -- Mostramos la llave del producto para identificación unívoca.
  p.p_partkey AS producto_id,
  -- Mostramos el nombre del producto para interpretación humana.
  p.p_name AS producto,
  -- SUM(l_quantity) acumula unidades vendidas del producto.
  SUM(l.l_quantity) AS volumen_vendido,
  -- SUM del ingreso neto ayuda a contrastar volumen contra monetización.
  ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS ingreso_neto
-- FROM parte desde lineitem porque contiene la cantidad vendida.
FROM samples.tpch.lineitem AS l
-- JOIN con part para traducir la llave a atributos de producto.
INNER JOIN samples.tpch.part AS p
  ON l.l_partkey = p.p_partkey
-- GROUP BY conserva una fila por producto.
GROUP BY p.p_partkey, p.p_name
-- ORDER BY prioriza los productos con más unidades vendidas.
ORDER BY volumen_vendido DESC, ingreso_neto DESC
-- LIMIT restringe la salida a los 10 productos líderes.
LIMIT 10;

-- COMMAND ----------

-- Ejemplo 5: países con suficiente base de proveedores para análisis comparativo.
-- ¿Por qué así?: HAVING permite quedarnos solo con grupos con volumen mínimo.
-- Resultado esperado: naciones con al menos 4 proveedores y saldo promedio positivo.
SELECT
  -- El nombre del país identifica el grupo.
  n.n_name AS pais,
  -- COUNT(*) cuenta proveedores en cada país.
  COUNT(*) AS total_proveedores,
  -- AVG(s_acctbal) resume el saldo promedio de proveedores por país.
  ROUND(AVG(s.s_acctbal), 2) AS saldo_promedio
-- FROM toma la tabla de proveedores.
FROM samples.tpch.supplier AS s
-- JOIN con nation para traducir la llave del país.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- GROUP BY crea una fila por país.
GROUP BY n.n_name
-- HAVING filtra solo los países con volumen suficiente y saldo promedio útil para análisis.
HAVING COUNT(*) >= 4
  -- Esta segunda condición exige un promedio positivo.
  AND AVG(s.s_acctbal) > 0
-- ORDER BY deja arriba los países con más proveedores.
ORDER BY total_proveedores DESC, saldo_promedio DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado
-- MAGIC
-- MAGIC A continuación verás cinco consultas con una lógica muy parecida a la que usarías en un taller acompañado por el docente.
-- MAGIC
-- MAGIC ### Estrategia de trabajo
-- MAGIC 1. Lee la pregunta.
-- MAGIC 2. Identifica la dimensión de agrupación.
-- MAGIC 3. Elige la métrica.
-- MAGIC 4. Verifica si el filtro pertenece a `WHERE` o a `HAVING`.
-- MAGIC 5. Revisa si existe riesgo de doble conteo por joins.
-- MAGIC
-- MAGIC | Ejercicio guiado | Dificultad | Enfoque |
-- MAGIC |---|---|---|
-- MAGIC | 1 | Muy fácil | `COUNT` por región |
-- MAGIC | 2 | Fácil | `SUM` por año y segmento |
-- MAGIC | 3 | Fácil | `HAVING` por producto |
-- MAGIC | 4 | Intermedio | `CASE WHEN` + porcentajes |
-- MAGIC | 5 | Intermedio | `ROLLUP` temporal |
-- COMMAND ----------

-- Guiado 1: contar clientes por región.
-- ¿Por qué así?: es un ejemplo simple para practicar GROUP BY con joins de dimensión.
-- Resultado esperado: una fila por región con cantidad de clientes.
SELECT
  -- La región es la dimensión a resumir.
  r.r_name AS region,
  -- COUNT(*) cuenta clientes que pertenecen a la región.
  COUNT(*) AS total_clientes
-- FROM parte de customer porque queremos contar clientes.
FROM samples.tpch.customer AS c
-- JOIN con nation para subir a geografía.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region para obtener la etiqueta regional.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY genera una fila por región.
GROUP BY r.r_name
-- ORDER BY muestra primero las regiones con más clientes.
ORDER BY total_clientes DESC;

-- COMMAND ----------

-- Guiado 2: ingreso por segmento y año.
-- ¿Por qué así?: combinar una dimensión temporal y una comercial es muy común en BI.
-- Error común evitado: olvidar agrupar simultáneamente por año y segmento.
SELECT
  -- YEAR extrae el año del pedido para la vista temporal.
  YEAR(o.o_orderdate) AS anio,
  -- El segmento del cliente aporta la vista comercial.
  c.c_mktsegment AS segmento,
  -- SUM agrega el valor total de pedidos del grupo.
  ROUND(SUM(o.o_totalprice), 2) AS ingreso_total,
  -- COUNT(*) entrega el contexto de volumen de pedidos.
  COUNT(*) AS total_pedidos
-- FROM usa pedidos como hecho base.
FROM samples.tpch.orders AS o
-- JOIN con customer para obtener segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- GROUP BY define una fila por año y segmento.
GROUP BY YEAR(o.o_orderdate), c.c_mktsegment
-- ORDER BY deja la salida en formato analítico legible.
ORDER BY anio, ingreso_total DESC;

-- COMMAND ----------

-- Guiado 3: productos con suficiente frecuencia y cantidad promedio alta.
-- ¿Por qué así?: HAVING es ideal cuando queremos seleccionar grupos que cumplan umbrales.
-- Resultado esperado: productos con más de 100 líneas y cantidad promedio mayor a 25.
SELECT
  -- La llave del producto identifica el grupo.
  p.p_partkey AS producto_id,
  -- El nombre del producto facilita interpretación.
  p.p_name AS producto,
  -- COUNT(*) mide cuántas veces aparece el producto en lineitem.
  COUNT(*) AS total_lineas,
  -- AVG(l_quantity) resume la cantidad típica por línea.
  ROUND(AVG(l.l_quantity), 2) AS cantidad_promedio
-- FROM parte desde el detalle de líneas.
FROM samples.tpch.lineitem AS l
-- JOIN con part para incorporar atributos del producto.
INNER JOIN samples.tpch.part AS p
  ON l.l_partkey = p.p_partkey
-- GROUP BY genera una fila por producto.
GROUP BY p.p_partkey, p.p_name
-- HAVING retiene solo grupos con volumen y cantidad promedio relevantes.
HAVING COUNT(*) > 100
  -- Esta segunda condición obliga a que la cantidad promedio también sea alta.
  AND AVG(l.l_quantity) > 25
-- ORDER BY ayuda a priorizar productos más frecuentes.
ORDER BY total_lineas DESC, cantidad_promedio DESC;

-- COMMAND ----------

-- Guiado 4: distribución de prioridades de pedido con CASE WHEN y porcentaje.
-- ¿Por qué así?: simplifica categorías operativas en grupos de negocio más fáciles de comunicar.
-- Resultado esperado: porcentaje de pedidos urgentes versus estándar.
WITH prioridades AS (
  -- Clasificamos cada pedido según su prioridad textual original.
  SELECT
    -- Creamos una etiqueta compacta para negocio.
    CASE
      WHEN o_orderpriority IN ('1-URGENT', '2-HIGH') THEN 'Urgente/Alta'
      ELSE 'Estándar'
    END AS prioridad_resumida
  -- La fuente es la tabla de pedidos.
  FROM samples.tpch.orders
)
-- Agregamos las etiquetas creadas.
SELECT
  -- La etiqueta resumida define el grupo.
  prioridad_resumida,
  -- COUNT(*) cuantifica pedidos por clase.
  COUNT(*) AS total_pedidos,
  -- Calculamos participación porcentual dentro del total.
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje_total
-- FROM usa la CTE de prioridades.
FROM prioridades
-- GROUP BY colapsa filas en una por etiqueta.
GROUP BY prioridad_resumida
-- ORDER BY ubica primero la categoría más numerosa.
ORDER BY total_pedidos DESC;

-- COMMAND ----------

-- Guiado 5: ROLLUP temporal por año y mes.
-- ¿Por qué así?: ROLLUP permite ver detalle mensual junto con subtotal anual y total general.
-- Resultado esperado: filas por año-mes, una fila subtotal por año y una fila total general.
WITH calendario_pedidos AS (
  -- Preparamos el año y el mes en columnas explícitas para mejorar legibilidad.
  SELECT
    -- YEAR(o_orderdate) extrae el año y lo deja disponible para agrupar y etiquetar.
    YEAR(o_orderdate) AS anio_num,
    -- MONTH(o_orderdate) extrae el mes y lo deja disponible para agrupar y etiquetar.
    MONTH(o_orderdate) AS mes_num,
    -- Conservamos el valor del pedido para agregarlo después.
    o_totalprice
  -- FROM toma pedidos como base temporal.
  FROM samples.tpch.orders
)
-- Aplicamos el rollup sobre las columnas ya preparadas.
SELECT
  -- Etiquetamos el año o el total general según GROUPING.
  CASE WHEN GROUPING(anio_num) = 1 THEN 'TOTAL_GENERAL' ELSE CAST(anio_num AS STRING) END AS anio,
  -- Etiquetamos el mes o el subtotal anual según GROUPING.
  CASE WHEN GROUPING(mes_num) = 1 THEN 'TOTAL_MES' ELSE LPAD(CAST(mes_num AS STRING), 2, '0') END AS mes,
  -- COUNT(*) cuenta pedidos en cada nivel del rollup.
  COUNT(*) AS total_pedidos,
  -- SUM agrega el valor total de pedidos en cada nivel del rollup.
  ROUND(SUM(o_totalprice), 2) AS ingreso_total
-- FROM consume la CTE con el calendario ya preparado.
FROM calendario_pedidos
-- GROUP BY ROLLUP genera (año, mes), (año), ().
GROUP BY ROLLUP (anio_num, mes_num)
-- ORDER BY deja juntos los registros de cada año y sus subtotales.
ORDER BY anio, mes;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado
-- MAGIC
-- MAGIC En esta sección debes intentar resolver primero por tu cuenta y luego comparar con la solución propuesta.
-- MAGIC
-- MAGIC ### Progresión de dificultad
-- MAGIC | Nivel | Objetivo |
-- MAGIC |---|---|
-- MAGIC | Muy fácil | practicar conteos básicos |
-- MAGIC | Fácil | combinar `SUM` y `AVG` con una dimensión |
-- MAGIC | Intermedio | usar `HAVING` con umbrales |
-- MAGIC | Intermedio alto | resumir detalle de ventas por producto |
-- MAGIC | Desafío | calcular participaciones porcentuales mensuales |
-- MAGIC
-- MAGIC > **📝 Nota:** Si recibes el error *"expression is neither present in the group by, nor is it an aggregate function"*, revisa inmediatamente las columnas del `SELECT`.
-- COMMAND ----------

-- Solución guiada 1 (Muy fácil): contar pedidos y clientes distintos.
-- ¿Por qué así?: muestra la diferencia entre volumen de transacciones y volumen de entidades únicas.
-- Resultado esperado: una sola fila con dos métricas globales.
SELECT
  -- COUNT(*) cuenta todos los pedidos registrados.
  COUNT(*) AS total_pedidos,
  -- COUNT(DISTINCT o_custkey) cuenta cuántos clientes únicos hicieron pedidos.
  COUNT(DISTINCT o_custkey) AS clientes_con_pedidos
-- FROM usa la tabla de pedidos directamente.
FROM samples.tpch.orders;

-- COMMAND ----------

-- Solución guiada 2 (Fácil): total y promedio por segmento.
-- ¿Por qué así?: combina dos métricas complementarias para cada segmento.
-- Resultado esperado: una fila por segmento con ingreso y ticket promedio.
SELECT
  -- El segmento define la fila del resultado.
  c.c_mktsegment AS segmento,
  -- SUM agrega el ingreso bruto del segmento.
  ROUND(SUM(o.o_totalprice), 2) AS ingreso_total,
  -- AVG mide el ticket medio dentro del segmento.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio
-- FROM parte de pedidos.
FROM samples.tpch.orders AS o
-- JOIN con customer para conocer el segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- GROUP BY resume por segmento.
GROUP BY c.c_mktsegment
-- ORDER BY muestra primero los segmentos con mayor ingreso.
ORDER BY ingreso_total DESC;

-- COMMAND ----------

-- Solución guiada 3 (Intermedio): proveedores por país con HAVING.
-- ¿Por qué así?: ejemplifica cómo filtrar grupos con un mínimo de observaciones.
-- Resultado esperado: países con al menos 4 proveedores.
SELECT
  -- El país es la dimensión agrupada.
  n.n_name AS pais,
  -- COUNT(*) cuantifica proveedores por país.
  COUNT(*) AS total_proveedores
-- FROM usa la dimensión de proveedores.
FROM samples.tpch.supplier AS s
-- JOIN con nation para mostrar el nombre del país.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- GROUP BY crea una fila por país.
GROUP BY n.n_name
-- HAVING conserva solo países con cuatro o más proveedores.
HAVING COUNT(*) >= 4
-- ORDER BY facilita comparar tamaños de base.
ORDER BY total_proveedores DESC, pais;

-- COMMAND ----------

-- Solución guiada 4 (Intermedio alto): top 10 productos por ingreso neto.
-- ¿Por qué así?: a veces interesa más monetización que volumen físico.
-- Resultado esperado: diez productos ordenados por ingreso neto descendente.
SELECT
  -- La llave identifica de forma inequívoca el producto.
  p.p_partkey AS producto_id,
  -- El nombre hace legible el reporte.
  p.p_name AS producto,
  -- Sumamos ingreso neto usando descuento a nivel de línea.
  ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS ingreso_neto,
  -- Sumamos unidades para añadir contexto operacional.
  SUM(l.l_quantity) AS unidades_vendidas
-- FROM parte desde lineitem.
FROM samples.tpch.lineitem AS l
-- JOIN con part añade atributos del producto.
INNER JOIN samples.tpch.part AS p
  ON l.l_partkey = p.p_partkey
-- GROUP BY resume al nivel producto.
GROUP BY p.p_partkey, p.p_name
-- ORDER BY deja arriba a los productos más rentables en ingreso.
ORDER BY ingreso_neto DESC, unidades_vendidas DESC
-- LIMIT restringe el resultado a los diez primeros.
LIMIT 10;

-- COMMAND ----------

-- Solución guiada 5 (Desafío): porcentaje mensual del ingreso anual 1995.
-- ¿Por qué así?: muestra cómo calcular ratios sobre un total dentro del mismo resultado.
-- Resultado esperado: una fila por mes de 1995 con ingreso y participación porcentual.
WITH ingresos_mensuales AS (
  -- Agregamos primero el ingreso por mes para no repetir cálculos complejos.
  SELECT
    -- La clave temporal será el primer día de cada mes.
    DATE_TRUNC('month', o_orderdate) AS mes,
    -- Sumamos el valor total del pedido dentro del mes.
    SUM(o_totalprice) AS ingreso_mensual
  -- La fuente es orders.
  FROM samples.tpch.orders
  -- WHERE limita el análisis a 1995 antes de agrupar.
  WHERE o_orderdate >= DATE('1995-01-01')
    -- Este límite superior excluye 1996.
    AND o_orderdate < DATE('1996-01-01')
  -- GROUP BY resume por mes.
  GROUP BY DATE_TRUNC('month', o_orderdate)
)
-- Calculamos porcentaje una vez que ya tenemos el ingreso mensual.
SELECT
  -- Mostramos la clave temporal del mes.
  mes,
  -- Mostramos el ingreso mensual redondeado para lectura ejecutiva.
  ROUND(ingreso_mensual, 2) AS ingreso_mensual,
  -- Dividimos el ingreso del mes entre el ingreso anual total para obtener participación.
  ROUND(100.0 * ingreso_mensual / SUM(ingreso_mensual) OVER (), 2) AS porcentaje_anual
-- FROM consume la CTE mensual.
FROM ingresos_mensuales
-- ORDER BY mantiene la secuencia cronológica.
ORDER BY mes;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Ejercicio individual
-- MAGIC
-- MAGIC Ahora trabaja de manera autónoma. La idea es que construyas las consultas antes de mirar la solución de referencia de la celda siguiente.
-- MAGIC
-- MAGIC ### Recomendaciones
-- MAGIC - Escribe primero el `SELECT` con la métrica.
-- MAGIC - Luego decide si la dimensión pertenece al `GROUP BY`.
-- MAGIC - Si usas joins, pregúntate: **¿cambia el número de filas?**
-- MAGIC - Comprueba si tus porcentajes suman aproximadamente 100.
-- MAGIC
-- MAGIC | Ejercicio | Nivel | Resultado esperado |
-- MAGIC |---|---|---|
-- MAGIC | 1 | Muy fácil | ingreso por región y año |
-- MAGIC | 2 | Fácil | descuento promedio por región |
-- MAGIC | 3 | Intermedio | productos distintos por país proveedor |
-- MAGIC | 4 | Intermedio alto | años con ticket promedio alto |
-- MAGIC | 5 | Desafío | resumen con `GROUPING SETS` |
-- COMMAND ----------

-- Solución individual 1: ingreso por región y año.
-- ¿Por qué así?: cruza una dimensión geográfica con una temporal para análisis estratégico.
-- Resultado esperado: una fila por región y año, ordenada por año y por ingreso.
SELECT
  -- YEAR extrae el año del pedido para el eje temporal.
  YEAR(o.o_orderdate) AS anio,
  -- El nombre de la región identifica el eje geográfico.
  r.r_name AS region,
  -- SUM del ingreso neto aproxima ventas por región y año.
  ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS ingreso_neto
-- FROM inicia en lineitem para calcular ventas con descuento.
FROM samples.tpch.lineitem AS l
-- JOIN con orders conecta cada línea con la fecha del pedido.
INNER JOIN samples.tpch.orders AS o
  ON l.l_orderkey = o.o_orderkey
-- JOIN con customer conecta el pedido con el cliente.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation enlaza país del cliente.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region entrega la dimensión regional.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY define una fila por año y región.
GROUP BY YEAR(o.o_orderdate), r.r_name
-- ORDER BY organiza la lectura cronológica y geográfica.
ORDER BY anio, ingreso_neto DESC;

-- COMMAND ----------

-- Solución individual 2: descuento promedio por región.
-- ¿Por qué así?: el descuento promedio puede revelar agresividad comercial por mercado.
-- Resultado esperado: una fila por región con descuento promedio y número de líneas.
SELECT
  -- La región es la dimensión de negocio.
  r.r_name AS region,
  -- AVG(l_discount) resume el descuento medio otorgado en la región.
  ROUND(AVG(l.l_discount), 4) AS descuento_promedio,
  -- COUNT(*) cuantifica la base de líneas usada en el promedio.
  COUNT(*) AS total_lineas
-- FROM usa lineitem porque el descuento está a nivel de línea.
FROM samples.tpch.lineitem AS l
-- JOIN con orders conecta la línea con el cliente del pedido.
INNER JOIN samples.tpch.orders AS o
  ON l.l_orderkey = o.o_orderkey
-- JOIN con customer identifica el mercado del comprador.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation enlaza el país.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region entrega la dimensión final.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY resume por región.
GROUP BY r.r_name
-- ORDER BY facilita comparar políticas comerciales.
ORDER BY descuento_promedio DESC;

-- COMMAND ----------

-- Solución individual 3: cantidad de productos distintos suministrados por país del proveedor.
-- ¿Por qué así?: COUNT(DISTINCT) es útil cuando interesa variedad y no número de líneas.
-- Resultado esperado: una fila por país proveedor con número de productos únicos.
SELECT
  -- El país del proveedor define el grupo.
  n.n_name AS pais_proveedor,
  -- COUNT(DISTINCT l_partkey) cuenta productos únicos asociados a proveedores del país.
  COUNT(DISTINCT l.l_partkey) AS productos_distintos,
  -- COUNT(DISTINCT s_suppkey) aporta contexto de cuántos proveedores participan.
  COUNT(DISTINCT s.s_suppkey) AS proveedores_distintos
-- FROM parte desde supplier porque el foco es el origen del proveedor.
FROM samples.tpch.supplier AS s
-- JOIN con nation para recuperar el país del proveedor.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- JOIN con lineitem para observar qué productos despacha cada proveedor.
INNER JOIN samples.tpch.lineitem AS l
  ON s.s_suppkey = l.l_suppkey
-- GROUP BY crea una fila por país proveedor.
GROUP BY n.n_name
-- ORDER BY prioriza países con mayor diversidad de productos.
ORDER BY productos_distintos DESC, proveedores_distintos DESC;

-- COMMAND ----------

-- Solución individual 4: años con ticket promedio alto usando WHERE y HAVING correctamente.
-- ¿Por qué así?: WHERE limita filas base y HAVING filtra años según su promedio ya calculado.
-- Resultado esperado: años entre 1993 y 1997 cuyo ticket promedio supera 200000.
SELECT
  -- YEAR(o_orderdate) construye la dimensión anual.
  YEAR(o_orderdate) AS anio,
  -- COUNT(*) muestra cuántos pedidos forman el promedio anual.
  COUNT(*) AS total_pedidos,
  -- AVG(o_totalprice) calcula el ticket promedio del año.
  ROUND(AVG(o_totalprice), 2) AS ticket_promedio
-- FROM usa la tabla de pedidos.
FROM samples.tpch.orders
-- WHERE filtra el rango de fechas antes de agrupar.
WHERE o_orderdate >= DATE('1993-01-01')
  -- Este límite superior mantiene el análisis hasta antes de 1998.
  AND o_orderdate < DATE('1998-01-01')
-- GROUP BY resume por año.
GROUP BY YEAR(o_orderdate)
-- HAVING retiene solo los años con ticket promedio alto.
HAVING AVG(o_totalprice) > 200000
-- ORDER BY presenta los años en secuencia temporal.
ORDER BY anio;

-- COMMAND ----------

-- Solución individual 5: resumen flexible con GROUPING SETS.
-- ¿Por qué así?: GROUPING SETS permite reunir varios reportes en una sola consulta controlada.
-- Resultado esperado: detalle por región-año, por segmento-año y total anual.
SELECT
  -- Etiquetamos la región o el nivel agregado correspondiente.
  CASE WHEN GROUPING(r.r_name) = 1 THEN 'TODAS_LAS_REGIONES' ELSE r.r_name END AS region,
  -- Etiquetamos el segmento o el nivel agregado correspondiente.
  CASE WHEN GROUPING(c.c_mktsegment) = 1 THEN 'TODOS_LOS_SEGMENTOS' ELSE c.c_mktsegment END AS segmento,
  -- El año también puede aparecer como subtotal si se agregara, pero aquí siempre permanece en el grupo.
  YEAR(o.o_orderdate) AS anio,
  -- SUM resume el valor de pedidos en cada conjunto definido.
  ROUND(SUM(o.o_totalprice), 2) AS ingreso_total
-- FROM usa pedidos como hecho base.
FROM samples.tpch.orders AS o
-- JOIN con customer añade el segmento.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation habilita la región.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region añade la etiqueta regional.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY GROUPING SETS solicita exactamente tres reportes en una sola salida.
GROUP BY GROUPING SETS ((r.r_name, YEAR(o.o_orderdate)), (c.c_mktsegment, YEAR(o.o_orderdate)), (YEAR(o.o_orderdate)))
-- ORDER BY hace legible la mezcla de niveles.
ORDER BY anio, region, segmento;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Desafío
-- MAGIC
-- MAGIC Estas consultas elevan el nivel analítico. Intenta entender la lógica de negocio antes de ejecutarlas.
-- MAGIC
-- MAGIC ### Enfoques avanzados de esta sección
-- MAGIC | Desafío | Concepto dominante |
-- MAGIC |---|---|
-- MAGIC | 1 | porcentaje de participación por región y segmento |
-- MAGIC | 2 | `ROLLUP` temporal con ventas |
-- MAGIC | 3 | `CUBE` de región y prioridad |
-- MAGIC | 4 | `GROUPING SETS` con marca de producto |
-- MAGIC | 5 | comparación contra promedio global |
-- MAGIC
-- MAGIC > **📝 Nota:** Un buen desafío no es solo escribir SQL que corra; es escribir SQL que entregue una historia clara para la toma de decisiones.
-- COMMAND ----------

-- Desafío 1: participación del ingreso por región y segmento.
-- ¿Por qué así?: combina análisis dimensional con porcentaje sobre el total global del reporte.
-- Resultado esperado: una fila por región-segmento con ingreso y share porcentual.
WITH ingreso_region_segmento AS (
  -- Agregamos primero al nivel analítico deseado para simplificar el cálculo del porcentaje.
  SELECT
    -- La región será una de las dimensiones del resumen.
    r.r_name AS region,
    -- El segmento será la segunda dimensión del resumen.
    c.c_mktsegment AS segmento,
    -- Sumamos ingreso neto a partir del detalle de líneas.
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS ingreso_neto
  -- FROM parte desde lineitem para usar descuento real.
  FROM samples.tpch.lineitem AS l
  -- JOIN con orders conecta la línea con el cliente.
  INNER JOIN samples.tpch.orders AS o
    ON l.l_orderkey = o.o_orderkey
  -- JOIN con customer expone el segmento del cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- JOIN con nation enlaza el país.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- JOIN con region entrega la región del cliente.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- GROUP BY define una fila por región y segmento.
  GROUP BY r.r_name, c.c_mktsegment
)
-- Calculamos la participación usando una ventana sobre el conjunto ya agregado.
SELECT
  -- Mostramos la región del grupo.
  region,
  -- Mostramos el segmento del grupo.
  segmento,
  -- Redondeamos el ingreso neto para reporte.
  ROUND(ingreso_neto, 2) AS ingreso_neto,
  -- Dividimos el ingreso del grupo entre el total agregado de todos los grupos.
  ROUND(100.0 * ingreso_neto / SUM(ingreso_neto) OVER (), 2) AS porcentaje_total
-- FROM usa la CTE agregada.
FROM ingreso_region_segmento
-- ORDER BY prioriza los grupos con mayor participación.
ORDER BY porcentaje_total DESC, region, segmento;

-- COMMAND ----------

-- Desafío 2: ROLLUP de ventas por año y mes con ingreso neto.
-- ¿Por qué así?: combina la jerarquía temporal con una métrica de negocio más rica que el total del pedido.
-- Resultado esperado: detalle mes a mes, subtotal anual y total general.
WITH lineas_calendario AS (
  -- Preparamos el calendario y las columnas necesarias antes del rollup para evitar repetir expresiones.
  SELECT
    -- YEAR(o_orderdate) se guarda como columna para reutilizarla con claridad.
    YEAR(o.o_orderdate) AS anio_num,
    -- MONTH(o_orderdate) se guarda como columna para reutilizarla con claridad.
    MONTH(o.o_orderdate) AS mes_num,
    -- Conservamos el identificador del pedido para contar pedidos únicos luego.
    o.o_orderkey,
    -- Conservamos el ingreso neto por línea para agregarlo después.
    l.l_extendedprice * (1 - l.l_discount) AS ingreso_neto_linea
  -- FROM parte desde lineitem porque queremos ingreso neto real.
  FROM samples.tpch.lineitem AS l
  -- JOIN con orders aporta la fecha y la llave del pedido.
  INNER JOIN samples.tpch.orders AS o
    ON l.l_orderkey = o.o_orderkey
)
-- Aplicamos el rollup sobre el calendario ya preparado.
SELECT
  -- Etiquetamos el año o el total general dependiendo del nivel del rollup.
  CASE WHEN GROUPING(anio_num) = 1 THEN 'TOTAL_GENERAL' ELSE CAST(anio_num AS STRING) END AS anio,
  -- Etiquetamos el mes o el subtotal anual dependiendo del nivel del rollup.
  CASE WHEN GROUPING(mes_num) = 1 THEN 'TOTAL_MES' ELSE LPAD(CAST(mes_num AS STRING), 2, '0') END AS mes,
  -- Sumamos ingreso neto por nivel de agregación.
  ROUND(SUM(ingreso_neto_linea), 2) AS ingreso_neto,
  -- COUNT(DISTINCT) cuenta pedidos únicos por nivel para evitar confundir líneas con pedidos.
  COUNT(DISTINCT o_orderkey) AS pedidos_unicos
-- FROM consume la CTE con calendario y métricas preparadas.
FROM lineas_calendario
-- GROUP BY ROLLUP genera detalle mensual, subtotal anual y total general.
GROUP BY ROLLUP (anio_num, mes_num)
-- ORDER BY organiza la salida como una tabla de control temporal.
ORDER BY anio, mes;

-- COMMAND ----------

-- Desafío 3: CUBE entre región y prioridad del pedido.
-- ¿Por qué así?: sirve para tableros donde se quiere analizar todas las vistas cruzadas posibles.
-- Resultado esperado: detalle región-prioridad, subtotales por región, por prioridad y total global.
SELECT
  -- Etiquetamos la región según el nivel del cubo.
  CASE WHEN GROUPING(r.r_name) = 1 THEN 'TOTAL_REGION' ELSE r.r_name END AS region,
  -- Etiquetamos la prioridad según el nivel del cubo.
  CASE WHEN GROUPING(o.o_orderpriority) = 1 THEN 'TOTAL_PRIORIDAD' ELSE o.o_orderpriority END AS prioridad,
  -- COUNT(*) mide volumen de pedidos por celda del cubo.
  COUNT(*) AS total_pedidos,
  -- AVG(o_totalprice) resume el valor medio de la celda.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio
-- FROM usa pedidos como hecho.
FROM samples.tpch.orders AS o
-- JOIN con customer conecta cliente y geografía.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation añade el país.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region añade la dimensión regional.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY CUBE produce todas las combinaciones relevantes.
GROUP BY CUBE (r.r_name, o.o_orderpriority)
-- ORDER BY hace navegable la matriz resultante.
ORDER BY region, prioridad;

-- COMMAND ----------

-- Desafío 4: GROUPING SETS de región y marca de producto.
-- ¿Por qué así?: permite entregar en una sola consulta el detalle región-marca, total regional, total por marca y total global.
-- Resultado esperado: salida útil para un tablero comercial de portafolio.
SELECT
  -- Etiquetamos la región o su total correspondiente.
  CASE WHEN GROUPING(r.r_name) = 1 THEN 'TOTAL_REGION' ELSE r.r_name END AS region,
  -- Etiquetamos la marca o su total correspondiente.
  CASE WHEN GROUPING(p.p_brand) = 1 THEN 'TOTAL_MARCA' ELSE p.p_brand END AS marca,
  -- Sumamos unidades para medir volumen comercial.
  SUM(l.l_quantity) AS unidades_vendidas,
  -- Sumamos ingreso neto para medir monetización.
  ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS ingreso_neto
-- FROM parte desde lineitem.
FROM samples.tpch.lineitem AS l
-- JOIN con part aporta la marca del producto.
INNER JOIN samples.tpch.part AS p
  ON l.l_partkey = p.p_partkey
-- JOIN con orders conecta la línea con el cliente.
INNER JOIN samples.tpch.orders AS o
  ON l.l_orderkey = o.o_orderkey
-- JOIN con customer conecta el pedido con la geografía.
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
-- JOIN con nation enlaza el país del cliente.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- JOIN con region entrega la región del cliente.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- GROUP BY GROUPING SETS pide exactamente los cuatro niveles requeridos.
GROUP BY GROUPING SETS ((r.r_name, p.p_brand), (r.r_name), (p.p_brand), ())
-- ORDER BY ayuda a revisar detalle y subtotales de forma ordenada.
ORDER BY region, marca;

-- COMMAND ----------

-- Desafío 5: meses cuyo ingreso supera el promedio mensual global.
-- ¿Por qué así?: compara cada grupo contra una referencia agregada general para detectar meses sobresalientes.
-- Resultado esperado: meses por encima del promedio de ingreso mensual del conjunto completo.
WITH ingreso_por_mes AS (
  -- Agregamos primero el ingreso por mes.
  SELECT
    -- DATE_TRUNC crea una clave temporal consistente por mes.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- SUM agrega el valor total del pedido dentro de cada mes.
    SUM(o.o_totalprice) AS ingreso_mensual
  -- FROM usa pedidos como fuente.
  FROM samples.tpch.orders AS o
  -- GROUP BY resume por mes.
  GROUP BY DATE_TRUNC('month', o.o_orderdate)
),
promedio_global AS (
  -- Calculamos el promedio mensual global en una segunda CTE para poder reutilizarlo en SELECT y WHERE.
  SELECT
    -- AVG sobre el ingreso mensual entrega la referencia contra la que compararemos cada mes.
    AVG(ingreso_mensual) AS promedio_mensual_global
  -- FROM consume la CTE con un registro por mes.
  FROM ingreso_por_mes
)
-- Filtramos comparando cada mes contra el promedio global de la serie mensual.
SELECT
  -- Mostramos el mes analizado.
  i.mes,
  -- Redondeamos el ingreso mensual para reporte.
  ROUND(i.ingreso_mensual, 2) AS ingreso_mensual,
  -- Calculamos también la desviación respecto del promedio para interpretación adicional.
  ROUND(i.ingreso_mensual - p.promedio_mensual_global, 2) AS diferencia_vs_promedio
-- FROM consume la CTE con el ingreso mensual ya resumido.
FROM ingreso_por_mes AS i
-- CROSS JOIN incorpora la referencia global a cada fila mensual sin cambiar el número de meses.
CROSS JOIN promedio_global AS p
-- WHERE filtra meses individuales usando el promedio global ya materializado.
WHERE i.ingreso_mensual > p.promedio_mensual_global
-- ORDER BY prioriza los meses más fuertes.
ORDER BY ingreso_mensual DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Resumen
-- MAGIC
-- MAGIC ### Ideas clave de este notebook
-- MAGIC - `COUNT(*)` cuenta filas; `COUNT(columna)` ignora `NULL`.
-- MAGIC - `COUNT(DISTINCT)` sirve para cardinalidad única, no para volumen bruto.
-- MAGIC - `GROUP BY` define el **nivel de detalle** del resultado.
-- MAGIC - `HAVING` filtra grupos; `WHERE` filtra filas antes de agrupar.
-- MAGIC - `ROLLUP` agrega subtotales jerárquicos.
-- MAGIC - `CUBE` crea todas las combinaciones de subtotales entre dimensiones.
-- MAGIC - `GROUPING SETS` ofrece control explícito de qué resúmenes generar.
-- MAGIC - `CASE WHEN` es ideal para construir categorías analíticas antes de agregar.
-- MAGIC - Los porcentajes requieren una base claramente definida: por grupo, por subtotal o por total general.
-- MAGIC
-- MAGIC ### Lista de chequeo mental
-- MAGIC | Pregunta | Sí/No |
-- MAGIC |---|---|
-- MAGIC | ¿Definí el grano del análisis? |  |
-- MAGIC | ¿Toda columna del `SELECT` está agregada o en `GROUP BY`? |  |
-- MAGIC | ¿Los filtros de detalle van en `WHERE`? |  |
-- MAGIC | ¿Los filtros de grupo van en `HAVING`? |  |
-- MAGIC | ¿Validé el impacto de `NULL` y de los joins? |  |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Laboratorio
-- MAGIC
-- MAGIC ### Preguntas reales de negocio para DataCorp Analytics
-- MAGIC 1. ¿Qué región concentra la mayor parte del ingreso neto y qué porcentaje representa sobre el total?
-- MAGIC 2. ¿Qué segmento de cliente tiene el ticket promedio más alto en cada región?
-- MAGIC 3. ¿En qué meses cae el volumen de pedidos y cómo cambia el ingreso mensual?
-- MAGIC 4. ¿Qué marcas o productos combinan alto volumen con alto ingreso?
-- MAGIC 5. ¿Qué prioridades de pedido dominan en cada región?
-- MAGIC 6. ¿Qué países proveedores tienen suficiente escala y diversidad de productos?
-- MAGIC 7. ¿Qué subtotales conviene mostrar en el dashboard ejecutivo: por región, por segmento o ambos?
-- MAGIC
-- MAGIC ### Sugerencia de dinámica de laboratorio
-- MAGIC | Paso | Acción |
-- MAGIC |---|---|
-- MAGIC | 1 | Formular la pregunta en lenguaje de negocio |
-- MAGIC | 2 | Definir la métrica y el grano |
-- MAGIC | 3 | Seleccionar tablas y joins |
-- MAGIC | 4 | Escribir la agregación |
-- MAGIC | 5 | Validar resultados y explicar hallazgos |
-- MAGIC
-- MAGIC ## 14. Autoevaluación
-- MAGIC
-- MAGIC Marca si puedes resolver cada punto sin ayuda:
-- MAGIC
-- MAGIC - [ ] Explico la diferencia entre `COUNT(*)` y `COUNT(columna)`.
-- MAGIC - [ ] Sé cuándo usar `WHERE` y cuándo usar `HAVING`.
-- MAGIC - [ ] Puedo corregir un error por columna no agregada.
-- MAGIC - [ ] Puedo crear resúmenes por dos o más dimensiones.
-- MAGIC - [ ] Puedo calcular un porcentaje sobre el total con agregaciones.
-- MAGIC - [ ] Puedo usar `ROLLUP`, `CUBE` y `GROUPING SETS` según la necesidad.
-- MAGIC - [ ] Puedo justificar por qué una consulta responde una pregunta real de BI.
-- MAGIC
-- MAGIC > **📝 Nota:** Si todavía dudas en alguno de los puntos, vuelve a las secciones 6 a 11 y repite las consultas cambiando la dimensión de análisis.
