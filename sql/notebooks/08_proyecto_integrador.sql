-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Notebook 08: Proyecto Integrador
-- MAGIC ## Fundamentos de Programación
-- MAGIC ### Maestría en Ciencia de Datos · Universidad de Antioquia
-- MAGIC ## 1. Bienvenida al Proyecto Final
-- MAGIC 
-- MAGIC Bienvenida y bienvenido al **capstone** del curso **Fundamentos de Programación** de la **Maestría en Ciencia de Datos** de la **Universidad de Antioquia**.
-- MAGIC 
-- MAGIC En este notebook asumirás el rol de **Data Analyst Senior en DataCorp Analytics** y entregarás un reporte integral para el comité ejecutivo (**CEO, CFO, CMO, COO y Chief Data Officer**). El objetivo es transformar datos transaccionales en decisiones de negocio accionables usando **consultas básicas, funciones SQL, agregaciones, JOINs, subconsultas, CTEs y funciones de ventana**.
-- MAGIC 
-- MAGIC ### Entregable esperado
-- MAGIC | Entregable | Descripción ejecutiva |
-- MAGIC |---|---|
-- MAGIC | Análisis 360 de clientes | LTV, retención, inactividad y segmentación |
-- MAGIC | Análisis comercial | ventas, demanda, margen y proveedores |
-- MAGIC | Análisis geográfico | regiones, países y concentración del ingreso |
-- MAGIC | Análisis temporal | evolución mensual, tendencia y estabilidad |
-- MAGIC | Dataset para ML | variables listas para modelos de churn o propensión |
-- MAGIC | Dashboard SQL | reporte consolidado para la C-suite |
-- MAGIC 
-- MAGIC > **📝 Nota:** Este notebook está diseñado para demostrar integración de competencias. No se trata de una sola consulta “correcta”, sino de construir una narrativa analítica completa y defendible.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC 
-- MAGIC Al finalizar este proyecto serás capaz de:
-- MAGIC 
-- MAGIC 1. Integrar **todas las habilidades del curso** en un caso de negocio de nivel profesional.
-- MAGIC 2. Traducir preguntas ejecutivas en consultas SQL reproducibles y explicables.
-- MAGIC 3. Diseñar indicadores de clientes, productos, ventas, geografía y tiempo.
-- MAGIC 4. Aplicar **CTEs, subconsultas y funciones de ventana** para crear métricas avanzadas.
-- MAGIC 5. Preparar un **dataset analítico** reutilizable para modelos de Machine Learning.
-- MAGIC 6. Construir un **dashboard SQL** orientado a toma de decisiones.
-- MAGIC 
-- MAGIC ### Mapa de aprendizaje del proyecto
-- MAGIC ```text
-- MAGIC Pregunta de negocio
-- MAGIC         -> Definición del grano
-- MAGIC         -> Unión de tablas correctas
-- MAGIC         -> Transformación y cálculo
-- MAGIC         -> Validación ejecutiva
-- MAGIC         -> Recomendación accionable
-- MAGIC ```
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias demostradas
-- MAGIC 
-- MAGIC ### Competencias técnicas
-- MAGIC - Escritura de consultas SQL legibles y bien documentadas.
-- MAGIC - Integración de tablas relacionales con claves de negocio.
-- MAGIC - Construcción de métricas con `SUM`, `AVG`, `COUNT`, `CASE`, `COALESCE` y `NULLIF`.
-- MAGIC - Uso de **subconsultas y CTEs** para organizar lógica analítica compleja.
-- MAGIC - Aplicación de **window functions** como `ROW_NUMBER`, `DENSE_RANK`, `NTILE`, `LAG` y acumulados.
-- MAGIC 
-- MAGIC ### Competencias analíticas
-- MAGIC - Priorizar clientes por valor y riesgo.
-- MAGIC - Detectar concentración comercial y geográfica.
-- MAGIC - Relacionar demanda, margen y abastecimiento.
-- MAGIC - Identificar tendencias temporales y señales tempranas de cambio.
-- MAGIC 
-- MAGIC ### Competencias de comunicación ejecutiva
-- MAGIC | Competencia | Evidencia en este notebook |
-- MAGIC |---|---|
-- MAGIC | Sintetizar hallazgos | tablas resumen y KPIs |
-- MAGIC | Explicar supuestos | comentarios y notas metodológicas |
-- MAGIC | Recomendar acciones | interpretación al cierre de cada módulo |
-- MAGIC | Pensar en escalabilidad | vista final para ML y dashboard reutilizable |
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC 
-- MAGIC **DataCorp Analytics** es una firma global que comercializa productos a clientes empresariales en múltiples regiones. Durante el último comité trimestral, la dirección detectó cuatro necesidades críticas:
-- MAGIC 
-- MAGIC 1. **Crecimiento con rentabilidad:** no basta vender más; hay que identificar qué clientes, productos y regiones generan valor sostenible.
-- MAGIC 2. **Retención y reactivación:** existe preocupación por clientes que dejaron de comprar y por segmentos cuyo comportamiento se está debilitando.
-- MAGIC 3. **Planeación comercial y operativa:** el área de compras necesita claridad sobre demanda y confiabilidad de proveedores.
-- MAGIC 4. **Preparación para analítica avanzada:** el área de datos quiere transformar los hallazgos SQL en variables listas para modelos de churn, scoring o recomendación.
-- MAGIC 
-- MAGIC ### Preguntas del comité ejecutivo
-- MAGIC - ¿Cuáles son los **10 clientes con mayor valor de vida**?
-- MAGIC - ¿Qué **segmentos de clientes** generan más ingresos?
-- MAGIC - ¿Cómo evoluciona la **venta mensual**?
-- MAGIC - ¿Qué **productos** concentran la mayor demanda?
-- MAGIC - ¿Qué **proveedores** son más confiables por volumen?
-- MAGIC - ¿Dónde se concentran las ventas por **región**?
-- MAGIC - ¿Qué clientes están **inactivos**?
-- MAGIC - ¿Cuál es la **tasa de retención**?
-- MAGIC - ¿Qué productos presentan **mayor margen estimado**?
-- MAGIC - ¿Cómo preparar un **dataset para Machine Learning**?
-- MAGIC 
-- MAGIC > **📝 Nota:** En un contexto real, la diferencia entre un buen analista y un analista estratégico suele estar en su capacidad para conectar métricas aisladas con decisiones concretas de negocio.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Arquitectura de datos
-- MAGIC 
-- MAGIC ### Esquema de trabajo
-- MAGIC 
-- MAGIC ```text
-- MAGIC customer --< orders --< lineitem >-- part
-- MAGIC    |                        |
-- MAGIC    v                        v
-- MAGIC nation -----------------> supplier
-- MAGIC    |
-- MAGIC    v
-- MAGIC region
-- MAGIC 
-- MAGIC nyctaxi.trips
-- MAGIC    |
-- MAGIC    -> dataset complementario para pensar patrones temporales y escalabilidad analítica
-- MAGIC ```
-- MAGIC 
-- MAGIC ### Rol de cada dataset
-- MAGIC | Tabla | Rol analítico | Grano principal |
-- MAGIC |---|---|---|
-- MAGIC | `samples.tpch.customer` | perfil del cliente | 1 fila por cliente |
-- MAGIC | `samples.tpch.orders` | encabezado de pedido | 1 fila por pedido |
-- MAGIC | `samples.tpch.lineitem` | detalle transaccional | 1 fila por línea de pedido |
-- MAGIC | `samples.tpch.part` | catálogo de productos | 1 fila por producto |
-- MAGIC | `samples.tpch.supplier` | catálogo de proveedores | 1 fila por proveedor |
-- MAGIC | `samples.tpch.nation` | dimensión país | 1 fila por país |
-- MAGIC | `samples.tpch.region` | dimensión región | 1 fila por región |
-- MAGIC | `samples.nyctaxi.trips` | referencia temporal adicional | 1 fila por viaje |
-- MAGIC 
-- MAGIC ### Regla metodológica clave
-- MAGIC - Para métricas comerciales agregadas, el **grano correcto** depende de la pregunta.
-- MAGIC - Si analizas ingreso por pedido, la base natural es `orders`.
-- MAGIC - Si analizas producto, proveedor o volumen físico, la base natural es `lineitem`.
-- MAGIC - Si analizas geografía de cliente, el camino es `customer -> nation -> region`.
-- COMMAND ----------

