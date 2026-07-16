-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Notebook 02: SELECT y Consultas Básicas
-- MAGIC ## Fundamentos de Programación
-- MAGIC ### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia
-- MAGIC
-- MAGIC **Semana 2**  
-- MAGIC **Rol del estudiante:** Data Analyst en **DataCorp Analytics**  
-- MAGIC **Misión del día:** responder solicitudes básicas del gerente usando consultas `SELECT` sobre clientes, órdenes y catálogos operativos.
-- MAGIC
-- MAGIC > **📝 Nota:** Este notebook está diseñado para ejecutarse en Databricks SQL. Todas las consultas usan únicamente tablas públicas del catálogo `samples`.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 1. Bienvenida
-- MAGIC
-- MAGIC En esta segunda semana pasamos de la exploración del entorno a la **consulta directa de datos**. La sentencia `SELECT` es la puerta de entrada a casi todo análisis en SQL: permite elegir columnas, filtrar filas, ordenar resultados y limitar salidas.
-- MAGIC
-- MAGIC En el contexto de **DataCorp Analytics**, tu gerente necesita un reporte preliminar con información de clientes, órdenes y catálogos. Antes de construir métricas complejas, debes dominar las consultas básicas con precisión.
-- MAGIC
-- MAGIC ```text
-- MAGIC Necesidad del negocio
-- MAGIC        │
-- MAGIC        ├── ¿Qué columnas necesito?
-- MAGIC        ├── ¿Qué filas cumplen la condición?
-- MAGIC        ├── ¿Cómo presento el resultado?
-- MAGIC        └── ¿Cómo evito errores comunes?
-- MAGIC                 ↓
-- MAGIC              SELECT
-- MAGIC ```

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC
-- MAGIC Al finalizar este notebook podrás:
-- MAGIC
-- MAGIC 1. Identificar la anatomía completa de una consulta `SELECT`.
-- MAGIC 2. Diferenciar entre `SELECT *` y la selección explícita de columnas.
-- MAGIC 3. Crear alias legibles con `AS` para mejorar reportes.
-- MAGIC 4. Aplicar `DISTINCT` para obtener valores únicos.
-- MAGIC 5. Filtrar filas con `WHERE`, operadores de comparación y operadores lógicos.
-- MAGIC 6. Usar `BETWEEN`, `IN`, `LIKE`, `IS NULL` e `IS NOT NULL`.
-- MAGIC 7. Ordenar y recortar resultados con `ORDER BY` y `LIMIT`.
-- MAGIC 8. Interpretar tipos de datos básicos en tablas analíticas.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias
-- MAGIC
-- MAGIC | Competencia | Descripción aplicada al curso | Evidencia esperada |
-- MAGIC |---|---|---|
-- MAGIC | Lectura de datos | Reconoce tablas, columnas y tipos de datos relevantes | Consulta columnas correctas sin ambigüedad |
-- MAGIC | Pensamiento analítico | Traduce preguntas del negocio a filtros SQL | Usa `WHERE` con condiciones claras |
-- MAGIC | Comunicación técnica | Presenta resultados con nombres entendibles | Usa alias con `AS` |
-- MAGIC | Calidad analítica | Reduce ruido y evita duplicados innecesarios | Aplica `DISTINCT`, `ORDER BY` y `LIMIT` |
-- MAGIC | Validación | Detecta errores de sintaxis y de lógica | Explica por qué una consulta funciona |

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC
-- MAGIC El gerente comercial de **DataCorp Analytics** pidió un corte rápido de información para una reunión regional:
-- MAGIC
-- MAGIC - identificar clientes relevantes,
-- MAGIC - revisar órdenes por estado,
-- MAGIC - explorar segmentos de mercado,
-- MAGIC - observar catálogos de productos y proveedores,
-- MAGIC - preparar una muestra pequeña para el reporte ejecutivo.
-- MAGIC
-- MAGIC Tu trabajo no es todavía unir todas las tablas, sino **consultar con precisión cada fuente** y devolver resultados limpios, entendibles y verificables.
-- MAGIC
-- MAGIC > **📝 Nota:** En ciencia de datos, muchas fallas del análisis comienzan por una mala consulta base: columnas innecesarias, filtros ambiguos o resultados sin ordenar.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos
-- MAGIC
-- MAGIC ### 5.1 Anatomía de una consulta `SELECT`
-- MAGIC
-- MAGIC ```text
-- MAGIC SELECT columna_1, columna_2
-- MAGIC FROM tabla
-- MAGIC WHERE condición
-- MAGIC ORDER BY columna
-- MAGIC LIMIT n
-- MAGIC ```
-- MAGIC
-- MAGIC ### 5.2 ¿Qué hace cada cláusula?
-- MAGIC
-- MAGIC | Cláusula | Función | Pregunta que responde |
-- MAGIC |---|---|---|
-- MAGIC | `SELECT` | Elige columnas o expresiones | ¿Qué quiero ver? |
-- MAGIC | `FROM` | Indica la tabla de origen | ¿De dónde sale la información? |
-- MAGIC | `WHERE` | Filtra filas | ¿Qué registros cumplen la condición? |
-- MAGIC | `ORDER BY` | Ordena el resultado | ¿Cómo presento primero lo más importante? |
-- MAGIC | `LIMIT` | Restringe el número de filas | ¿Cuántas filas necesito inspeccionar? |
-- MAGIC
-- MAGIC ### 5.3 Tipos de datos básicos en SQL
-- MAGIC
-- MAGIC | Tipo | Ejemplo | Uso frecuente |
-- MAGIC |---|---|---|
-- MAGIC | Entero (`INT`, `BIGINT`) | `c_custkey`, `o_orderkey` | Identificadores y conteos |
-- MAGIC | Decimal (`DECIMAL`, `DOUBLE`) | `c_acctbal`, `o_totalprice` | Importes, saldos, distancias |
-- MAGIC | Texto (`STRING`) | `c_name`, `o_orderstatus` | Nombres, estados, comentarios |
-- MAGIC | Fecha (`DATE`) | `o_orderdate` | Seguimiento temporal |
-- MAGIC
-- MAGIC > **📝 Nota:** El tipo de dato define qué operaciones tienen sentido. Comparar fechas como texto o sumar columnas de texto suele producir errores o resultados engañosos.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos (continuación)
-- MAGIC
-- MAGIC ### 5.4 Operadores que usaremos hoy
-- MAGIC
-- MAGIC | Categoría | Operadores | Uso |
-- MAGIC |---|---|---|
-- MAGIC | Comparación | `=`, `!=`, `<`, `>`, `<=`, `>=` | Comparar valores |
-- MAGIC | Lógicos | `AND`, `OR`, `NOT` | Combinar condiciones |
-- MAGIC | Rango | `BETWEEN ... AND` | Buscar dentro de un intervalo |
-- MAGIC | Conjunto | `IN (...)` | Buscar dentro de una lista |
-- MAGIC | Patrones | `LIKE`, `%`, `_` | Buscar coincidencias parciales |
-- MAGIC | Nulos | `IS NULL`, `IS NOT NULL` | Detectar ausencia de dato |
-- MAGIC
-- MAGIC ### 5.5 Buenas prácticas iniciales
-- MAGIC
-- MAGIC 1. Evita `SELECT *` en reportes finales.
-- MAGIC 2. Usa alias para nombres comprensibles.
-- MAGIC 3. Ordena resultados cuando comparas extremos.
-- MAGIC 4. Limita filas durante la exploración.
-- MAGIC 5. Lee el error: casi siempre indica la cláusula problemática.
-- MAGIC
-- MAGIC > **📝 Nota:** Un error muy común es escribir `WHERE columna = NULL`. En SQL, la comparación correcta es `WHERE columna IS NULL`.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso
-- MAGIC
-- MAGIC En esta sección iremos de lo más básico a lo más útil para un analista junior:
-- MAGIC
-- MAGIC 1. seleccionar columnas,
-- MAGIC 2. renombrarlas,
-- MAGIC 3. quitar duplicados,
-- MAGIC 4. filtrar,
-- MAGIC 5. combinar condiciones,
-- MAGIC 6. ordenar y limitar.
-- MAGIC
-- MAGIC Cada consulta incluye:
-- MAGIC
-- MAGIC - **por qué** se escribe así,
-- MAGIC - **qué hace** cada línea,
-- MAGIC - **qué resultado** esperar,
-- MAGIC - **qué error común** evitar.

