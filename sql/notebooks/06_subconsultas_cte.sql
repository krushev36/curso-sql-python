-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Notebook 06: Subconsultas y CTE
-- MAGIC ## Fundamentos de Programación
-- MAGIC ### Maestría en Ciencia de Datos · Universidad de Antioquia
-- MAGIC ## 1. Bienvenida
-- MAGIC 
-- MAGIC Bienvenidas y bienvenidos al sexto notebook del curso **Fundamentos de Programación** de la **Maestría en Ciencia de Datos** de la **Universidad de Antioquia**.
-- MAGIC 
-- MAGIC En esta sesión asumirás el rol de **Data Analyst en DataCorp Analytics**. El equipo de analítica necesita responder preguntas de negocio que no se resuelven con una sola agregación: hace falta **descomponer el problema en pasos intermedios**, comparar contra promedios, validar existencia de registros relacionados y construir bloques reutilizables.
-- MAGIC 
-- MAGIC ### Rol profesional del caso
-- MAGIC | Elemento | Descripción |
-- MAGIC |---|---|
-- MAGIC | Empresa | DataCorp Analytics |
-- MAGIC | Rol del estudiante | Data Analyst |
-- MAGIC | Necesidad del negocio | Resolver preguntas analíticas multi-etapa |
-- MAGIC | Herramientas centrales | Subconsultas, `EXISTS`, `IN`, `ANY`, `ALL`, `WITH` |
-- MAGIC | Resultado esperado | Consultas legibles, correctas y reutilizables |
-- MAGIC 
-- MAGIC ```text
-- MAGIC Pregunta compleja -> Subpasos analíticos -> Validación lógica -> Resultado accionable
-- MAGIC ```
-- MAGIC 
-- MAGIC > **📝 Nota:** Una subconsulta no es “SQL avanzado por complejidad”, sino una forma ordenada de pensar: primero calculo algo intermedio, luego lo uso para decidir.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC 
-- MAGIC Al finalizar este notebook podrás:
-- MAGIC 
-- MAGIC 1. Explicar qué es una **subconsulta** y cuándo conviene usarla.
-- MAGIC 2. Aplicar subconsultas en `WHERE`, `FROM` y `SELECT`.
-- MAGIC 3. Distinguir correctamente entre subconsultas **correlacionadas** y **no correlacionadas**.
-- MAGIC 4. Resolver problemas de existencia con `EXISTS` y `NOT EXISTS`.
-- MAGIC 5. Comparar el uso de `IN` con subconsulta frente a `JOIN`.
-- MAGIC 6. Usar operadores `ANY` y `ALL` para comparaciones contra conjuntos.
-- MAGIC 7. Construir **CTE** simples, múltiples y encadenadas con `WITH`.
-- MAGIC 8. Reconocer cuándo una CTE mejora la **legibilidad**, la **modularidad** y la **mantenibilidad**.
-- MAGIC 9. Identificar escenarios donde conviene materializar resultados intermedios.
-- MAGIC 10. Interpretar casos de uso reales en negocio con subconsultas y CTE.
-- MAGIC 
-- MAGIC ### Evidencias esperadas
-- MAGIC | Habilidad | Evidencia |
-- MAGIC |---|---|
-- MAGIC | Descomponer problemas | consultas en varias capas |
-- MAGIC | Elegir la técnica correcta | uso razonado de subconsulta o CTE |
-- MAGIC | Evitar errores lógicos | control de duplicados, filtros y promedios |
-- MAGIC | Comunicar resultados | aliases y comentarios claros |

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias
-- MAGIC 
-- MAGIC ### Competencias técnicas
-- MAGIC - Diseñar subconsultas escalares, de tabla y de existencia.
-- MAGIC - Construir CTE nombradas para separar lógica analítica en módulos.
-- MAGIC - Encadenar varias CTE sin perder el grano del análisis.
-- MAGIC - Comparar conjuntos con `IN`, `ANY` y `ALL`.
-- MAGIC 
-- MAGIC ### Competencias analíticas
-- MAGIC - Traducir preguntas multi-etapa a una secuencia reproducible de pasos SQL.
-- MAGIC - Justificar por qué una comparación debe hacerse contra un promedio global, local o por segmento.
-- MAGIC - Detectar cuándo un `JOIN` puede duplicar filas y alterar la interpretación.
-- MAGIC 
-- MAGIC ### Competencias profesionales
-- MAGIC | Competencia | Aplicación en el trabajo |
-- MAGIC |---|---|
-- MAGIC | Claridad lógica | consultas auditables por otros analistas |
-- MAGIC | Reusabilidad | bloques SQL fáciles de extender |
-- MAGIC | Trazabilidad | resultados intermedios bien nombrados |
-- MAGIC | Comunicación | explicación de supuestos y riesgos |
-- MAGIC 
-- MAGIC > **📝 Nota:** En equipos de datos maduros, escribir SQL legible es tan importante como escribir SQL correcto.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC 
-- MAGIC El director de analítica de **DataCorp Analytics** ha pedido un notebook base para responder preguntas como:
-- MAGIC 
-- MAGIC 1. ¿Qué clientes están **por encima del comportamiento promedio**?
-- MAGIC 2. ¿Qué proveedores participan en productos de **demanda superior a su categoría**?
-- MAGIC 3. ¿Qué regiones combinan **alto volumen**, **alto ticket** y **concentración de clientes estratégicos**?
-- MAGIC 4. ¿Cómo estructurar consultas largas sin convertirlas en un bloque difícil de mantener?
-- MAGIC 
-- MAGIC ### Flujo de trabajo del analista
-- MAGIC 
-- MAGIC ```text
-- MAGIC Tablas base
-- MAGIC     |
-- MAGIC     v
-- MAGIC Resultado intermedio 1 (promedio, lista, existencia)
-- MAGIC     |
-- MAGIC     v
-- MAGIC Resultado intermedio 2 (filtrado o enriquecido)
-- MAGIC     |
-- MAGIC     v
-- MAGIC Resultado final para decisión
-- MAGIC ```
-- MAGIC 
-- MAGIC ### Tablas de trabajo de este notebook
-- MAGIC | Dataset | Uso principal |
-- MAGIC |---|---|
-- MAGIC | `samples.tpch.customer` | clientes, segmento, saldo |
-- MAGIC | `samples.tpch.orders` | pedidos, fechas, valor total |
-- MAGIC | `samples.tpch.lineitem` | detalle de venta, cantidad, descuento |
-- MAGIC | `samples.tpch.part` | producto, tipo, tamaño, precio |
-- MAGIC | `samples.tpch.supplier` | proveedor |
-- MAGIC | `samples.tpch.nation` | país |
-- MAGIC | `samples.tpch.region` | región |
-- MAGIC | `samples.nyctaxi.trips` | referencia opcional para extender ejercicios temporales |
-- MAGIC 
-- MAGIC > **📝 Nota:** Aunque el caso es ficticio, el patrón de trabajo es real: casi toda pregunta compleja en analítica requiere uno o varios pasos intermedios.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos
-- MAGIC 
-- MAGIC ### 5.1 ¿Qué es una subconsulta?
-- MAGIC Una **subconsulta** es una consulta dentro de otra consulta. Sirve para producir un valor, una lista o una tabla intermedia que luego usa la consulta principal.
-- MAGIC 
-- MAGIC ### 5.2 Tipos principales
-- MAGIC | Tipo | Devuelve | Lugar típico | Uso frecuente |
-- MAGIC |---|---|---|---|
-- MAGIC | Escalar | un solo valor | `SELECT`, `WHERE` | comparar contra promedio o total global |
-- MAGIC | De lista | una columna con varios valores | `IN`, `ANY`, `ALL` | filtrar por pertenencia o comparación |
-- MAGIC | De tabla | varias columnas y filas | `FROM` | crear una tabla derivada o vista inline |
-- MAGIC | Correlacionada | depende de la fila externa | `WHERE`, `SELECT` | comparar cada fila con su propio grupo |
-- MAGIC 
-- MAGIC ### 5.3 `EXISTS` y `NOT EXISTS`
-- MAGIC - `EXISTS` devuelve verdadero si la subconsulta encuentra al menos una fila.
-- MAGIC - `NOT EXISTS` devuelve verdadero si la subconsulta no encuentra filas.
-- MAGIC - Suele ser ideal cuando la pregunta es: **“¿existe relación?”**
-- MAGIC 
-- MAGIC ### 5.4 `IN` con subconsulta vs `JOIN`
-- MAGIC | Técnica | Ventaja | Riesgo | Cuándo usar |
-- MAGIC |---|---|---|---|
-- MAGIC | `IN (subconsulta)` | semántica clara de pertenencia | puede requerir cuidado con `NULL` | cuando filtras por membresía |
-- MAGIC | `JOIN` | permite traer columnas adicionales | puede duplicar filas | cuando además necesitas enriquecer el resultado |
-- MAGIC 
-- MAGIC ### 5.5 `ANY` y `ALL`
-- MAGIC - `> ANY (...)` significa “mayor que **al menos uno** de los valores del conjunto”.
-- MAGIC - `> ALL (...)` significa “mayor que **todos** los valores del conjunto”.
-- MAGIC - Una forma intuitiva de recordarlo es:
-- MAGIC 
-- MAGIC ```text
-- MAGIC > ANY  ~ mayor que el mínimo de algún grupo
-- MAGIC > ALL  ~ mayor que el máximo de todo un grupo
-- MAGIC ```
-- MAGIC 
-- MAGIC ### 5.6 CTE (`WITH`)
-- MAGIC Una **Common Table Expression** es un bloque con nombre definido al inicio de la consulta mediante `WITH`.
-- MAGIC 
-- MAGIC ```text
-- MAGIC WITH bloque_1 AS (...),
-- MAGIC      bloque_2 AS (...)
-- MAGIC SELECT ...
-- MAGIC ```
-- MAGIC 
-- MAGIC ### 5.7 Cuándo preferir CTE o subconsulta
-- MAGIC | Si necesitas... | Conviene más |
-- MAGIC |---|---|
-- MAGIC | usar el resultado una sola vez y muy cerca del filtro | subconsulta |
-- MAGIC | dividir la lógica en etapas legibles | CTE |
-- MAGIC | reutilizar un bloque en varias partes de la misma consulta | CTE |
-- MAGIC | expresar existencia puntual | `EXISTS` |
-- MAGIC 
-- MAGIC ### 5.8 CTE recursivas y materialización
-- MAGIC - **CTE recursiva:** se referencia a sí misma para recorrer jerarquías, secuencias o grafos simples.
-- MAGIC - **Materializar una CTE:** cuando el resultado intermedio es costoso y se reutiliza muchas veces, puede convenir persistirlo como `TEMP VIEW` o tabla intermedia.
-- MAGIC - En Databricks, una CTE suele ser una construcción lógica; el optimizador decide cómo ejecutarla.
-- MAGIC 
-- MAGIC > **📝 Nota:** La mejor pregunta no es “¿qué sintaxis me sé?”, sino “¿qué estructura hace más comprensible esta lógica dentro de mi equipo?”.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso
-- MAGIC 
-- MAGIC ### Método recomendado para resolver preguntas multi-etapa
-- MAGIC 
-- MAGIC 1. **Define la pregunta exacta.** ¿Buscas comparar, filtrar, detectar existencia o construir una tabla intermedia?
-- MAGIC 2. **Fija el grano.** ¿Una fila por cliente, pedido, región o producto?
-- MAGIC 3. **Decide el tipo de resultado intermedio.** Valor único, lista de llaves o tabla resumida.
-- MAGIC 4. **Elige la estructura.** Subconsulta escalar, correlacionada, tabla derivada o CTE.
-- MAGIC 5. **Valida duplicados.** Si un `JOIN` cambia el número de filas, quizás necesitabas `EXISTS`, `IN` o una agregación previa.
-- MAGIC 6. **Nombra bien los bloques.** Una CTE llamada `ingresos_cliente` comunica mejor que una subconsulta anónima larga.
-- MAGIC 7. **Comprueba el resultado esperado.** Antes de optimizar, verifica la lógica.
-- MAGIC 
-- MAGIC ### Flujo lógico típico
-- MAGIC 
-- MAGIC ```text
-- MAGIC FROM/JOIN
-- MAGIC    -> WHERE
-- MAGIC    -> subconsulta o CTE intermedia
-- MAGIC    -> SELECT final
-- MAGIC    -> ORDER BY / LIMIT
-- MAGIC ```
-- MAGIC 
-- MAGIC ### Errores comunes
-- MAGIC | Error | Por qué ocurre | Cómo evitarlo |
-- MAGIC |---|---|---|
-- MAGIC | La subconsulta devuelve muchas filas cuando se esperaba una | se usó subconsulta escalar sin asegurar unicidad | agregar agregación o filtro |
-- MAGIC | Un `JOIN` duplica clientes o pedidos | se unió contra detalle sin resumir antes | agregar `GROUP BY`, `DISTINCT` o usar `EXISTS` |
-- MAGIC | La consulta es correcta pero ilegible | demasiada lógica anidada sin nombres | mover bloques a CTE |
-- MAGIC | `NOT IN` falla con `NULL` | semántica de `NULL` en listas | preferir `NOT EXISTS` cuando hay duda |
-- MAGIC 
-- MAGIC > **📝 Nota:** En términos pedagógicos, una CTE es una forma de “poner nombre a un pensamiento intermedio”.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado
-- MAGIC 
-- MAGIC En esta sección verás **5 ejemplos completos**. Cada consulta incluye el motivo de diseño, el papel de cada cláusula, el resultado esperado y errores comunes.
-- MAGIC 
-- MAGIC | Ejemplo | Dificultad | Idea central |
-- MAGIC |---|---|---|
-- MAGIC | 1 de 5 | Muy Fácil | subconsulta no correlacionada en `WHERE` |
-- MAGIC | 2 de 5 | Fácil | subconsulta correlacionada en `WHERE` |
-- MAGIC | 3 de 5 | Intermedio | subconsulta en `FROM` |
-- MAGIC | 4 de 5 | Intermedio | subconsulta escalar en `SELECT` |
-- MAGIC | 5 de 5 | Intermedio Alto | `EXISTS` y `NOT EXISTS` |