-- Pregunta de negocio: ¿qué cobertura tiene cada tabla y cuál será su peso relativo en el proyecto?
-- Enfoque: construimos una tabla resumen con el volumen de registros por dataset.
WITH volumen_tablas AS (
  -- Contamos el número de filas de la tabla de clientes.
  SELECT 'samples.tpch.customer' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.customer
  UNION ALL
  -- Contamos el número de filas de la tabla de pedidos.
  SELECT 'samples.tpch.orders' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.orders
  UNION ALL
  -- Contamos el número de filas de la tabla de detalle de pedido.
  SELECT 'samples.tpch.lineitem' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.lineitem
  UNION ALL
  -- Contamos el número de filas de la tabla de productos.
  SELECT 'samples.tpch.part' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.part
  UNION ALL
  -- Contamos el número de filas de la tabla de proveedores.
  SELECT 'samples.tpch.supplier' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.supplier
  UNION ALL
  -- Contamos el número de filas de la tabla de países.
  SELECT 'samples.tpch.nation' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.nation
  UNION ALL
  -- Contamos el número de filas de la tabla de regiones.
  SELECT 'samples.tpch.region' AS tabla, COUNT(*) AS registros
  FROM samples.tpch.region
  UNION ALL
  -- Contamos el número de filas del dataset complementario de movilidad.
  SELECT 'samples.nyctaxi.trips' AS tabla, COUNT(*) AS registros
  FROM samples.nyctaxi.trips
)
-- Mostramos el volumen relativo de cada dataset para dimensionar el análisis.
SELECT
  -- Exponemos el nombre de la tabla evaluada.
  tabla,
  -- Exponemos el volumen de registros disponible.
  registros
FROM volumen_tablas
-- Ordenamos de mayor a menor para identificar rápidamente la tabla dominante.
ORDER BY registros DESC, tabla ASC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Módulo 1: Análisis de Clientes
-- MAGIC 
-- MAGIC En este módulo responderemos preguntas sobre **valor, segmentación, inactividad y concentración de ingresos**.
-- MAGIC 
-- MAGIC ### Hipótesis ejecutiva
-- MAGIC Si identificamos qué clientes compran más, qué segmentos aportan más valor y quiénes muestran señales de abandono, podremos asignar presupuesto comercial con mayor precisión.
-- MAGIC 
-- MAGIC ### Flujo analítico
-- MAGIC ```text
-- MAGIC Cliente -> Pedido -> Ingreso -> Recencia/Frecuencia -> Prioridad comercial
-- MAGIC ```
-- COMMAND ----------

-- Pregunta de negocio: ¿qué segmentos de clientes generan más ingresos y cómo se compara su productividad comercial?
-- Enfoque: consolidamos clientes y pedidos para calcular tamaño del segmento, volumen de pedidos e ingreso total.
WITH clientes_pedidos AS (
  -- Seleccionamos el identificador del cliente para agregar su actividad comercial.
  SELECT
    -- Conservamos la llave del cliente.
    c.c_custkey AS cliente_id,
    -- Conservamos el segmento de mercado para el análisis ejecutivo.
    c.c_mktsegment AS segmento,
    -- Conservamos el identificador del pedido para medir frecuencia de compra.
    o.o_orderkey AS pedido_id,
    -- Conservamos el valor total del pedido como métrica monetaria base.
    o.o_totalprice AS valor_pedido
  -- Partimos de la dimensión cliente.
  FROM samples.tpch.customer AS c
  -- Unimos pedidos para capturar comportamiento transaccional.
  INNER JOIN samples.tpch.orders AS o
    ON c.c_custkey = o.o_custkey
),
resumen_segmento AS (
  -- Agregamos por segmento para producir una tabla ejecutiva.
  SELECT
    -- Segmento comercial evaluado.
    segmento,
    -- Número de clientes únicos que compraron en el segmento.
    COUNT(DISTINCT cliente_id) AS clientes_activos,
    -- Número de pedidos emitidos por el segmento.
    COUNT(DISTINCT pedido_id) AS pedidos,
    -- Ingreso total aportado por el segmento.
    SUM(valor_pedido) AS ingresos,
    -- Ticket promedio por pedido del segmento.
    AVG(valor_pedido) AS ticket_promedio,
    -- Valor promedio por cliente activo dentro del segmento.
    SUM(valor_pedido) / COUNT(DISTINCT cliente_id) AS ltv_promedio_segmento
  -- Leemos desde la base preparada.
  FROM clientes_pedidos
  -- Consolidamos en una fila por segmento.
  GROUP BY segmento
)
-- Presentamos el ranking final para priorización de marketing y ventas.
SELECT
  -- Segmento comercial analizado.
  segmento,
  -- Clientes activos del segmento.
  clientes_activos,
  -- Pedidos del segmento.
  pedidos,
  -- Ingresos del segmento.
  ROUND(ingresos, 2) AS ingresos,
  -- Ticket promedio del segmento.
  ROUND(ticket_promedio, 2) AS ticket_promedio,
  -- LTV promedio del segmento.
  ROUND(ltv_promedio_segmento, 2) AS ltv_promedio_segmento,
  -- Ranking ejecutivo del segmento por ingreso total.
  DENSE_RANK() OVER (ORDER BY ingresos DESC) AS ranking_ingresos
FROM resumen_segmento
-- Ordenamos por la contribución monetaria total.
ORDER BY ingresos DESC;

-- COMMAND ----------

-- Pregunta de negocio: ¿cuáles son los 10 clientes con mayor valor de vida (LTV)?
-- Enfoque: sumamos el valor histórico de todos sus pedidos y agregamos contexto geográfico.
WITH ltv_cliente AS (
  -- Construimos una base analítica por cliente.
  SELECT
    -- Identificador del cliente.
    c.c_custkey AS cliente_id,
    -- Nombre del cliente para consumo ejecutivo.
    c.c_name AS cliente,
    -- Segmento de mercado del cliente.
    c.c_mktsegment AS segmento,
    -- País del cliente.
    n.n_name AS pais,
    -- Región del cliente.
    r.r_name AS region,
    -- Número de pedidos realizados por el cliente.
    COUNT(DISTINCT o.o_orderkey) AS pedidos,
    -- Fecha de la compra más reciente del cliente.
    MAX(o.o_orderdate) AS ultima_compra,
    -- Valor de vida histórico aproximado del cliente.
    SUM(o.o_totalprice) AS ltv
  -- Partimos del cliente.
  FROM samples.tpch.customer AS c
  -- Unimos pedidos para monetizar la relación comercial.
  INNER JOIN samples.tpch.orders AS o
    ON c.c_custkey = o.o_custkey
  -- Unimos país del cliente.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Unimos región del cliente.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Consolidamos al nivel cliente.
  GROUP BY c.c_custkey, c.c_name, c.c_mktsegment, n.n_name, r.r_name
),
ranking_ltv AS (
  -- Aplicamos ranking descendente por LTV.
  SELECT
    -- Conservamos todas las columnas calculadas.
    *,
    -- Asignamos una posición única por valor de vida.
    ROW_NUMBER() OVER (ORDER BY ltv DESC, pedidos DESC, cliente_id ASC) AS posicion_ltv
  FROM ltv_cliente
)
-- Devolvemos el top 10 ejecutivo.
SELECT
  -- Posición del cliente en el ranking de LTV.
  posicion_ltv,
  -- Identificador del cliente.
  cliente_id,
  -- Nombre del cliente.
  cliente,
  -- Segmento del cliente.
  segmento,
  -- Región del cliente.
  region,
  -- País del cliente.
  pais,
  -- Número de pedidos del cliente.
  pedidos,
  -- Fecha de última compra.
  ultima_compra,
  -- Valor de vida total del cliente.
  ROUND(ltv, 2) AS ltv
FROM ranking_ltv
-- Filtramos solo los diez clientes líderes.
WHERE posicion_ltv <= 10
-- Ordenamos por la posición calculada.
ORDER BY posicion_ltv ASC;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué clientes no han comprado en los últimos periodos y deberían entrar a un plan de reactivación?
-- Enfoque: tomamos la fecha máxima de pedidos como referencia y detectamos clientes sin compra en los últimos tres meses del histórico.
WITH fecha_referencia AS (
  -- Calculamos la fecha máxima observada en la tabla de pedidos.
  SELECT
    -- Fecha de corte del proyecto.
    MAX(o_orderdate) AS fecha_maxima
  FROM samples.tpch.orders
),
ultima_compra_cliente AS (
  -- Resumimos la compra más reciente por cliente.
  SELECT
    -- Identificador del cliente.
    c.c_custkey AS cliente_id,
    -- Nombre del cliente.
    c.c_name AS cliente,
    -- Segmento del cliente.
    c.c_mktsegment AS segmento,
    -- Fecha de la compra más reciente.
    MAX(o.o_orderdate) AS ultima_compra,
    -- Ingreso histórico total del cliente para priorizar reactivación.
    SUM(o.o_totalprice) AS ingresos_historicos
  FROM samples.tpch.customer AS c
  LEFT JOIN samples.tpch.orders AS o
    ON c.c_custkey = o.o_custkey
  GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
)
-- Producimos la lista priorizada de clientes en riesgo de abandono.
SELECT
  -- Identificador del cliente inactivo.
  u.cliente_id,
  -- Nombre del cliente inactivo.
  u.cliente,
  -- Segmento del cliente inactivo.
  u.segmento,
  -- Fecha de la última compra registrada.
  u.ultima_compra,
  -- Días transcurridos desde la última compra hasta la fecha de referencia.
  DATEDIFF(f.fecha_maxima, u.ultima_compra) AS dias_desde_ultima_compra,
  -- Ingreso histórico generado por el cliente para priorizar campañas.
  ROUND(u.ingresos_historicos, 2) AS ingresos_historicos