-- COMMAND ----------
-- Resultado esperado: una muestra de clientes con cuatro columnas relevantes para inspección inicial.
-- ¿Por qué esta consulta está escrita así? Porque primero conviene observar pocas columnas clave en lugar de traer toda la tabla.
-- Error común: usar SELECT * cuando todavía no sabes qué columnas necesitas para el reporte.
SELECT                                      -- Iniciamos la consulta indicando qué columnas queremos recuperar.
  c_custkey,                                -- Traemos el identificador único del cliente.
  c_name,                                   -- Traemos el nombre del cliente para que el resultado sea interpretable.
  c_nationkey,                              -- Incluimos la referencia de nación para contexto geográfico posterior.
  c_acctbal                                 -- Incluimos el saldo de la cuenta, útil para priorización comercial.
FROM samples.tpch.customer                  -- Indicamos la tabla de origen dentro del catálogo público samples.
LIMIT 10;                                   -- Limitamos a 10 filas para explorar rápido sin saturar la salida.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Paso 1: `SELECT` específico vs `SELECT *`
-- MAGIC
-- MAGIC **¿Por qué no usar `SELECT *` aquí?**
-- MAGIC
-- MAGIC - porque trae columnas que quizá no necesitas,
-- MAGIC - consume más lectura y hace más difícil validar resultados,
-- MAGIC - vuelve frágil un reporte si la estructura de la tabla cambia.
-- MAGIC
-- MAGIC **Resultado esperado:** una vista pequeña, clara y útil para validar la tabla `customer`.

-- COMMAND ----------
-- Resultado esperado: una muestra de órdenes con nombres de columna más legibles para negocio.
-- ¿Por qué esta consulta está escrita así? Porque los alias permiten transformar nombres técnicos en nombres amigables para reportes.
-- Error común: olvidar el alias en columnas calculadas o usar alias con nombres ambiguos.
SELECT                                              -- Iniciamos la consulta seleccionando las columnas de interés.
  o_orderkey AS id_orden,                           -- Renombramos la llave de la orden para que el negocio la reconozca con rapidez.
  o_custkey AS id_cliente,                          -- Renombramos la llave del cliente para mantener consistencia semántica.
  o_orderstatus AS estado_orden,                    -- El alias convierte un nombre técnico en una etiqueta clara.
  o_totalprice AS valor_total_orden,                -- Hacemos explícito que el monto representa el total de la orden.
  o_orderdate AS fecha_orden                        -- Renombramos la fecha para lectura directa del reporte.
FROM samples.tpch.orders                            -- Consultamos la tabla de órdenes, fuente central del reporte gerencial.
LIMIT 10;                                           -- Mostramos solo 10 filas para validar estructura y formato.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Paso 2: Alias con `AS`
-- MAGIC
-- MAGIC Los alias ayudan cuando:
-- MAGIC
-- MAGIC - el nombre original es críptico,
-- MAGIC - quieres estandarizar vocabulario del negocio,
-- MAGIC - necesitas exportar resultados a usuarios no técnicos.
-- MAGIC
-- MAGIC > **📝 Nota:** Aunque `AS` es opcional en muchos motores, usarlo mejora legibilidad y reduce confusiones.

-- COMMAND ----------
-- Resultado esperado: una lista ordenada de estados de orden sin repetidos.
-- ¿Por qué esta consulta está escrita así? Porque DISTINCT elimina duplicados cuando solo importa el conjunto de valores posibles.
-- Error común: creer que DISTINCT elimina duplicados solo en una columna cuando en realidad evalúa la combinación completa seleccionada.
SELECT DISTINCT                           -- Pedimos valores únicos para evitar repeticiones en la salida.
  o_orderstatus                           -- Seleccionamos la columna de estado de la orden.