-- COMMAND ----------
-- Ejemplo 1 de 5.
-- ¿Por qué esta consulta está escrita así?: porque primero calculamos un promedio global y luego filtramos clientes por encima de ese valor de referencia.
-- Qué hace cada cláusula:
-- - SELECT proyecta las columnas que permiten interpretar quién supera el promedio.
-- - FROM define la tabla base de clientes.
-- - WHERE aplica una subconsulta escalar no correlacionada, porque se ejecuta como referencia global.
-- - ORDER BY prioriza a los clientes con mayor saldo.
-- Resultado esperado: una lista de clientes cuyo saldo de cuenta supera el promedio general de la tabla customer.
-- Error común: escribir una subconsulta que devuelva varias filas; aquí evitamos ese error usando AVG, que siempre devuelve un solo valor.
SELECT
  -- Seleccionamos la llave del cliente para identificar de forma única cada registro del resultado.
  c.c_custkey AS cliente_id,
  -- Mostramos el nombre del cliente para hacer interpretable la salida para negocio.
  c.c_name AS nombre_cliente,
  -- Conservamos el segmento para contextualizar el perfil comercial del cliente.
  c.c_mktsegment AS segmento,
  -- Mostramos el saldo de cuenta que será comparado contra el promedio global.
  c.c_acctbal AS saldo_cuenta
-- Indicamos que la tabla principal del análisis es la dimensión de clientes.
FROM samples.tpch.customer AS c
-- Filtramos solo clientes cuyo saldo es mayor que el promedio global calculado por la subconsulta.
WHERE c.c_acctbal > (
  -- La subconsulta calcula el promedio de saldo para toda la cartera de clientes.
  SELECT AVG(c2.c_acctbal)
  -- Leemos nuevamente la tabla customer, pero ahora como fuente del valor de referencia global.
  FROM samples.tpch.customer AS c2
)
-- Ordenamos de mayor a menor para ver primero los clientes con mayor saldo.
ORDER BY c.c_acctbal DESC
-- Limitamos la salida para revisión pedagógica rápida.
LIMIT 15;

-- COMMAND ----------

-- Ejemplo 2 de 5.
-- ¿Por qué esta consulta está escrita así?: porque queremos comparar cada pedido contra el promedio de pedidos del mismo cliente, no contra el promedio global.
-- Qué hace cada cláusula:
-- - SELECT muestra el pedido y su contexto analítico.
-- - FROM toma la tabla orders como hecho principal.
-- - WHERE contiene una subconsulta correlacionada porque depende del cliente de la fila externa.
-- - ORDER BY agrupa visualmente por cliente y prioriza pedidos altos.
-- Resultado esperado: pedidos cuyo valor supera el ticket promedio histórico del propio cliente.
-- Error común: olvidar la condición de correlación y terminar comparando contra el promedio global por accidente.
SELECT
  -- Seleccionamos la llave del pedido para identificar la transacción específica.
  o.o_orderkey AS pedido_id,
  -- Seleccionamos la llave del cliente porque la comparación se hace dentro de cada cliente.
  o.o_custkey AS cliente_id,
  -- Conservamos la fecha del pedido para posibles lecturas temporales.
  o.o_orderdate AS fecha_pedido,
  -- Mostramos el valor total del pedido que se compara contra el promedio individual.
  o.o_totalprice AS total_pedido
-- Indicamos la tabla transaccional base del análisis.
FROM samples.tpch.orders AS o
-- Filtramos pedidos que quedan por encima del promedio histórico del mismo cliente.
WHERE o.o_totalprice > (
  -- Calculamos el promedio de valor de pedido para el cliente de la fila externa.
  SELECT AVG(o2.o_totalprice)
  -- Leemos la tabla orders como conjunto de comparación.
  FROM samples.tpch.orders AS o2
  -- Correlacionamos por cliente para que cada fila se compare contra su propio grupo.
  WHERE o2.o_custkey = o.o_custkey
)
-- Ordenamos por cliente y luego por total descendente para facilitar la inspección.
ORDER BY o.o_custkey, o.o_totalprice DESC
-- Limitamos la muestra para mantener la lectura manejable.
LIMIT 20;

-- COMMAND ----------

-- Ejemplo 3 de 5.
-- ¿Por qué esta consulta está escrita así?: porque la pregunta final necesita trabajar sobre una tabla resumida por cliente, y esa tabla intermedia se construye en la cláusula FROM.
-- Qué hace cada cláusula:
-- - La subconsulta en FROM genera una tabla derivada con una fila por cliente.
-- - El SELECT externo resume esa tabla derivada por segmento.
-- - GROUP BY en el nivel externo produce una fila por segmento.
-- Resultado esperado: ingreso promedio por cliente y pedidos promedio por cliente dentro de cada segmento.
-- Error común: intentar calcular el promedio por segmento directamente desde orders sin construir primero el grano correcto por cliente.
SELECT
  -- Mostramos el segmento como dimensión final del análisis.
  base.segmento,
  -- Calculamos el ingreso promedio por cliente dentro de cada segmento.
  AVG(base.ingreso_cliente) AS ingreso_promedio_por_cliente,
  -- Calculamos cuántos pedidos tiene en promedio un cliente del segmento.
  AVG(base.pedidos_cliente) AS pedidos_promedio_por_cliente
-- Consumimos una tabla derivada creada inline en la cláusula FROM.
FROM (
  -- La tabla derivada produce una fila por cliente y segmento.
  SELECT
    -- Tomamos el segmento del cliente como atributo de agrupación analítica.
    c.c_mktsegment AS segmento,
    -- Conservamos la llave del cliente para mantener el grano una fila por cliente.
    o.o_custkey AS cliente_id,
    -- Sumamos el valor de los pedidos para calcular el ingreso total del cliente.
    SUM(o.o_totalprice) AS ingreso_cliente,
    -- Contamos cuántos pedidos realizó cada cliente.
    COUNT(*) AS pedidos_cliente
  -- Leemos la tabla de clientes porque aporta el segmento.
  FROM samples.tpch.customer AS c
  -- Unimos orders para llevar el valor monetario del comportamiento de compra.
  INNER JOIN samples.tpch.orders AS o
    -- Relacionamos pedido con cliente mediante su llave natural en el modelo TPC-H.
    ON c.c_custkey = o.o_custkey
  -- Agrupamos por segmento y cliente para construir el grano correcto de la tabla derivada.
  GROUP BY c.c_mktsegment, o.o_custkey
) AS base
-- Agrupamos por segmento para resumir la tabla derivada en la salida final.
GROUP BY base.segmento
-- Ordenamos de mayor a menor ingreso promedio por cliente.
ORDER BY ingreso_promedio_por_cliente DESC;

-- COMMAND ----------

-- Ejemplo 4 de 5.
-- ¿Por qué esta consulta está escrita así?: porque queremos mostrar, junto al ingreso de cada región, una referencia global constante dentro del mismo resultado.
-- Qué hace cada cláusula:
-- - SELECT calcula el ingreso regional y añade subconsultas escalares para el total global.
-- - FROM y JOIN conectan pedidos con cliente, nación y región.
-- - GROUP BY produce una fila por región.
-- Resultado esperado: una tabla donde cada región puede compararse contra el ingreso total del portafolio.
-- Error común: olvidar que la subconsulta escalar debe devolver un solo valor; por eso usamos SUM sin GROUP BY.
SELECT
  -- Mostramos el nombre de la región como dimensión principal del reporte.
  r.r_name AS region,
  -- Sumamos el valor de los pedidos pertenecientes a la región del cliente.
  SUM(o.o_totalprice) AS ingreso_region,
  -- Incorporamos el ingreso global como subconsulta escalar para usarlo como referencia constante.
  (
    -- La subconsulta suma el valor de todos los pedidos de la base completa.
    SELECT SUM(o2.o_totalprice)
    -- Leemos la tabla orders como fuente del total global.
    FROM samples.tpch.orders AS o2
  ) AS ingreso_global,
  -- Calculamos el porcentaje que representa cada región sobre el total global.
  ROUND(
    SUM(o.o_totalprice)
    /
    (
      -- Repetimos la subconsulta escalar porque Databricks evalúa expresiones dentro del SELECT final.
      SELECT SUM(o3.o_totalprice)
      -- Tomamos nuevamente la tabla orders para la referencia global.
      FROM samples.tpch.orders AS o3
    )
    * 100,
    2
  ) AS porcentaje_sobre_global
-- Iniciamos desde orders porque el valor monetario está en esta tabla.
FROM samples.tpch.orders AS o
-- Unimos customer para saber a qué cliente pertenece cada pedido.
INNER JOIN samples.tpch.customer AS c
  -- Relacionamos pedido y cliente mediante la llave del cliente.
  ON o.o_custkey = c.c_custkey
-- Unimos nation para convertir al cliente en una geografía de país.
INNER JOIN samples.tpch.nation AS n
  -- Relacionamos la nación del cliente con la dimensión nation.
  ON c.c_nationkey = n.n_nationkey
-- Unimos region para llevar el análisis al nivel regional.
INNER JOIN samples.tpch.region AS r
  -- Relacionamos la nación con su región correspondiente.
  ON n.n_regionkey = r.r_regionkey
-- Agrupamos por región para obtener una fila por zona geográfica.
GROUP BY r.r_name
-- Ordenamos las regiones por ingreso descendente.
ORDER BY ingreso_region DESC;

-- COMMAND ----------

