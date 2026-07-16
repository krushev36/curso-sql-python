-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Notebook 07: Window Functions
-- MAGIC ## Fundamentos de Programación
-- MAGIC ### Maestría en Ciencia de Datos · Universidad de Antioquia
-- MAGIC ## 1. Bienvenida
-- MAGIC
-- MAGIC Bienvenidos al séptimo notebook del curso **Fundamentos de Programación** de la **Maestría en Ciencia de Datos** de la **Universidad de Antioquia**.
-- MAGIC
-- MAGIC En esta sesión asumirás el rol de **Data Analyst en DataCorp Analytics**. El CFO necesita análisis avanzados que no destruyan el detalle original: acumulados, rankings, comparaciones mes contra mes, percentiles y señales tempranas de tendencia.
-- MAGIC
-- MAGIC Las **window functions** resuelven exactamente ese problema: permiten calcular métricas analíticas **sin colapsar las filas** como ocurre con `GROUP BY`.
-- MAGIC
-- MAGIC ### Idea central
-- MAGIC | Pregunta del negocio | ¿Basta con `GROUP BY`? | ¿Se beneficia de ventanas? |
-- MAGIC |---|---|---|
-- MAGIC | ¿Cuál es el total por región? | Sí | A veces |
-- MAGIC | ¿Cómo se compara cada pedido con el promedio de su región? | No | Sí |
-- MAGIC | ¿Cuál es el ranking de clientes dentro de cada segmento? | No | Sí |
-- MAGIC | ¿Cuál es el acumulado mes a mes sin perder el mes individual? | No | Sí |
-- MAGIC
-- MAGIC > **📝 Nota:** Piensa en una ventana como un **subconjunto dinámico de filas relacionadas** con la fila actual. SQL calcula sobre ese subconjunto y luego devuelve el resultado en la misma fila.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC
-- MAGIC Al finalizar este notebook podrás:
-- MAGIC
-- MAGIC 1. Explicar qué es una función de ventana y por qué es más poderosa que una agregación simple en ciertos escenarios.
-- MAGIC 2. Describir la anatomía de `OVER()` y el papel de `PARTITION BY`, `ORDER BY` y el frame.
-- MAGIC 3. Aplicar funciones de ranking: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` y `NTILE()`.
-- MAGIC 4. Aplicar funciones de desplazamiento: `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()` y `NTH_VALUE()`.
-- MAGIC 5. Construir acumulados, medias móviles, porcentajes del total y percentiles.
-- MAGIC 6. Usar `QUALIFY` en Databricks para filtrar directamente resultados basados en funciones de ventana.
-- MAGIC 7. Diseñar variables derivadas útiles para *feature engineering* en proyectos de analítica avanzada y ML.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias
-- MAGIC
-- MAGIC ### Competencias técnicas
-- MAGIC - Construir consultas con ventanas manteniendo el nivel de detalle correcto.
-- MAGIC - Seleccionar la partición y el orden adecuados según la pregunta de negocio.
-- MAGIC - Elegir el frame correcto para evitar resultados engañosos.
-- MAGIC
-- MAGIC ### Competencias analíticas
-- MAGIC - Detectar líderes, rezagos, cambios de tendencia y concentración de ingresos.
-- MAGIC - Traducir preguntas ejecutivas a patrones analíticos reproducibles.
-- MAGIC - Comparar individuos contra su grupo de referencia sin perder granularidad.
-- MAGIC
-- MAGIC ### Competencias profesionales
-- MAGIC | Competencia | Evidencia esperada |
-- MAGIC |---|---|
-- MAGIC | Comunicación analítica | Explicas por qué la ventana responde mejor la pregunta |
-- MAGIC | Calidad SQL | Comentarios claros, alias semánticos y orden lógico |
-- MAGIC | Pensamiento crítico | Detectas errores de partición, orden y frame |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC
-- MAGIC En **DataCorp Analytics**, el CFO revisa desempeño comercial, estabilidad de ingresos y riesgos de concentración. El problema es que varios reportes actuales solo entregan agregados finales y no permiten responder preguntas como:
-- MAGIC
-- MAGIC 1. ¿Qué pedido está muy por encima del promedio de su segmento?
-- MAGIC 2. ¿Qué clientes vienen perdiendo dinamismo mes a mes?
-- MAGIC 3. ¿Qué regiones explican la mayor parte del ingreso total?
-- MAGIC 4. ¿Qué proveedores o productos están en percentiles extremos?
-- MAGIC 5. ¿Qué variables históricas pueden alimentar un modelo predictivo?
-- MAGIC
-- MAGIC ### Datasets del notebook
-- MAGIC | Dataset | Uso analítico principal |
-- MAGIC |---|---|
-- MAGIC | `samples.tpch.customer` | segmentos, cuentas y clientes |
-- MAGIC | `samples.tpch.orders` | historial de pedidos y valor monetario |
-- MAGIC | `samples.tpch.lineitem` | detalle transaccional por ítem |
-- MAGIC | `samples.tpch.part` | catálogo de productos |
-- MAGIC | `samples.tpch.supplier` | proveedores |
-- MAGIC | `samples.tpch.nation` | país |
-- MAGIC | `samples.tpch.region` | región |
-- MAGIC | `samples.nyctaxi.trips` | referencia opcional para series temporales urbanas |
-- MAGIC
-- MAGIC > **📝 Nota:** En este notebook trabajaremos principalmente con TPCH porque ofrece relaciones claras entre clientes, pedidos, productos, proveedores y regiones.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos
-- MAGIC
-- MAGIC ### 5.1 ¿Qué es una window function?
-- MAGIC Una función de ventana calcula un valor usando varias filas relacionadas con la fila actual, **pero devuelve el resultado sin agrupar ni eliminar filas**.
-- MAGIC
-- MAGIC ```text
-- MAGIC GROUP BY colapsa filas
-- MAGIC cliente  pedido  valor    ->   cliente  total
-- MAGIC A        1       100          A        250
-- MAGIC A        2       150
-- MAGIC
-- MAGIC Window function conserva filas
-- MAGIC cliente  pedido  valor  total_cliente
-- MAGIC A        1       100    250
-- MAGIC A        2       150    250
-- MAGIC ```
-- MAGIC
-- MAGIC ### 5.2 Anatomía de `OVER()`
-- MAGIC | Componente | Función | Ejemplo conceptual |
-- MAGIC |---|---|---|
-- MAGIC | `OVER()` | activa el comportamiento de ventana | `SUM(x) OVER()` |
-- MAGIC | `PARTITION BY` | divide en grupos lógicos sin colapsar filas | `PARTITION BY region` |
-- MAGIC | `ORDER BY` | define secuencia dentro de la ventana | `ORDER BY fecha` |
-- MAGIC | `ROWS BETWEEN` / `RANGE BETWEEN` | define qué filas exactas entran al cálculo | acumulado, media móvil |
-- MAGIC
-- MAGIC ### 5.3 Tipos frecuentes
-- MAGIC - **Ranking:** posición relativa dentro de un grupo.
-- MAGIC - **Offset:** comparación con filas previas o siguientes.
-- MAGIC - **Agregadas sobre ventana:** suma, promedio, conteo, mínimo, máximo por grupo o recorrido.
-- MAGIC - **Percentiles y distribución:** concentración y posición acumulada.
-- MAGIC
-- MAGIC ### 5.4 Frame de ventana
-- MAGIC
-- MAGIC ```text
-- MAGIC Fila actual = mes 4
-- MAGIC
-- MAGIC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
-- MAGIC [mes 2] [mes 3] [mes 4]
-- MAGIC
-- MAGIC RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
-- MAGIC incluye filas cuyo valor de orden está entre (valor_actual - 1) y valor_actual
-- MAGIC ```
-- MAGIC
-- MAGIC ### 5.5 Errores comunes
-- MAGIC | Error | Qué ocurre | Cómo evitarlo |
-- MAGIC |---|---|---|
-- MAGIC | Olvidar `ORDER BY` en acumulados | la suma no sigue secuencia temporal | ordenar por fecha o secuencia |
-- MAGIC | Usar `LAST_VALUE()` sin frame completo | devuelve el valor de la fila actual y no el último total | usar `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` |
-- MAGIC | Elegir mal `PARTITION BY` | comparas elementos de grupos incorrectos | revisar grano y pregunta del negocio |
-- MAGIC | Filtrar con `WHERE` una función ventana | error semántico | usar subconsulta o `QUALIFY` |
-- MAGIC
-- MAGIC > **📝 Nota:** La regla mental es: **ventana = quiénes participan (`PARTITION BY`), en qué orden (`ORDER BY`) y hasta dónde llega el cálculo (frame)**.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso
-- MAGIC
-- MAGIC ### Método recomendado
-- MAGIC 1. **Define el grano actual**: pedido, cliente-mes, proveedor-día, etc.
-- MAGIC 2. **Define la comparación**: contra sí mismo, contra su grupo o contra el histórico.
-- MAGIC 3. **Elige la partición**: ¿por segmento, región, cliente o proveedor?
-- MAGIC 4. **Elige el orden**: ¿fecha, monto, cantidad, prioridad?
-- MAGIC 5. **Define el frame**: ¿toda la historia, solo ventanas móviles o rango de valores?
-- MAGIC 6. **Valida el resultado** con pocas filas antes de escalar.
-- MAGIC
-- MAGIC ### Patrón mental
-- MAGIC
-- MAGIC ```text
-- MAGIC Tabla base -> definir grano -> crear ventana -> calcular -> interpretar
-- MAGIC ```
-- MAGIC
-- MAGIC ### Cuándo usar cada familia
-- MAGIC | Necesidad | Patrón recomendado |
-- MAGIC |---|---|
-- MAGIC | Ranking top N | `ROW_NUMBER`, `RANK`, `DENSE_RANK` + `QUALIFY` |
-- MAGIC | Comparar con fila previa | `LAG` |
-- MAGIC | Proyección siguiente | `LEAD` |
-- MAGIC | Acumulado | `SUM() OVER (ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` |
-- MAGIC | Media móvil | `AVG() OVER (ORDER BY ... ROWS BETWEEN n PRECEDING AND CURRENT ROW)` |
-- MAGIC | Participación porcentual | `valor / SUM(valor) OVER (...)` |
-- MAGIC | Percentil relativo | `PERCENT_RANK`, `CUME_DIST`, `NTILE` |
-- MAGIC
-- MAGIC > **📝 Nota:** Cuando una consulta con ventanas se vuelve compleja, usa una **CTE** para separar el cálculo base del cálculo analítico. Mejora legibilidad y reduce errores.
-- COMMAND ----------

-- Ejemplo completamente explicado 1: comparar cada pedido contra el promedio global.
-- ¿Por qué esta consulta?: porque demuestra que una ventana agrega contexto sin perder cada pedido.
-- ¿Qué cláusulas debes observar?: OVER() sin partición ni orden significa "todas las filas visibles".
-- Resultado esperado: cada pedido conserva su fila y añade el promedio global y su desviación.
-- Error común evitado: usar GROUP BY y perder el pedido individual.
SELECT
  -- Conservamos la llave del pedido para mantener el detalle transaccional.
  o_orderkey,
  -- Conservamos la llave del cliente para saber quién hizo el pedido.
  o_custkey,
  -- Mostramos el valor del pedido como métrica base.
  o_totalprice,
  -- AVG() OVER() calcula el promedio sobre todas las filas filtradas sin colapsarlas.
  AVG(o_totalprice) OVER () AS promedio_global_pedido,
  -- Restamos el promedio global al valor del pedido para medir desviación absoluta.
  o_totalprice - AVG(o_totalprice) OVER () AS desviacion_vs_promedio
-- FROM indica la tabla de pedidos como fuente de análisis.
FROM samples.tpch.orders
-- WHERE restringe el ejemplo a un periodo corto para facilitar lectura.
WHERE o_orderdate >= DATE '1995-01-01'
  -- Esta segunda condición cierra el periodo en marzo de 1995.
  AND o_orderdate < DATE '1995-04-01'
-- ORDER BY prioriza los pedidos de mayor valor para ver extremos con facilidad.
ORDER BY o_totalprice DESC, o_orderkey
-- LIMIT reduce la salida y hace visible la lógica del ejemplo.
LIMIT 20;

-- COMMAND ----------

-- Ejemplo completamente explicado 2: usar PARTITION BY para comparar cada pedido contra su región.
-- ¿Por qué esta consulta?: porque el CFO no solo quiere ver un pedido, sino su contexto regional.
-- ¿Qué hace la partición?: crea una ventana independiente por región sin mezclar regiones.
-- Resultado esperado: cada fila muestra pedidos de su región, el total regional y el ticket promedio regional.
-- Error común evitado: particionar por cliente cuando la pregunta es regional.
WITH pedidos_region AS (
  -- La CTE prepara una base detallada de pedido con región asociada.
  SELECT
    -- Conservamos el identificador del pedido.
    o.o_orderkey,
    -- Conservamos el valor del pedido.
    o.o_totalprice,
    -- Traemos el segmento del cliente para análisis complementario.
    c.c_mktsegment,
    -- Traducimos la jerarquía geográfica hasta región.
    r.r_name AS region
  -- FROM inicia en orders porque el pedido es el hecho principal.
  FROM samples.tpch.orders AS o
  -- JOIN con customer conecta cada pedido con su cliente.
  INNER JOIN samples.tpch.customer AS c
    -- La llave del cliente vincula pedido y cliente.
    ON o.o_custkey = c.c_custkey
  -- JOIN con nation permite pasar del cliente a su país.
  INNER JOIN samples.tpch.nation AS n
    -- La nación del cliente habilita la ruta hacia región.
    ON c.c_nationkey = n.n_nationkey
  -- JOIN con region completa la geografía del pedido.
  INNER JOIN samples.tpch.region AS r
    -- La región se obtiene desde la nación.
    ON n.n_regionkey = r.r_regionkey
)
-- La consulta final calcula métricas ventana sobre la base ya enriquecida.
SELECT
  -- Mostramos la región de cada pedido.
  region,
  -- Conservamos el pedido individual.
  o_orderkey,
  -- Conservamos el segmento por claridad contextual.
  c_mktsegment,
  -- Conservamos el valor base del pedido.
  o_totalprice,
  -- COUNT(*) OVER(PARTITION BY region) cuenta cuántos pedidos tiene la región en el conjunto visible.
  COUNT(*) OVER (PARTITION BY region) AS pedidos_en_region,
  -- SUM() OVER(PARTITION BY region) suma el ingreso total de la región sin perder el pedido.
  SUM(o_totalprice) OVER (PARTITION BY region) AS ingreso_total_region,
  -- AVG() OVER(PARTITION BY region) calcula el ticket promedio de la región.
  AVG(o_totalprice) OVER (PARTITION BY region) AS ticket_promedio_region
-- FROM consume la CTE con región ya resuelta.
FROM pedidos_region
-- ORDER BY agrupa visualmente por región y destaca pedidos grandes dentro de cada una.
ORDER BY region, o_totalprice DESC, o_orderkey
-- LIMIT evita una salida demasiado extensa en el notebook.
LIMIT 25;

-- COMMAND ----------

-- Ejemplo completamente explicado 3: acumulado mensual de ingresos.
-- ¿Por qué esta consulta?: el CFO necesita ver cómo crece el ingreso a lo largo del tiempo.
-- ¿Qué hace ORDER BY dentro de OVER?: define la secuencia temporal del acumulado.
-- ¿Qué hace el frame?: desde el primer mes hasta el mes actual.
-- Resultado esperado: el ingreso acumulado nunca disminuye dentro del año.
WITH ingresos_mensuales AS (
  -- La CTE agrega pedidos al nivel mes, porque el acumulado se calcula sobre meses.
  SELECT
    -- DATE_TRUNC agrupa todas las fechas al primer día del mes.
    DATE_TRUNC('month', o_orderdate) AS mes,
    -- SUM resume el ingreso del mes antes de aplicar la ventana.
    SUM(o_totalprice) AS ingreso_mensual
  -- FROM toma la tabla de pedidos como fuente monetaria.
  FROM samples.tpch.orders
  -- WHERE limita el análisis al año 1995 para mantener continuidad temporal simple.
  WHERE YEAR(o_orderdate) = 1995
  -- GROUP BY define una fila por mes.
  GROUP BY DATE_TRUNC('month', o_orderdate)
)
-- La consulta final aplica la ventana sobre el resultado mensual.
SELECT
  -- Mostramos el mes como dimensión temporal.
  mes,
  -- Mostramos el ingreso del mes.
  ingreso_mensual,
  -- SUM OVER ordenado por mes produce un running total o acumulado.
  SUM(ingreso_mensual) OVER (
    -- ORDER BY establece el orden cronológico del acumulado.
    ORDER BY mes
    -- ROWS define que el frame va desde el inicio hasta la fila actual.
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS ingreso_acumulado
-- FROM usa la serie mensual ya agregada.
FROM ingresos_mensuales
-- ORDER BY mantiene la lectura cronológica del resultado.
ORDER BY mes;

-- COMMAND ----------

-- Ejemplo completamente explicado 4: media móvil de tres meses.
-- ¿Por qué esta consulta?: porque suaviza volatilidad y ayuda a detectar tendencia real.
-- ¿Qué hace el frame ROWS BETWEEN 2 PRECEDING AND CURRENT ROW?: toma el mes actual y los dos anteriores.
-- Resultado esperado: los primeros meses usan menos observaciones porque no existe historial suficiente.
-- Error común evitado: creer que siempre se usan exactamente tres filas en los primeros registros.
WITH ingresos_mensuales AS (
  -- Reutilizamos el grano mensual para calcular una tendencia suavizada.
  SELECT
    -- Mes calendario del pedido.
    DATE_TRUNC('month', o_orderdate) AS mes,
    -- Ingreso agregado del mes.
    SUM(o_totalprice) AS ingreso_mensual
  -- Fuente transaccional de pedidos.
  FROM samples.tpch.orders
  -- Se limita al año 1995 para una serie simple y ordenada.
  WHERE YEAR(o_orderdate) = 1995
  -- Una fila por mes.
  GROUP BY DATE_TRUNC('month', o_orderdate)
)
-- Aplicamos la ventana móvil sobre la serie mensual.
SELECT
  -- Dimensión temporal.
  mes,
  -- Métrica base del mes.
  ingreso_mensual,
  -- AVG OVER con frame móvil calcula el promedio de la ventana reciente.
  AVG(ingreso_mensual) OVER (
    -- ORDER BY define la progresión temporal.
    ORDER BY mes
    -- ROWS especifica dos meses previos y el actual.
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS media_movil_3_meses
-- La tabla fuente es la CTE mensual.
FROM ingresos_mensuales
-- El orden cronológico facilita ver la tendencia.
ORDER BY mes;

-- COMMAND ----------

-- Ejemplo completamente explicado 5: ranking de clientes por ingreso dentro de su segmento.
-- ¿Por qué esta consulta?: el negocio compara clientes contra pares, no contra toda la empresa.
-- ¿Qué diferencia hay entre ROW_NUMBER, RANK y DENSE_RANK?: manejan empates de forma distinta.
-- Resultado esperado: verás posiciones consecutivas, saltos por empate y cuartiles.
-- Error común evitado: usar ROW_NUMBER cuando los empates deberían compartir posición.
WITH ingreso_cliente AS (
  -- La CTE calcula el ingreso total por cliente y segmento.
  SELECT
    -- Llave del cliente.
    c.c_custkey,
    -- Nombre del cliente para lectura humana.
    c.c_name,
    -- Segmento comercial del cliente.
    c.c_mktsegment,
    -- Ingreso total generado por el cliente.
    SUM(o.o_totalprice) AS ingreso_total_cliente
  -- FROM inicia en customer para conservar atributos del cliente.
  FROM samples.tpch.customer AS c
  -- JOIN con orders enlaza los pedidos de cada cliente.
  INNER JOIN samples.tpch.orders AS o
    -- La llave del cliente vincula ambos datasets.
    ON c.c_custkey = o.o_custkey
  -- GROUP BY deja una fila por cliente dentro de su segmento.
  GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
)
-- La consulta final aplica múltiples funciones de ranking.
SELECT
  -- Segmento del cliente.
  c_mktsegment,
  -- Cliente identificado por nombre.
  c_name,
  -- Ingreso total usado para ordenar.
  ingreso_total_cliente,
  -- ROW_NUMBER fuerza una numeración única incluso con empates.
  ROW_NUMBER() OVER (
    -- La partición aísla el ranking por segmento.
    PARTITION BY c_mktsegment
    -- El orden descendente pone primero al cliente con mayor ingreso.
    ORDER BY ingreso_total_cliente DESC, c_name
  ) AS fila_unica_segmento,
  -- RANK asigna la misma posición a empates y luego deja huecos.
  RANK() OVER (
    PARTITION BY c_mktsegment
    ORDER BY ingreso_total_cliente DESC
  ) AS ranking_segmento,
  -- DENSE_RANK asigna la misma posición a empates pero sin huecos.
  DENSE_RANK() OVER (
    PARTITION BY c_mktsegment
    ORDER BY ingreso_total_cliente DESC
  ) AS ranking_denso_segmento,
  -- NTILE divide el segmento en cuatro grupos de tamaño casi igual.
  NTILE(4) OVER (
    PARTITION BY c_mktsegment
    ORDER BY ingreso_total_cliente DESC
  ) AS cuartil_segmento
-- FROM usa la base ya agregada por cliente.
FROM ingreso_cliente
-- ORDER BY facilita revisar un segmento completo de arriba abajo.
ORDER BY c_mktsegment, ingreso_total_cliente DESC, c_name
-- LIMIT mantiene el ejemplo manejable.
LIMIT 40;

-- COMMAND ----------

-- Ejemplo completamente explicado 6: funciones de desplazamiento y valores de referencia.
-- ¿Por qué esta consulta?: porque muchas preguntas ejecutivas implican comparar contra el periodo previo, siguiente o extremo.
-- ¿Qué debes notar?: LAST_VALUE necesita un frame completo para devolver el último mes total.
-- Resultado esperado: cada mes muestra ingreso previo, siguiente, primero, último y tercer valor de la serie.
WITH ingresos_mensuales AS (
  -- Preparamos una serie temporal mensual de ingresos.
  SELECT
    -- Mes del pedido truncado a nivel calendario.
    DATE_TRUNC('month', o_orderdate) AS mes,
    -- Ingreso agregado del mes.
    SUM(o_totalprice) AS ingreso_mensual
  -- Fuente de pedidos.
  FROM samples.tpch.orders
  -- Restricción temporal al año 1995.
  WHERE YEAR(o_orderdate) = 1995
  -- Una fila por mes.
  GROUP BY DATE_TRUNC('month', o_orderdate)
)
-- Aplicamos funciones offset y de referencia extrema.
SELECT
  -- Mostramos el mes.
  mes,
  -- Mostramos el ingreso observado.
  ingreso_mensual,
  -- LAG trae el ingreso del mes anterior.
  LAG(ingreso_mensual, 1) OVER (
    ORDER BY mes
  ) AS ingreso_mes_previo,
  -- LEAD trae el ingreso del mes siguiente.
  LEAD(ingreso_mensual, 1) OVER (
    ORDER BY mes
  ) AS ingreso_mes_siguiente,
  -- FIRST_VALUE devuelve el primer ingreso de toda la serie al usar frame completo.
  FIRST_VALUE(ingreso_mensual) OVER (
    ORDER BY mes
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS ingreso_primer_mes,
  -- LAST_VALUE devuelve el último ingreso de toda la serie solo porque el frame cubre toda la partición.
  LAST_VALUE(ingreso_mensual) OVER (
    ORDER BY mes
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS ingreso_ultimo_mes,
  -- NTH_VALUE devuelve el ingreso del tercer mes de la serie, útil como ancla comparativa.
  NTH_VALUE(ingreso_mensual, 3) OVER (
    ORDER BY mes
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS ingreso_tercer_mes
-- FROM usa la CTE mensual.
FROM ingresos_mensuales
-- ORDER BY mantiene secuencia temporal.
ORDER BY mes;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado
-- MAGIC
-- MAGIC Ya viste seis ejemplos completos. Observa cómo cambió el comportamiento según la combinación de:
-- MAGIC
-- MAGIC 1. **Sin partición:** referencia global.
-- MAGIC 2. **Con partición:** referencia por grupo.
-- MAGIC 3. **Con orden:** referencia secuencial.
-- MAGIC 4. **Con frame:** referencia controlada en tamaño o rango.
-- MAGIC
-- MAGIC > **📝 Nota:** En analítica real, la mayor parte de los errores con ventanas no están en la función (`SUM`, `AVG`, `LAG`), sino en una partición, orden o frame mal definidos.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado
-- MAGIC
-- MAGIC En esta sección el objetivo es que leas la consulta como si estuvieras acompañando a un analista junior. Cada ejemplo está resuelto, pero debes intentar anticipar el resultado antes de ejecutarlo.
-- COMMAND ----------

-- Ejemplo guiado 1: porcentaje del total por región.
-- ¿Por qué esta consulta?: porque el CFO necesita entender concentración de ingresos sin perder la fila regional.
-- ¿Qué aporta la ventana?: permite calcular el total general sin una subconsulta adicional.
-- Resultado esperado: una fila por región con su ingreso y su participación porcentual.
WITH ingreso_region AS (
  -- La CTE resume ingresos al nivel región.
  SELECT
    -- Nombre de la región como dimensión de análisis.
    r.r_name AS region,
    -- Suma total de pedidos asociados a clientes de la región.
    SUM(o.o_totalprice) AS ingreso_region
  -- La tabla de pedidos es la base monetaria.
  FROM samples.tpch.orders AS o
  -- Relacionamos con customer para llegar a la geografía.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Relacionamos con nation para seguir la jerarquía geográfica.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Relacionamos con region para la dimensión final.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Agrupamos porque aquí sí queremos una fila por región antes de calcular participación.
  GROUP BY r.r_name
)
-- La salida final añade el porcentaje del total corporativo.
SELECT
  -- Región analizada.
  region,
  -- Ingreso absoluto de la región.
  ingreso_region,
  -- La suma ventana sobre todas las regiones produce el total corporativo.
  SUM(ingreso_region) OVER () AS ingreso_total_corporativo,
  -- Dividimos el ingreso regional por el total para obtener participación relativa.
  ROUND(100 * ingreso_region / SUM(ingreso_region) OVER (), 2) AS porcentaje_del_total
-- FROM usa la CTE regional.
FROM ingreso_region
-- ORDER BY prioriza las regiones de mayor participación.
ORDER BY porcentaje_del_total DESC, region;

-- COMMAND ----------

-- Ejemplo guiado 2: percentiles relativos por segmento de cliente.
-- ¿Por qué esta consulta?: porque no basta con saber cuánto vende un cliente; también importa su posición relativa.
-- ¿Qué muestran PERCENT_RANK y CUME_DIST?: posición relativa y distribución acumulada.
-- Resultado esperado: clientes con mayor ingreso se acercan a 1 en ambas métricas.
WITH ingreso_cliente AS (
  -- Calculamos el ingreso por cliente dentro de su segmento.
  SELECT
    -- Segmento comercial del cliente.
    c.c_mktsegment,
    -- Nombre del cliente.
    c.c_name,
    -- Ingreso total del cliente.
    SUM(o.o_totalprice) AS ingreso_total_cliente
  -- La base monetaria es orders.
  FROM samples.tpch.customer AS c
  -- Unimos pedidos para sumar el valor histórico por cliente.
  INNER JOIN samples.tpch.orders AS o
    ON c.c_custkey = o.o_custkey
  -- Dejamos una fila por cliente y segmento.
  GROUP BY c.c_mktsegment, c.c_name
)
-- Aplicamos funciones de percentil sobre los ingresos por segmento.
SELECT
  -- Segmento de referencia.
  c_mktsegment,
  -- Cliente observado.
  c_name,
  -- Métrica base de ingreso.
  ingreso_total_cliente,
  -- PERCENT_RANK ubica al cliente entre 0 y 1 según su orden relativo.
  PERCENT_RANK() OVER (
    PARTITION BY c_mktsegment
    ORDER BY ingreso_total_cliente
  ) AS percent_rank_segmento,
  -- CUME_DIST mide la proporción acumulada de clientes con ingreso menor o igual.
  CUME_DIST() OVER (
    PARTITION BY c_mktsegment
    ORDER BY ingreso_total_cliente
  ) AS distribucion_acumulada_segmento
-- FROM usa la base agregada por cliente.
FROM ingreso_cliente
-- ORDER BY permite leer cada segmento desde el menor al mayor ingreso.
ORDER BY c_mktsegment, ingreso_total_cliente, c_name
-- LIMIT reduce la salida visible.
LIMIT 40;

-- COMMAND ----------

-- Ejemplo guiado 3: top 3 clientes por región usando QUALIFY.
-- ¿Por qué esta consulta?: porque Databricks permite filtrar directamente resultados de ventana sin anidar otra subconsulta.
-- ¿Qué hace QUALIFY?: aplica una condición después de calcular la función de ventana.
-- Resultado esperado: solo aparecen tres clientes por región.
WITH ingreso_cliente_region AS (
  -- La CTE calcula ingreso total por cliente y región.
  SELECT
    -- Región del cliente.
    r.r_name AS region,
    -- Nombre del cliente.
    c.c_name,
    -- Ingreso total del cliente en todos sus pedidos.
    SUM(o.o_totalprice) AS ingreso_total_cliente
  -- Base transaccional de pedidos.
  FROM samples.tpch.orders AS o
  -- Enlace con customer para atributos del cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Enlace con nation para llegar a región.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Enlace con region para la dimensión final.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Dejamos una fila por cliente y región.
  GROUP BY r.r_name, c.c_name
)
-- La consulta final rankea y filtra en el mismo nivel lógico.
SELECT
  -- Región de comparación.
  region,
  -- Cliente evaluado.
  c_name,
  -- Ingreso total del cliente.
  ingreso_total_cliente,
  -- ROW_NUMBER ordena clientes de mayor a menor ingreso dentro de cada región.
  ROW_NUMBER() OVER (
    PARTITION BY region
    ORDER BY ingreso_total_cliente DESC, c_name
  ) AS posicion_region
-- FROM usa la CTE cliente-región.
FROM ingreso_cliente_region
-- QUALIFY filtra con base en el ranking ya calculado.
QUALIFY posicion_region <= 3
-- ORDER BY presenta el top regional de forma ordenada.
ORDER BY region, posicion_region, c_name;

-- COMMAND ----------

-- Ejemplo guiado 4: diferencia entre ROWS y RANGE.
-- ¿Por qué esta consulta?: porque ambos frames parecen similares, pero conceptualmente no son iguales.
-- ¿Qué verás aquí?: con un mes por fila, ROWS y RANGE producen el mismo resultado; con duplicados podrían divergir.
-- Resultado esperado: ambas columnas coinciden en esta serie mensual simplificada.
WITH ingresos_mensuales AS (
  -- Agregamos pedidos por número de mes para tener una fila por mes en 1995.
  SELECT
    -- MONTH crea una clave numérica adecuada para RANGE de un mes hacia atrás.
    MONTH(o_orderdate) AS numero_mes,
    -- Conservamos también el mes truncado para lectura humana.
    DATE_TRUNC('month', o_orderdate) AS mes,
    -- Sumamos ingresos del mes.
    SUM(o_totalprice) AS ingreso_mensual
  -- Fuente de pedidos.
  FROM samples.tpch.orders
  -- Limitamos al año 1995.
  WHERE YEAR(o_orderdate) = 1995
  -- Agrupamos por las dos representaciones del mes.
  GROUP BY MONTH(o_orderdate), DATE_TRUNC('month', o_orderdate)
)
-- Calculamos una ventana de dos meses conceptualmente equivalente por RANGE y ROWS.
SELECT
  -- Mes calendario.
  mes,
  -- Ingreso observado del mes.
  ingreso_mensual,
  -- RANGE usa la distancia del valor de orden y no el número físico de filas.
  SUM(ingreso_mensual) OVER (
    ORDER BY numero_mes
    RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
  ) AS suma_range_mes_actual_y_anterior,
  -- ROWS usa la fila física anterior dentro del orden establecido.
  SUM(ingreso_mensual) OVER (
    ORDER BY numero_mes
    ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
  ) AS suma_rows_mes_actual_y_anterior
-- FROM toma la serie mensual preparada.
FROM ingresos_mensuales
-- ORDER BY conserva la secuencia natural de los meses.
ORDER BY numero_mes;

-- COMMAND ----------

-- Ejemplo guiado 5: feature engineering con historial de pedidos por cliente.
-- ¿Por qué esta consulta?: porque muchas variables predictivas nacen de ventanas sobre comportamiento histórico.
-- ¿Qué variables produce?: recencia, importe previo, gasto acumulado y ticket móvil.
-- Resultado esperado: cada pedido tiene contexto histórico útil para modelado.
WITH historial_pedidos AS (
  -- Construimos un historial ordenado de pedidos por cliente.
  SELECT
    -- Cliente dueño del pedido.
    o_custkey,
    -- Pedido individual.
    o_orderkey,
    -- Fecha del pedido usada para secuencia temporal.
    o_orderdate,
    -- Importe del pedido como señal monetaria.
    o_totalprice,
    -- ROW_NUMBER enumera la secuencia de compra del cliente.
    ROW_NUMBER() OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
    ) AS numero_pedido_cliente,
    -- LAG sobre fecha recupera la fecha de compra anterior del mismo cliente.
    LAG(o_orderdate, 1) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
    ) AS fecha_pedido_previo,
    -- LAG sobre importe recupera el importe del pedido anterior.
    LAG(o_totalprice, 1) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
    ) AS importe_pedido_previo,
    -- SUM acumulado resume el valor histórico gastado por el cliente hasta el pedido actual.
    SUM(o_totalprice) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS gasto_acumulado_cliente,
    -- AVG móvil de tres pedidos suaviza el comportamiento reciente del cliente.
    AVG(o_totalprice) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS ticket_movil_3_pedidos
  -- FROM usa la tabla de pedidos completa.
  FROM samples.tpch.orders
)
-- En la salida derivamos variables legibles para modelado o scoring.
SELECT
  -- Cliente analizado.
  o_custkey,
  -- Pedido actual.
  o_orderkey,
  -- Fecha del pedido.
  o_orderdate,
  -- Importe actual.
  o_totalprice,
  -- Secuencia histórica del pedido.
  numero_pedido_cliente,
  -- DATEDIFF calcula días desde la compra previa cuando existe historial.
  DATEDIFF(o_orderdate, fecha_pedido_previo) AS dias_desde_pedido_previo,
  -- Conservamos el importe previo como predictor de continuidad.
  importe_pedido_previo,
  -- Conservamos el gasto acumulado como proxy de valor de vida.
  gasto_acumulado_cliente,
  -- Conservamos la media móvil reciente como señal de tendencia individual.
  ticket_movil_3_pedidos
-- FROM usa la CTE enriquecida con ventanas.
FROM historial_pedidos
-- ORDER BY facilita revisar secuencias de clientes concretos.
ORDER BY o_custkey, o_orderdate, o_orderkey
-- LIMIT hace visible la lógica sin imprimir toda la tabla.
LIMIT 50;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Observaciones del ejemplo guiado
-- MAGIC
-- MAGIC | Patrón | Valor para negocio |
-- MAGIC |---|---|
-- MAGIC | `% del total` | mide concentración |
-- MAGIC | percentiles | mide posición relativa |
-- MAGIC | `QUALIFY` | simplifica top N y filtrado post-ventana |
-- MAGIC | `RANGE` vs `ROWS` | controla qué filas exactas participan |
-- MAGIC | *feature engineering* | transforma historial en variables predictivas |
-- MAGIC
-- MAGIC > **📝 Nota:** Si tu objetivo final es ML, las ventanas suelen ser el puente entre datos crudos y variables explicativas robustas.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado
-- MAGIC
-- MAGIC A continuación verás ejercicios con progresión **Muy Fácil → Fácil → Intermedio → Intermedio Alto → Desafío**. Intenta resolverlos primero y luego compara con la solución de referencia incluida en la celda.
-- COMMAND ----------

-- Ejercicio guiado 1 (Muy Fácil): enumerar proveedores dentro de cada nación.
-- ¿Por qué esta solución?: porque ROW_NUMBER es la forma más simple de dar una posición única por grupo.
-- Resultado esperado: los proveedores quedan numerados alfabéticamente dentro de su nación.
-- Error común evitado: olvidar PARTITION BY y obtener una sola numeración global.
SELECT
  -- Mostramos la nación del proveedor.
  n.n_name AS nacion,
  -- Mostramos el nombre del proveedor.
  s.s_name AS proveedor,
  -- Mostramos el saldo de cuenta como contexto adicional.
  s.s_acctbal AS saldo_cuenta,
  -- ROW_NUMBER genera una secuencia única por nación ordenada por nombre.
  ROW_NUMBER() OVER (
    PARTITION BY n.n_name
    ORDER BY s.s_name
  ) AS numero_proveedor_en_nacion
-- FROM parte de supplier porque el sujeto analítico es el proveedor.
FROM samples.tpch.supplier AS s
-- JOIN con nation agrega la dimensión geográfica.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- ORDER BY facilita verificar la numeración.
ORDER BY nacion, numero_proveedor_en_nacion
-- LIMIT mantiene el resultado compacto.
LIMIT 40;

-- COMMAND ----------

-- Ejercicio guiado 2 (Fácil): acumulado de cantidad enviada por proveedor y fecha de envío.
-- ¿Por qué esta solución?: porque convierte el detalle de lineitem en una serie diaria por proveedor y luego acumula.
-- Resultado esperado: la cantidad acumulada crece dentro de cada proveedor.
WITH cantidad_diaria_proveedor AS (
  -- Preparamos una serie diaria por proveedor.
  SELECT
    -- Proveedor responsable de la línea.
    l_suppkey,
    -- Fecha de envío como eje temporal.
    l_shipdate,
    -- Cantidad total enviada por el proveedor ese día.
    SUM(l_quantity) AS cantidad_diaria
  -- FROM usa la tabla de detalle lineitem.
  FROM samples.tpch.lineitem
  -- GROUP BY deja una fila por proveedor y día.
  GROUP BY l_suppkey, l_shipdate
)
-- Aplicamos el acumulado por proveedor.
SELECT
  -- Proveedor de la serie.
  l_suppkey,
  -- Fecha observada.
  l_shipdate,
  -- Cantidad del día.
  cantidad_diaria,
  -- SUM acumulado sigue la historia del proveedor en orden temporal.
  SUM(cantidad_diaria) OVER (
    PARTITION BY l_suppkey
    ORDER BY l_shipdate
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cantidad_acumulada_proveedor
-- FROM usa la serie diaria preparada.
FROM cantidad_diaria_proveedor
-- ORDER BY permite validar el acumulado proveedor por proveedor.
ORDER BY l_suppkey, l_shipdate
-- LIMIT acota la salida.
LIMIT 50;

-- COMMAND ----------

-- Ejercicio guiado 3 (Intermedio): variación mes contra mes del ingreso por región.
-- ¿Por qué esta solución?: porque LAG permite comparar cada mes regional con el inmediatamente anterior.
-- Resultado esperado: obtendrás ingreso previo y diferencia absoluta por región.
WITH ingreso_region_mes AS (
  -- Calculamos ingreso por región y mes.
  SELECT
    -- Región geográfica del cliente.
    r.r_name AS region,
    -- Mes calendario del pedido.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Ingreso total del mes en la región.
    SUM(o.o_totalprice) AS ingreso_mensual_region
  -- Base monetaria de pedidos.
  FROM samples.tpch.orders AS o
  -- Relación con cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Relación con nación.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Relación con región.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Restringimos a 1995 para una serie continua y compacta.
  WHERE YEAR(o.o_orderdate) = 1995
  -- Una fila por región y mes.
  GROUP BY r.r_name, DATE_TRUNC('month', o.o_orderdate)
)
-- Comparamos cada mes con el previo dentro de su región.
SELECT
  -- Región analizada.
  region,
  -- Mes observado.
  mes,
  -- Ingreso actual del mes.
  ingreso_mensual_region,
  -- LAG trae el ingreso del mes previo de la misma región.
  LAG(ingreso_mensual_region, 1) OVER (
    PARTITION BY region
    ORDER BY mes
  ) AS ingreso_mes_previo,
  -- Restamos para obtener la variación absoluta mes a mes.
  ingreso_mensual_region - LAG(ingreso_mensual_region, 1) OVER (
    PARTITION BY region
    ORDER BY mes
  ) AS variacion_absoluta_mom
-- FROM usa la serie región-mes.
FROM ingreso_region_mes
-- ORDER BY mantiene lectura regional y cronológica.
ORDER BY region, mes;

-- COMMAND ----------

-- Ejercicio guiado 4 (Intermedio Alto): cuartiles de productos por precio dentro de cada fabricante.
-- ¿Por qué esta solución?: porque NTILE crea grupos comparables y útiles para segmentar catálogo.
-- Resultado esperado: cada parte queda asignada a un cuartil de precio dentro de su fabricante.
SELECT
  -- Fabricante del producto.
  p_mfgr AS fabricante,
  -- Nombre descriptivo del producto.
  p_name AS producto,
  -- Precio de venta de lista.
  p_retailprice AS precio_lista,
  -- NTILE divide el fabricante en cuatro grupos ordenados por precio.
  NTILE(4) OVER (
    PARTITION BY p_mfgr
    ORDER BY p_retailprice DESC, p_name
  ) AS cuartil_precio_fabricante
-- FROM toma el catálogo de partes.
FROM samples.tpch.part
-- ORDER BY organiza la lectura por fabricante y precio.
ORDER BY fabricante, precio_lista DESC, producto
-- LIMIT acota la salida visible.
LIMIT 50;

-- COMMAND ----------

-- Ejercicio guiado 5 (Desafío): top 2 proveedores por saldo dentro de cada región usando QUALIFY.
-- ¿Por qué esta solución?: porque combina la jerarquía geográfica con ranking directo sobre el resultado.
-- Resultado esperado: verás dos proveedores por región, priorizados por saldo de cuenta.
WITH proveedor_region AS (
  -- Construimos una base con proveedor y región.
  SELECT
    -- Región del proveedor.
    r.r_name AS region,
    -- Nombre del proveedor.
    s.s_name AS proveedor,
    -- Saldo de cuenta del proveedor.
    s.s_acctbal AS saldo_cuenta
  -- FROM parte de supplier.
  FROM samples.tpch.supplier AS s
  -- JOIN con nation para seguir la geografía.
  INNER JOIN samples.tpch.nation AS n
    ON s.s_nationkey = n.n_nationkey
  -- JOIN con region para la dimensión final.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
)
-- Rankeamos proveedores y filtramos top 2 por región.
SELECT
  -- Región evaluada.
  region,
  -- Proveedor candidato.
  proveedor,
  -- Saldo observado.
  saldo_cuenta,
  -- DENSE_RANK permite que proveedores empatados compartan posición.
  DENSE_RANK() OVER (
    PARTITION BY region
    ORDER BY saldo_cuenta DESC, proveedor
  ) AS posicion_saldo_region
-- FROM usa la base proveedor-región.
FROM proveedor_region
-- QUALIFY retiene solo los dos primeros lugares por región.
QUALIFY posicion_saldo_region <= 2
-- ORDER BY mejora la lectura final.
ORDER BY region, posicion_saldo_region, proveedor;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Cierre del ejercicio guiado
-- MAGIC
-- MAGIC Si resolviste los cinco ejercicios, ya dominas los patrones mínimos para:
-- MAGIC - numerar,
-- MAGIC - acumular,
-- MAGIC - comparar contra el periodo previo,
-- MAGIC - segmentar en grupos,
-- MAGIC - y filtrar top N con `QUALIFY`.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Ejercicio individual
-- MAGIC
-- MAGIC En esta sección debes intentar resolver primero por tu cuenta. La consulta mostrada es una **solución de referencia** para que valides tu razonamiento.
-- COMMAND ----------

-- Ejercicio individual 1 (Muy Fácil): contar cuántos pedidos tiene cada cliente sin perder cada pedido.
-- ¿Por qué esta solución?: porque COUNT OVER PARTITION BY conserva el pedido y agrega su frecuencia histórica.
-- Resultado esperado: todos los pedidos del mismo cliente comparten el mismo conteo.
SELECT
  -- Cliente dueño del pedido.
  o_custkey,
  -- Pedido individual.
  o_orderkey,
  -- Fecha del pedido para contexto temporal.
  o_orderdate,
  -- Conteo total de pedidos del cliente dentro del conjunto completo.
  COUNT(*) OVER (
    PARTITION BY o_custkey
  ) AS total_pedidos_cliente
-- FROM usa la tabla de pedidos.
FROM samples.tpch.orders
-- ORDER BY organiza por cliente y fecha.
ORDER BY o_custkey, o_orderdate, o_orderkey
-- LIMIT reduce la salida.
LIMIT 40;

-- COMMAND ----------

-- Ejercicio individual 2 (Fácil): participación del saldo del cliente dentro de su segmento.
-- ¿Por qué esta solución?: porque compara el saldo individual contra el total del segmento.
-- Resultado esperado: clientes del mismo segmento comparten el mismo denominador.
SELECT
  -- Segmento del cliente.
  c_mktsegment,
  -- Nombre del cliente.
  c_name,
  -- Saldo de cuenta individual.
  c_acctbal,
  -- Suma de saldos dentro del segmento como referencia de grupo.
  SUM(c_acctbal) OVER (
    PARTITION BY c_mktsegment
  ) AS saldo_total_segmento,
  -- Porcentaje del saldo del cliente dentro del segmento.
  ROUND(100 * c_acctbal / SUM(c_acctbal) OVER (PARTITION BY c_mktsegment), 4) AS porcentaje_saldo_segmento
-- FROM usa la dimensión de clientes.
FROM samples.tpch.customer
-- ORDER BY facilita revisar concentraciones altas dentro de cada segmento.
ORDER BY c_mktsegment, porcentaje_saldo_segmento DESC, c_name
-- LIMIT acota la salida.
LIMIT 40;

-- COMMAND ----------

-- Ejercicio individual 3 (Intermedio): identificar el primer pedido de cada cliente.
-- ¿Por qué esta solución?: porque ROW_NUMBER sobre la secuencia temporal permite marcar el comienzo de la relación comercial.
-- Resultado esperado: exactamente un pedido por cliente tendrá el indicador 1.
WITH pedidos_ordenados AS (
  -- Ordenamos la historia de pedidos por cliente.
  SELECT
    -- Cliente observado.
    o_custkey,
    -- Pedido individual.
    o_orderkey,
    -- Fecha del pedido.
    o_orderdate,
    -- Numeramos los pedidos del cliente en orden cronológico.
    ROW_NUMBER() OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
    ) AS secuencia_cliente
  -- FROM usa la tabla de pedidos.
  FROM samples.tpch.orders
)
-- Marcamos el primer pedido con una bandera analítica.
SELECT
  -- Cliente analizado.
  o_custkey,
  -- Pedido evaluado.
  o_orderkey,
  -- Fecha del pedido.
  o_orderdate,
  -- Posición cronológica del pedido.
  secuencia_cliente,
  -- CASE crea una variable binaria útil para cohortes o activación.
  CASE
    -- Si el pedido es el primero, marcamos 1.
    WHEN secuencia_cliente = 1 THEN 1
    -- En otro caso, marcamos 0.
    ELSE 0
  END AS es_primer_pedido
-- FROM usa la CTE ya numerada.
FROM pedidos_ordenados
-- ORDER BY conserva la historia de cada cliente.
ORDER BY o_custkey, o_orderdate, o_orderkey
-- LIMIT acota la salida visible.
LIMIT 40;

-- COMMAND ----------

-- Ejercicio individual 4 (Intermedio Alto): comparar cada pedido con el anterior y el siguiente del mismo cliente.
-- ¿Por qué esta solución?: porque LAG y LEAD permiten construir contexto bidireccional alrededor de la fila actual.
-- Resultado esperado: el primer pedido no tendrá previo y el último no tendrá siguiente.
SELECT
  -- Cliente de referencia.
  o_custkey,
  -- Pedido actual.
  o_orderkey,
  -- Fecha actual del pedido.
  o_orderdate,
  -- Valor actual del pedido.
  o_totalprice,
  -- Valor del pedido anterior del mismo cliente.
  LAG(o_totalprice, 1) OVER (
    PARTITION BY o_custkey
    ORDER BY o_orderdate, o_orderkey
  ) AS valor_pedido_previo,
  -- Valor del pedido siguiente del mismo cliente.
  LEAD(o_totalprice, 1) OVER (
    PARTITION BY o_custkey
    ORDER BY o_orderdate, o_orderkey
  ) AS valor_pedido_siguiente,
  -- Diferencia contra el pedido previo, útil para medir aceleración o caída.
  o_totalprice - LAG(o_totalprice, 1) OVER (
    PARTITION BY o_custkey
    ORDER BY o_orderdate, o_orderkey
  ) AS diferencia_vs_previo
-- FROM usa la historia de pedidos.
FROM samples.tpch.orders
-- ORDER BY mantiene la secuencia natural por cliente.
ORDER BY o_custkey, o_orderdate, o_orderkey
-- LIMIT reduce el volumen impreso.
LIMIT 50;

-- COMMAND ----------

-- Ejercicio individual 5 (Desafío): distribución acumulada del saldo de proveedores dentro de su región.
-- ¿Por qué esta solución?: porque CUME_DIST ayuda a detectar proveedores ubicados en la cola alta de saldo dentro de su contexto geográfico.
-- Resultado esperado: los valores se mueven entre 0 y 1 dentro de cada región.
SELECT
  -- Región del proveedor.
  r.r_name AS region,
  -- Proveedor observado.
  s.s_name AS proveedor,
  -- Saldo del proveedor.
  s.s_acctbal AS saldo_cuenta,
  -- Distribución acumulada del saldo dentro de la región.
  CUME_DIST() OVER (
    PARTITION BY r.r_name
    ORDER BY s.s_acctbal
  ) AS cume_dist_saldo_region
-- FROM parte de supplier.
FROM samples.tpch.supplier AS s
-- JOIN con nation aporta el enlace territorial.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- JOIN con region define el grupo final.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- ORDER BY ayuda a leer la distribución desde saldos bajos a altos.
ORDER BY region, saldo_cuenta, proveedor;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Pista de auto-revisión
-- MAGIC
-- MAGIC Antes de aceptar tu solución individual, pregúntate:
-- MAGIC
-- MAGIC 1. ¿La partición coincide con la pregunta?
-- MAGIC 2. ¿El orden temporal o numérico es el correcto?
-- MAGIC 3. ¿Necesito conservar el detalle o sí debía agrupar antes?
-- MAGIC 4. ¿Un `NULL` esperado en `LAG` o `LEAD` significa error o simplemente borde de la serie?
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Desafío
-- MAGIC
-- MAGIC Esta sección eleva la complejidad. Ahora combinaremos varias ventanas y varias capas de CTE para responder preguntas más cercanas a un entorno profesional.
-- COMMAND ----------

-- Desafío 1 (Muy Fácil): ranking de pedidos por valor dentro de cada cliente.
-- ¿Por qué esta solución?: porque ayuda a identificar los pedidos más importantes de cada cuenta.
-- Resultado esperado: cada cliente tendrá sus pedidos ordenados de mayor a menor valor.
SELECT
  -- Cliente del pedido.
  o_custkey,
  -- Pedido individual.
  o_orderkey,
  -- Valor monetario del pedido.
  o_totalprice,
  -- Posición única del pedido dentro del cliente por valor.
  ROW_NUMBER() OVER (
    PARTITION BY o_custkey
    ORDER BY o_totalprice DESC, o_orderdate, o_orderkey
  ) AS ranking_pedido_cliente
-- FROM usa la tabla de pedidos.
FROM samples.tpch.orders
-- ORDER BY facilita revisar el top por cliente.
ORDER BY o_custkey, ranking_pedido_cliente
-- LIMIT acota la salida.
LIMIT 40;

-- COMMAND ----------

-- Desafío 2 (Fácil): detectar cambios bruscos de ingreso mensual por región.
-- ¿Por qué esta solución?: porque combina agregación mensual, LAG y porcentaje de cambio.
-- Resultado esperado: verás subidas y bajadas relativas por región.
WITH ingreso_region_mes AS (
  -- Calculamos ingreso mensual por región.
  SELECT
    -- Región del cliente.
    r.r_name AS region,
    -- Mes del pedido.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Ingreso del mes para la región.
    SUM(o.o_totalprice) AS ingreso_mensual_region
  -- Base de pedidos.
  FROM samples.tpch.orders AS o
  -- Relación con customer.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Relación con nation.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Relación con region.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Filtramos a 1995 para compactar la serie.
  WHERE YEAR(o.o_orderdate) = 1995
  -- Una fila por región y mes.
  GROUP BY r.r_name, DATE_TRUNC('month', o.o_orderdate)
)
-- Medimos el cambio absoluto y relativo frente al mes previo.
SELECT
  -- Región analizada.
  region,
  -- Mes observado.
  mes,
  -- Ingreso actual.
  ingreso_mensual_region,
  -- Ingreso del mes previo.
  LAG(ingreso_mensual_region, 1) OVER (
    PARTITION BY region
    ORDER BY mes
  ) AS ingreso_previo_region,
  -- Diferencia absoluta frente al mes anterior.
  ingreso_mensual_region - LAG(ingreso_mensual_region, 1) OVER (
    PARTITION BY region
    ORDER BY mes
  ) AS cambio_absoluto,
  -- Cambio porcentual con NULLIF para evitar división por cero.
  ROUND(
    100 * (ingreso_mensual_region - LAG(ingreso_mensual_region, 1) OVER (
      PARTITION BY region
      ORDER BY mes
    )) / NULLIF(LAG(ingreso_mensual_region, 1) OVER (
      PARTITION BY region
      ORDER BY mes
    ), 0),
    2
  ) AS cambio_porcentual
-- FROM usa la serie regional.
FROM ingreso_region_mes
-- ORDER BY conserva lectura cronológica regional.
ORDER BY region, mes;

-- COMMAND ----------

-- Desafío 3 (Intermedio): media móvil regional de tres meses.
-- ¿Por qué esta solución?: porque la tendencia regional se interpreta mejor con suavizamiento.
-- Resultado esperado: cada región tendrá una serie suavizada propia.
WITH ingreso_region_mes AS (
  -- Repetimos la agregación región-mes porque el desafío se centra en la ventana posterior.
  SELECT
    -- Región del cliente.
    r.r_name AS region,
    -- Mes de la compra.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Ingreso agregado regional del mes.
    SUM(o.o_totalprice) AS ingreso_mensual_region
  -- Base monetaria.
  FROM samples.tpch.orders AS o
  -- Relación con customer.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Relación con nation.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Relación con region.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Filtrado temporal.
  WHERE YEAR(o.o_orderdate) = 1995
  -- Una fila por región y mes.
  GROUP BY r.r_name, DATE_TRUNC('month', o.o_orderdate)
)
-- Calculamos la media móvil por región.
SELECT
  -- Región analizada.
  region,
  -- Mes observado.
  mes,
  -- Ingreso del mes.
  ingreso_mensual_region,
  -- Promedio móvil de tres meses por región.
  AVG(ingreso_mensual_region) OVER (
    PARTITION BY region
    ORDER BY mes
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS media_movil_3_meses_region
-- FROM usa la serie mensual regional.
FROM ingreso_region_mes
-- ORDER BY mantiene lectura ordenada.
ORDER BY region, mes;

-- COMMAND ----------

-- Desafío 4 (Intermedio Alto): percentil de precio de producto dentro de su marca.
-- ¿Por qué esta solución?: porque permite detectar productos premium dentro de cada portafolio de marca.
-- Resultado esperado: productos con percent_rank alto están entre los más caros de su marca.
SELECT
  -- Marca del producto.
  p_brand AS marca,
  -- Nombre del producto.
  p_name AS producto,
  -- Precio de lista.
  p_retailprice AS precio_lista,
  -- Percent rank dentro de la marca ordenada por precio.
  PERCENT_RANK() OVER (
    PARTITION BY p_brand
    ORDER BY p_retailprice
  ) AS percent_rank_precio_marca
-- FROM usa el catálogo de partes.
FROM samples.tpch.part
-- QUALIFY deja solo el decil superior aproximado de precio por marca.
QUALIFY percent_rank_precio_marca >= 0.90
-- ORDER BY lista primero los productos más caros.
ORDER BY marca, precio_lista DESC, producto;

-- COMMAND ----------

-- Desafío 5 (Desafío): vista RFM ampliada con ventanas para priorización de clientes.
-- ¿Por qué esta solución?: porque combina recencia, frecuencia y valor monetario con señales de tendencia útiles para scoring.
-- Resultado esperado: una fila por pedido con contexto histórico y una clasificación del cliente.
WITH historial_cliente AS (
  -- Construimos una historia ordenada de pedidos por cliente.
  SELECT
    -- Cliente evaluado.
    o_custkey,
    -- Pedido individual.
    o_orderkey,
    -- Fecha del pedido.
    o_orderdate,
    -- Importe del pedido.
    o_totalprice,
    -- Secuencia total de pedidos del cliente.
    ROW_NUMBER() OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
    ) AS numero_pedido,
    -- Gasto acumulado hasta el pedido actual.
    SUM(o_totalprice) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS gasto_acumulado,
    -- Ticket medio reciente en una ventana de tres pedidos.
    AVG(o_totalprice) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS ticket_movil_3,
    -- Fecha del pedido anterior para medir recencia transaccional.
    LAG(o_orderdate, 1) OVER (
      PARTITION BY o_custkey
      ORDER BY o_orderdate, o_orderkey
    ) AS fecha_previa
  -- FROM usa orders como historial transaccional.
  FROM samples.tpch.orders AS o
),
resumen_cliente AS (
  -- Derivamos variables interpretables por pedido.
  SELECT
    -- Cliente evaluado.
    o_custkey,
    -- Pedido actual.
    o_orderkey,
    -- Fecha del pedido.
    o_orderdate,
    -- Importe actual.
    o_totalprice,
    -- Número de pedido del cliente.
    numero_pedido,
    -- Días desde la compra anterior como proxy de recencia.
    DATEDIFF(o_orderdate, fecha_previa) AS dias_desde_previo,
    -- Gasto acumulado histórico.
    gasto_acumulado,
    -- Ticket móvil reciente.
    ticket_movil_3,
    -- NTILE segmenta clientes en quintiles de valor acumulado dentro del instante observado.
    NTILE(5) OVER (
      ORDER BY gasto_acumulado DESC
    ) AS quintil_valor_acumulado
  -- FROM usa la historia enriquecida.
  FROM historial_cliente
)
-- Presentamos una vista de scoring operativo por pedido.
SELECT
  -- Cliente analizado.
  o_custkey,
  -- Pedido evaluado.
  o_orderkey,
  -- Fecha del pedido.
  o_orderdate,
  -- Importe actual.
  o_totalprice,
  -- Número histórico de pedido.
  numero_pedido,
  -- Días desde el pedido previo.
  dias_desde_previo,
  -- Gasto acumulado del cliente.
  gasto_acumulado,
  -- Ticket móvil reciente.
  ticket_movil_3,
  -- Quintil de valor para priorización.
  quintil_valor_acumulado
-- FROM usa la vista intermedia de resumen.
FROM resumen_cliente
-- ORDER BY facilita revisar clientes de mayor valor acumulado.
ORDER BY quintil_valor_acumulado, gasto_acumulado DESC, o_custkey
-- LIMIT acota la salida visible.
LIMIT 60;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Resumen
-- MAGIC
-- MAGIC ### Ideas clave
-- MAGIC - `OVER()` convierte una función normal en una función de ventana.
-- MAGIC - `PARTITION BY` define **quiénes compiten o se comparan**.
-- MAGIC - `ORDER BY` define **la secuencia analítica**.
-- MAGIC - `ROWS` usa posiciones físicas; `RANGE` usa distancia del valor de orden.
-- MAGIC - `ROW_NUMBER`, `RANK`, `DENSE_RANK` y `NTILE` resuelven ranking y segmentación.
-- MAGIC - `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE` y `NTH_VALUE` conectan filas entre sí.
-- MAGIC - `SUM`, `AVG`, `COUNT`, `MIN` y `MAX` sobre ventana crean acumulados, promedios y referencias de grupo.
-- MAGIC - `QUALIFY` simplifica el filtrado posterior a funciones ventana en Databricks.
-- MAGIC
-- MAGIC > **📝 Nota:** Si una pregunta necesita contexto relativo **sin perder la fila original**, probablemente necesites una window function.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Laboratorio
-- MAGIC
-- MAGIC Responde las siguientes preguntas reales del CFO usando las consultas de referencia. El objetivo del laboratorio no es memorizar sintaxis, sino reconocer el patrón correcto.
-- MAGIC
-- MAGIC ### Preguntas del negocio
-- MAGIC 1. ¿Qué clientes muestran una tendencia descendente reciente en su gasto?
-- MAGIC 2. ¿Qué regiones concentran aproximadamente el 80% del ingreso?
-- MAGIC 3. ¿Qué proveedores son atípicos por saldo dentro de su región?
-- COMMAND ----------

-- Laboratorio 1: clientes con tendencia descendente reciente en su gasto.
-- ¿Por qué esta consulta?: porque usa LAG sobre ingreso mensual del cliente para detectar dos descensos consecutivos.
-- Resultado esperado: aparecerán clientes cuya serie mensual cayó en los dos últimos pasos observables.
WITH ingreso_cliente_mes AS (
  -- Agregamos pedidos por cliente y mes.
  SELECT
    -- Cliente observado.
    o_custkey,
    -- Mes calendario del pedido.
    DATE_TRUNC('month', o_orderdate) AS mes,
    -- Ingreso total del cliente en el mes.
    SUM(o_totalprice) AS ingreso_mensual_cliente
  -- FROM usa la tabla de pedidos.
  FROM samples.tpch.orders
  -- GROUP BY deja una fila por cliente y mes.
  GROUP BY o_custkey, DATE_TRUNC('month', o_orderdate)
),
cliente_tendencia AS (
  -- Calculamos referencias previas para detectar trayectoria.
  SELECT
    -- Cliente observado.
    o_custkey,
    -- Mes actual.
    mes,
    -- Ingreso actual.
    ingreso_mensual_cliente,
    -- Ingreso del mes inmediatamente anterior.
    LAG(ingreso_mensual_cliente, 1) OVER (
      PARTITION BY o_custkey
      ORDER BY mes
    ) AS ingreso_mes_previo,
    -- Ingreso de dos meses atrás para confirmar secuencia descendente.
    LAG(ingreso_mensual_cliente, 2) OVER (
      PARTITION BY o_custkey
      ORDER BY mes
    ) AS ingreso_dos_meses_atras
  -- FROM usa la serie mensual del cliente.
  FROM ingreso_cliente_mes
)
-- Filtramos observaciones donde el cliente cae dos veces seguidas.
SELECT
  -- Cliente con posible deterioro reciente.
  o_custkey,
  -- Mes evaluado.
  mes,
  -- Ingreso actual.
  ingreso_mensual_cliente,
  -- Ingreso del mes previo.
  ingreso_mes_previo,
  -- Ingreso de dos meses atrás.
  ingreso_dos_meses_atras
-- FROM usa la serie con referencias históricas.
FROM cliente_tendencia
-- WHERE conserva solo patrones de descenso consecutivo.
WHERE ingreso_dos_meses_atras > ingreso_mes_previo
  -- Esta segunda condición exige que el mes actual siga cayendo.
  AND ingreso_mes_previo > ingreso_mensual_cliente
-- ORDER BY prioriza la caída más reciente por cliente.
ORDER BY o_custkey, mes;

-- COMMAND ----------

-- Laboratorio 2: regiones que concentran aproximadamente el 80% del ingreso.
-- ¿Por qué esta consulta?: porque combina participación regional con acumulado ordenado de mayor a menor ingreso.
-- Resultado esperado: las primeras regiones explican la mayor parte del total corporativo.
WITH ingreso_region AS (
  -- Resumimos el ingreso por región.
  SELECT
    -- Región del cliente.
    r.r_name AS region,
    -- Ingreso total asociado a la región.
    SUM(o.o_totalprice) AS ingreso_region
  -- Base monetaria de pedidos.
  FROM samples.tpch.orders AS o
  -- Enlace con customer.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Enlace con nation.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Enlace con region.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Una fila por región.
  GROUP BY r.r_name
)
-- Calculamos contribución acumulada tipo Pareto.
SELECT
  -- Región evaluada.
  region,
  -- Ingreso absoluto de la región.
  ingreso_region,
  -- Participación individual de la región sobre el total.
  ROUND(100 * ingreso_region / SUM(ingreso_region) OVER (), 2) AS porcentaje_individual,
  -- Acumulado ordenado de participaciones para encontrar el punto 80/20.
  ROUND(
    100 * SUM(ingreso_region) OVER (
      ORDER BY ingreso_region DESC, region
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / SUM(ingreso_region) OVER (),
    2
  ) AS porcentaje_acumulado
-- FROM usa la base regional.
FROM ingreso_region
-- ORDER BY sigue la lógica de Pareto de mayor a menor contribución.
ORDER BY ingreso_region DESC, region;

-- COMMAND ----------

-- Laboratorio 3: proveedores atípicos por saldo dentro de su región.
-- ¿Por qué esta consulta?: porque percent_rank ayuda a detectar cola alta y cola baja sin suponer distribución normal.
-- Resultado esperado: solo se verán proveedores en extremos relativos de su región.
WITH proveedor_region AS (
  -- Construimos una base con saldo y región del proveedor.
  SELECT
    -- Región del proveedor.
    r.r_name AS region,
    -- Nombre del proveedor.
    s.s_name AS proveedor,
    -- Saldo del proveedor.
    s.s_acctbal AS saldo_cuenta
  -- FROM parte de supplier.
  FROM samples.tpch.supplier AS s
  -- JOIN con nation para el enlace territorial.
  INNER JOIN samples.tpch.nation AS n
    ON s.s_nationkey = n.n_nationkey
  -- JOIN con region para la dimensión final.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
)
-- Calculamos percentiles y nos quedamos con extremos.
SELECT
  -- Región analizada.
  region,
  -- Proveedor observado.
  proveedor,
  -- Saldo de cuenta.
  saldo_cuenta,
  -- Percent rank del proveedor dentro de la región.
  PERCENT_RANK() OVER (
    PARTITION BY region
    ORDER BY saldo_cuenta
  ) AS percent_rank_region
-- FROM usa la base proveedor-región.
FROM proveedor_region
-- QUALIFY deja solo extremos inferiores y superiores.
QUALIFY percent_rank_region <= 0.10 OR percent_rank_region >= 0.90
-- ORDER BY ayuda a revisar primero la cola baja y luego la alta.
ORDER BY region, percent_rank_region, proveedor;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 14. Autoevaluación
-- MAGIC
-- MAGIC Responde mentalmente o por escrito antes de avanzar al siguiente notebook:
-- MAGIC
-- MAGIC 1. ¿Cuál es la diferencia central entre `GROUP BY` y una window function?
-- MAGIC 2. ¿Qué problema resuelve `PARTITION BY`?
-- MAGIC 3. ¿Por qué un acumulado necesita `ORDER BY` dentro de `OVER()`?
-- MAGIC 4. ¿Cuándo elegirías `ROWS` en lugar de `RANGE`?
-- MAGIC 5. ¿Qué diferencia práctica existe entre `ROW_NUMBER()`, `RANK()` y `DENSE_RANK()`?
-- MAGIC 6. ¿Qué devuelve `LAG()` cuando no existe una fila previa?
-- MAGIC 7. ¿Por qué `LAST_VALUE()` suele requerir un frame explícito?
-- MAGIC 8. ¿Cómo calcularías el porcentaje de una fila respecto al total sin perder la fila original?
-- MAGIC 9. ¿Qué ventaja ofrece `QUALIFY` en Databricks?
-- MAGIC 10. ¿Qué variables de comportamiento histórico podrías construir para un modelo de churn o propensión?
-- MAGIC
-- MAGIC ### Lista de verificación personal
-- MAGIC | Pregunta | Sí | No |
-- MAGIC |---|---|---|
-- MAGIC | ¿Puedo explicar la anatomía de `OVER()`? | ☐ | ☐ |
-- MAGIC | ¿Puedo construir un acumulado y una media móvil? | ☐ | ☐ |
-- MAGIC | ¿Puedo interpretar percentiles y rankings? | ☐ | ☐ |
-- MAGIC | ¿Puedo usar `QUALIFY` correctamente? | ☐ | ☐ |
-- MAGIC | ¿Puedo diseñar features históricas con ventanas? | ☐ | ☐ |
-- MAGIC
-- MAGIC > **📝 Nota:** Si aún dudas entre `GROUP BY` y ventanas, vuelve a los ejemplos 1 y 3: allí está la diferencia conceptual más importante del notebook.