FROM samples.tpch.orders                  -- Leemos la información desde la tabla orders.
ORDER BY o_orderstatus ASC;               -- Ordenamos alfabéticamente para facilitar la lectura del catálogo de estados.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Paso 3: `DISTINCT`
-- MAGIC
-- MAGIC `DISTINCT` responde preguntas como:
-- MAGIC
-- MAGIC - ¿qué estados existen?
-- MAGIC - ¿qué segmentos de mercado aparecen?
-- MAGIC - ¿qué modos de pago están registrados?
-- MAGIC
-- MAGIC **Resultado esperado:** un pequeño catálogo de estados, normalmente con muy pocas filas.

-- COMMAND ----------
-- Resultado esperado: clientes del segmento AUTOMOBILE con saldo mayor a 5000.
-- ¿Por qué esta consulta está escrita así? Porque WHERE filtra filas antes de mostrar el resultado y concentra el análisis en casos relevantes.
-- Error común: escribir condiciones de texto sin comillas simples o usar operadores incompatibles con el tipo de dato.
SELECT                                            -- Indicamos que vamos a recuperar un subconjunto de columnas útiles.
  c_custkey AS id_cliente,                        -- Mostramos la llave del cliente con alias de negocio.
  c_name AS nombre_cliente,                       -- Mostramos el nombre del cliente para identificarlo.
  c_mktsegment AS segmento,                       -- Incluimos el segmento de mercado para validar el filtro aplicado.
  c_acctbal AS saldo_cuenta                       -- Incluimos el saldo para verificar que sí supere el umbral.
FROM samples.tpch.customer                        -- Leemos la tabla customer como fuente del análisis comercial.
WHERE c_mktsegment = 'AUTOMOBILE'                 -- Filtramos clientes cuyo segmento sea exactamente AUTOMOBILE.
  AND c_acctbal > 5000                            -- Exigimos además un saldo superior a 5000 para priorizar cuentas importantes.
ORDER BY c_acctbal DESC                           -- Ordenamos del mayor saldo al menor para ver primero los casos más relevantes.
LIMIT 10;                                         -- Limitamos la salida para revisión rápida.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Paso 4: `WHERE` y operadores de comparación
-- MAGIC
-- MAGIC Observa cómo cambia el significado con cada operador:
-- MAGIC
-- MAGIC | Operador | Significado | Ejemplo |
-- MAGIC |---|---|---|
-- MAGIC | `=` | Igual a | `c_mktsegment = 'AUTOMOBILE'` |
-- MAGIC | `!=` | Distinto de | `o_orderstatus != 'F'` |
-- MAGIC | `>` | Mayor que | `c_acctbal > 5000` |
-- MAGIC | `<=` | Menor o igual que | `o_totalprice <= 100000` |
-- MAGIC
-- MAGIC **Resultado esperado:** pocas filas, enfocadas en un criterio de negocio concreto.

-- COMMAND ----------
-- Resultado esperado: órdenes abiertas o pendientes de cartera en un rango de fechas y montos controlado.
-- ¿Por qué esta consulta está escrita así? Porque combina filtros de estado, fecha y monto usando AND, OR, NOT, BETWEEN e IN.
-- Error común: olvidar paréntesis cuando se mezclan AND y OR, cambiando la lógica del filtro.
SELECT                                                      -- Seleccionamos columnas suficientes para interpretar cada orden filtrada.
  o_orderkey AS id_orden,                                   -- Mostramos el identificador de la orden.
  o_orderstatus AS estado_orden,                            -- Incluimos el estado para validar la lógica del filtro.
  o_totalprice AS valor_total_orden,                        -- Incluimos el valor total para revisar el rango monetario.
  o_orderdate AS fecha_orden,                               -- Incluimos la fecha para validar el rango temporal.
  o_orderpriority AS prioridad                              -- Añadimos prioridad para enriquecer la inspección del resultado.
FROM samples.tpch.orders                                    -- Usamos la tabla orders porque la pregunta del negocio trata de órdenes.
WHERE o_orderdate BETWEEN DATE '1995-01-01' AND DATE '1995-12-31'  -- Restringimos a órdenes registradas durante 1995.
  AND o_orderstatus IN ('O', 'P', 'F')                      -- Limitamos a un conjunto explícito de estados permitidos.
  AND NOT o_totalprice < 100000                             -- Excluimos órdenes menores a 100000 usando NOT como negación lógica.
  AND (o_orderpriority = '1-URGENT' OR o_orderpriority = '2-HIGH')  -- Conservamos solo prioridades críticas o altas.
ORDER BY o_totalprice DESC                                  -- Ordenamos por valor para ver primero las órdenes más grandes.
LIMIT 15;                                                   -- Dejamos una muestra manejable para inspección.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Paso 5: `AND`, `OR`, `NOT`, `BETWEEN` e `IN`
-- MAGIC
-- MAGIC Estas expresiones son útiles cuando una pregunta del negocio tiene varias condiciones al mismo tiempo.
-- MAGIC
-- MAGIC **Lectura lógica de la consulta anterior:**
-- MAGIC
-- MAGIC 1. la orden debe ser de 1995,
-- MAGIC 2. el estado debe pertenecer a una lista válida,
-- MAGIC 3. el valor no puede ser bajo,
-- MAGIC 4. la prioridad debe ser urgente o alta.
-- MAGIC
-- MAGIC > **📝 Nota:** Siempre que mezcles `AND` y `OR`, usa paréntesis para dejar explícita la intención lógica.

-- COMMAND ----------
-- Resultado esperado: una lista ordenada de proveedores cuyo nombre sigue un patrón y que tienen comentario registrado.
-- ¿Por qué esta consulta está escrita así? Porque LIKE ayuda a detectar patrones de texto y IS NOT NULL verifica presencia de dato.
-- Error común: confundir % con _; % representa muchos caracteres y _ exactamente uno.
SELECT                                            -- Definimos las columnas que describen al proveedor en el resultado.
  s_suppkey AS id_proveedor,                      -- Mostramos la llave del proveedor con alias entendible.
  s_name AS nombre_proveedor,                     -- Mostramos el nombre para facilitar validación visual.
  s_phone AS telefono,                            -- Incluimos el teléfono como dato de contacto del catálogo.
  s_acctbal AS saldo_proveedor                    -- Incluimos el saldo para ordenar por relevancia financiera.