-- Ejemplo 5 de 5.
-- ¿Por qué esta consulta está escrita así?: porque el negocio a veces solo necesita saber si existe o no una relación, y `EXISTS`/`NOT EXISTS` expresan esa intención mejor que un JOIN.
-- Qué hace cada cláusula:
-- - SELECT muestra la identidad del cliente y una clasificación basada en existencia.
-- - CASE traduce la lógica booleana a etiquetas de negocio.
-- - Las subconsultas de EXISTS y NOT EXISTS verifican si el cliente tiene pedidos.
-- Resultado esperado: clientes clasificados como "Con historial de pedidos" o "Sin historial de pedidos".
-- Error común: usar JOIN para esta tarea y luego obtener duplicados porque un cliente puede tener muchos pedidos.
SELECT
  -- Mostramos la llave del cliente para identificar la entidad analizada.
  c.c_custkey AS cliente_id,
  -- Mostramos el nombre del cliente para lectura funcional del resultado.
  c.c_name AS nombre_cliente,
  -- Conservamos el segmento como atributo adicional para enriquecer la interpretación.
  c.c_mktsegment AS segmento,
  -- Clasificamos al cliente según exista o no al menos un pedido asociado.
  CASE
    -- La primera rama se activa cuando existe por lo menos un pedido para el cliente actual.
    WHEN EXISTS (
      -- La subconsulta busca cualquier fila relacionada en orders.
      SELECT 1
      -- Leemos la tabla de pedidos como tabla de verificación.
      FROM samples.tpch.orders AS o
      -- Correlacionamos la llave del cliente para verificar la relación correcta.
      WHERE o.o_custkey = c.c_custkey
    ) THEN 'Con historial de pedidos'
    -- La segunda rama documenta explícitamente el caso de no existencia.
    WHEN NOT EXISTS (
      -- La subconsulta vuelve a revisar la tabla orders, ahora buscando ausencia total.
      SELECT 1
      -- Leemos la misma tabla de pedidos porque la pregunta de existencia sigue siendo la misma.
      FROM samples.tpch.orders AS o2
      -- Correlacionamos otra vez con el cliente externo para preservar la lógica por fila.
      WHERE o2.o_custkey = c.c_custkey
    ) THEN 'Sin historial de pedidos'
  END AS estado_relacion_pedidos
-- Leemos la dimensión customer porque cada fila del resultado representa un cliente.
FROM samples.tpch.customer AS c
-- Ordenamos por cliente para obtener una muestra estable y fácil de revisar.
ORDER BY c.c_custkey
-- Limitamos a veinte filas para aprendizaje visual rápido.
LIMIT 20;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado
-- MAGIC 
-- MAGIC En esta sección ya no explicamos cada línea en un texto aparte, pero las consultas siguen comentadas y orientadas a la toma de decisiones.
-- MAGIC 
-- MAGIC | Ejemplo guiado | Enfoque | Nivel |
-- MAGIC |---|---|---|
-- MAGIC | 1 de 5 | `IN` con subconsulta | Muy Fácil |
-- MAGIC | 2 de 5 | `ANY` | Fácil |
-- MAGIC | 3 de 5 | `ALL` | Intermedio |
-- MAGIC | 4 de 5 | CTE nombrada | Intermedio |
-- MAGIC | 5 de 5 | múltiples CTE encadenadas | Intermedio Alto |

-- COMMAND ----------

-- Ejemplo guiado 1 de 5.
-- Objetivo: mostrar cómo `IN` expresa pertenencia a un conjunto de clientes con pedidos de alto valor.
-- Por qué esta consulta es útil: la subconsulta devuelve una lista de llaves; la consulta externa solo valida membresía.
-- Resultado esperado: clientes que tienen al menos un pedido superior a 300000.
-- Error común: reemplazar esto por un JOIN y olvidar DISTINCT, generando repetición de clientes.
SELECT
  -- Proyectamos la llave del cliente para identificar la entidad del filtro.
  c.c_custkey AS cliente_id,
  -- Mostramos el nombre del cliente para lectura de negocio.
  c.c_name AS nombre_cliente,
  -- Conservamos el segmento para ver qué perfiles aparecen en pedidos altos.
  c.c_mktsegment AS segmento
-- Leemos la dimensión customer como tabla principal del resultado.
FROM samples.tpch.customer AS c
-- Filtramos los clientes cuya llave aparece en la lista producida por la subconsulta.
WHERE c.c_custkey IN (
  -- La subconsulta devuelve clientes con al menos un pedido de alto valor.
  SELECT DISTINCT o.o_custkey
  -- Leemos orders porque allí se encuentra el valor monetario del pedido.
  FROM samples.tpch.orders AS o
  -- Conservamos solo pedidos por encima del umbral definido para el ejemplo.
  WHERE o.o_totalprice > 300000
)
-- Ordenamos por cliente para obtener una salida estable.
ORDER BY c.c_custkey
-- Limitamos la vista para revisión rápida.
LIMIT 20;

-- COMMAND ----------

-- Ejemplo guiado 2 de 5.
-- Objetivo: comparar el precio de una parte contra un conjunto usando `> ANY`.
-- Por qué esta consulta es útil: `ANY` ayuda cuando la pregunta es "¿es mayor que al menos uno de los valores del grupo de referencia?".
-- Resultado esperado: partes cuyo precio es superior al menos a una parte de tamaño 5.
-- Error común: pensar que `> ANY` significa mayor que todas; en realidad basta superar un elemento del conjunto.
SELECT
  -- Mostramos la llave de la parte para identificar el producto.
  p.p_partkey AS parte_id,
  -- Mostramos el nombre de la parte para interpretar la salida.
  p.p_name AS nombre_parte,
  -- Conservamos el tamaño porque el grupo de referencia se define parcialmente por esta variable.
  p.p_size AS tamano,
  -- Mostramos el precio minorista, que es la variable comparada.
  p.p_retailprice AS precio_retail
-- Tomamos part como tabla fuente de los productos a evaluar.
FROM samples.tpch.part AS p
-- Filtramos las partes cuyo precio supera al menos uno de los precios del conjunto interno.
WHERE p.p_retailprice > ANY (
  -- La subconsulta devuelve el conjunto de precios de partes con tamaño 5.
  SELECT p2.p_retailprice
  -- Leemos la misma tabla part como grupo de referencia.
  FROM samples.tpch.part AS p2
  -- Definimos el subconjunto contra el cual se hará la comparación.
  WHERE p2.p_size = 5
)
-- Ordenamos de mayor a menor para inspeccionar primero los precios más altos.
ORDER BY p.p_retailprice DESC
-- Limitamos el resultado por motivos pedagógicos.
LIMIT 15;

-- COMMAND ----------

-- Ejemplo guiado 3 de 5.
-- Objetivo: usar `> ALL` para identificar partes que superan por precio a todas las partes de un grupo de referencia.
-- Por qué esta consulta es útil: `ALL` equivale a una condición fuerte sobre un conjunto completo.
-- Resultado esperado: partes más caras que cualquier parte de tamaño 49.
-- Error común: usar `> ALL` cuando el subconjunto puede ser vacío sin pensar en la semántica del resultado.
SELECT
  -- Seleccionamos la llave de la parte para rastrear el producto.
  p.p_partkey AS parte_id,
  -- Seleccionamos el nombre del producto para hacer legible la salida.
  p.p_name AS nombre_parte,
  -- Conservamos el tamaño de la parte como contexto descriptivo.
  p.p_size AS tamano,
  -- Mostramos el precio que debe superar a todos los valores del conjunto interno.
  p.p_retailprice AS precio_retail
-- Leemos la dimensión de partes.
FROM samples.tpch.part AS p
-- Filtramos solo productos cuyo precio es mayor que todos los precios del grupo de referencia.
WHERE p.p_retailprice > ALL (
  -- La subconsulta devuelve los precios de las partes de tamaño 49.
  SELECT p2.p_retailprice
  -- Leemos nuevamente part como conjunto de comparación.
  FROM samples.tpch.part AS p2
  -- Definimos el subconjunto de referencia por tamaño.
  WHERE p2.p_size = 49
)
-- Ordenamos por precio descendente para priorizar los valores más altos.
ORDER BY p.p_retailprice DESC
-- Acotamos la salida del ejemplo.
LIMIT 15;

-- COMMAND ----------

-- Ejemplo guiado 4 de 5.
-- Objetivo: mostrar cómo una CTE nombrada mejora la claridad cuando resumimos ingresos por cliente.
-- Por qué esta consulta es útil: la CTE separa el cálculo del ingreso del cliente de la presentación final con atributos de customer.
-- Resultado esperado: clientes con mayor ingreso total acumulado y su cantidad de pedidos.
-- Error común: anidar el resumen dentro del FROM sin darle nombre, haciendo más difícil mantener la consulta.
WITH ingresos_cliente AS (
  -- Calculamos una fila por cliente con sus métricas principales de pedidos.
  SELECT
    -- Conservamos la llave del cliente porque será la llave de unión posterior.
    o.o_custkey AS cliente_id,
    -- Sumamos el valor de todos los pedidos del cliente para construir el ingreso acumulado.
    SUM(o.o_totalprice) AS ingreso_total,
    -- Contamos cuántos pedidos realizó el cliente.
    COUNT(*) AS total_pedidos
  -- Leemos orders porque contiene las transacciones monetarias.
  FROM samples.tpch.orders AS o
  -- Agrupamos por cliente para obtener una fila por cada uno.
  GROUP BY o.o_custkey
)
SELECT
  -- Mostramos la llave del cliente ya enriquecida por la CTE.
  c.c_custkey AS cliente_id,
  -- Mostramos el nombre para interpretación de negocio.
  c.c_name AS nombre_cliente,
  -- Conservamos el segmento comercial del cliente.
  c.c_mktsegment AS segmento,
  -- Traemos el ingreso total calculado en la CTE.
  ic.ingreso_total,
  -- Traemos la cantidad de pedidos calculada en la CTE.
  ic.total_pedidos
-- La consulta final parte de la CTE para reutilizar el resumen ya calculado.
FROM ingresos_cliente AS ic
-- Unimos customer para agregar atributos descriptivos del cliente.
INNER JOIN samples.tpch.customer AS c
  -- Relacionamos la llave de cliente de la CTE con la dimensión customer.
  ON ic.cliente_id = c.c_custkey
-- Ordenamos de mayor a menor ingreso para priorizar clientes clave.
ORDER BY ic.ingreso_total DESC
-- Limitamos el resultado a los quince clientes de mayor ingreso.
LIMIT 15;

-- COMMAND ----------

-- Ejemplo guiado 5 de 5.
-- Objetivo: encadenar varias CTE para llegar desde pedidos base hasta un ranking por región y segmento.
-- Por qué esta consulta es útil: cada CTE representa una etapa lógica distinta y eso hace visible el razonamiento analítico.
-- Resultado esperado: top 3 clientes por ingreso dentro de cada combinación región-segmento.
-- Error común: intentar resolver todo en un solo SELECT muy largo, perdiendo control del grano y de la legibilidad.
WITH base_pedidos AS (
  -- Construimos una base analítica con una fila por pedido y atributos del cliente y geografía.
  SELECT
    -- Conservamos la región porque será una dimensión final del ranking.
    r.r_name AS region,
    -- Conservamos el segmento del cliente como segunda dimensión del ranking.
    c.c_mktsegment AS segmento,
    -- Conservamos la llave del cliente para acumular ingresos por persona jurídica.
    o.o_custkey AS cliente_id,
    -- Conservamos el valor del pedido como métrica base.
    o.o_totalprice AS total_pedido
  -- Leemos orders como tabla de hechos.
  FROM samples.tpch.orders AS o
  -- Unimos customer para acceder a segmento y nación del cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Unimos nation para recorrer la jerarquía geográfica.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Unimos region para llegar al nivel regional requerido por negocio.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
),
ingreso_cliente AS (
  -- Resumimos la base anterior a una fila por región, segmento y cliente.
  SELECT
    -- Mantenemos la región como clave del siguiente nivel analítico.
    region,
    -- Mantenemos el segmento como clave de agrupación.
    segmento,
    -- Mantenemos el cliente para calcular su posición relativa.
    cliente_id,
    -- Sumamos los pedidos para obtener el ingreso total por cliente.
    SUM(total_pedido) AS ingreso_cliente
  -- Leemos la CTE base_pedidos como fuente ya enriquecida.
  FROM base_pedidos
  -- Agrupamos por región, segmento y cliente para construir el ranking posterior.
  GROUP BY region, segmento, cliente_id
),
ranking_cliente AS (
  -- Calculamos el ranking de cada cliente dentro de su región y segmento.
  SELECT
    -- Conservamos la región para la salida final.
    region,
    -- Conservamos el segmento para la salida final.
    segmento,
    -- Conservamos el cliente que será rankeado.
    cliente_id,
    -- Conservamos el ingreso ya agregado.
    ingreso_cliente,
    -- Asignamos una posición usando una función de ventana por región y segmento.
    DENSE_RANK() OVER (
      PARTITION BY region, segmento
      ORDER BY ingreso_cliente DESC
    ) AS ranking_en_grupo
  -- Leemos la CTE ingreso_cliente, que ya tiene el grano correcto.
  FROM ingreso_cliente
)
SELECT
  -- Mostramos la región del grupo analítico.
  rc.region,
  -- Mostramos el segmento del grupo analítico.
  rc.segmento,
  -- Mostramos la llave del cliente ranqueado.
  rc.cliente_id,
  -- Mostramos el ingreso acumulado del cliente.
  rc.ingreso_cliente,
  -- Mostramos la posición relativa dentro del grupo.
  rc.ranking_en_grupo