FROM ultima_compra_cliente AS u
CROSS JOIN fecha_referencia AS f
-- Filtramos clientes cuya última compra ocurrió antes de la ventana de tres meses.
WHERE u.ultima_compra < ADD_MONTHS(f.fecha_maxima, -3)
-- Ordenamos por mayor antigüedad y luego por valor histórico.
ORDER BY dias_desde_ultima_compra DESC, ingresos_historicos DESC
-- Limitamos la salida para una lista accionable.
LIMIT 25;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué tan concentrado está el ingreso en pocos clientes?
-- Enfoque: clasificamos clientes en deciles por LTV y medimos cuánto ingreso acumula cada grupo.
WITH ltv_cliente AS (
  -- Calculamos el ingreso histórico por cliente.
  SELECT
    -- Identificador del cliente.
    o.o_custkey AS cliente_id,
    -- Ingreso total histórico del cliente.
    SUM(o.o_totalprice) AS ltv
  FROM samples.tpch.orders AS o
  GROUP BY o.o_custkey
),
deciles_ltv AS (
  -- Distribuimos los clientes en diez grupos por valor.
  SELECT
    -- Identificador del cliente.
    cliente_id,
    -- LTV del cliente.
    ltv,
    -- Decil asignado por valor de vida.
    NTILE(10) OVER (ORDER BY ltv DESC) AS decil_valor
  FROM ltv_cliente
)
-- Mostramos la concentración del ingreso por decil.
SELECT
  -- Decil del cliente, donde 1 representa mayor valor.
  decil_valor,
  -- Número de clientes dentro del decil.
  COUNT(*) AS clientes,
  -- Ingreso agregado del decil.
  ROUND(SUM(ltv), 2) AS ingreso_decil,
  -- Participación del decil sobre el ingreso total.
  ROUND(100 * SUM(ltv) / SUM(SUM(ltv)) OVER (), 2) AS porcentaje_ingreso,
  -- Participación acumulada para evaluar concentración tipo Pareto.
  ROUND(
    100 * SUM(SUM(ltv)) OVER (ORDER BY decil_valor ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    / SUM(SUM(ltv)) OVER (),
    2
  ) AS porcentaje_acumulado
FROM deciles_ltv
GROUP BY decil_valor
-- Ordenamos desde el decil de mayor valor al de menor valor.
ORDER BY decil_valor ASC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Lectura ejecutiva del Módulo 1
-- MAGIC 
-- MAGIC - El ranking de segmentos permite enfocar campañas y asignación de ejecutivos.
-- MAGIC - El top 10 de LTV identifica cuentas estratégicas que requieren gestión diferenciada.
-- MAGIC - La lista de clientes inactivos sirve como base para campañas de reactivación.
-- MAGIC - La concentración por deciles ayuda a responder si el negocio depende de una base muy reducida de clientes.
-- MAGIC 
-- MAGIC > **📝 Nota:** Si observas alta concentración en pocos clientes, la prioridad estratégica no es solo vender más, sino **diversificar riesgo comercial**.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Módulo 2: Análisis de Ventas y Productos
-- MAGIC 
-- MAGIC Ahora pasamos del nivel cliente al nivel **producto, demanda y abastecimiento**.
-- MAGIC 
-- MAGIC ### Supuesto metodológico
-- MAGIC La tabla `lineitem` nos permite observar la realidad operativa: cantidades, descuentos, proveedores y líneas vendidas.
-- MAGIC 
-- MAGIC > **📝 Nota:** La tabla `part` no contiene costo real. Para aproximar margen construiremos un **margen estimado** usando un costo teórico equivalente al **65% del precio retail**. El objetivo es pedagógico: documentar un supuesto y volverlo transparente.
-- COMMAND ----------

-- Pregunta de negocio: ¿qué productos o partes tienen mayor demanda?
-- Enfoque: agregamos líneas por producto para medir cantidad total, pedidos únicos e ingreso neto.
WITH demanda_producto AS (
  -- Consolidamos la demanda al nivel de producto.
  SELECT
    -- Identificador del producto.
    p.p_partkey AS producto_id,
    -- Nombre del producto.
    p.p_name AS producto,
    -- Marca del producto.
    p.p_brand AS marca,
    -- Tipo del producto.
    p.p_type AS tipo,
    -- Cantidad total vendida del producto.
    SUM(l.l_quantity) AS cantidad_total,
    -- Número de pedidos en los que aparece el producto.
    COUNT(DISTINCT l.l_orderkey) AS pedidos_con_producto,
    -- Ingreso neto estimado de venta del producto.
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS ventas_netas
  FROM samples.tpch.lineitem AS l
  INNER JOIN samples.tpch.part AS p
    ON l.l_partkey = p.p_partkey
  GROUP BY p.p_partkey, p.p_name, p.p_brand, p.p_type
)
-- Retornamos el ranking de mayor demanda para decisiones de surtido.
SELECT
  -- Posición del producto por cantidad vendida.
  ROW_NUMBER() OVER (ORDER BY cantidad_total DESC, ventas_netas DESC) AS ranking_demanda,
  -- Identificador del producto.
  producto_id,
  -- Nombre del producto.
  producto,
  -- Marca del producto.
  marca,
  -- Tipo del producto.
  tipo,
  -- Cantidad total vendida.
  ROUND(cantidad_total, 2) AS cantidad_total,
  -- Pedidos distintos con presencia del producto.
  pedidos_con_producto,
  -- Ventas netas del producto.
  ROUND(ventas_netas, 2) AS ventas_netas
FROM demanda_producto
ORDER BY cantidad_total DESC, ventas_netas DESC
LIMIT 15;

-- COMMAND ----------

-- Pregunta de negocio: ¿cuáles son los productos con mayor margen estimado?
-- Enfoque: calculamos ventas netas y restamos un costo teórico equivalente al 65% del precio retail multiplicado por la cantidad vendida.
WITH margen_producto AS (
  -- Construimos métricas económicas aproximadas por producto.
  SELECT
    -- Identificador del producto.
    p.p_partkey AS producto_id,
    -- Nombre del producto.
    p.p_name AS producto,
    -- Marca del producto.
    p.p_brand AS marca,
    -- Precio retail de referencia del catálogo.
    p.p_retailprice AS precio_retail,
    -- Cantidad total vendida del producto.
    SUM(l.l_quantity) AS cantidad_total,
    -- Ventas netas observadas descontando promociones.
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS ventas_netas,
    -- Costo teórico del producto según el supuesto pedagógico.
    SUM(l.l_quantity * p.p_retailprice * 0.65) AS costo_estimado
  FROM samples.tpch.lineitem AS l
  INNER JOIN samples.tpch.part AS p
    ON l.l_partkey = p.p_partkey
  GROUP BY p.p_partkey, p.p_name, p.p_brand, p.p_retailprice
)
-- Mostramos el ranking por margen absoluto y porcentaje de margen.
SELECT
  -- Identificador del producto.
  producto_id,
  -- Nombre del producto.
  producto,
  -- Marca del producto.
  marca,
  -- Cantidad total vendida.
  ROUND(cantidad_total, 2) AS cantidad_total,
  -- Ventas netas observadas.
  ROUND(ventas_netas, 2) AS ventas_netas,
  -- Costo teórico utilizado para el cálculo.
  ROUND(costo_estimado, 2) AS costo_estimado,
  -- Margen estimado en valor monetario.
  ROUND(ventas_netas - costo_estimado, 2) AS margen_estimado,
  -- Margen estimado como porcentaje de ventas.
  ROUND(100 * (ventas_netas - costo_estimado) / NULLIF(ventas_netas, 0), 2) AS porcentaje_margen_estimado,
  -- Ranking por margen absoluto.
  DENSE_RANK() OVER (ORDER BY ventas_netas - costo_estimado DESC) AS ranking_margen
FROM margen_producto
ORDER BY margen_estimado DESC
LIMIT 15;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué proveedores son más confiables por volumen y consistencia operativa?
-- Enfoque: combinamos líneas, pedidos, proveedor y tiempo para medir cantidad abastecida, pedidos servidos y meses activos.
WITH desempeno_proveedor AS (
  -- Agregamos desempeño operativo por proveedor.
  SELECT
    -- Identificador del proveedor.
    s.s_suppkey AS proveedor_id,
    -- Nombre del proveedor.
    s.s_name AS proveedor,
    -- País del proveedor.
    n.n_name AS pais_proveedor,
    -- Región del proveedor.
    r.r_name AS region_proveedor,
    -- Número de pedidos atendidos por el proveedor.
    COUNT(DISTINCT l.l_orderkey) AS pedidos_atendidos,
    -- Cantidad total suministrada por el proveedor.
    SUM(l.l_quantity) AS cantidad_suministrada,
    -- Ingreso neto asociado a los ítems suministrados por el proveedor.
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS ventas_asociadas,
    -- Número de meses con actividad visible en el histórico.
    COUNT(DISTINCT DATE_TRUNC('month', o.o_orderdate)) AS meses_activos
  FROM samples.tpch.lineitem AS l
  INNER JOIN samples.tpch.orders AS o
    ON l.l_orderkey = o.o_orderkey
  INNER JOIN samples.tpch.supplier AS s
    ON l.l_suppkey = s.s_suppkey
  INNER JOIN samples.tpch.nation AS n
    ON s.s_nationkey = n.n_nationkey
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  GROUP BY s.s_suppkey, s.s_name, n.n_name, r.r_name
)
-- Priorizamos proveedores con alto volumen y cobertura temporal sostenida.
SELECT
  -- Ranking de confiabilidad basado en cantidad y meses activos.
  DENSE_RANK() OVER (ORDER BY cantidad_suministrada DESC, meses_activos DESC, pedidos_atendidos DESC) AS ranking_confiabilidad,
  -- Identificador del proveedor.
  proveedor_id,
  -- Nombre del proveedor.
  proveedor,
  -- Región del proveedor.
  region_proveedor,
  -- País del proveedor.
  pais_proveedor,
  -- Pedidos atendidos por el proveedor.
  pedidos_atendidos,
  -- Cantidad total suministrada.
  ROUND(cantidad_suministrada, 2) AS cantidad_suministrada,
  -- Ventas asociadas al proveedor.
  ROUND(ventas_asociadas, 2) AS ventas_asociadas,
  -- Meses con actividad.
  meses_activos
FROM desempeno_proveedor
ORDER BY cantidad_suministrada DESC, meses_activos DESC, pedidos_atendidos DESC
LIMIT 15;

-- COMMAND ----------

-- Pregunta de negocio: para los productos de mayor demanda, ¿qué proveedor lidera el abastecimiento?
-- Enfoque: identificamos productos top y calculamos la participación de cada proveedor dentro de esos productos.
WITH top_productos AS (
  -- Seleccionamos los veinte productos con mayor cantidad vendida.
  SELECT
    -- Producto analizado.
    l.l_partkey AS producto_id,
    -- Cantidad total vendida del producto.
    SUM(l.l_quantity) AS cantidad_total
  FROM samples.tpch.lineitem AS l
  GROUP BY l.l_partkey
  ORDER BY cantidad_total DESC
  LIMIT 20
),
participacion_proveedor AS (
  -- Calculamos participación del proveedor dentro de cada producto top.
  SELECT
    -- Producto analizado.
    p.p_name AS producto,
    -- Nombre del proveedor.
    s.s_name AS proveedor,
    -- Cantidad abastecida por ese proveedor para el producto.
    SUM(l.l_quantity) AS cantidad_proveedor,
    -- Participación relativa del proveedor en el producto.
    SUM(l.l_quantity) / SUM(SUM(l.l_quantity)) OVER (PARTITION BY l.l_partkey) AS participacion_producto,
    -- Ranking del proveedor dentro del producto.
    ROW_NUMBER() OVER (PARTITION BY l.l_partkey ORDER BY SUM(l.l_quantity) DESC, s.s_name ASC) AS ranking_proveedor_producto
  FROM top_productos AS t
  INNER JOIN samples.tpch.lineitem AS l
    ON t.producto_id = l.l_partkey
  INNER JOIN samples.tpch.part AS p
    ON l.l_partkey = p.p_partkey
  INNER JOIN samples.tpch.supplier AS s
    ON l.l_suppkey = s.s_suppkey
  GROUP BY l.l_partkey, p.p_name, s.s_name
)
-- Mostramos el proveedor líder por producto crítico.
SELECT
  -- Producto analizado.
  producto,
  -- Proveedor con mayor participación.
  proveedor,
  -- Cantidad suministrada por el proveedor líder.
  ROUND(cantidad_proveedor, 2) AS cantidad_proveedor,
  -- Participación del proveedor sobre la demanda del producto.
  ROUND(100 * participacion_producto, 2) AS porcentaje_participacion
FROM participacion_proveedor
WHERE ranking_proveedor_producto = 1
ORDER BY porcentaje_participacion DESC, cantidad_proveedor DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Lectura ejecutiva del Módulo 2
-- MAGIC 
-- MAGIC - Los productos con más demanda ayudan a priorizar inventario, merchandising y negociación comercial.
-- MAGIC - El margen estimado introduce una conversación clave: **no todo lo que más vende es lo que más rentabiliza**.
-- MAGIC - El ranking de proveedores sirve para identificar aliados críticos y riesgos de dependencia.
-- MAGIC - La relación producto-proveedor apoya decisiones de abastecimiento y continuidad operativa.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Módulo 3: Análisis Geográfico
-- MAGIC 
-- MAGIC En este módulo evaluaremos la distribución espacial del negocio: **regiones, países, densidad de clientes y concentración del ingreso**.
-- MAGIC 
-- MAGIC ### Pregunta estratégica
-- MAGIC ¿La compañía está equilibrada globalmente o depende de unas pocas geografías?
-- COMMAND ----------

-- Pregunta de negocio: ¿en qué regiones y países del mundo se concentran las ventas?
-- Enfoque: unimos clientes con su geografía y resumimos pedidos e ingresos por región y país.
WITH ventas_geograficas AS (
  -- Construimos una base por pedido enriquecida con país y región del cliente.
  SELECT
    -- Región del cliente comprador.
    r.r_name AS region,
    -- País del cliente comprador.
    n.n_name AS pais,
    -- Identificador del cliente.
    c.c_custkey AS cliente_id,
    -- Identificador del pedido.
    o.o_orderkey AS pedido_id,
    -- Valor monetario del pedido.
    o.o_totalprice AS valor_pedido
  FROM samples.tpch.orders AS o
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
)
-- Agregamos la información para producir un mapa ejecutivo de ingresos.
SELECT
  -- Región del cliente.
  region,
  -- País del cliente.
  pais,
  -- Clientes únicos activos en la geografía.
  COUNT(DISTINCT cliente_id) AS clientes_activos,
  -- Pedidos emitidos desde la geografía.
  COUNT(DISTINCT pedido_id) AS pedidos,
  -- Ingreso total de la geografía.
  ROUND(SUM(valor_pedido), 2) AS ingresos,
  -- Ticket promedio de la geografía.
  ROUND(AVG(valor_pedido), 2) AS ticket_promedio
FROM ventas_geograficas
GROUP BY region, pais
ORDER BY ingresos DESC, pedidos DESC;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué tan concentradas están las ventas globales por región?
-- Enfoque: calculamos participación y acumulado regional para medir dependencia geográfica.
WITH ventas_region AS (
  -- Resumimos ingresos al nivel región.
  SELECT
    -- Región del cliente.
    r.r_name AS region,
    -- Ingreso total de la región.
    SUM(o.o_totalprice) AS ingresos
  FROM samples.tpch.orders AS o
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  GROUP BY r.r_name
)
-- Mostramos participación y acumulado para una lectura tipo Pareto geográfico.
SELECT
  -- Región analizada.
  region,
  -- Ingreso total de la región.
  ROUND(ingresos, 2) AS ingresos,
  -- Participación porcentual de la región en el total global.
  ROUND(100 * ingresos / SUM(ingresos) OVER (), 2) AS porcentaje_global,
  -- Porcentaje acumulado según ranking de ingresos.
  ROUND(
    100 * SUM(ingresos) OVER (ORDER BY ingresos DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    / SUM(ingresos) OVER (),
    2
  ) AS porcentaje_acumulado,
  -- Ranking regional por ingreso.
  DENSE_RANK() OVER (ORDER BY ingresos DESC) AS ranking_region
FROM ventas_region
ORDER BY ingresos DESC;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué regiones tienen mucha base de clientes pero menor monetización por cliente?
-- Enfoque: comparamos número de clientes, ingreso total e ingreso promedio por cliente para detectar oportunidades de expansión.
WITH clientes_region AS (
  -- Contamos clientes por región en la base maestra.
  SELECT
    -- Región del cliente.
    r.r_name AS region,
    -- Número de clientes registrados en la región.
    COUNT(DISTINCT c.c_custkey) AS clientes_registrados
  FROM samples.tpch.customer AS c
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  GROUP BY r.r_name
),
ingresos_region AS (
  -- Calculamos ingreso observado por región.
  SELECT
    -- Región del cliente comprador.
    r.r_name AS region,
    -- Ingreso total observado en pedidos.
    SUM(o.o_totalprice) AS ingresos
  FROM samples.tpch.orders AS o
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  GROUP BY r.r_name
)
-- Combinamos tamaño de base y monetización para orientar crecimiento geográfico.
SELECT
  -- Región evaluada.
  c.region,
  -- Clientes registrados en la región.
  c.clientes_registrados,
  -- Ingreso total observado en la región.
  ROUND(i.ingresos, 2) AS ingresos,
  -- Ingreso promedio por cliente registrado.
  ROUND(i.ingresos / NULLIF(c.clientes_registrados, 0), 2) AS ingreso_por_cliente,
  -- Ranking por tamaño de base.
  DENSE_RANK() OVER (ORDER BY c.clientes_registrados DESC) AS ranking_clientes,
  -- Ranking por monetización regional.
  DENSE_RANK() OVER (ORDER BY i.ingresos DESC) AS ranking_ingresos
FROM clientes_region AS c
INNER JOIN ingresos_region AS i
  ON c.region = i.region
ORDER BY ingreso_por_cliente ASC, clientes_registrados DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Lectura ejecutiva del Módulo 3
-- MAGIC 
-- MAGIC - Las regiones con mayor ingreso explican la actual concentración comercial.
-- MAGIC - Los países líderes dentro de cada región sirven para focalizar expansión o defensa competitiva.
-- MAGIC - Una región con muchos clientes pero bajo ingreso por cliente puede requerir mejora en pricing, cross-sell o cobertura comercial.
-- MAGIC 
-- MAGIC > **📝 Nota:** El análisis geográfico no solo dice “dónde vendemos”, sino también “dónde estamos subcapitalizando nuestra base instalada”.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Módulo 4: Análisis de Tendencias Temporales
-- MAGIC 
-- MAGIC En este módulo pasamos del estado actual a la **dinámica temporal**: crecimiento, desaceleración, retención y estacionalidad.
-- MAGIC 
-- MAGIC ### Diagrama temporal
-- MAGIC ```text
-- MAGIC Fecha de pedido -> Mes -> Ingreso -> Variación -> Tendencia -> Acción
-- MAGIC ```
-- COMMAND ----------

-- Pregunta de negocio: ¿cuál es la evolución mensual de ventas?
-- Enfoque: resumimos pedidos por mes para monitorear ingresos, volumen y clientes activos.
WITH ventas_mensuales AS (
  -- Consolidamos actividad comercial al nivel mes.
  SELECT
    -- Mes calendario del pedido.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Pedidos del mes.
    COUNT(DISTINCT o.o_orderkey) AS pedidos,
    -- Clientes únicos del mes.
    COUNT(DISTINCT o.o_custkey) AS clientes_activos,
    -- Ingreso total del mes.
    SUM(o.o_totalprice) AS ingresos
  FROM samples.tpch.orders AS o
  GROUP BY DATE_TRUNC('month', o.o_orderdate)
)
-- Presentamos la serie temporal para el comité ejecutivo.
SELECT
  -- Mes analizado.
  mes,
  -- Pedidos del mes.
  pedidos,
  -- Clientes activos del mes.
  clientes_activos,
  -- Ingreso mensual.
  ROUND(ingresos, 2) AS ingresos,
  -- Ticket promedio mensual.
  ROUND(ingresos / NULLIF(pedidos, 0), 2) AS ticket_promedio_mensual
FROM ventas_mensuales
ORDER BY mes ASC;

-- COMMAND ----------

-- Pregunta de negocio: ¿la tendencia mensual está acelerando o desacelerando?
-- Enfoque: calculamos crecimiento mes contra mes y promedio móvil de tres meses.
WITH ventas_mensuales AS (
  -- Reutilizamos la agregación mensual de ingresos.
  SELECT
    -- Mes calendario del pedido.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Ingreso total del mes.
    SUM(o.o_totalprice) AS ingresos
  FROM samples.tpch.orders AS o
  GROUP BY DATE_TRUNC('month', o.o_orderdate)
),
serie_enriquecida AS (
  -- Añadimos métricas de tendencia usando funciones de ventana.
  SELECT
    -- Mes analizado.
    mes,
    -- Ingreso del mes.
    ingresos,
    -- Ingreso del mes anterior para comparación.
    LAG(ingresos) OVER (ORDER BY mes) AS ingresos_mes_anterior,
    -- Promedio móvil de tres meses para suavizar la serie.
    AVG(ingresos) OVER (ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS promedio_movil_3m
  FROM ventas_mensuales
)
-- Mostramos la lectura de tendencia ya lista para dashboard.
SELECT
  -- Mes analizado.
  mes,
  -- Ingreso del mes.
  ROUND(ingresos, 2) AS ingresos,
  -- Ingreso del mes previo.
  ROUND(ingresos_mes_anterior, 2) AS ingresos_mes_anterior,
  -- Variación porcentual mes contra mes.
  ROUND(100 * (ingresos - ingresos_mes_anterior) / NULLIF(ingresos_mes_anterior, 0), 2) AS crecimiento_mensual_pct,
  -- Promedio móvil de tres meses.
  ROUND(promedio_movil_3m, 2) AS promedio_movil_3m
FROM serie_enriquecida
ORDER BY mes ASC;

-- COMMAND ----------

-- Pregunta de negocio: ¿cuál es la tasa de retención de clientes mes a mes?
-- Enfoque: observamos clientes activos en un mes y verificamos cuántos repiten al mes siguiente.
WITH actividad_mensual AS (
  -- Generamos una fila por cliente y mes con actividad de compra.
  SELECT DISTINCT
    -- Mes en que el cliente estuvo activo.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Cliente activo en ese mes.
    o.o_custkey AS cliente_id
  FROM samples.tpch.orders AS o
),
retencion AS (
  -- Comparamos cada mes con el mes siguiente para medir continuidad.
  SELECT
    -- Mes base sobre el cual medimos retención.
    a1.mes AS mes_base,
    -- Número de clientes activos en el mes base.
    COUNT(DISTINCT a1.cliente_id) AS clientes_mes_base,
    -- Número de clientes del mes base que vuelven el mes siguiente.
    COUNT(DISTINCT a2.cliente_id) AS clientes_retenidos
  FROM actividad_mensual AS a1
  LEFT JOIN actividad_mensual AS a2
    ON a1.cliente_id = a2.cliente_id
   AND ADD_MONTHS(a1.mes, 1) = a2.mes
  GROUP BY a1.mes
)
-- Reportamos la tasa de retención para seguimiento comercial.
SELECT
  -- Mes base de la retención.
  mes_base,
  -- Clientes activos del mes base.
  clientes_mes_base,
  -- Clientes retenidos en el mes siguiente.
  clientes_retenidos,
  -- Tasa de retención porcentual.
  ROUND(100 * clientes_retenidos / NULLIF(clientes_mes_base, 0), 2) AS tasa_retencion_pct
FROM retencion
ORDER BY mes_base ASC;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué aprendizaje temporal complementario podemos tomar de otro dataset operativo?
-- Enfoque: usamos el dataset de taxis como ejemplo de serie temporal escalable para comparar patrones de volumen y ticket promedio.
WITH viajes_mensuales AS (
  -- Agregamos los viajes por mes calendario.
  SELECT
    -- Mes de pickup del viaje.
    DATE_TRUNC('month', tpep_pickup_datetime) AS mes,
    -- Número total de viajes observados.
    COUNT(*) AS viajes,
    -- Distancia promedio recorrida por viaje.
    AVG(trip_distance) AS distancia_promedio,
    -- Tarifa promedio por viaje.
    AVG(fare_amount) AS tarifa_promedio
  FROM samples.nyctaxi.trips
  GROUP BY DATE_TRUNC('month', tpep_pickup_datetime)
)
-- Mostramos la serie temporal resumida como benchmark operativo.
SELECT
  -- Mes observado en el dataset de taxis.
  mes,
  -- Volumen de viajes.
  viajes,
  -- Distancia promedio.
  ROUND(distancia_promedio, 2) AS distancia_promedio,
  -- Tarifa promedio.
  ROUND(tarifa_promedio, 2) AS tarifa_promedio
FROM viajes_mensuales
ORDER BY mes ASC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Lectura ejecutiva del Módulo 4
-- MAGIC 
-- MAGIC - La evolución mensual ayuda a distinguir crecimiento estructural de ruido de corto plazo.
-- MAGIC - El promedio móvil reduce volatilidad y mejora la lectura gerencial.
-- MAGIC - La retención mensual conecta ingresos con salud de la base de clientes.
-- MAGIC - El ejemplo de `nyctaxi.trips` muestra cómo la misma lógica temporal puede escalar a otros dominios analíticos.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Módulo 5: Preparación de datos para Machine Learning
-- MAGIC 
-- MAGIC El objetivo ahora es crear un **dataset analítico por cliente** que pueda alimentar modelos de:
-- MAGIC 
-- MAGIC - churn o riesgo de fuga,
-- MAGIC - scoring de valor,
-- MAGIC - recomendación comercial,
-- MAGIC - priorización de cuentas.
-- MAGIC 
-- MAGIC ### Principio de diseño
-- MAGIC Una buena tabla para ML debe tener una fila por entidad objetivo y columnas numéricas o categóricas que resuman comportamiento histórico.
-- COMMAND ----------

-- Pregunta de negocio: ¿qué variables base describen el comportamiento histórico de compra de cada cliente?
-- Enfoque: creamos una vista temporal con recencia, frecuencia, monetización, diversidad de productos y descuento promedio.
CREATE OR REPLACE TEMP VIEW vista_features_clientes AS
WITH fecha_referencia AS (
  -- Definimos una fecha máxima del histórico para medir recencia.
  SELECT
    -- Fecha de corte del dataset transaccional.
    MAX(o_orderdate) AS fecha_maxima
  FROM samples.tpch.orders
),
resumen_cliente AS (
  -- Construimos métricas de comportamiento por cliente.
  SELECT
    -- Identificador del cliente.
    c.c_custkey AS cliente_id,
    -- Segmento del cliente.
    c.c_mktsegment AS segmento,
    -- Saldo de cuenta reportado en la dimensión cliente.
    c.c_acctbal AS saldo_cuenta,
    -- Fecha de la primera compra registrada.
    MIN(o.o_orderdate) AS primera_compra,
    -- Fecha de la última compra registrada.
    MAX(o.o_orderdate) AS ultima_compra,
    -- Número total de pedidos del cliente.
    COUNT(DISTINCT o.o_orderkey) AS total_pedidos,
    -- Valor monetario total del cliente.
    SUM(o.o_totalprice) AS ingreso_total,
    -- Ticket promedio del cliente.
    AVG(o.o_totalprice) AS ticket_promedio,
    -- Número de meses distintos con actividad.
    COUNT(DISTINCT DATE_TRUNC('month', o.o_orderdate)) AS meses_activos,
    -- Número de productos distintos adquiridos por el cliente.
    COUNT(DISTINCT l.l_partkey) AS productos_distintos,
    -- Cantidad total comprada por el cliente.
    SUM(l.l_quantity) AS cantidad_total,
    -- Descuento promedio recibido en líneas de pedido.
    AVG(l.l_discount) AS descuento_promedio
  FROM samples.tpch.customer AS c
  LEFT JOIN samples.tpch.orders AS o
    ON c.c_custkey = o.o_custkey
  LEFT JOIN samples.tpch.lineitem AS l
    ON o.o_orderkey = l.l_orderkey
  GROUP BY c.c_custkey, c.c_mktsegment, c.c_acctbal
)
-- Dejamos lista la vista base de features por cliente.
SELECT
  -- Identificador del cliente.
  r.cliente_id,
  -- Segmento comercial.
  r.segmento,
  -- Saldo de cuenta reportado.
  r.saldo_cuenta,
  -- Primera compra del cliente.
  r.primera_compra,
  -- Última compra del cliente.
  r.ultima_compra,
  -- Recencia en días frente a la fecha máxima del histórico.
  DATEDIFF(f.fecha_maxima, r.ultima_compra) AS recencia_dias,
  -- Total de pedidos del cliente.
  r.total_pedidos,
  -- Ingreso total acumulado del cliente.
  r.ingreso_total,
  -- Ticket promedio del cliente.
  r.ticket_promedio,
  -- Meses activos del cliente.
  r.meses_activos,
  -- Número de productos distintos adquiridos.
  r.productos_distintos,
  -- Cantidad total comprada.
  r.cantidad_total,
  -- Descuento promedio observado.
  r.descuento_promedio
FROM resumen_cliente AS r
CROSS JOIN fecha_referencia AS f;

-- COMMAND ----------

-- Pregunta de negocio: ¿cómo enriquecemos la tabla base con scores y una etiqueta sencilla de riesgo?
-- Enfoque: añadimos quintiles de valor y recencia, más una etiqueta binaria de riesgo de fuga.
CREATE OR REPLACE TEMP VIEW dataset_ml_clientes AS
SELECT
  -- Identificador único del cliente.
  cliente_id,
  -- Segmento de mercado.
  segmento,
  -- Saldo de cuenta como predictor financiero.
  saldo_cuenta,
  -- Fecha de primera compra.
  primera_compra,
  -- Fecha de última compra.
  ultima_compra,
  -- Recencia en días.
  recencia_dias,
  -- Frecuencia medida por número de pedidos.
  total_pedidos,
  -- Ingreso monetario total.
  ingreso_total,
  -- Ticket promedio histórico.
  ticket_promedio,
  -- Número de meses con actividad.
  meses_activos,
  -- Diversidad de productos.
  productos_distintos,
  -- Volumen físico comprado.
  cantidad_total,
  -- Descuento promedio recibido.
  descuento_promedio,
  -- Score de valor, donde 1 es el grupo de mayor ingreso.
  NTILE(5) OVER (ORDER BY ingreso_total DESC NULLS LAST) AS quintil_valor,
  -- Score de recencia, donde 1 es el grupo más reciente.
  NTILE(5) OVER (ORDER BY recencia_dias ASC NULLS LAST) AS quintil_recencia,
  -- Etiqueta simple de riesgo de fuga para modelos supervisados iniciales.
  CASE WHEN recencia_dias > 90 THEN 1 ELSE 0 END AS etiqueta_riesgo_fuga,
  -- Indicador de cliente con compras observadas.
  CASE WHEN total_pedidos > 0 THEN 1 ELSE 0 END AS cliente_con_historial
FROM vista_features_clientes;

-- COMMAND ----------

-- Pregunta de negocio: ¿cómo luce el dataset final listo para modelos de Machine Learning?
-- Enfoque: inspeccionamos las features generadas y priorizamos los clientes más valiosos.
SELECT
  -- Identificador del cliente.
  cliente_id,
  -- Segmento comercial.
  segmento,
  -- Recencia del cliente en días.
  recencia_dias,
  -- Frecuencia histórica del cliente.
  total_pedidos,
  -- Ingreso acumulado del cliente.
  ROUND(ingreso_total, 2) AS ingreso_total,
  -- Ticket promedio del cliente.
  ROUND(ticket_promedio, 2) AS ticket_promedio,
  -- Número de meses activos.
  meses_activos,
  -- Diversidad de productos del cliente.
  productos_distintos,
  -- Descuento promedio recibido.
  ROUND(descuento_promedio, 4) AS descuento_promedio,
  -- Score de valor.
  quintil_valor,
  -- Score de recencia.
  quintil_recencia,
  -- Etiqueta de riesgo de fuga.
  etiqueta_riesgo_fuga
FROM dataset_ml_clientes
ORDER BY ingreso_total DESC NULLS LAST
LIMIT 50;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Dashboard SQL (reporte integral de negocio)
-- MAGIC 
-- MAGIC En esta sección condensamos los hallazgos en un formato cercano a un **dashboard ejecutivo**.
-- MAGIC 
-- MAGIC ### Estructura del dashboard
-- MAGIC ```text
-- MAGIC KPIs globales
-- MAGIC    + matriz región-segmento
-- MAGIC    + watchlist comercial
-- MAGIC    + panel de productos y proveedores
-- MAGIC ```
-- MAGIC 
-- MAGIC > **📝 Nota:** En Databricks, estas salidas pueden convertirse fácilmente en visualizaciones nativas: tarjetas KPI, barras, líneas, mapas o tablas con formato condicional.
-- COMMAND ----------

-- Pregunta de negocio: ¿cuál es el estado ejecutivo actual del negocio en una sola vista?
-- Enfoque: unimos métricas globales, retención reciente y líderes de región y segmento.
WITH kpi_global AS (
  -- Calculamos los principales indicadores de negocio.
  SELECT
    -- Número total de clientes con al menos una compra.
    COUNT(DISTINCT o.o_custkey) AS clientes_activos_historicos,
    -- Número total de pedidos históricos.
    COUNT(DISTINCT o.o_orderkey) AS pedidos_totales,
    -- Ingreso histórico total.
    SUM(o.o_totalprice) AS ingresos_totales,
    -- Ticket promedio histórico.
    AVG(o.o_totalprice) AS ticket_promedio
  FROM samples.tpch.orders AS o
),
fecha_referencia AS (
  -- Definimos la fecha más reciente del histórico para métricas de actividad.
  SELECT
    -- Fecha máxima observada en pedidos.
    MAX(o_orderdate) AS fecha_maxima
  FROM samples.tpch.orders
),
clientes_recientes AS (
  -- Contamos los clientes activos en la ventana reciente de noventa días.
  SELECT
    -- Número de clientes recientes.
    COUNT(DISTINCT o.o_custkey) AS clientes_activos_90d
  FROM samples.tpch.orders AS o
  CROSS JOIN fecha_referencia AS f
  WHERE o.o_orderdate >= DATE_ADD(f.fecha_maxima, -90)
),
retencion_reciente AS (
  -- Calculamos la retención del último mes base disponible.
  SELECT
    -- Tasa de retención más reciente del histórico.
    MAX(tasa_retencion_pct) AS ultima_retencion_pct
  FROM (
    SELECT
      -- Mes base de análisis.
      a1.mes AS mes_base,
      -- Tasa de retención resultante.
      ROUND(100 * COUNT(DISTINCT a2.cliente_id) / NULLIF(COUNT(DISTINCT a1.cliente_id), 0), 2) AS tasa_retencion_pct
    FROM (
      SELECT DISTINCT DATE_TRUNC('month', o_orderdate) AS mes, o_custkey AS cliente_id
      FROM samples.tpch.orders
    ) AS a1
    LEFT JOIN (
      SELECT DISTINCT DATE_TRUNC('month', o_orderdate) AS mes, o_custkey AS cliente_id
      FROM samples.tpch.orders
    ) AS a2
      ON a1.cliente_id = a2.cliente_id
     AND ADD_MONTHS(a1.mes, 1) = a2.mes
    GROUP BY a1.mes
  )
),
region_lider AS (
  -- Identificamos la región con mayor ingreso.
  SELECT
    -- Región líder por ventas.
    r.r_name AS region_lider,
    -- Ingreso total de la región líder.
    SUM(o.o_totalprice) AS ingreso_region
  FROM samples.tpch.orders AS o
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  GROUP BY r.r_name
  ORDER BY ingreso_region DESC
  LIMIT 1
),
segmento_lider AS (
  -- Identificamos el segmento con mayor ingreso.
  SELECT
    -- Segmento líder por ventas.
    c.c_mktsegment AS segmento_lider,
    -- Ingreso total del segmento líder.
    SUM(o.o_totalprice) AS ingreso_segmento
  FROM samples.tpch.orders AS o
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  GROUP BY c.c_mktsegment
  ORDER BY ingreso_segmento DESC
  LIMIT 1
)
-- Entregamos una sola fila con los KPIs del dashboard ejecutivo.
SELECT
  -- Clientes activos históricos.
  g.clientes_activos_historicos,
  -- Pedidos históricos totales.
  g.pedidos_totales,
  -- Ingreso total histórico.
  ROUND(g.ingresos_totales, 2) AS ingresos_totales,
  -- Ticket promedio histórico.
  ROUND(g.ticket_promedio, 2) AS ticket_promedio,
  -- Clientes activos en los últimos noventa días del histórico.
  c.clientes_activos_90d,
  -- Tasa de retención más reciente.
  r.ultima_retencion_pct,
  -- Región líder por ingresos.
  rl.region_lider,
  -- Segmento líder por ingresos.
  sl.segmento_lider
FROM kpi_global AS g
CROSS JOIN clientes_recientes AS c
CROSS JOIN retencion_reciente AS r
CROSS JOIN region_lider AS rl
CROSS JOIN segmento_lider AS sl;

-- COMMAND ----------

-- Pregunta de negocio: ¿cómo se distribuye el negocio en la intersección región-segmento?
-- Enfoque: construimos una matriz comercial para decisiones de cobertura y presupuesto.
SELECT
  -- Región del cliente.
  r.r_name AS region,
  -- Segmento del cliente.
  c.c_mktsegment AS segmento,
  -- Número de clientes únicos en la intersección.
  COUNT(DISTINCT c.c_custkey) AS clientes,
  -- Número de pedidos en la intersección.
  COUNT(DISTINCT o.o_orderkey) AS pedidos,
  -- Ingreso total de la intersección región-segmento.
  ROUND(SUM(o.o_totalprice), 2) AS ingresos,
  -- Ticket promedio en la intersección.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio,
  -- Participación sobre el total global.
  ROUND(100 * SUM(o.o_totalprice) / SUM(SUM(o.o_totalprice)) OVER (), 2) AS porcentaje_global
FROM samples.tpch.orders AS o
INNER JOIN samples.tpch.customer AS c
  ON o.o_custkey = c.c_custkey
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
GROUP BY r.r_name, c.c_mktsegment
ORDER BY ingresos DESC, clientes DESC;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué clientes deben entrar de inmediato a una watchlist comercial?
-- Enfoque: combinamos alto valor histórico con señales de inactividad para crear una lista de acción.
WITH fecha_referencia AS (
  -- Definimos la fecha máxima del histórico.
  SELECT
    -- Fecha más reciente observada en pedidos.
    MAX(o_orderdate) AS fecha_maxima
  FROM samples.tpch.orders
),
perfil_cliente AS (
  -- Resumimos valor y recencia por cliente.
  SELECT
    -- Identificador del cliente.
    c.c_custkey AS cliente_id,
    -- Nombre del cliente.
    c.c_name AS cliente,
    -- Segmento del cliente.
    c.c_mktsegment AS segmento,
    -- Ingreso histórico acumulado.
    SUM(o.o_totalprice) AS ingreso_total,
    -- Fecha de última compra del cliente.
    MAX(o.o_orderdate) AS ultima_compra
  FROM samples.tpch.customer AS c
  INNER JOIN samples.tpch.orders AS o
    ON c.c_custkey = o.o_custkey
  GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
watchlist_base AS (
  -- Calculamos recencia y deciles de valor antes de clasificar clientes.
  SELECT
    -- Identificador del cliente.
    p.cliente_id,
    -- Nombre del cliente.
    p.cliente,
    -- Segmento del cliente.
    p.segmento,
    -- Ingreso histórico del cliente.
    p.ingreso_total,
    -- Fecha de última compra.
    p.ultima_compra,
    -- Días de recencia frente a la fecha máxima.
    DATEDIFF(f.fecha_maxima, p.ultima_compra) AS recencia_dias,
    -- Decil de valor histórico del cliente para priorización.
    NTILE(10) OVER (ORDER BY p.ingreso_total DESC) AS decil_valor
  FROM perfil_cliente AS p
  CROSS JOIN fecha_referencia AS f
),
watchlist AS (
  -- Etiquetamos clientes según valor e inactividad.
  SELECT
    -- Identificador del cliente.
    w.cliente_id,
    -- Nombre del cliente.
    w.cliente,
    -- Segmento del cliente.
    w.segmento,
    -- Ingreso histórico del cliente.
    w.ingreso_total,
    -- Fecha de última compra.
    w.ultima_compra,
    -- Días de recencia frente a la fecha máxima.
    w.recencia_dias,
    -- Decil de valor histórico del cliente.
    w.decil_valor,
    -- Clasificación operativa para la acción comercial.
    CASE
      WHEN w.decil_valor = 1
       AND w.recencia_dias > 90 THEN 'VIP en riesgo'
      WHEN w.decil_valor <= 3
       AND w.recencia_dias BETWEEN 60 AND 90 THEN 'Cuenta estratégica por reactivar'
      ELSE 'Seguimiento estándar'
    END AS categoria_watchlist
  FROM watchlist_base AS w
)
-- Mostramos solo clientes que requieren atención prioritaria.
SELECT
  -- Identificador del cliente.
  cliente_id,
  -- Nombre del cliente.
  cliente,
  -- Segmento del cliente.
  segmento,
  -- Categoría de la watchlist.
  categoria_watchlist,
  -- Ingreso histórico del cliente.
  ROUND(ingreso_total, 2) AS ingreso_total,
  -- Fecha de última compra.
  ultima_compra,
  -- Recencia medida en días.
  recencia_dias
FROM watchlist
WHERE categoria_watchlist <> 'Seguimiento estándar'
ORDER BY ingreso_total DESC, recencia_dias DESC
LIMIT 25;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué combinación producto-proveedor sostiene el negocio operativo actual?
-- Enfoque: resumimos ventas y volumen por producto y señalamos el proveedor dominante.
WITH ventas_producto_proveedor AS (
  -- Agregamos líneas al nivel producto-proveedor.
  SELECT
    -- Producto analizado.
    p.p_name AS producto,
    -- Proveedor asociado.
    s.s_name AS proveedor,
    -- Cantidad total suministrada por la combinación.
    SUM(l.l_quantity) AS cantidad_total,
    -- Venta neta asociada a la combinación.
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS ventas_netas,
    -- Ranking del proveedor dentro del producto.
    ROW_NUMBER() OVER (
      PARTITION BY p.p_name
      ORDER BY SUM(l.l_quantity) DESC, SUM(l.l_extendedprice * (1 - l.l_discount)) DESC
    ) AS ranking_proveedor
  FROM samples.tpch.lineitem AS l
  INNER JOIN samples.tpch.part AS p
    ON l.l_partkey = p.p_partkey
  INNER JOIN samples.tpch.supplier AS s
    ON l.l_suppkey = s.s_suppkey
  GROUP BY p.p_name, s.s_name
),
productos_lideres AS (
  -- Seleccionamos productos de mayor peso comercial con su proveedor principal.
  SELECT
    -- Producto analizado.
    producto,
    -- Proveedor dominante del producto.
    proveedor,
    -- Cantidad total suministrada del producto por el proveedor líder.
    cantidad_total,
    -- Ventas netas asociadas.
    ventas_netas
  FROM ventas_producto_proveedor
  WHERE ranking_proveedor = 1
)
-- Presentamos el panel operativo para compras y supply chain.
SELECT
  -- Producto líder del panel.
  producto,
  -- Proveedor principal del producto.
  proveedor,
  -- Volumen suministrado.
  ROUND(cantidad_total, 2) AS cantidad_total,
  -- Ventas netas asociadas.
  ROUND(ventas_netas, 2) AS ventas_netas,
  -- Ranking comercial del producto por ventas netas.
  DENSE_RANK() OVER (ORDER BY ventas_netas DESC) AS ranking_producto_comercial
FROM productos_lideres
ORDER BY ventas_netas DESC
LIMIT 20;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Desafíos adicionales
-- MAGIC 
-- MAGIC Si quieres llevar el proyecto más lejos, intenta resolver estos desafíos por tu cuenta:
-- MAGIC 
-- MAGIC 1. Construir una **cohorte de clientes** por mes de primera compra y medir supervivencia a 3, 6 y 12 meses.
-- MAGIC 2. Crear un **índice RFM** completo (`Recency`, `Frequency`, `Monetary`) y clasificar clientes premium.
-- MAGIC 3. Detectar **anomalías de pedidos** usando desviación estándar o percentiles por segmento y mes.
-- MAGIC 4. Diseñar un **ranking de riesgo de abastecimiento** considerando concentración de proveedor por producto.
-- MAGIC 5. Crear una tabla de **contribución acumulada** de productos para encontrar el equivalente al principio 80/20.
-- MAGIC 6. Integrar una serie temporal de `samples.nyctaxi.trips` con ventanas móviles de 7 y 30 periodos.
-- MAGIC 
-- MAGIC A continuación se muestran dos desafíos resueltos como ejemplo de extensión analítica.
-- COMMAND ----------

-- Pregunta de negocio: ¿cómo se comportan las cohortes de clientes según su mes de primera compra?
-- Enfoque: asignamos un mes de primera compra a cada cliente y medimos actividad posterior por antigüedad de la cohorte.
WITH primera_compra AS (
  -- Calculamos el primer mes de compra por cliente.
  SELECT
    -- Cliente de la cohorte.
    o.o_custkey AS cliente_id,
    -- Mes de inicio de la relación comercial.
    DATE_TRUNC('month', MIN(o.o_orderdate)) AS mes_cohorte
  FROM samples.tpch.orders AS o
  GROUP BY o.o_custkey
),
actividad_cohorte AS (
  -- Relacionamos cada compra con la cohorte del cliente.
  SELECT
    -- Mes de cohorte del cliente.
    p.mes_cohorte,
    -- Mes de actividad observado.
    DATE_TRUNC('month', o.o_orderdate) AS mes_actividad,
    -- Cliente activo en ese mes.
    o.o_custkey AS cliente_id
  FROM samples.tpch.orders AS o
  INNER JOIN primera_compra AS p
    ON o.o_custkey = p.cliente_id
)
-- Medimos supervivencia de clientes por cohorte y antigüedad mensual.
SELECT
  -- Cohorte de origen del cliente.
  mes_cohorte,
  -- Mes de actividad observado.
  mes_actividad,
  -- Meses transcurridos desde el origen de la cohorte.
  MONTHS_BETWEEN(mes_actividad, mes_cohorte) AS meses_desde_cohorte,
  -- Clientes activos observados en esa combinación.
  COUNT(DISTINCT cliente_id) AS clientes_activos
FROM actividad_cohorte
GROUP BY mes_cohorte, mes_actividad
ORDER BY mes_cohorte ASC, mes_actividad ASC;

-- COMMAND ----------

-- Pregunta de negocio: ¿qué pedidos son anómalamente altos para su segmento y mes?
-- Enfoque: comparamos cada pedido contra el promedio y la desviación estándar de su grupo temporal-comercial.
WITH pedidos_segmentados AS (
  -- Enriquecemos cada pedido con su segmento y mes.
  SELECT
    -- Identificador del pedido.
    o.o_orderkey AS pedido_id,
    -- Mes del pedido.
    DATE_TRUNC('month', o.o_orderdate) AS mes,
    -- Segmento del cliente que realizó el pedido.
    c.c_mktsegment AS segmento,
    -- Valor monetario del pedido.
    o.o_totalprice AS valor_pedido
  FROM samples.tpch.orders AS o
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
),
estadisticas_grupo AS (
  -- Calculamos estadísticos por mes y segmento.
  SELECT
    -- Mes del grupo.
    mes,
    -- Segmento del grupo.
    segmento,
    -- Promedio del valor de pedido dentro del grupo.
    AVG(valor_pedido) AS promedio_grupo,
    -- Desviación estándar muestral del grupo.
    STDDEV_SAMP(valor_pedido) AS desviacion_grupo
  FROM pedidos_segmentados
  GROUP BY mes, segmento
)
-- Detectamos outliers altos usando la regla promedio + 2 desviaciones estándar.
SELECT
  -- Identificador del pedido anómalo.
  p.pedido_id,
  -- Mes del pedido.
  p.mes,
  -- Segmento del pedido.
  p.segmento,
  -- Valor del pedido.
  ROUND(p.valor_pedido, 2) AS valor_pedido,
  -- Promedio del grupo de comparación.
  ROUND(e.promedio_grupo, 2) AS promedio_grupo,
  -- Desviación estándar del grupo.
  ROUND(e.desviacion_grupo, 2) AS desviacion_grupo,
  -- Exceso del pedido respecto al umbral de anomalía.
  ROUND(p.valor_pedido - (e.promedio_grupo + 2 * e.desviacion_grupo), 2) AS exceso_sobre_umbral
FROM pedidos_segmentados AS p
INNER JOIN estadisticas_grupo AS e
  ON p.mes = e.mes
 AND p.segmento = e.segmento
WHERE p.valor_pedido > e.promedio_grupo + 2 * e.desviacion_grupo
ORDER BY exceso_sobre_umbral DESC, valor_pedido DESC
LIMIT 30;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Resumen del curso
-- MAGIC 
-- MAGIC A lo largo de los ocho notebooks recorriste un camino completo:
-- MAGIC 
-- MAGIC | Notebook | Competencia principal | Evidencia en este proyecto |
-- MAGIC |---|---|---|
-- MAGIC | 01 | exploración inicial | lectura del ecosistema Databricks |
-- MAGIC | 02 | consultas básicas | selección y filtrado de información |
-- MAGIC | 03 | funciones SQL | limpieza, reglas y transformaciones |
-- MAGIC | 04 | agregaciones | KPIs y métricas de negocio |
-- MAGIC | 05 | JOINs | integración de tablas relacionales |
-- MAGIC | 06 | subconsultas y CTEs | modularidad y análisis avanzado |
-- MAGIC | 07 | window functions | rankings, tendencias y concentración |
-- MAGIC | 08 | proyecto integrador | narrativa ejecutiva completa |
-- MAGIC 
-- MAGIC ### Idea central del curso
-- MAGIC **SQL no es solo un lenguaje para consultar datos; es una herramienta para pensar, estructurar y comunicar decisiones basadas en evidencia.**
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 14. Reflexión final y próximos pasos
-- MAGIC 
-- MAGIC Ya dominas el corazón del análisis relacional en Databricks SQL. El siguiente paso natural es integrar este trabajo con **Python y PySpark** para automatizar pipelines, entrenar modelos y publicar activos analíticos reutilizables.
-- MAGIC 
-- MAGIC ### Vista previa de integración
-- MAGIC ```python
-- MAGIC # Ejemplo conceptual en un siguiente módulo práctico
-- MAGIC df_ml = spark.sql("SELECT * FROM dataset_ml_clientes")
-- MAGIC display(df_ml)
-- MAGIC 
-- MAGIC # Luego podrías:
-- MAGIC # 1. limpiar valores faltantes,
-- MAGIC # 2. entrenar un modelo de churn,
-- MAGIC # 3. escribir predicciones en una tabla Delta,
-- MAGIC # 4. volver a consumirlas desde SQL.
-- MAGIC ```
-- MAGIC 
-- MAGIC ### Próximos pasos sugeridos
-- MAGIC 1. Convertir vistas temporales en tablas curadas.
-- MAGIC 2. Orquestar actualizaciones periódicas con jobs de Databricks.
-- MAGIC 3. Conectar dashboards SQL con modelos de scoring en PySpark.
-- MAGIC 4. Publicar resultados a usuarios de negocio mediante visualizaciones y alertas.
-- MAGIC 
-- MAGIC > **📝 Nota:** El perfil más valioso en ciencia de datos aplicada suele combinar tres capacidades: **SQL para entender el negocio, Python para automatizar y Spark para escalar**.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 15. Autoevaluación final
-- MAGIC 
-- MAGIC Responde estas preguntas antes de cerrar el proyecto:
-- MAGIC 
-- MAGIC 1. ¿Puedo explicar con claridad la diferencia entre el grano de `orders` y el de `lineitem`?
-- MAGIC 2. ¿Sé justificar por qué una métrica debe agregarse por cliente, producto, región o mes?
-- MAGIC 3. ¿Entiendo cuándo conviene usar una CTE, una subconsulta o una función de ventana?
-- MAGIC 4. ¿Puedo documentar supuestos analíticos, como el uso de un margen estimado?
-- MAGIC 5. ¿Sería capaz de convertir este notebook en una vista o pipeline productivo?
-- MAGIC 
-- MAGIC ### Checklist de dominio
-- MAGIC - [ ] Puedo construir consultas ejecutivas sin ambigüedad en el grano.
-- MAGIC - [ ] Puedo identificar clientes inactivos, segmentos líderes y productos críticos.
-- MAGIC - [ ] Puedo medir retención, concentración y tendencia temporal.
-- MAGIC - [ ] Puedo preparar un dataset analítico listo para ML.
-- MAGIC - [ ] Puedo comunicar hallazgos de forma profesional a una audiencia no técnica.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## ¡Felicitaciones!
-- MAGIC 
-- MAGIC Has completado el **Proyecto Integrador** del curso **Fundamentos de Programación** de la **Maestría en Ciencia de Datos** de la **Universidad de Antioquia**.
-- MAGIC 
-- MAGIC Cerraste el ciclo completo: desde consultas básicas hasta un reporte de inteligencia de negocio listo para una **C-suite**. Este es exactamente el tipo de trabajo que convierte a SQL en una competencia estratégica dentro de un programa de **Maestría en Ciencia de Datos**.
-- MAGIC 
-- MAGIC **Siguiente meta:** llevar estos resultados a notebooks híbridos con **SQL + Python + PySpark**, construir features en producción y conectar análisis descriptivo con modelos predictivos.
-- MAGIC 
-- MAGIC ¡Excelente trabajo!