FROM samples.tpch.supplier                        -- Consultamos la tabla supplier del esquema TPCH.
WHERE s_name LIKE 'Supplier#00000_'               -- Filtramos nombres que comienzan igual y terminan con exactamente un carácter variable.
  AND s_comment IS NOT NULL                       -- Conservamos filas donde el comentario existe y no es nulo.
ORDER BY s_acctbal DESC                           -- Ordenamos de mayor a menor saldo para priorizar revisión.
LIMIT 10;                                         -- Mostramos diez filas para exploración controlada.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Paso 6: `LIKE`, `IS NULL`, `IS NOT NULL`, `ORDER BY` y `LIMIT`
-- MAGIC
-- MAGIC | Elemento | Idea clave | Ejemplo mental |
-- MAGIC |---|---|---|
-- MAGIC | `LIKE 'ABC%'` | Empieza por `ABC` | prefijos |
-- MAGIC | `LIKE '%ABC%'` | Contiene `ABC` | búsqueda parcial |
-- MAGIC | `LIKE 'A_C'` | Un solo carácter intermedio | patrón fijo |
-- MAGIC | `IS NULL` | Falta el dato | ausencia real |
-- MAGIC | `IS NOT NULL` | El dato sí existe | completitud |
-- MAGIC | `ORDER BY ... DESC` | De mayor a menor | top valores |
-- MAGIC | `LIMIT 10` | Solo una muestra | revisión rápida |
-- MAGIC
-- MAGIC **Error frecuente:** ordenar una columna distinta de la que el negocio quiere priorizar.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado
-- MAGIC
-- MAGIC A continuación verás **cinco ejemplos completos**. Cada uno incluye el motivo de negocio, la consulta comentada y la interpretación esperada.

-- COMMAND ----------
-- Ejemplo 1.
-- Pregunta de negocio: ¿qué campos básicos del cliente sirven para un primer directorio comercial?
-- Resultado esperado: una muestra corta de clientes con identificación, nombre, segmento y saldo.
-- Error común: seleccionar demasiadas columnas y dificultar la lectura del directorio.
SELECT                                      -- Seleccionamos únicamente las columnas esenciales para un directorio preliminar.
  c_custkey AS id_cliente,                  -- Llave única del cliente para referencia interna.
  c_name AS nombre_cliente,                 -- Nombre visible del cliente para el usuario final.
  c_mktsegment AS segmento_mercado,         -- Segmento comercial para clasificación de cartera.
  c_acctbal AS saldo_cuenta                 -- Saldo del cliente para priorización financiera.
FROM samples.tpch.customer                  -- La información proviene de la tabla customer.
ORDER BY c_custkey ASC                      -- Ordenamos por identificador para revisar registros en orden natural.
LIMIT 12;                                   -- Mostramos solo doce filas para mantener el ejemplo simple.

-- COMMAND ----------
-- Ejemplo 2.
-- Pregunta de negocio: ¿cómo hacer que una consulta de órdenes sea legible para un gerente no técnico?
-- Resultado esperado: columnas con alias claros y un conjunto de órdenes recientes en el orden cronológico de la tabla.
-- Error común: dejar nombres técnicos sin traducir al lenguaje del negocio.
SELECT                                               -- Iniciamos la selección de columnas que aparecerán en el reporte.
  o_orderkey AS id_orden,                            -- Alias amigable para la llave de la orden.
  o_custkey AS id_cliente,                           -- Alias consistente para la llave del cliente asociada.
  o_orderstatus AS estado,                           -- Alias corto que simplifica la lectura ejecutiva.
  o_totalprice AS total_orden,                       -- Alias que deja claro que el importe es el total de la orden.
  o_orderdate AS fecha_orden                         -- Alias orientado a negocio para la fecha.
FROM samples.tpch.orders                             -- Tomamos los datos desde la tabla orders.
ORDER BY o_orderdate DESC                            -- Ordenamos de la fecha más reciente a la más antigua.
LIMIT 10;                                            -- Dejamos un conjunto pequeño para validación manual.

-- COMMAND ----------
-- Ejemplo 3.
-- Pregunta de negocio: ¿qué segmentos de mercado existen sin repetir valores?
-- Resultado esperado: un listado pequeño de segmentos únicos.
-- Error común: olvidar DISTINCT y obtener muchas filas repetidas que no aportan información nueva.
SELECT DISTINCT                           -- Solicitamos valores únicos en la salida.
  c_mktsegment AS segmento_mercado        -- Seleccionamos la columna de segmento con alias descriptivo.
FROM samples.tpch.customer                -- Leemos la tabla de clientes.
ORDER BY segmento_mercado ASC;            -- Ordenamos alfabéticamente los segmentos para visualizarlos mejor.

-- COMMAND ----------
-- Ejemplo 4.
-- Pregunta de negocio: ¿qué órdenes cerradas superan un valor importante para el reporte comercial?
-- Resultado esperado: órdenes con estado F y monto mayor a 200000.
-- Error común: comparar texto con números o no usar comillas en el estado de la orden.
SELECT                                              -- Iniciamos la consulta de órdenes relevantes.
  o_orderkey AS id_orden,                           -- Mostramos la identificación de la orden.
  o_orderstatus AS estado_orden,                    -- Mostramos el estado para confirmar que sea cerrada.
  o_totalprice AS valor_total,                      -- Mostramos el valor monetario para validar el filtro.
  o_orderpriority AS prioridad                      -- Incluimos la prioridad para enriquecer el análisis.
FROM samples.tpch.orders                            -- Tomamos los registros desde la tabla orders.
WHERE o_orderstatus = 'F'                           -- Filtramos órdenes cerradas.
  AND o_totalprice > 200000                         -- Conservamos solo las que superan el umbral de valor.