-- Consumimos la CTE final que contiene el ranking ya calculado.
FROM ranking_cliente AS rc
-- Filtramos solo las tres primeras posiciones de cada grupo.
WHERE rc.ranking_en_grupo <= 3
-- Ordenamos para que la lectura sea natural por región, segmento y posición.
ORDER BY rc.region, rc.segmento, rc.ranking_en_grupo, rc.ingreso_cliente DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado
-- MAGIC 
-- MAGIC Ahora pasamos a ejercicios con solución de referencia. La progresión sigue la escala **Muy Fácil → Fácil → Intermedio → Intermedio Alto → Desafío**.
-- MAGIC 
-- MAGIC | Ejercicio guiado | Nivel | Habilidad principal |
-- MAGIC |---|---|---|
-- MAGIC | 1 de 5 | Muy Fácil | tabla derivada en `FROM` |
-- MAGIC | 2 de 5 | Fácil | subconsulta escalar sobre CTE |
-- MAGIC | 3 de 5 | Intermedio | subconsulta correlacionada |
-- MAGIC | 4 de 5 | Intermedio Alto | `NOT EXISTS` |
-- MAGIC | 5 de 5 | Desafío | múltiples CTE y porcentajes |

-- COMMAND ----------

-- Ejercicio guiado 1 de 5 - Muy Fácil.
-- Enunciado: calcular el promedio de líneas y el promedio de cantidad por pedido usando una subconsulta en FROM.
-- Por qué la solución está escrita así: primero resumimos a nivel pedido; luego promediamos sobre esa tabla resumida.
-- Resultado esperado: una sola fila con dos métricas promedio por pedido.
-- Error común: promediar directamente sobre lineitem sin distinguir entre línea y pedido.
SELECT
  -- Calculamos el promedio de líneas por pedido a partir de la tabla derivada.
  AVG(resumen_pedido.total_lineas) AS promedio_lineas_por_pedido,
  -- Calculamos el promedio de cantidad total por pedido desde la misma tabla derivada.
  AVG(resumen_pedido.cantidad_total) AS promedio_cantidad_por_pedido
-- Leemos una tabla derivada que ya contiene una fila por pedido.
FROM (
  -- Construimos el resumen por pedido a partir del detalle lineitem.
  SELECT
    -- Conservamos la llave del pedido para fijar el grano del resumen.
    l.l_orderkey AS pedido_id,
    -- Contamos cuántas líneas tiene cada pedido.
    COUNT(*) AS total_lineas,
    -- Sumamos la cantidad pedida en todas las líneas del pedido.
    SUM(l.l_quantity) AS cantidad_total
  -- Leemos la tabla lineitem, que contiene el detalle transaccional.
  FROM samples.tpch.lineitem AS l
  -- Agrupamos por pedido para obtener exactamente una fila por orden.
  GROUP BY l.l_orderkey
) AS resumen_pedido;

-- COMMAND ----------

-- Ejercicio guiado 2 de 5 - Fácil.
-- Enunciado: comparar el gasto total de cada cliente contra el gasto promedio de la cartera de clientes compradores.
-- Por qué la solución está escrita así: usamos una CTE para calcular el gasto por cliente y luego una subconsulta escalar para obtener el promedio del portafolio sobre ese mismo conjunto.
-- Resultado esperado: clientes con su gasto total, el promedio de referencia y la diferencia frente a ese promedio.
-- Error común: comparar contra el promedio de pedidos en vez del promedio de gasto por cliente.
WITH gasto_cliente AS (
  -- Calculamos una fila por cliente con el gasto total acumulado en pedidos.
  SELECT
    -- Conservamos la llave del cliente como identificador analítico.
    o.o_custkey AS cliente_id,
    -- Sumamos el valor total de sus pedidos para medir el gasto acumulado.
    SUM(o.o_totalprice) AS gasto_total
  -- Leemos la tabla orders como fuente de ingresos por cliente.
  FROM samples.tpch.orders AS o
  -- Agrupamos por cliente para obtener una fila por comprador.
  GROUP BY o.o_custkey
)
SELECT
  -- Mostramos la llave del cliente para identificación.
  gc.cliente_id,
  -- Mostramos el nombre del cliente desde la dimensión customer.
  c.c_name AS nombre_cliente,
  -- Mostramos el gasto total calculado en la CTE.
  gc.gasto_total,
  -- Insertamos como referencia el promedio del gasto total entre clientes compradores.
  (
    -- La subconsulta promedia el gasto total de la propia CTE.
    SELECT AVG(gc2.gasto_total)
    -- Leemos la CTE gasto_cliente como universo de referencia.
    FROM gasto_cliente AS gc2
  ) AS gasto_promedio_portafolio,
  -- Calculamos la diferencia absoluta entre el cliente y el promedio del portafolio.
  gc.gasto_total - (
    -- Repetimos la subconsulta para construir la métrica comparativa en la misma salida.
    SELECT AVG(gc3.gasto_total)
    -- Leemos otra vez la CTE para mantener el mismo universo de cálculo.
    FROM gasto_cliente AS gc3
  ) AS diferencia_vs_promedio
-- Partimos de la CTE gasto_cliente, que contiene el grano correcto por cliente.
FROM gasto_cliente AS gc
-- Unimos customer para enriquecer la salida con el nombre descriptivo.
INNER JOIN samples.tpch.customer AS c
  ON gc.cliente_id = c.c_custkey
-- Ordenamos de mayor a menor gasto para observar primero los clientes de mayor valor.
ORDER BY gc.gasto_total DESC
-- Limitamos la salida para facilitar la revisión.
LIMIT 20;

-- COMMAND ----------

-- Ejercicio guiado 3 de 5 - Intermedio.
-- Enunciado: identificar pedidos de 1995 cuyo valor está por encima del promedio histórico de su propio cliente.
-- Por qué la solución está escrita así: combinamos un filtro temporal externo con una comparación correlacionada al historial completo del cliente.
-- Resultado esperado: pedidos de 1995 que representan desempeño superior al hábito de compra del mismo cliente.
-- Error común: filtrar también la subconsulta a 1995 y terminar comparando contra un promedio parcial, no histórico.
SELECT
  -- Seleccionamos la llave del pedido para identificar la transacción evaluada.
  o.o_orderkey AS pedido_id,
  -- Seleccionamos la llave del cliente para contextualizar el resultado.
  o.o_custkey AS cliente_id,
  -- Mostramos la fecha del pedido para confirmar que pertenece a 1995.
  o.o_orderdate AS fecha_pedido,
  -- Mostramos el valor total comparado contra el promedio histórico del cliente.
  o.o_totalprice AS total_pedido
-- Leemos la tabla de pedidos.
FROM samples.tpch.orders AS o
-- Filtramos solo pedidos cuyo año es 1995.
WHERE YEAR(o.o_orderdate) = 1995
  -- Añadimos la condición correlacionada para comparar con el promedio histórico del mismo cliente.
  AND o.o_totalprice > (
    -- Calculamos el promedio histórico de valor de pedido para el cliente actual.
    SELECT AVG(o2.o_totalprice)
    -- Leemos la tabla orders como historial del cliente.
    FROM samples.tpch.orders AS o2
    -- Correlacionamos por cliente para mantener una comparación personalizada.
    WHERE o2.o_custkey = o.o_custkey
  )
-- Ordenamos por valor descendente para revisar primero los casos más notorios.
ORDER BY o.o_totalprice DESC
-- Limitamos la salida para lectura rápida.
LIMIT 20;

-- COMMAND ----------

-- Ejercicio guiado 4 de 5 - Intermedio Alto.
-- Enunciado: listar proveedores que no participaron en líneas con descuento alto, definido aquí como descuento mayor o igual a 0.09.
-- Por qué la solución está escrita así: `NOT EXISTS` evita duplicados y expresa de forma directa la ausencia de relación bajo una condición específica.
-- Resultado esperado: proveedores sin evidencia de participación en líneas de descuento alto.
-- Error común: usar `NOT IN` sobre una subconsulta con posibles nulos y obtener resultados inesperados.
SELECT
  -- Mostramos la llave del proveedor como identificador principal.
  s.s_suppkey AS proveedor_id,
  -- Mostramos el nombre del proveedor para interpretación funcional.
  s.s_name AS nombre_proveedor,
  -- Mostramos la nación del proveedor para enriquecer la lectura geográfica.
  n.n_name AS pais_proveedor
-- Leemos la dimensión de proveedores.
FROM samples.tpch.supplier AS s
-- Unimos nation para agregar la geografía del proveedor.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- Filtramos solo proveedores para los cuales no existe ninguna línea con descuento alto.
WHERE NOT EXISTS (
  -- La subconsulta busca líneas asociadas al proveedor actual que cumplan la condición de descuento.
  SELECT 1
  -- Leemos el detalle lineitem porque allí vive el descuento aplicado.
  FROM samples.tpch.lineitem AS l
  -- Correlacionamos por proveedor para evaluar la condición sobre cada supplier.
  WHERE l.l_suppkey = s.s_suppkey
    -- Definimos explícitamente qué entendemos por descuento alto en este ejercicio.
    AND l.l_discount >= 0.09
)
-- Ordenamos para obtener una salida estable y fácil de auditar.
ORDER BY s.s_suppkey
-- Limitamos a veinte filas para revisión pedagógica.
LIMIT 20;

-- COMMAND ----------

-- Ejercicio guiado 5 de 5 - Desafío.
-- Enunciado: calcular, por región, cuántos clientes están por encima del ingreso promedio por cliente y qué porcentaje representan dentro de la región.
-- Por qué la solución está escrita así: la lógica necesita varios pasos legibles y por eso se encadena en CTE.
-- Resultado esperado: una fila por región con clientes de alto ingreso, total de clientes compradores y porcentaje de concentración.
-- Error común: comparar clientes contra un promedio regional cuando el enunciado pide un promedio global por cliente.
WITH ingreso_cliente AS (
  -- Calculamos el ingreso total por cliente para construir la unidad de comparación.
  SELECT
    -- Conservamos la llave del cliente como nivel de detalle principal.
    o.o_custkey AS cliente_id,
    -- Sumamos el valor de los pedidos para medir el ingreso acumulado del cliente.
    SUM(o.o_totalprice) AS ingreso_total
  -- Leemos orders como tabla base del comportamiento de compra.
  FROM samples.tpch.orders AS o
  -- Agrupamos por cliente para obtener una fila por comprador.
  GROUP BY o.o_custkey
),
clientes_alto_ingreso AS (
  -- Filtramos solo clientes cuyo ingreso total supera el promedio global de ingreso por cliente.
  SELECT
    -- Conservamos la llave del cliente porque será necesaria en el siguiente cruce geográfico.
    ic.cliente_id,
    -- Conservamos el ingreso total para posibles auditorías posteriores.
    ic.ingreso_total
  -- Leemos la CTE ingreso_cliente como universo de comparación.
  FROM ingreso_cliente AS ic
  -- Aplicamos la comparación contra una subconsulta escalar global.
  WHERE ic.ingreso_total > (
    -- La subconsulta promedia el ingreso total entre clientes compradores.
    SELECT AVG(ic2.ingreso_total)
    -- Leemos otra vez la CTE ingreso_cliente para mantener el mismo universo.
    FROM ingreso_cliente AS ic2
  )
),
clientes_region AS (
  -- Asociamos cada cliente comprador a su región para medir concentración regional.
  SELECT
    -- Llevamos la región como dimensión final del reporte.
    r.r_name AS region,
    -- Conservamos la llave del cliente para contar compradores por región.
    c.c_custkey AS cliente_id
  -- Leemos la dimensión customer para ubicar al cliente en una geografía.
  FROM samples.tpch.customer AS c
  -- Unimos nation para recorrer la geografía.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Unimos region para obtener el nivel final del laboratorio.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Filtramos solo clientes que efectivamente aparecen en orders para no mezclar no compradores.
  WHERE c.c_custkey IN (
    -- La subconsulta devuelve todas las llaves de clientes con al menos un pedido.
    SELECT DISTINCT o.o_custkey
    -- Leemos orders porque allí se define la condición de comprador.
    FROM samples.tpch.orders AS o
  )
)
SELECT
  -- Mostramos la región analizada.
  cr.region,
  -- Contamos cuántos clientes de alto ingreso pertenecen a la región.
  COUNT(cai.cliente_id) AS clientes_alto_ingreso,
  -- Contamos el total de clientes compradores de la región.
  COUNT(cr.cliente_id) AS clientes_compradores_region,
  -- Calculamos el porcentaje de clientes de alto ingreso dentro del total regional.
  ROUND(
    COUNT(cai.cliente_id) / NULLIF(COUNT(cr.cliente_id), 0) * 100,
    2
  ) AS porcentaje_clientes_alto_ingreso