ORDER BY o_totalprice DESC                          -- Ordenamos para ver primero las de mayor monto.
LIMIT 15;                                           -- Recortamos la salida para revisión rápida.

-- COMMAND ----------
-- Ejemplo 5.
-- Pregunta de negocio: ¿qué proveedores muestran un patrón de código y tienen saldo alto?
-- Resultado esperado: proveedores cuyo nombre sigue el patrón indicado y ordenados por saldo descendente.
-- Error común: usar % cuando se desea exactamente un carácter variable; para eso se usa _.
SELECT                                            -- Seleccionamos datos necesarios del catálogo de proveedores.
  s_suppkey AS id_proveedor,                      -- Mostramos el identificador único del proveedor.
  s_name AS nombre_proveedor,                     -- Mostramos el nombre para comprobar el patrón LIKE.
  s_nationkey AS id_nacion,                       -- Incluimos la nación del proveedor para contexto posterior.
  s_acctbal AS saldo_proveedor                    -- Incluimos el saldo para priorizar la lista.
FROM samples.tpch.supplier                        -- Consultamos la tabla supplier.
WHERE s_name LIKE 'Supplier#00000_'               -- Exigimos el prefijo fijo y un solo carácter final variable.
  AND s_acctbal >= 9000                           -- Restringimos a proveedores con saldo alto.
ORDER BY s_acctbal DESC                           -- Ordenamos del saldo mayor al menor.
LIMIT 10;                                         -- Mostramos diez filas para una inspección ejecutiva.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado
-- MAGIC
-- MAGIC En los siguientes cinco casos ya conoces la intención de negocio y la estructura general. La idea es que leas la explicación, ejecutes la consulta y luego modifiques el filtro por tu cuenta.

-- COMMAND ----------
-- Ejemplo guiado 1.
-- Meta de negocio: identificar clientes del segmento BUILDING con saldo positivo para una campaña enfocada.
-- Resultado esperado: clientes BUILDING ordenados por saldo descendente.
-- Error común: olvidar que los textos deben ir entre comillas simples.
SELECT                                            -- Seleccionamos columnas útiles para la campaña comercial.
  c_custkey AS id_cliente,                        -- Identificador único del cliente.
  c_name AS nombre_cliente,                       -- Nombre del cliente para interpretación directa.
  c_mktsegment AS segmento,                       -- Segmento comercial para validar el filtro.
  c_acctbal AS saldo_cuenta                       -- Saldo que se usará para priorización.
FROM samples.tpch.customer                        -- Fuente de datos: tabla customer.
WHERE c_mktsegment = 'BUILDING'                   -- Mantenemos solo clientes del segmento BUILDING.
  AND c_acctbal > 0                               -- Pedimos saldo positivo para enfoque comercial saludable.
ORDER BY c_acctbal DESC                           -- Ordenamos del saldo más alto al más bajo.
LIMIT 15;                                         -- Dejamos quince filas para revisión inicial.

-- COMMAND ----------
-- Ejemplo guiado 2.
-- Meta de negocio: revisar órdenes emitidas en 1994 para una auditoría histórica sencilla.
-- Resultado esperado: órdenes de 1994 con columnas clave y orden cronológico descendente.
-- Error común: usar fechas como texto libre sin el literal DATE.
SELECT                                                      -- Elegimos columnas suficientes para identificar la orden y su valor.
  o_orderkey AS id_orden,                                   -- Identificador de la orden.
  o_custkey AS id_cliente,                                  -- Cliente asociado a la orden.
  o_orderdate AS fecha_orden,                               -- Fecha usada en el filtro temporal.
  o_totalprice AS valor_total_orden                         -- Importe total que se inspeccionará.
FROM samples.tpch.orders                                    -- Fuente: tabla orders.
WHERE o_orderdate BETWEEN DATE '1994-01-01' AND DATE '1994-12-31'  -- Restringimos el análisis al año 1994.
ORDER BY o_orderdate DESC                                   -- Vemos primero las órdenes más recientes dentro del rango.
LIMIT 15;                                                   -- Mostramos una muestra pequeña y controlada.

-- COMMAND ----------
-- Ejemplo guiado 3.
-- Meta de negocio: inspeccionar órdenes con estados específicos y valores medios-altos.
-- Resultado esperado: órdenes con estado O o P y total entre 100000 y 250000.
-- Error común: intentar usar BETWEEN con el límite superior antes del inferior.
SELECT                                             -- Seleccionamos los campos necesarios para validar el filtro compuesto.
  o_orderkey AS id_orden,                          -- Identificador único de la orden.
  o_orderstatus AS estado_orden,                   -- Estado incluido para comprobar la lista IN.
  o_totalprice AS total_orden,                     -- Valor total incluido para revisar el rango.
  o_orderpriority AS prioridad                     -- Prioridad de la orden para más contexto analítico.
FROM samples.tpch.orders                           -- Leemos la tabla orders.
WHERE o_orderstatus IN ('O', 'P')                  -- Conservamos órdenes con estados abiertos o pendientes.
  AND o_totalprice BETWEEN 100000 AND 250000       -- Exigimos que el total esté dentro del rango indicado.
ORDER BY o_totalprice DESC                         -- Ordenamos por monto descendente.
LIMIT 15;                                          -- Limitamos para inspección rápida.

-- COMMAND ----------
-- Ejemplo guiado 4.
-- Meta de negocio: encontrar clientes cuyo nombre siga un patrón conocido por el gerente.
-- Resultado esperado: clientes cuyo nombre comience con Customer#0001.
-- Error común: olvidar que % representa cualquier cantidad de caracteres, incluso cero.
SELECT                                           -- Elegimos columnas mínimas para validar coincidencias del patrón.
  c_custkey AS id_cliente,                       -- Identificador del cliente.
  c_name AS nombre_cliente,                      -- Nombre usado en la búsqueda LIKE.
  c_phone AS telefono                            -- Teléfono como dato adicional de contacto.
FROM samples.tpch.customer                       -- Fuente: tabla customer.
WHERE c_name LIKE 'Customer#0001%'               -- Buscamos nombres que empiecen con ese prefijo.
ORDER BY c_name ASC                              -- Ordenamos alfabéticamente para leer el grupo resultante.
LIMIT 20;                                        -- Mostramos veinte coincidencias como máximo.

-- COMMAND ----------
-- Ejemplo guiado 5.
-- Meta de negocio: revisar piezas de bajo precio y contenedores específicos para compras rápidas.
-- Resultado esperado: piezas de cierto conjunto de contenedores con precio pequeño.
-- Error común: usar OR repetido en vez de IN, haciendo la consulta más larga y más propensa a fallas.
SELECT                                      -- Seleccionamos columnas clave del catálogo de partes.
  p_partkey AS id_parte,                    -- Identificador de la parte.
  p_name AS nombre_parte,                   -- Nombre descriptivo de la parte.
  p_mfgr AS fabricante,                     -- Fabricante para contexto de abastecimiento.
  p_container AS contenedor,                -- Tipo de contenedor usado en el filtro.
  p_retailprice AS precio_lista             -- Precio de lista para revisión de costo.
FROM samples.tpch.part                      -- Fuente: catálogo de partes.
WHERE p_container IN ('SM CASE', 'SM BOX')  -- Filtramos partes de dos contenedores pequeños específicos.
  AND p_retailprice <= 1000                 -- Conservamos solo precios bajos o moderados.
ORDER BY p_retailprice ASC                  -- Ordenamos del precio menor al mayor.
LIMIT 15;                                   -- Mostramos una muestra compacta.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado
-- MAGIC
-- MAGIC **Instrucción:** intenta resolver cada reto antes de mirar el resultado. Luego compara tu versión con la solución propuesta.
-- MAGIC
-- MAGIC | Nivel | Reto |
-- MAGIC |---|---|
-- MAGIC | Muy Fácil | Mostrar 10 naciones con alias legibles |
-- MAGIC | Fácil | Listar regiones únicas ordenadas |
-- MAGIC | Intermedio | Filtrar clientes de dos segmentos |
-- MAGIC | Intermedio Alto | Buscar órdenes no cerradas y de precio alto |
-- MAGIC | Desafío | Detectar filas con valor nulo en una columna derivada |

-- COMMAND ----------
-- Solución guiada 1.
-- Resultado esperado: diez naciones con clave, nombre y región.
-- Error común: olvidar el FROM o escribir mal el nombre completo de la tabla.
SELECT                                 -- Seleccionamos columnas básicas del catálogo de naciones.
  n_nationkey AS id_nacion,            -- Identificador de la nación.
  n_name AS nombre_nacion,             -- Nombre de la nación.
  n_regionkey AS id_region             -- Región a la que pertenece la nación.
FROM samples.tpch.nation               -- Fuente: tabla nation del catálogo TPCH.
ORDER BY n_name ASC                    -- Ordenamos alfabéticamente por nombre.
LIMIT 10;                              -- Dejamos solo diez filas para revisión.

-- COMMAND ----------
-- Solución guiada 2.
-- Resultado esperado: listado único de nombres de región.
-- Error común: usar DISTINCT en varias columnas cuando solo quieres un catálogo simple.
SELECT DISTINCT                        -- Solicitamos valores únicos.
  r_name AS nombre_region              -- Seleccionamos el nombre de la región con alias claro.
FROM samples.tpch.region               -- Fuente: tabla region.
ORDER BY nombre_region ASC;            -- Ordenamos alfabéticamente el catálogo resultante.

-- COMMAND ----------
-- Solución guiada 3.
-- Resultado esperado: clientes de los segmentos AUTOMOBILE y HOUSEHOLD.
-- Error común: mezclar AND y OR sin pensar en la lógica del filtro.
SELECT                                                -- Seleccionamos columnas comerciales relevantes.
  c_custkey AS id_cliente,                            -- Identificador del cliente.
  c_name AS nombre_cliente,                           -- Nombre para revisión manual.
  c_mktsegment AS segmento,                           -- Segmento usado como criterio principal.
  c_acctbal AS saldo                                  -- Saldo para enriquecer la salida.
FROM samples.tpch.customer                            -- Fuente: tabla customer.
WHERE c_mktsegment IN ('AUTOMOBILE', 'HOUSEHOLD')     -- Filtramos clientes que pertenecen a cualquiera de los dos segmentos.
ORDER BY c_mktsegment ASC, c_acctbal DESC             -- Ordenamos primero por segmento y luego por saldo descendente.
LIMIT 20;                                             -- Recortamos la salida para lectura cómoda.

-- COMMAND ----------
-- Solución guiada 4.
-- Resultado esperado: órdenes que no estén cerradas y cuyo valor sea alto.
-- Error común: usar != sin considerar el resto de filtros necesarios para aislar los casos de interés.
SELECT                                          -- Seleccionamos los campos clave de la orden.
  o_orderkey AS id_orden,                       -- Identificador de la orden.
  o_orderstatus AS estado_orden,                -- Estado para comprobar la negación.
  o_totalprice AS valor_total,                  -- Valor total que debe ser alto.
  o_orderdate AS fecha_orden                    -- Fecha útil para contexto del caso.
FROM samples.tpch.orders                        -- Fuente: tabla orders.
WHERE o_orderstatus != 'F'                      -- Excluimos las órdenes cerradas.
  AND o_totalprice >= 250000                    -- Conservamos órdenes de valor alto.
ORDER BY o_totalprice DESC                      -- Ordenamos por valor descendente.
LIMIT 20;                                       -- Mostramos una cantidad controlada de filas.