-- Partimos de la CTE que representa el universo de compradores por región.
FROM clientes_region AS cr
-- Unimos la lista de clientes de alto ingreso para medir cuántos caen en cada región.
LEFT JOIN clientes_alto_ingreso AS cai
  ON cr.cliente_id = cai.cliente_id
-- Agrupamos por región para construir una fila por cada una.
GROUP BY cr.region
-- Ordenamos por porcentaje descendente para priorizar regiones más concentradas.
ORDER BY porcentaje_clientes_alto_ingreso DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Ejercicio individual
-- MAGIC 
-- MAGIC Recomendación didáctica: intenta resolver cada problema antes de ejecutar la solución de referencia. Aquí la solución está incluida para que puedas comparar tu razonamiento.
-- MAGIC 
-- MAGIC | Ejercicio individual | Nivel | Tema dominante |
-- MAGIC |---|---|---|
-- MAGIC | 1 de 5 | Muy Fácil | `IN` y pertenencia |
-- MAGIC | 2 de 5 | Fácil | CTE temporal por mes |
-- MAGIC | 3 de 5 | Intermedio | `EXISTS` vs duplicados |
-- MAGIC | 4 de 5 | Intermedio Alto | `ANY` y `ALL` |
-- MAGIC | 5 de 5 | Desafío | top 3 países por ingreso y participación |

-- COMMAND ----------

-- Ejercicio individual 1 de 5 - Muy Fácil.
-- Enunciado: identificar naciones que tienen al menos un cliente perteneciente al segmento BUILDING y con pedidos registrados.
-- Por qué la solución está escrita así: `IN` permite filtrar naciones a partir de la membresía de sus clientes en un conjunto que cumple dos condiciones.
-- Resultado esperado: países con actividad del segmento BUILDING en pedidos.
-- Error común: unir nation, customer y orders sin DISTINCT y luego interpretar la lista como si fueran países únicos.
SELECT
  -- Mostramos la llave de la nación para identificación técnica.
  n.n_nationkey AS pais_id,
  -- Mostramos el nombre de la nación para lectura de negocio.
  n.n_name AS pais
-- Leemos la dimensión de naciones.
FROM samples.tpch.nation AS n
-- Filtramos las naciones cuya llave aparece en el conjunto de clientes BUILDING con pedidos.
WHERE n.n_nationkey IN (
  -- La subconsulta devuelve las llaves de nación asociadas a clientes BUILDING que además tienen pedidos.
  SELECT DISTINCT c.c_nationkey
  -- Leemos customer porque contiene segmento y nación del cliente.
  FROM samples.tpch.customer AS c
  -- Filtramos al segmento BUILDING como condición de negocio.
  WHERE c.c_mktsegment = 'BUILDING'
    -- Añadimos una condición de pertenencia para asegurar que el cliente sí tiene pedidos.
    AND c.c_custkey IN (
      -- La subconsulta interna devuelve los clientes con al menos un pedido.
      SELECT DISTINCT o.o_custkey
      -- Leemos orders porque allí se materializa la relación comercial efectiva.
      FROM samples.tpch.orders AS o
    )
)
-- Ordenamos alfabéticamente para lectura estable.
ORDER BY n.n_name;

-- COMMAND ----------

-- Ejercicio individual 2 de 5 - Fácil.
-- Enunciado: construir una CTE mensual con número de pedidos e ingreso total por año y mes.
-- Por qué la solución está escrita así: una CTE con nombre hace fácil reutilizar el resumen temporal en consultas posteriores.
-- Resultado esperado: una fila por año y mes con volumen y valor económico.
-- Error común: seleccionar la fecha completa y terminar con una fila por día o por pedido.
WITH pedidos_mensuales AS (
  -- Resumimos la tabla orders a nivel año-mes.
  SELECT
    -- Extraemos el año del pedido para la primera dimensión temporal.
    YEAR(o.o_orderdate) AS anio,
    -- Extraemos el mes del pedido para la segunda dimensión temporal.
    MONTH(o.o_orderdate) AS mes,
    -- Contamos cuántos pedidos ocurrieron en el periodo.
    COUNT(*) AS total_pedidos,
    -- Sumamos el valor económico de todos los pedidos del periodo.
    SUM(o.o_totalprice) AS ingreso_total
  -- Leemos la tabla de pedidos como fuente temporal y monetaria.
  FROM samples.tpch.orders AS o
  -- Agrupamos por año y mes para consolidar el resumen temporal.
  GROUP BY YEAR(o.o_orderdate), MONTH(o.o_orderdate)
)
SELECT
  -- Mostramos el año del periodo analizado.
  pm.anio,
  -- Mostramos el mes del periodo analizado.
  pm.mes,
  -- Mostramos el número de pedidos del periodo.
  pm.total_pedidos,
  -- Mostramos el ingreso total del periodo.
  pm.ingreso_total
-- Consumimos la CTE temporal ya resumida.
FROM pedidos_mensuales AS pm
-- Ordenamos cronológicamente para lectura natural.
ORDER BY pm.anio, pm.mes;

-- COMMAND ----------

-- Ejercicio individual 3 de 5 - Intermedio.
-- Enunciado: contar cuántos clientes tienen al menos un pedido superior a 250000 sin duplicar clientes.
-- Por qué la solución está escrita así: `EXISTS` responde exactamente la pregunta de existencia y evita que múltiples pedidos del mismo cliente inflen el conteo.
-- Resultado esperado: una sola fila con el número de clientes que cumplen la condición.
-- Error común: usar JOIN y COUNT(*) sobre orders, obteniendo el número de pedidos en vez del número de clientes.
SELECT
  -- Contamos clientes, no pedidos, porque cada fila externa representa un cliente.
  COUNT(*) AS clientes_con_pedido_mayor_250k
-- Leemos la dimensión customer como universo de clientes a evaluar.
FROM samples.tpch.customer AS c
-- Conservamos solo clientes para los que existe al menos un pedido sobre el umbral definido.
WHERE EXISTS (
  -- La subconsulta busca pedidos del cliente actual por encima del umbral.
  SELECT 1
  -- Leemos orders porque contiene el valor monetario requerido.
  FROM samples.tpch.orders AS o
  -- Correlacionamos por cliente para verificar la condición por cada fila externa.
  WHERE o.o_custkey = c.c_custkey
    -- Aplicamos el umbral monetario del enunciado.
    AND o.o_totalprice > 250000
);

-- COMMAND ----------

-- Ejercicio individual 4 de 5 - Intermedio Alto.
-- Enunciado: listar partes cuyo precio es mayor que cualquier precio de las partes tamaño 10 y, a la vez, menor que todos los precios de las partes tamaño 40.
-- Por qué la solución está escrita así: permite practicar `ANY` y `ALL` en una misma consulta para acotar un rango lógico por conjuntos.
-- Resultado esperado: partes ubicadas entre ambos conjuntos de referencia según precio.
-- Error común: confundir el sentido lógico de ANY y ALL y terminar creando un filtro imposible o demasiado amplio.
SELECT
  -- Mostramos la llave de la parte para identificación.
  p.p_partkey AS parte_id,
  -- Mostramos el nombre para interpretación funcional.
  p.p_name AS nombre_parte,
  -- Mostramos el tamaño para contexto descriptivo.
  p.p_size AS tamano,
  -- Mostramos el precio que será comparado con ambos conjuntos.
  p.p_retailprice AS precio_retail
-- Leemos la dimensión part como universo a filtrar.
FROM samples.tpch.part AS p
-- Exigimos que el precio sea mayor que al menos un elemento del conjunto tamaño 10.
WHERE p.p_retailprice > ANY (
  -- La subconsulta devuelve los precios del grupo de tamaño 10.
  SELECT p10.p_retailprice
  -- Leemos part como primer conjunto de referencia.
  FROM samples.tpch.part AS p10
  -- Definimos el conjunto de referencia por tamaño.
  WHERE p10.p_size = 10
)
  -- Exigimos además que el precio sea menor que todos los elementos del conjunto tamaño 40.
  AND p.p_retailprice < ALL (
    -- La subconsulta devuelve los precios del grupo de tamaño 40.
    SELECT p40.p_retailprice
    -- Leemos part como segundo conjunto de referencia.
    FROM samples.tpch.part AS p40
    -- Definimos el segundo conjunto por tamaño.
    WHERE p40.p_size = 40
  )
-- Ordenamos por precio para inspeccionar el rango obtenido.
ORDER BY p.p_retailprice DESC
-- Limitamos el conjunto visible del ejercicio.
LIMIT 20;

-- COMMAND ----------

-- Ejercicio individual 5 de 5 - Desafío.
-- Enunciado: obtener el top 3 de países por ingreso total y su participación porcentual sobre el ingreso global.
-- Por qué la solución está escrita así: usamos CTE encadenadas para separar base, agregación y ranking, manteniendo clara la lógica del negocio.
-- Resultado esperado: tres países con mayor ingreso total y su peso relativo sobre todo el portafolio.
-- Error común: calcular el porcentaje sobre el subtotal de los tres primeros en vez del total global.
WITH base_nacion AS (
  -- Construimos una base con una fila por pedido y la nación del cliente que lo originó.
  SELECT
    -- Conservamos el nombre de la nación como dimensión final del ranking.
    n.n_name AS pais,
    -- Conservamos el total del pedido como métrica base del ingreso.
    o.o_totalprice AS total_pedido
  -- Leemos orders como hecho de ventas.
  FROM samples.tpch.orders AS o
  -- Unimos customer para saber la nación del cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Unimos nation para proyectar la geografía nacional.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
),
ingreso_pais AS (
  -- Resumimos el ingreso a una fila por país.
  SELECT
    -- Conservamos el país como clave de agregación.
    pais,
    -- Sumamos el valor total de los pedidos por país.
    SUM(total_pedido) AS ingreso_total
  -- Leemos la base geográfica preparada en la CTE anterior.
  FROM base_nacion
  -- Agrupamos por país para obtener una fila por nación.
  GROUP BY pais
),
ranking_pais AS (
  -- Calculamos la posición de cada país por ingreso.
  SELECT
    -- Conservamos el país para la salida final.
    pais,
    -- Conservamos el ingreso total ya agregado.
    ingreso_total,
    -- Asignamos ranking descendente por ingreso.
    DENSE_RANK() OVER (ORDER BY ingreso_total DESC) AS ranking_ingreso
  -- Leemos la CTE ingreso_pais como universo a rankear.
  FROM ingreso_pais
)
SELECT
  -- Mostramos el país rankeado.
  rp.pais,
  -- Mostramos el ingreso total del país.
  rp.ingreso_total,
  -- Mostramos la posición del país en el ranking global.
  rp.ranking_ingreso,
  -- Calculamos la participación porcentual del país sobre el ingreso global de todos los países.
  ROUND(
    rp.ingreso_total / (
      -- La subconsulta escalar suma el ingreso de todos los países para usarlo como denominador global.
      SELECT SUM(ip.ingreso_total)
      -- Leemos la CTE ingreso_pais porque allí ya está consolidado el valor por nación.
      FROM ingreso_pais AS ip
    ) * 100,
    2
  ) AS participacion_global_pct