-- COMMAND ----------
-- Solución guiada 5.
-- Resultado esperado: filas donde el teléfono derivado queda nulo porque el saldo es negativo.
-- ¿Por qué sirve? Porque permite practicar IS NULL aunque la tabla original tenga pocos nulos en columnas visibles.
-- Error común: intentar filtrar nulos con = NULL en lugar de IS NULL.
SELECT                                                        -- Seleccionamos columnas de cliente junto con una columna derivada.
  c_custkey AS id_cliente,                                    -- Identificador del cliente.
  c_name AS nombre_cliente,                                   -- Nombre para interpretar la fila.
  c_acctbal AS saldo_cuenta,                                  -- Saldo usado para construir la lógica del nulo.
  CASE                                                        -- Creamos una columna derivada para practicar valores nulos.
    WHEN c_acctbal >= 0 THEN c_phone                          -- Si el saldo es no negativo, conservamos el teléfono.
    ELSE NULL                                                 -- Si el saldo es negativo, devolvemos NULL explícitamente.
  END AS telefono_reporte                                     -- Asignamos un alias claro a la columna derivada.
FROM samples.tpch.customer                                    -- Fuente: tabla customer.
WHERE CASE                                                    -- Repetimos la lógica derivada para filtrar adecuadamente.
    WHEN c_acctbal >= 0 THEN c_phone                          -- Si el saldo es no negativo, el valor será el teléfono original.
    ELSE NULL                                                 -- Si el saldo es negativo, el valor será NULL.
  END IS NULL                                                 -- Conservamos solo las filas donde la expresión termina siendo NULL.
LIMIT 15;                                                     -- Mostramos quince casos para validación.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Ejercicio individual
-- MAGIC
-- MAGIC Resuelve estos retos **sin ver ayuda adicional**. El nivel progresa de **Muy Fácil** a **Desafío**.
-- MAGIC
-- MAGIC | Nivel | Ejercicio | Pista |
-- MAGIC |---|---|---|
-- MAGIC | Muy Fácil | Mostrar 8 clientes con `SELECT` explícito y `LIMIT` | Evita `SELECT *` |
-- MAGIC | Fácil | Obtener estados únicos de órdenes con `DISTINCT` | Usa `ORDER BY` |
-- MAGIC | Intermedio | Filtrar partes con precio entre 900 y 1100 | Usa `BETWEEN` |
-- MAGIC | Intermedio Alto | Buscar proveedores con saldo distinto de 0 y nombre tipo `Supplier#00001%` | Combina `!=` y `LIKE` |
-- MAGIC | Desafío | Mostrar órdenes de 1996, prioridad alta y estado en una lista específica | Mezcla `BETWEEN`, `IN` y `AND` |
-- MAGIC
-- MAGIC > **📝 Nota:** Antes de ejecutar, intenta escribir la consulta en papel identificando `SELECT`, `FROM`, `WHERE`, `ORDER BY` y `LIMIT`.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Desafío
-- MAGIC
-- MAGIC Ahora piensa como analista de negocio. Cada reto exige que decidas **qué columna ver**, **cómo filtrar** y **cómo presentar** el resultado.
-- MAGIC
-- MAGIC | Nivel | Desafío analítico |
-- MAGIC |---|---|
-- MAGIC | Muy Fácil | Listar regiones en orden descendente |
-- MAGIC | Fácil | Encontrar clientes cuyo nombre contenga `009` |
-- MAGIC | Intermedio | Mostrar órdenes con total menor a 75000 y estado distinto de `F` |
-- MAGIC | Intermedio Alto | Encontrar proveedores con saldo entre 5000 y 8000 y comentario no nulo |
-- MAGIC | Desafío | Diseñar una consulta que muestre piezas de ciertos tamaños y precios, ordenadas por fabricante y precio |
-- MAGIC
-- MAGIC **Criterios de éxito:**
-- MAGIC
-- MAGIC 1. columnas pertinentes,
-- MAGIC 2. filtros correctos,
-- MAGIC 3. alias claros,
-- MAGIC 4. orden lógico,
-- MAGIC 5. salida legible.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Resumen
-- MAGIC
-- MAGIC Hoy consolidaste la base operativa de cualquier analista SQL:
-- MAGIC
-- MAGIC - `SELECT` para elegir columnas,
-- MAGIC - `FROM` para indicar la tabla,
-- MAGIC - `WHERE` para filtrar,
-- MAGIC - `AS` para comunicar mejor,
-- MAGIC - `DISTINCT` para eliminar repetición,
-- MAGIC - operadores de comparación y lógicos para traducir reglas de negocio,
-- MAGIC - `ORDER BY` y `LIMIT` para presentar resultados útiles.
-- MAGIC
-- MAGIC ### Regla de oro
-- MAGIC
-- MAGIC ```text
-- MAGIC Primero claridad,
-- MAGIC luego precisión,
-- MAGIC luego velocidad.
-- MAGIC ```
-- MAGIC
-- MAGIC Si una consulta no es clara, será difícil confiar en el análisis posterior.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Laboratorio
-- MAGIC
-- MAGIC **Escenario:** tu gerente necesita respuestas rápidas para un reporte ejecutivo de media mañana. Debes responder con consultas simples, legibles y listas para exportar.
-- MAGIC
-- MAGIC **Preguntas reales de negocio:**
-- MAGIC
-- MAGIC 1. ¿Qué clientes del segmento `MACHINERY` tienen mayor saldo?
-- MAGIC 2. ¿Qué órdenes abiertas o pendientes superan 300000?
-- MAGIC 3. ¿Qué líneas de pedido tienen descuentos entre 0.05 y 0.07?
-- MAGIC 4. ¿Qué partes del fabricante `Manufacturer#1` tienen precio de lista bajo?
-- MAGIC 5. ¿Qué proveedores tienen saldo alto y teléfono registrado?

-- COMMAND ----------
-- Laboratorio 1.
-- Respuesta esperada: clientes MACHINERY ordenados por saldo descendente.
-- Error común: no incluir ORDER BY y perder la priorización que necesita el gerente.
SELECT                                           -- Seleccionamos datos comerciales relevantes del cliente.
  c_custkey AS id_cliente,                       -- Identificador del cliente.
  c_name AS nombre_cliente,                      -- Nombre del cliente.
  c_mktsegment AS segmento,                      -- Segmento de mercado para validar el filtro.
  c_acctbal AS saldo_cuenta                      -- Saldo que el gerente quiere priorizar.