-- Consumimos la CTE ranking_pais que ya tiene posición e ingreso.
FROM ranking_pais AS rp
-- Filtramos el top 3 solicitado en el enunciado.
WHERE rp.ranking_ingreso <= 3
-- Ordenamos por ranking para entregar la lista en orden natural.
ORDER BY rp.ranking_ingreso, rp.ingreso_total DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Desafío
-- MAGIC 
-- MAGIC Esta sección eleva el nivel de complejidad. Las soluciones siguen comentadas, pero el objetivo es que puedas leerlas como diseños analíticos completos.
-- MAGIC 
-- MAGIC | Desafío | Nivel | Tema dominante |
-- MAGIC |---|---|---|
-- MAGIC | 1 de 5 | Muy Fácil | clasificación con `EXISTS` |
-- MAGIC | 2 de 5 | Fácil | CTE + promedio global |
-- MAGIC | 3 de 5 | Intermedio | múltiples CTE con proveedores y regiones |
-- MAGIC | 4 de 5 | Intermedio Alto | modularidad y reutilización de CTE |
-- MAGIC | 5 de 5 | Desafío | introducción breve a CTE recursivas |

-- COMMAND ----------

-- Desafío 1 de 5 - Muy Fácil.
-- Objetivo: clasificar segmentos según tengan o no clientes con pedidos mayores a 300000.
-- Por qué esta consulta es útil: combina existencia con una salida resumida por segmento.
-- Resultado esperado: una fila por segmento con una etiqueta booleana de negocio.
-- Error común: pensar que la existencia debe evaluarse pedido por pedido en lugar de segmento por segmento.
SELECT
  -- Mostramos el segmento como dimensión resumida del análisis.
  c.c_mktsegment AS segmento,
  -- Traducimos la existencia de pedidos altos a una etiqueta de negocio legible.
  CASE
    -- Marcamos el segmento como activo en alto valor si existe al menos un cliente del segmento con pedido alto.
    WHEN EXISTS (
      -- La subconsulta busca pedidos altos relacionados con cualquier cliente del segmento externo.
      SELECT 1
      -- Leemos orders porque allí está el valor del pedido.
      FROM samples.tpch.orders AS o
      -- Unimos customer interno para saber el segmento del cliente que emitió el pedido.
      INNER JOIN samples.tpch.customer AS c2
        ON o.o_custkey = c2.c_custkey
      -- Correlacionamos por segmento y aplicamos el umbral de alto valor.
      WHERE c2.c_mktsegment = c.c_mktsegment
        AND o.o_totalprice > 300000
    ) THEN 'Sí tiene pedidos altos'
    -- Si no existe ningún caso, etiquetamos el segmento como ausente de ese patrón.
    ELSE 'No tiene pedidos altos'
  END AS estado_segmento
-- Leemos customer porque los segmentos viven en esta dimensión.
FROM samples.tpch.customer AS c
-- Agrupamos por segmento implícitamente mediante DISTINCT en la proyección final.
GROUP BY c.c_mktsegment
-- Ordenamos por nombre de segmento para una lectura estable.
ORDER BY c.c_mktsegment;

-- COMMAND ----------

-- Desafío 2 de 5 - Fácil.
-- Objetivo: identificar pedidos por encima del promedio global usando una CTE para hacer explícito el valor de referencia.
-- Por qué esta consulta es útil: demuestra que una CTE simple puede ser más legible que repetir subconsultas escalares.
-- Resultado esperado: pedidos con total superior al promedio global y la referencia visible en la misma fila.
-- Error común: repetir muchas veces la misma subconsulta escalar cuando un bloque nombrado comunica mejor la intención.
WITH promedio_global AS (
  -- Calculamos una sola fila con el promedio global de valor de pedido.
  SELECT
    -- Promediamos el total de los pedidos de toda la tabla orders.
    AVG(o.o_totalprice) AS promedio_pedido_global
  -- Leemos orders como universo completo del indicador global.
  FROM samples.tpch.orders AS o
)
SELECT
  -- Mostramos la llave del pedido evaluado.
  o.o_orderkey AS pedido_id,
  -- Mostramos la llave del cliente para trazabilidad del pedido.
  o.o_custkey AS cliente_id,
  -- Mostramos el total del pedido que se evalúa.
  o.o_totalprice AS total_pedido,
  -- Mostramos el promedio global como referencia constante traída desde la CTE.
  pg.promedio_pedido_global
-- Leemos orders como conjunto de pedidos a filtrar.
FROM samples.tpch.orders AS o
-- Cruzamos la CTE de promedio global para disponer del valor de referencia en cada fila.
CROSS JOIN promedio_global AS pg
-- Filtramos solo pedidos por encima del promedio calculado.
WHERE o.o_totalprice > pg.promedio_pedido_global
-- Ordenamos de mayor a menor total para revisar primero los casos más altos.
ORDER BY o.o_totalprice DESC
-- Limitamos la salida del desafío.
LIMIT 20;

-- COMMAND ----------

-- Desafío 3 de 5 - Intermedio.
-- Objetivo: encontrar el proveedor con mayor ingreso descontado dentro de cada región de proveedor.
-- Por qué esta consulta es útil: combina detalle de línea, proveedores, geografía y ranking en una cadena modular de CTE.
-- Resultado esperado: una fila por región con el proveedor líder y su ingreso neto descontado.
-- Error común: sumar l_extendedprice sin aplicar el descuento o rankear antes de agregar por proveedor.
WITH ingreso_proveedor AS (
  -- Calculamos el ingreso neto por proveedor y región usando el detalle lineitem.
  SELECT
    -- Conservamos la región del proveedor como dimensión del ranking final.
    r.r_name AS region_proveedor,
    -- Conservamos la llave del proveedor para acumular su ingreso.
    s.s_suppkey AS proveedor_id,
    -- Conservamos el nombre del proveedor para la salida legible.
    s.s_name AS nombre_proveedor,
    -- Sumamos el ingreso neto considerando el descuento aplicado a cada línea.
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS ingreso_neto
  -- Leemos lineitem porque contiene el detalle monetario más fino.
  FROM samples.tpch.lineitem AS l
  -- Unimos supplier para saber quién abasteció cada línea.
  INNER JOIN samples.tpch.supplier AS s
    ON l.l_suppkey = s.s_suppkey
  -- Unimos nation para conocer la nación del proveedor.
  INNER JOIN samples.tpch.nation AS n
    ON s.s_nationkey = n.n_nationkey
  -- Unimos region para elevar el análisis a nivel regional.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
  -- Agrupamos por región y proveedor para obtener una fila por proveedor dentro de su región.
  GROUP BY r.r_name, s.s_suppkey, s.s_name
),
ranking_proveedor AS (
  -- Rankeamos los proveedores dentro de cada región según ingreso neto.
  SELECT
    -- Conservamos la región del proveedor para la salida final.
    region_proveedor,
    -- Conservamos la llave del proveedor.
    proveedor_id,
    -- Conservamos el nombre del proveedor.
    nombre_proveedor,
    -- Conservamos el ingreso neto agregado.
    ingreso_neto,
    -- Asignamos una posición dentro de cada región.
    DENSE_RANK() OVER (
      PARTITION BY region_proveedor
      ORDER BY ingreso_neto DESC
    ) AS ranking_region
  -- Leemos la CTE ingreso_proveedor ya agregada.
  FROM ingreso_proveedor
)
SELECT
  -- Mostramos la región del proveedor líder.
  rp.region_proveedor,
  -- Mostramos la llave del proveedor líder.
  rp.proveedor_id,
  -- Mostramos el nombre del proveedor líder.
  rp.nombre_proveedor,
  -- Mostramos el ingreso neto que justifica el liderazgo.
  rp.ingreso_neto
-- Consumimos la CTE de ranking.
FROM ranking_proveedor AS rp
-- Filtramos la primera posición de cada región.
WHERE rp.ranking_region = 1
-- Ordenamos por ingreso neto descendente para comparar líderes regionales.
ORDER BY rp.ingreso_neto DESC;

-- COMMAND ----------

-- Desafío 4 de 5 - Intermedio Alto.
-- Objetivo: cruzar métricas por región y por segmento a partir de una misma base reutilizable, y discutir cuándo conviene materializarla.
-- Por qué esta consulta es útil: muestra cómo una CTE base puede alimentar varios resúmenes sin repetir joins pesados.
-- Resultado esperado: combinaciones región-segmento donde ambos indicadores quedan por encima de sus respectivos promedios.
-- Error común: rehacer la misma base en múltiples subconsultas, dificultando mantenimiento y potencialmente empeorando rendimiento.
-- Nota práctica: si `ventas_base` se reutilizara en muchas consultas del notebook, podría materializarse como `TEMP VIEW`.
WITH ventas_base AS (
  -- Construimos una base reutilizable con región, segmento y valor de pedido.
  SELECT
    -- Conservamos la región del cliente como dimensión analítica.
    r.r_name AS region,
    -- Conservamos el segmento del cliente como segunda dimensión analítica.
    c.c_mktsegment AS segmento,
    -- Conservamos el valor del pedido como métrica base.
    o.o_totalprice AS total_pedido
  -- Leemos orders como hecho monetario principal.
  FROM samples.tpch.orders AS o
  -- Unimos customer para acceder al segmento y geografía del cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Unimos nation para escalar la geografía del cliente.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Unimos region para llegar al nivel regional.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
),
metricas_region AS (
  -- Resumimos la base por región.
  SELECT
    -- Conservamos la región como clave de agrupación.
    region,
    -- Calculamos el ticket promedio de la región.
    AVG(total_pedido) AS ticket_promedio_region
  -- Leemos la base reutilizable ventas_base.
  FROM ventas_base
  -- Agrupamos por región para obtener una fila por cada una.
  GROUP BY region
),
metricas_segmento AS (
  -- Resumimos la base por segmento.
  SELECT
    -- Conservamos el segmento como clave de agrupación.
    segmento,
    -- Calculamos el ticket promedio del segmento.
    AVG(total_pedido) AS ticket_promedio_segmento
  -- Leemos la misma base reutilizable ventas_base.
  FROM ventas_base
  -- Agrupamos por segmento para obtener una fila por categoría comercial.
  GROUP BY segmento
),
cruce_region_segmento AS (
  -- Calculamos el ticket promedio para cada combinación región-segmento.
  SELECT
    -- Conservamos la región.
    region,
    -- Conservamos el segmento.
    segmento,
    -- Calculamos el ticket promedio de la combinación.
    AVG(total_pedido) AS ticket_promedio_combinacion
  -- Leemos nuevamente ventas_base porque ahora el grano es la combinación de ambas dimensiones.
  FROM ventas_base
  -- Agrupamos por región y segmento.
  GROUP BY region, segmento
)
SELECT
  -- Mostramos la región evaluada.
  crs.region,
  -- Mostramos el segmento evaluado.
  crs.segmento,
  -- Mostramos el ticket promedio de la combinación región-segmento.
  crs.ticket_promedio_combinacion,
  -- Mostramos el ticket promedio de referencia de la región.
  mr.ticket_promedio_region,
  -- Mostramos el ticket promedio de referencia del segmento.
  ms.ticket_promedio_segmento
-- Partimos de la combinación región-segmento ya resumida.
FROM cruce_region_segmento AS crs
-- Unimos el resumen regional para comparar contra su promedio regional.
INNER JOIN metricas_region AS mr
  ON crs.region = mr.region
-- Unimos el resumen por segmento para comparar contra su promedio de segmento.
INNER JOIN metricas_segmento AS ms
  ON crs.segmento = ms.segmento
-- Conservamos solo combinaciones por encima de ambos referentes.
WHERE crs.ticket_promedio_combinacion > mr.ticket_promedio_region
  AND crs.ticket_promedio_combinacion > ms.ticket_promedio_segmento
-- Ordenamos por el ticket de la combinación para destacar las mejores zonas de oportunidad.
ORDER BY crs.ticket_promedio_combinacion DESC;

-- COMMAND ----------

-- Desafío 5 de 5 - Desafío.
-- Objetivo: presentar una introducción breve a CTE recursivas recorriendo la tabla de regiones por llave consecutiva.
-- Por qué esta consulta es útil: ilustra la estructura anchor + recursive step de una CTE recursiva sin salir del contexto del curso.
-- Resultado esperado: una secuencia de regiones encadenadas desde la llave 0 hasta completar cinco niveles.
-- Error común: olvidar la condición de corte y crear una recursión infinita.
WITH RECURSIVE recorrido_regiones AS (
  -- Definimos el caso base de la recursión comenzando por la región con llave 0.
  SELECT
    -- Conservamos la llave de la región actual.
    r.r_regionkey AS region_key,
    -- Conservamos el nombre de la región actual.
    r.r_name AS region_nombre,
    -- Inicializamos el nivel en 1 porque esta es la primera fila del recorrido.
    1 AS nivel,
    -- Construimos una ruta textual inicial para visualizar el avance.
    CAST(r.r_name AS STRING) AS ruta
  -- Leemos la dimensión region como punto de partida del ejemplo recursivo.
  FROM samples.tpch.region AS r
  -- Elegimos la región inicial del recorrido.
  WHERE r.r_regionkey = 0

  UNION ALL

  -- Definimos el paso recursivo que avanza a la siguiente llave de región.
  SELECT
    -- Conservamos la llave de la siguiente región encontrada.
    r2.r_regionkey AS region_key,
    -- Conservamos el nombre de la siguiente región.
    r2.r_name AS region_nombre,
    -- Incrementamos el nivel para marcar el avance de la recursión.
    rr.nivel + 1 AS nivel,
    -- Extendemos la ruta textual agregando la nueva región al recorrido previo.
    CONCAT(rr.ruta, ' -> ', r2.r_name) AS ruta
  -- Leemos la CTE a sí misma como estado previo del recorrido.
  FROM recorrido_regiones AS rr
  -- Unimos la tabla region para avanzar a la siguiente llave consecutiva.
  INNER JOIN samples.tpch.region AS r2
    ON r2.r_regionkey = rr.region_key + 1
  -- Establecemos una condición de corte para evitar recursión infinita.
  WHERE rr.nivel < 5
)
SELECT
  -- Mostramos la llave de la región visitada en cada paso.
  rr.region_key,
  -- Mostramos el nombre de la región visitada.
  rr.region_nombre,
  -- Mostramos el nivel de profundidad alcanzado.
  rr.nivel,
  -- Mostramos la ruta acumulada del recorrido.
  rr.ruta
-- Consumimos la CTE recursiva una vez completado el proceso iterativo.
FROM recorrido_regiones AS rr
-- Ordenamos por nivel para ver la secuencia en el orden de construcción.
ORDER BY rr.nivel;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Resumen
-- MAGIC 
-- MAGIC ### Ideas clave del notebook
-- MAGIC - Una **subconsulta** sirve para producir un valor, una lista o una tabla intermedia.
-- MAGIC - Las subconsultas en `WHERE` son ideales para comparar o filtrar.
-- MAGIC - Las subconsultas en `FROM` son útiles cuando primero necesitas cambiar el grano del análisis.
-- MAGIC - Las subconsultas escalares en `SELECT` agregan referencias globales o locales al resultado final.
-- MAGIC - `EXISTS` y `NOT EXISTS` expresan mejor la lógica de existencia que muchos `JOIN`.
-- MAGIC - `IN` es excelente para pertenencia; `JOIN` es mejor cuando además necesitas columnas adicionales.
-- MAGIC - `ANY` y `ALL` permiten pensar en conjuntos, no solo en valores individuales.
-- MAGIC - Las **CTE** mejoran legibilidad, modularidad y mantenibilidad.
-- MAGIC - Si un bloque intermedio se reutiliza muchas veces o es costoso, evalúa **materializarlo**.
-- MAGIC 
-- MAGIC ### Regla de decisión rápida
-- MAGIC 
-- MAGIC ```text
-- MAGIC ¿Necesito un valor único?      -> subconsulta escalar
-- MAGIC ¿Necesito una lista?           -> IN / ANY / ALL
-- MAGIC ¿Necesito saber si existe?     -> EXISTS / NOT EXISTS
-- MAGIC ¿Necesito una tabla intermedia -> subconsulta en FROM o CTE
-- MAGIC ¿Necesito varias etapas claras -> CTE encadenadas
-- MAGIC ```
-- MAGIC 
-- MAGIC > **📝 Nota:** La técnica correcta es la que hace que el resultado sea correcto y el razonamiento sea visible para otra persona.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Laboratorio
-- MAGIC 
-- MAGIC A continuación desarrollarás consultas de estilo más profesional, pensadas como preguntas reales para el equipo de DataCorp Analytics.
-- MAGIC 
-- MAGIC | Caso | Pregunta de negocio |
-- MAGIC |---|---|
-- MAGIC | Laboratorio 1 | ¿Qué regiones concentran clientes de alto valor? |
-- MAGIC | Laboratorio 2 | ¿Qué proveedores abastecen partes con demanda superior a su tipo? |
-- MAGIC | Laboratorio 3 | ¿Qué segmentos combinan alto volumen y alto ticket? |
-- MAGIC | Laboratorio 4 | ¿Qué países superan simultáneamente el promedio global y el regional? |

-- COMMAND ----------

-- Laboratorio 1.
-- Pregunta de negocio: ¿qué regiones concentran clientes cuyo ingreso total supera el promedio global de ingreso por cliente?
-- Por qué la consulta está escrita así: primero medimos ingreso por cliente, luego filtramos alto valor y finalmente llevamos esa lista a la geografía regional.
-- Resultado esperado: regiones con conteo y promedio de ingreso de sus clientes de alto valor.
-- Error común: usar el promedio de pedido en vez del promedio de ingreso acumulado por cliente.
WITH ingreso_cliente AS (
  -- Calculamos una fila por cliente con su ingreso acumulado.
  SELECT
    -- Conservamos la llave del cliente como unidad principal del análisis.
    o.o_custkey AS cliente_id,
    -- Sumamos todos los pedidos del cliente para medir su ingreso total acumulado.
    SUM(o.o_totalprice) AS ingreso_total
  -- Leemos orders como fuente monetaria del análisis.
  FROM samples.tpch.orders AS o
  -- Agrupamos por cliente para obtener una fila por comprador.
  GROUP BY o.o_custkey
),
clientes_alto_valor AS (
  -- Filtramos clientes con ingreso superior al promedio global de ingreso por cliente.
  SELECT
    -- Conservamos la llave del cliente para la etapa geográfica posterior.
    ic.cliente_id,
    -- Conservamos el ingreso total del cliente para cálculos descriptivos.
    ic.ingreso_total
  -- Leemos la CTE ingreso_cliente como universo de comparación.
  FROM ingreso_cliente AS ic
  -- Aplicamos el corte de alto valor usando una subconsulta escalar global.
  WHERE ic.ingreso_total > (
    -- Calculamos el promedio global de ingreso entre clientes compradores.
    SELECT AVG(ic2.ingreso_total)
    -- Leemos la misma CTE como conjunto de referencia.
    FROM ingreso_cliente AS ic2
  )
)
SELECT
  -- Mostramos la región donde reside el cliente de alto valor.
  r.r_name AS region,
  -- Contamos cuántos clientes de alto valor pertenecen a la región.
  COUNT(*) AS clientes_alto_valor,
  -- Calculamos el ingreso promedio de esos clientes de alto valor dentro de la región.
  AVG(cav.ingreso_total) AS ingreso_promedio_cliente_alto_valor
-- Partimos de la lista de clientes de alto valor.
FROM clientes_alto_valor AS cav
-- Unimos customer para ubicar al cliente en la geografía.
INNER JOIN samples.tpch.customer AS c
  ON cav.cliente_id = c.c_custkey
-- Unimos nation para recorrer la jerarquía geográfica.
INNER JOIN samples.tpch.nation AS n
  ON c.c_nationkey = n.n_nationkey
-- Unimos region para llegar al nivel final del reporte.
INNER JOIN samples.tpch.region AS r
  ON n.n_regionkey = r.r_regionkey
-- Agrupamos por región para construir una fila por cada zona.
GROUP BY r.r_name
-- Ordenamos de mayor a menor número de clientes de alto valor.
ORDER BY clientes_alto_valor DESC, ingreso_promedio_cliente_alto_valor DESC;

-- COMMAND ----------

-- Laboratorio 2.
-- Pregunta de negocio: ¿qué proveedores participan en partes cuya demanda total está por encima del promedio de su tipo de producto?
-- Por qué la consulta está escrita así: necesitamos medir demanda por parte, comparar contra el promedio del tipo y luego rastrear qué proveedores abastecen esas partes.
-- Resultado esperado: proveedores vinculados con partes de demanda superior a su categoría.
-- Error común: comparar la demanda de una parte contra el promedio global de todas las partes en vez del promedio de su mismo tipo.
WITH demanda_parte AS (
  -- Resumimos la demanda total por parte usando la cantidad solicitada en lineitem.
  SELECT
    -- Conservamos la llave de la parte como unidad de demanda.
    l.l_partkey AS parte_id,
    -- Sumamos la cantidad pedida para medir demanda acumulada.
    SUM(l.l_quantity) AS demanda_total
  -- Leemos lineitem porque contiene la cantidad por línea de venta.
  FROM samples.tpch.lineitem AS l
  -- Agrupamos por parte para obtener una fila por producto.
  GROUP BY l.l_partkey
),
partes_sobre_promedio_tipo AS (
  -- Filtramos partes cuya demanda supera el promedio de demanda dentro de su propio tipo.
  SELECT
    -- Conservamos la llave de la parte para enlazarla después con proveedores.
    p.p_partkey AS parte_id,
    -- Conservamos el nombre de la parte para interpretar el resultado final.
    p.p_name AS nombre_parte,
    -- Conservamos el tipo de la parte porque es el grupo de comparación.
    p.p_type AS tipo_parte,
    -- Conservamos la demanda total calculada para auditoría y presentación.
    dp.demanda_total
  -- Leemos la dimensión part como tabla izquierda del filtro por tipo.
  FROM samples.tpch.part AS p
  -- Unimos la demanda resumida para asociar cada parte con su volumen acumulado.
  INNER JOIN demanda_parte AS dp
    -- Relacionamos la parte con su demanda resumida.
    ON p.p_partkey = dp.parte_id
  -- Aplicamos una subconsulta correlacionada sobre el tipo de producto.
  WHERE dp.demanda_total > (
    -- Calculamos el promedio de demanda entre partes del mismo tipo.
    SELECT AVG(dp2.demanda_total)
    -- Leemos demanda_parte como conjunto resumido de comparación.
    FROM demanda_parte AS dp2
    -- Unimos part para saber el tipo de cada parte del conjunto interno.
    INNER JOIN samples.tpch.part AS p2
      ON dp2.parte_id = p2.p_partkey
    -- Correlacionamos por tipo para comparar cada parte con su categoría correcta.
    WHERE p2.p_type = p.p_type
  )
)
SELECT DISTINCT
  -- Mostramos el nombre del proveedor participante.
  s.s_name AS proveedor,
  -- Mostramos el país del proveedor para contexto geográfico.
  n.n_name AS pais_proveedor,
  -- Mostramos la parte destacada por demanda.
  pst.nombre_parte,
  -- Mostramos el tipo de la parte destacada.
  pst.tipo_parte,
  -- Mostramos la demanda total que justificó la inclusión.
  pst.demanda_total
-- Partimos de la lista de partes destacadas por demanda.
FROM partes_sobre_promedio_tipo AS pst
-- Unimos lineitem para rastrear qué proveedores abastecieron esas partes.
INNER JOIN samples.tpch.lineitem AS l
  ON pst.parte_id = l.l_partkey