FROM samples.tpch.customer                       -- Fuente: tabla customer.
WHERE c_mktsegment = 'MACHINERY'                 -- Conservamos únicamente clientes del segmento MACHINERY.
ORDER BY c_acctbal DESC                          -- Ordenamos por saldo de mayor a menor.
LIMIT 20;                                        -- Entregamos veinte filas para el reporte ejecutivo.

-- COMMAND ----------
-- Laboratorio 2.
-- Respuesta esperada: órdenes de gran valor cuyo estado esté abierto o pendiente.
-- Error común: confundir el operador IN con múltiples condiciones mal parentizadas.
SELECT                                              -- Seleccionamos campos clave para el reporte de órdenes.
  o_orderkey AS id_orden,                           -- Identificador de la orden.
  o_custkey AS id_cliente,                          -- Cliente asociado.
  o_orderstatus AS estado_orden,                    -- Estado necesario para el filtro de negocio.
  o_totalprice AS valor_total_orden                 -- Valor total para priorización.
FROM samples.tpch.orders                            -- Fuente: tabla orders.
WHERE o_orderstatus IN ('O', 'P')                   -- Conservamos órdenes abiertas o pendientes.
  AND o_totalprice > 300000                         -- Restringimos a órdenes de alto valor.
ORDER BY o_totalprice DESC                          -- Ordenamos por valor descendente.
LIMIT 20;                                           -- Devolvemos veinte filas como máximo.

-- COMMAND ----------
-- Laboratorio 3.
-- Respuesta esperada: líneas de pedido con descuento dentro del rango solicitado.
-- Error común: olvidar que BETWEEN incluye ambos extremos del rango.
SELECT                                           -- Seleccionamos columnas necesarias de cada línea de pedido.
  l_orderkey AS id_orden,                        -- Identificador de la orden relacionada.
  l_partkey AS id_parte,                         -- Parte incluida en la línea.
  l_quantity AS cantidad,                        -- Cantidad pedida.
  l_discount AS descuento,                       -- Descuento usado como criterio principal.
  l_shipdate AS fecha_envio                      -- Fecha de envío para contexto operativo.
FROM samples.tpch.lineitem                       -- Fuente: tabla lineitem.
WHERE l_discount BETWEEN 0.05 AND 0.07           -- Filtramos descuentos dentro del rango requerido.
ORDER BY l_discount DESC, l_quantity DESC        -- Ordenamos primero por descuento y luego por cantidad.
LIMIT 20;                                        -- Mostramos veinte casos para revisión.

-- COMMAND ----------
-- Laboratorio 4.
-- Respuesta esperada: partes del fabricante 1 con precio de lista relativamente bajo.
-- Error común: no usar alias y dificultar la lectura del catálogo exportado.
SELECT                                                -- Seleccionamos columnas del catálogo de partes.
  p_partkey AS id_parte,                              -- Identificador de la parte.
  p_name AS nombre_parte,                             -- Nombre descriptivo de la parte.
  p_mfgr AS fabricante,                               -- Fabricante usado como criterio de filtro.
  p_brand AS marca,                                   -- Marca para enriquecer la interpretación.
  p_retailprice AS precio_lista                       -- Precio de lista que se comparará contra el umbral.
FROM samples.tpch.part                                -- Fuente: tabla part.
WHERE p_mfgr = 'Manufacturer#1'                       -- Conservamos partes del fabricante solicitado.
  AND p_retailprice < 950                             -- Restringimos a precios bajos para compras rápidas.
ORDER BY p_retailprice ASC                            -- Ordenamos del precio menor al mayor.
LIMIT 20;                                             -- Entregamos una muestra corta al gerente.

-- COMMAND ----------
-- Laboratorio 5.
-- Respuesta esperada: proveedores con saldo alto, teléfono disponible y comentario no nulo.
-- Error común: filtrar nulos con = NULL en lugar de IS NOT NULL.
SELECT                                            -- Seleccionamos columnas del catálogo de proveedores.
  s_suppkey AS id_proveedor,                      -- Identificador del proveedor.
  s_name AS nombre_proveedor,                     -- Nombre del proveedor.
  s_phone AS telefono,                            -- Teléfono requerido por el negocio.
  s_acctbal AS saldo_proveedor                    -- Saldo para priorización.
FROM samples.tpch.supplier                        -- Fuente: tabla supplier.
WHERE s_acctbal >= 8000                           -- Conservamos proveedores con saldo alto.
  AND s_phone IS NOT NULL                         -- Exigimos que exista teléfono registrado.
  AND s_comment IS NOT NULL                       -- Exigimos además comentario disponible.
ORDER BY s_acctbal DESC                           -- Ordenamos del mayor saldo al menor.
LIMIT 20;                                         -- Mostramos veinte filas como máximo.

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 14. Autoevaluación
-- MAGIC
-- MAGIC Responde sin ejecutar código. Si dudas, vuelve a la sección correspondiente.
-- MAGIC
-- MAGIC 1. ¿Cuándo conviene evitar `SELECT *`?
-- MAGIC 2. ¿Qué ventaja aporta `AS` en un reporte ejecutivo?
-- MAGIC 3. ¿Qué diferencia hay entre `DISTINCT columna` y `DISTINCT columna1, columna2`?
-- MAGIC 4. ¿Qué operador usarías para excluir un estado: `=` o `!=`?
-- MAGIC 5. ¿Cuándo usarías `AND` y cuándo `OR`?
-- MAGIC 6. ¿Qué ventaja tiene `IN (...)` frente a múltiples comparaciones con `OR`?
-- MAGIC 7. ¿Qué diferencia existe entre `LIKE 'AB%'` y `LIKE 'AB_'`?
-- MAGIC 8. ¿Por qué `columna = NULL` no es correcto en SQL?
-- MAGIC 9. ¿Qué efecto tiene `ORDER BY ... DESC` en la interpretación del resultado?
-- MAGIC 10. ¿Para qué sirve `LIMIT` durante la exploración inicial?
-- MAGIC
-- MAGIC > **📝 Nota:** Si puedes explicar en voz alta la lógica de una consulta simple, entonces ya estás avanzando de “escribir SQL” a “pensar analíticamente con SQL”.