-- Unimos supplier para proyectar la identidad del proveedor.
INNER JOIN samples.tpch.supplier AS s
  ON l.l_suppkey = s.s_suppkey
-- Unimos nation para agregar el país del proveedor.
INNER JOIN samples.tpch.nation AS n
  ON s.s_nationkey = n.n_nationkey
-- Ordenamos por demanda y proveedor para priorizar los casos más interesantes.
ORDER BY pst.demanda_total DESC, s.s_name
-- Limitamos la salida para revisión inicial del laboratorio.
LIMIT 25;

-- COMMAND ----------

-- Laboratorio 3.
-- Pregunta de negocio: ¿qué segmentos combinan alto volumen de pedidos y alto ticket promedio frente al comportamiento global?
-- Por qué la consulta está escrita así: separamos el resumen por segmento y luego lo comparamos contra referencias globales obtenidas desde una CTE de métricas.
-- Resultado esperado: segmentos cuyo volumen y ticket promedio están por encima del promedio entre segmentos.
-- Error común: comparar ticket promedio del segmento contra el ticket promedio de pedidos individuales sin alinear el nivel de comparación.
WITH metricas_segmento AS (
  -- Calculamos métricas de desempeño por segmento comercial.
  SELECT
    -- Conservamos el segmento como dimensión del análisis.
    c.c_mktsegment AS segmento,
    -- Contamos cuántos pedidos pertenecen al segmento.
    COUNT(*) AS total_pedidos,
    -- Calculamos el ticket promedio del segmento a partir de sus pedidos.
    AVG(o.o_totalprice) AS ticket_promedio_segmento
  -- Leemos orders como hecho transaccional.
  FROM samples.tpch.orders AS o
  -- Unimos customer para acceder al segmento del cliente que realizó el pedido.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Agrupamos por segmento para obtener una fila por grupo comercial.
  GROUP BY c.c_mktsegment
),
referencias_globales AS (
  -- Calculamos promedios entre segmentos ya resumidos.
  SELECT
    -- Promediamos el total de pedidos entre segmentos para obtener una referencia de volumen.
    AVG(ms.total_pedidos) AS promedio_pedidos_entre_segmentos,
    -- Promediamos el ticket promedio entre segmentos para obtener una referencia de valor.
    AVG(ms.ticket_promedio_segmento) AS promedio_ticket_entre_segmentos
  -- Leemos la CTE metricas_segmento como universo resumido de comparación.
  FROM metricas_segmento AS ms
)
SELECT
  -- Mostramos el segmento evaluado.
  ms.segmento,
  -- Mostramos el volumen de pedidos del segmento.
  ms.total_pedidos,
  -- Mostramos el ticket promedio del segmento.
  ms.ticket_promedio_segmento,
  -- Mostramos la referencia global de volumen entre segmentos.
  rg.promedio_pedidos_entre_segmentos,
  -- Mostramos la referencia global de ticket entre segmentos.
  rg.promedio_ticket_entre_segmentos
-- Partimos de la tabla resumida por segmento.
FROM metricas_segmento AS ms
-- Cruzamos la fila única de referencias globales para poder comparar en la misma salida.
CROSS JOIN referencias_globales AS rg
-- Conservamos segmentos que superan ambas referencias globales.
WHERE ms.total_pedidos > rg.promedio_pedidos_entre_segmentos
  AND ms.ticket_promedio_segmento > rg.promedio_ticket_entre_segmentos
-- Ordenamos por ticket y luego por volumen para priorizar segmentos rentables y activos.
ORDER BY ms.ticket_promedio_segmento DESC, ms.total_pedidos DESC;

-- COMMAND ----------

-- Laboratorio 4.
-- Pregunta de negocio: ¿qué países tienen un ticket promedio de pedido superior tanto al promedio global como al promedio de su propia región?
-- Por qué la consulta está escrita así: el negocio necesita una comparación doble, y eso se modela mejor con CTE separadas para país, región y global.
-- Resultado esperado: países sobresalientes en valor medio de pedido dentro del contexto mundial y regional.
-- Error común: comparar el promedio del país contra el total de la región o contra el promedio de clientes, mezclando niveles analíticos.
WITH pedidos_geografia AS (
  -- Construimos una base con pedido, país y región del cliente.
  SELECT
    -- Conservamos el país del cliente como dimensión posible de salida.
    n.n_name AS pais,
    -- Conservamos la región del cliente como contexto comparativo.
    r.r_name AS region,
    -- Conservamos el valor del pedido como métrica base.
    o.o_totalprice AS total_pedido
  -- Leemos orders como hecho monetario.
  FROM samples.tpch.orders AS o
  -- Unimos customer para conocer la nación del cliente.
  INNER JOIN samples.tpch.customer AS c
    ON o.o_custkey = c.c_custkey
  -- Unimos nation para obtener el país del cliente.
  INNER JOIN samples.tpch.nation AS n
    ON c.c_nationkey = n.n_nationkey
  -- Unimos region para obtener el contexto regional.
  INNER JOIN samples.tpch.region AS r
    ON n.n_regionkey = r.r_regionkey
),
promedio_pais AS (
  -- Calculamos el ticket promedio por país.
  SELECT
    -- Conservamos el país como clave de agregación.
    pais,
    -- Conservamos la región para poder enlazar después con su promedio regional.
    region,
    -- Calculamos el promedio de valor de pedido del país.
    AVG(total_pedido) AS ticket_promedio_pais
  -- Leemos la base geográfica de pedidos.
  FROM pedidos_geografia
  -- Agrupamos por país y región para construir una fila por nación.
  GROUP BY pais, region
),
promedio_region AS (
  -- Calculamos el ticket promedio por región.
  SELECT
    -- Conservamos la región como clave de agregación.
    region,
    -- Calculamos el promedio de valor de pedido regional.
    AVG(total_pedido) AS ticket_promedio_region
  -- Leemos la misma base geográfica de pedidos.
  FROM pedidos_geografia
  -- Agrupamos por región para obtener una fila por cada una.
  GROUP BY region
),
promedio_global AS (
  -- Calculamos una sola fila con el ticket promedio global.
  SELECT
    -- Promediamos el valor de todos los pedidos del universo completo.
    AVG(total_pedido) AS ticket_promedio_global
  -- Leemos la base geográfica para mantener el mismo universo de cálculo.
  FROM pedidos_geografia
)
SELECT
  -- Mostramos el país que supera ambas referencias.
  pp.pais,
  -- Mostramos la región del país para contexto adicional.
  pp.region,
  -- Mostramos el ticket promedio del país.
  pp.ticket_promedio_pais,
  -- Mostramos el ticket promedio de la región correspondiente.
  pr.ticket_promedio_region,
  -- Mostramos el ticket promedio global del portafolio.
  pg.ticket_promedio_global
-- Partimos del promedio por país.
FROM promedio_pais AS pp
-- Unimos el promedio regional para la comparación contextual.
INNER JOIN promedio_region AS pr
  ON pp.region = pr.region
-- Cruzamos la fila única del promedio global.
CROSS JOIN promedio_global AS pg
-- Conservamos países por encima del promedio de su región y del promedio global.
WHERE pp.ticket_promedio_pais > pr.ticket_promedio_region
  AND pp.ticket_promedio_pais > pg.ticket_promedio_global
-- Ordenamos por ticket promedio del país para destacar los mejores casos.
ORDER BY pp.ticket_promedio_pais DESC;

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 14. Autoevaluación
-- MAGIC 
-- MAGIC Usa esta sección para verificar si dominas la lógica del notebook.
-- MAGIC 
-- MAGIC ### Preguntas de reflexión
-- MAGIC 1. ¿Cuándo una subconsulta debe ser correlacionada y cuándo no?
-- MAGIC 2. ¿Qué ventaja lógica ofrece `EXISTS` frente a un `JOIN` cuando solo te interesa saber si hay relación?
-- MAGIC 3. ¿Qué hace más legible a una CTE que a una subconsulta inline?
-- MAGIC 4. ¿Qué diferencia conceptual existe entre `> ANY` y `> ALL`?
-- MAGIC 5. ¿Cuándo considerarías materializar una CTE en Databricks?
-- MAGIC 
-- MAGIC ### Minicheck técnico
-- MAGIC Ejecuta las siguientes consultas y explica con tus propias palabras por qué el resultado demuestra el concepto señalado.

-- COMMAND ----------

-- Autoevaluación 1.
-- Concepto a verificar: `IN` y `EXISTS` pueden expresar la misma lógica de pertenencia, pero con estilos distintos.
-- Resultado esperado: ambas métricas deberían coincidir porque están respondiendo la misma pregunta de negocio.
-- Error común: olvidar DISTINCT en la versión con IN y terminar con una cuenta inflada si se cambia la forma de agregación.
SELECT
  -- Calculamos con subconsulta IN cuántos clientes tienen al menos un pedido superior a 300000.
  (
    SELECT COUNT(*)
    FROM samples.tpch.customer AS c
    WHERE c.c_custkey IN (
      SELECT DISTINCT o.o_custkey
      FROM samples.tpch.orders AS o
      WHERE o.o_totalprice > 300000
    )
  ) AS clientes_via_in,
  -- Calculamos con EXISTS la misma métrica para contrastar equivalencia lógica.
  (
    SELECT COUNT(*)
    FROM samples.tpch.customer AS c
    WHERE EXISTS (
      SELECT 1
      FROM samples.tpch.orders AS o
      WHERE o.o_custkey = c.c_custkey
        AND o.o_totalprice > 300000
    )
  ) AS clientes_via_exists;

-- COMMAND ----------

-- Autoevaluación 2.
-- Concepto a verificar: `> ALL` se comporta de forma equivalente a comparar contra el máximo del conjunto cuando el subconjunto no es vacío.
-- Resultado esperado: las dos métricas deberían coincidir o ser muy cercanas en interpretación, mostrando la intuición de ALL.
-- Error común: creer que ALL compara contra el promedio del conjunto; en realidad exige superar todos los valores.
SELECT
  -- Contamos partes cuyo precio supera a todas las partes de tamaño 49 usando ALL.
  (
    SELECT COUNT(*)
    FROM samples.tpch.part AS p
    WHERE p.p_retailprice > ALL (
      SELECT p2.p_retailprice
      FROM samples.tpch.part AS p2
      WHERE p2.p_size = 49
    )
  ) AS conteo_via_all,
  -- Contamos partes equivalentes comparando contra el máximo del mismo conjunto de referencia.
  (
    SELECT COUNT(*)
    FROM samples.tpch.part AS p
    WHERE p.p_retailprice > (
      SELECT MAX(p2.p_retailprice)
      FROM samples.tpch.part AS p2
      WHERE p2.p_size = 49
    )
  ) AS conteo_via_maximo;

-- COMMAND ----------

-- Autoevaluación 3.
-- Concepto a verificar: una CTE permite reutilizar el mismo bloque lógico para dos métricas finales sin reescribir la base completa.
-- Resultado esperado: una sola fila con el promedio y el máximo del ingreso por cliente a partir de la misma CTE.
-- Error común: recalcular el resumen por cliente varias veces en subconsultas independientes, reduciendo legibilidad.
WITH ingreso_cliente AS (
  -- Construimos una fila por cliente con su ingreso total acumulado.
  SELECT
    -- Conservamos la llave del cliente como unidad de agregación.
    o.o_custkey AS cliente_id,
    -- Sumamos el valor de los pedidos del cliente.
    SUM(o.o_totalprice) AS ingreso_total
  -- Leemos la tabla orders como fuente monetaria.
  FROM samples.tpch.orders AS o
  -- Agrupamos por cliente para obtener el grano deseado.
  GROUP BY o.o_custkey
)
SELECT
  -- Calculamos el ingreso promedio entre clientes a partir de la misma CTE.
  AVG(ic.ingreso_total) AS ingreso_promedio_cliente,
  -- Calculamos el ingreso máximo entre clientes reutilizando exactamente el mismo bloque.
  MAX(ic.ingreso_total) AS ingreso_maximo_cliente
-- Consumimos la CTE una sola vez en la consulta final.
FROM ingreso_cliente AS ic;
