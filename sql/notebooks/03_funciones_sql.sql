-- Databricks notebook source
-- COMMAND ----------
-- MAGIC %md
-- MAGIC # Notebook 03: Funciones SQL
-- MAGIC ## 1. Bienvenida
-- MAGIC
-- MAGIC Bienvenidos al tercer notebook del curso **SQL para Ciencia de Datos usando Databricks**.
-- MAGIC
-- MAGIC En esta sesión trabajarás como **Data Analyst en DataCorp Analytics**. Tu gerente necesita un **reporte de calidad de datos** con texto limpio, fechas interpretables, métricas numéricas normalizadas y reglas condicionales claras para priorizar clientes, órdenes y proveedores.
-- MAGIC
-- MAGIC A lo largo del notebook usarás funciones SQL para transformar datos reales de tablas de ejemplo de Databricks. El objetivo no es solo “hacer que la consulta funcione”, sino entender **por qué** cada función resuelve un problema analítico concreto.
-- MAGIC
-- MAGIC > **📝 Nota:** Este notebook está diseñado para ejecutarse directamente en Databricks SQL o en un notebook con celdas SQL.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 2. Objetivos de aprendizaje
-- MAGIC
-- MAGIC Al finalizar este notebook podrás:
-- MAGIC
-- MAGIC 1. Aplicar funciones de texto para limpiar, estandarizar y combinar atributos.
-- MAGIC 2. Usar funciones numéricas para redondear, comparar y transformar métricas.
-- MAGIC 3. Trabajar con fechas y marcas de tiempo para calcular antigüedad, periodos y calendarios operativos.
-- MAGIC 4. Construir reglas de negocio con funciones condicionales como `CASE`, `IF`, `IIF`, `COALESCE` y `NULLIF`.
-- MAGIC 5. Convertir tipos de datos de forma segura con `CAST` y `TRY_CAST`.
-- MAGIC 6. Integrar múltiples funciones en consultas orientadas a calidad de datos y reporting ejecutivo.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 3. Competencias
-- MAGIC
-- MAGIC ### Competencias técnicas
-- MAGIC - Limpieza y perfilamiento de datos con SQL.
-- MAGIC - Transformación de variables para análisis descriptivo.
-- MAGIC - Preparación de insumos para dashboards y reportes.
-- MAGIC
-- MAGIC ### Competencias analíticas
-- MAGIC - Traducir requerimientos del negocio a transformaciones reproducibles.
-- MAGIC - Elegir la función adecuada según el tipo de dato y el objetivo analítico.
-- MAGIC - Detectar errores comunes de formato, valores nulos y conversiones inseguras.
-- MAGIC
-- MAGIC ### Competencias profesionales
-- MAGIC - Documentar consultas de manera clara.
-- MAGIC - Comunicar supuestos y resultados esperados.
-- MAGIC - Construir soluciones mantenibles para equipos de datos.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 4. Contexto empresarial
-- MAGIC
-- MAGIC **DataCorp Analytics** centraliza información comercial usando tablas de clientes, órdenes, ítems de venta, partes y proveedores.
-- MAGIC
-- MAGIC El gerente del área ha detectado cuatro necesidades:
-- MAGIC
-- MAGIC 1. Los nombres y segmentos aparecen con formatos inconsistentes en varios reportes.
-- MAGIC 2. Las fechas deben convertirse en indicadores operativos: antigüedad, semana del año y ventanas de seguimiento.
-- MAGIC 3. Las métricas monetarias requieren redondeos y validaciones para evitar errores de interpretación.
-- MAGIC 4. El equipo necesita clasificaciones automáticas para priorizar cuentas, productos y pedidos.
-- MAGIC
-- MAGIC En este notebook desarrollarás el tipo de transformaciones que normalmente anteceden a un dashboard o a una tabla analítica curada.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 5. Conceptos
-- MAGIC
-- MAGIC ### 5.1 Funciones de texto
-- MAGIC
-- MAGIC | Función | Uso principal | Ejemplo conceptual |
-- MAGIC |---|---|---|
-- MAGIC | `UPPER`, `LOWER`, `INITCAP` | Estandarizar capitalización | convertir nombres a mayúsculas o formato título |
-- MAGIC | `LENGTH` | Medir longitud | revisar calidad de campos cortos o vacíos |
-- MAGIC | `TRIM`, `LTRIM`, `RTRIM` | Limpiar espacios | corregir texto con espacios no deseados |
-- MAGIC | `SUBSTRING`, `LEFT`, `RIGHT` | Extraer fragmentos | separar prefijos, códigos o sufijos |
-- MAGIC | `REPLACE` | Sustituir caracteres | quitar guiones o símbolos |
-- MAGIC | `CONCAT`, `CONCAT_WS` | Unir campos | crear etiquetas o llaves legibles |
-- MAGIC | `LPAD`, `RPAD` | Rellenar cadenas | uniformar códigos visuales |
-- MAGIC | `SPLIT` | Separar texto en partes | descomponer teléfonos o identificadores |
-- MAGIC
-- MAGIC ### 5.2 Funciones numéricas
-- MAGIC
-- MAGIC | Función | Uso principal | Aplicación analítica |
-- MAGIC |---|---|---|
-- MAGIC | `ROUND` | Redondear decimales | reportes financieros |
-- MAGIC | `CEIL`, `FLOOR` | Aproximar arriba o abajo | umbrales operativos |
-- MAGIC | `ABS` | Distancia absoluta | comparar desviaciones |
-- MAGIC | `MOD` | Residuo de división | segmentaciones técnicas |
-- MAGIC | `POWER`, `SQRT` | Transformaciones matemáticas | escalamiento y exploración |
-- MAGIC | `GREATEST`, `LEAST` | Comparar múltiples valores | topes, mínimos y máximos |
-- MAGIC
-- MAGIC ### 5.3 Funciones de fecha y hora
-- MAGIC
-- MAGIC | Función | Uso principal | Aplicación |
-- MAGIC |---|---|---|
-- MAGIC | `CURRENT_DATE`, `CURRENT_TIMESTAMP` | Referencia actual | auditoría y recencia |
-- MAGIC | `DATE_FORMAT` | Formatear fecha | periodos para reportes |
-- MAGIC | `YEAR`, `MONTH`, `DAY` | Descomponer fecha | agregaciones temporales |
-- MAGIC | `DATEDIFF` | Diferencia entre fechas | antigüedad |
-- MAGIC | `DATE_ADD`, `DATE_SUB` | Sumar o restar días | ventanas de seguimiento |
-- MAGIC | `TO_DATE`, `TO_TIMESTAMP` | Conversión explícita | limpieza y compatibilidad |
-- MAGIC | `DAYOFWEEK`, `DAYOFYEAR`, `WEEKOFYEAR` | Calendario operativo | análisis por calendario |
-- MAGIC
-- MAGIC ### 5.4 Funciones condicionales y conversión de tipos
-- MAGIC
-- MAGIC | Función | Cuándo usarla | Riesgo que evita |
-- MAGIC |---|---|---|
-- MAGIC | `CASE WHEN ... THEN ... ELSE ... END` | lógica compleja | clasificaciones difíciles de leer |
-- MAGIC | `IF`, `IIF` | lógica binaria corta | expresiones innecesariamente largas |
-- MAGIC | `IFNULL`, `NVL`, `COALESCE` | sustituir nulos | propagación de `NULL` |
-- MAGIC | `NULLIF` | convertir coincidencia en `NULL` | valores centinela poco útiles |
-- MAGIC | `CAST`, `TRY_CAST` | convertir tipos | errores por tipos incompatibles |
-- MAGIC
-- MAGIC > **📝 Nota:** `TRY_CAST` es preferible cuando una cadena podría tener valores inválidos. En vez de fallar, devuelve `NULL` y permite seguir analizando.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 6. Explicación paso a paso
-- MAGIC
-- MAGIC ### Cómo pensar una transformación SQL
-- MAGIC
-- MAGIC 1. **Identifica el problema de negocio.** Ejemplo: nombres inconsistentes o fechas sin contexto.
-- MAGIC 2. **Reconoce el tipo de dato.** Texto, número, fecha o dato mixto.
-- MAGIC 3. **Elige la función mínima suficiente.** No uses una expresión compleja si una función simple resuelve el problema.
-- MAGIC 4. **Da nombre semántico al resultado.** El alias debe explicar el propósito del campo transformado.
-- MAGIC 5. **Valida el resultado esperado.** Compara el dato original con el transformado.
-- MAGIC 6. **Piensa en errores comunes.** Nulos, formatos inesperados, truncamientos o conversiones inválidas.
-- MAGIC
-- MAGIC ### Patrón recomendado en este notebook
-- MAGIC
-- MAGIC - Mostrar el valor original.
-- MAGIC - Mostrar la transformación.
-- MAGIC - Añadir una lectura de negocio del resultado.
-- MAGIC - Trabajar con muestras pequeñas (`LIMIT`) mientras aprendes.
-- MAGIC
-- MAGIC > **📝 Nota:** En producción normalmente complementarías estas consultas con `WHERE`, validaciones de calidad y persistencia en tablas curadas.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 1 de 5
-- MAGIC ### Limpieza y estandarización básica de texto
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** primero mostramos el valor original y luego varias transformaciones derivadas para comparar visualmente antes y después.
-- MAGIC
-- MAGIC **Qué hace cada cláusula:**
-- MAGIC - `SELECT` proyecta columnas originales y transformadas.
-- MAGIC - `FROM` toma la tabla de clientes.
-- MAGIC - `LIMIT` reduce el volumen para aprendizaje y validación rápida.
-- MAGIC
-- MAGIC **Resultado esperado:** nombres normalizados en mayúsculas, minúsculas, formato título y sin espacios accidentales.
-- MAGIC
-- MAGIC **Errores comunes:** olvidar alias, aplicar `TRIM` a columnas nulas sin considerar el contexto del negocio, o perder la columna original para comparar.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave del cliente para rastrear el registro original.
  c_custkey,
  -- Mostramos el nombre tal como viene en la fuente para comparar antes y después.
  c_name AS nombre_original,
  -- Convertimos el nombre completo a mayúsculas para estandarizar reportes ejecutivos.
  UPPER(c_name) AS nombre_en_mayusculas,
  -- Convertimos el nombre completo a minúsculas para preparar procesos de comparación textual.
  LOWER(c_name) AS nombre_en_minusculas,
  -- Medimos la longitud del nombre para detectar valores anómalos o demasiado cortos.
  LENGTH(c_name) AS longitud_nombre,
  -- Agregamos espacios artificiales y luego usamos TRIM para demostrar cómo limpiar bordes.
  TRIM(CONCAT('  ', c_name, '  ')) AS nombre_sin_espacios_externos,
  -- Formateamos el segmento a estilo título para hacerlo más legible en una interfaz de negocio.
  INITCAP(LOWER(c_mktsegment)) AS segmento_formateado,
  -- Demostramos LTRIM eliminando espacios solo del lado izquierdo.
  LTRIM(CONCAT('   ', c_name)) AS nombre_sin_espacios_izquierdos,
  -- Demostramos RTRIM eliminando espacios solo del lado derecho.
  RTRIM(CONCAT(c_name, '   ')) AS nombre_sin_espacios_derechos
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.customer
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 2 de 5
-- MAGIC ### Extracción y composición de texto
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** los teléfonos y etiquetas compuestas son frecuentes en reportes de calidad. Por eso combinamos funciones de corte, reemplazo y unión.
-- MAGIC
-- MAGIC **Qué hace cada cláusula:**
-- MAGIC - `SELECT` crea una vista enriquecida del teléfono del cliente.
-- MAGIC - `FROM` usa `customer` porque contiene nombre, teléfono y segmento.
-- MAGIC - `LIMIT` mantiene la muestra legible.
-- MAGIC
-- MAGIC **Resultado esperado:** prefijos extraídos, teléfono sin guiones y una ficha resumida por cliente.
-- MAGIC
-- MAGIC **Errores comunes:** asumir mal la posición del texto en `SUBSTRING`, olvidar que `SPLIT` devuelve un arreglo o usar separadores inconsistentes.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos el identificador para unir esta salida con otras tablas si fuera necesario.
  c_custkey,
  -- Mostramos el teléfono original como referencia de calidad.
  c_phone AS telefono_original,
  -- Extraemos los dos primeros caracteres para ilustrar el uso de SUBSTRING.
  SUBSTRING(c_phone, 1, 2) AS codigo_inicial_substring,
  -- Extraemos los dos primeros caracteres usando LEFT como alternativa más expresiva.
  LEFT(c_phone, 2) AS codigo_inicial_left,
  -- Extraemos los cuatro últimos caracteres para una vista rápida del número final.
  RIGHT(c_phone, 4) AS ultimos_cuatro_digitos,
  -- Reemplazamos guiones por espacios para construir una versión más limpia visualmente.
  REPLACE(c_phone, '-', ' ') AS telefono_con_espacios,
  -- Concatenamos nombre y teléfono para una etiqueta simple y explícita.
  CONCAT(c_name, ' | ', c_phone) AS nombre_y_telefono,
  -- Concatenamos con separador fijo varias columnas relevantes para una ficha operativa.
  CONCAT_WS(' / ', c_name, c_mktsegment, c_phone) AS ficha_cliente,
  -- Partimos el teléfono por guiones y tomamos el segundo bloque usando indexación basada en 1.
  ELEMENT_AT(SPLIT(c_phone, '-'), 2) AS bloque_central_telefono
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.customer
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 3 de 5
-- MAGIC ### Relleno visual y estandarización de identificadores
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** en tableros y exportaciones suele ser útil que códigos y descriptores tengan anchos consistentes.
-- MAGIC
-- MAGIC **Qué hace cada cláusula:**
-- MAGIC - `SELECT` mantiene columnas originales y añade versiones visualmente estandarizadas.
-- MAGIC - `FROM` usa `part` porque contiene identificadores y atributos textuales del producto.
-- MAGIC - `LIMIT` facilita la revisión manual.
-- MAGIC
-- MAGIC **Resultado esperado:** códigos rellenados con ceros, marcas extendidas a ancho fijo y nombres listos para presentación.
-- MAGIC
-- MAGIC **Errores comunes:** olvidar convertir un número a texto antes de usar `LPAD` o `RPAD`, o usar anchos demasiado pequeños que truncan el contexto esperado.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave de la parte para seguir el producto original.
  p_partkey,
  -- Mostramos el nombre original para comparar con las variantes formateadas.
  p_name AS nombre_producto,
  -- Convertimos la llave numérica a texto y la rellenamos con ceros a la izquierda para uniformar reportes.
  LPAD(CAST(p_partkey AS STRING), 8, '0') AS id_producto_formateado,
  -- Tomamos una porción de la marca y la rellenamos a la derecha para alinear salidas tabulares.
  RPAD(LEFT(p_brand, 5), 10, '.') AS marca_alineada,
  -- Medimos la longitud del nombre para perfilamiento básico de datos.
  LENGTH(p_name) AS longitud_nombre_producto,
  -- Creamos una versión recortada del nombre para demostración de SUBSTRING sobre descripciones largas.
  SUBSTRING(p_name, 1, 18) AS nombre_corto,
  -- Limpiamos espacios externos del contenedor simulado para mostrar TRIM con otro atributo.
  TRIM(CONCAT(' ', p_container, ' ')) AS contenedor_limpio
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.part
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 4 de 5
-- MAGIC ### Transformaciones numéricas para métricas operativas
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** un reporte de calidad no solo limpia texto; también normaliza importes y compara tasas como descuento e impuesto.
-- MAGIC
-- MAGIC **Qué hace cada cláusula:**
-- MAGIC - `SELECT` deriva medidas monetarias y comparativas.
-- MAGIC - `FROM` usa `lineitem`, donde aparecen precio, descuento, impuesto y cantidad.
-- MAGIC - `LIMIT` evita una salida demasiado extensa.
-- MAGIC
-- MAGIC **Resultado esperado:** precios redondeados, diferencias absolutas y valores máximo/mínimo entre tasas.
-- MAGIC
-- MAGIC **Errores comunes:** no redondear antes de reportar, aplicar `SQRT` a valores negativos o usar `MOD` sobre tipos no compatibles sin convertirlos.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la orden para contextualizar el ítem dentro de la venta.
  l_orderkey,
  -- Conservamos el número de línea para distinguir ítems de una misma orden.
  l_linenumber,
  -- Mostramos el precio extendido original para comparar la transformación.
  l_extendedprice,
  -- Mostramos el descuento original como insumo del cálculo neto.
  l_discount,
  -- Calculamos el ingreso neto aproximado después del descuento y lo redondeamos a dos decimales.
  ROUND(l_extendedprice * (1 - l_discount), 2) AS ingreso_neto_redondeado,
  -- Redondeamos hacia arriba para ilustrar una cota superior operativa.
  CEIL(l_extendedprice) AS precio_hacia_arriba,
  -- Redondeamos hacia abajo para ilustrar una cota inferior conservadora.
  FLOOR(l_extendedprice) AS precio_hacia_abajo,
  -- Medimos la distancia absoluta entre impuesto y descuento para detectar desbalances.
  ABS(l_tax - l_discount) AS diferencia_absoluta_tasas,
  -- Usamos el residuo de la llave de orden para construir grupos técnicos simples.
  MOD(CAST(l_orderkey AS INT), 5) AS grupo_modular,
  -- Elevamos la cantidad al cuadrado como ejemplo de transformación matemática.
  POWER(l_quantity, 2) AS cantidad_al_cuadrado,
  -- Calculamos la raíz cuadrada del precio para explorar escalamiento numérico.
  SQRT(l_extendedprice) AS raiz_cuadrada_precio,
  -- Retenemos la tasa mayor entre descuento e impuesto para comparaciones rápidas.
  GREATEST(l_discount, l_tax) AS mayor_tasa,
  -- Retenemos la tasa menor entre descuento e impuesto para comparaciones rápidas.
  LEAST(l_discount, l_tax) AS menor_tasa
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.lineitem
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 7. Ejemplo completamente explicado 5 de 5
-- MAGIC ### Fechas, condicionales y conversión segura de tipos
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** en un caso real, el analista suele necesitar una sola vista que combine tiempo, etiquetas de negocio y conversiones robustas.
-- MAGIC
-- MAGIC **Qué hace cada cláusula:**
-- MAGIC - `SELECT` mezcla indicadores temporales, etiquetas condicionales y conversiones de tipo.
-- MAGIC - `FROM` usa `orders`, donde la fecha y el importe total son claves para seguimiento.
-- MAGIC - `LIMIT` permite inspeccionar con detalle.
-- MAGIC
-- MAGIC **Resultado esperado:** fechas enriquecidas, categorías por valor y ejemplos claros de `CAST` frente a `TRY_CAST`.
-- MAGIC
-- MAGIC **Errores comunes:** convertir texto inválido con `CAST`, olvidar el `ELSE` en `CASE` o interpretar mal la diferencia entre fecha y timestamp.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la orden para referencia del negocio.
  o_orderkey,
  -- Mostramos la fecha original porque toda transformación temporal debe poder validarse contra la fuente.
  o_orderdate,
  -- Obtenemos la fecha actual del sistema para medir antigüedad relativa.
  CURRENT_DATE() AS fecha_actual,
  -- Obtenemos el timestamp actual para auditoría temporal más precisa.
  CURRENT_TIMESTAMP() AS timestamp_actual,
  -- Formateamos la fecha en año-mes para facilitar agrupaciones mensuales.
  DATE_FORMAT(o_orderdate, 'yyyy-MM') AS periodo_orden,
  -- Extraemos el año para análisis de tendencia anual.
  YEAR(o_orderdate) AS anio_orden,
  -- Extraemos el mes para análisis estacional.
  MONTH(o_orderdate) AS mes_orden,
  -- Extraemos el día del mes para granularidad diaria.
  DAY(o_orderdate) AS dia_orden,
  -- Calculamos los días transcurridos desde la orden hasta hoy.
  DATEDIFF(CURRENT_DATE(), o_orderdate) AS dias_desde_la_orden,
  -- Calculamos una fecha objetivo treinta días después de la orden para seguimiento.
  DATE_ADD(o_orderdate, 30) AS fecha_objetivo_30_dias,
  -- Calculamos una fecha de control siete días antes de la orden como ejemplo didáctico.
  DATE_SUB(o_orderdate, 7) AS fecha_control_7_dias_antes,
  -- Convertimos explícitamente la fecha a tipo DATE desde su representación textual.
  TO_DATE(CAST(o_orderdate AS STRING)) AS fecha_convertida,
  -- Construimos un timestamp añadiendo una hora ficticia para mostrar TO_TIMESTAMP.
  TO_TIMESTAMP(CONCAT(CAST(o_orderdate AS STRING), ' 08:30:00')) AS marca_tiempo_simulada,
  -- Identificamos el día de la semana en formato numérico operativo.
  DAYOFWEEK(o_orderdate) AS dia_de_semana,
  -- Identificamos el día del año para análisis de calendario.
  DAYOFYEAR(o_orderdate) AS dia_del_anio,
  -- Identificamos la semana del año para reportes semanales.
  WEEKOFYEAR(o_orderdate) AS semana_del_anio,
  -- Clasificamos la orden según su monto total para priorización comercial.
  CASE
    WHEN o_totalprice > 300000 THEN 'Orden de alto valor'
    WHEN o_totalprice > 150000 THEN 'Orden de valor medio'
    ELSE 'Orden estándar'
  END AS categoria_valor,
  -- Aplicamos una lógica binaria corta para resaltar si el monto supera un umbral.
  IF(o_totalprice > 200000, 'Revisar con gerencia', 'Seguimiento normal') AS accion_sugerida,
  -- Aplicamos una segunda variante binaria con IIF para mostrar sintaxis equivalente.
  IIF(o_orderstatus = 'F', 'Orden finalizada', 'Orden no finalizada') AS estado_interpretado,
  -- Convertimos la llave a texto para mostrar un caso simple de CAST a STRING.
  CAST(o_orderkey AS STRING) AS orden_como_texto,
  -- Convertimos un literal válido a entero para demostrar CAST a INT.
  CAST('123' AS INT) AS ejemplo_entero,
  -- Convertimos un literal válido a decimal para demostrar CAST a DOUBLE.
  CAST('123.45' AS DOUBLE) AS ejemplo_decimal,
  -- Intentamos convertir un literal inválido y devolvemos NULL en vez de error gracias a TRY_CAST.
  TRY_CAST('abc' AS INT) AS intento_entero_seguro,
  -- Sustituimos un valor nulo explícito usando IFNULL como ejemplo mínimo.
  IFNULL(NULL, 'respaldo_ifnull') AS ejemplo_ifnull,
  -- Convertimos a NULL el estado cuando coincide con F para ilustrar NULLIF.
  NULLIF(o_orderstatus, 'F') AS estado_null_si_finalizada,
  -- Tomamos el primer valor no nulo disponible usando COALESCE.
  COALESCE(NULL, CAST(o_totalprice AS STRING), 'sin_precio') AS primer_valor_no_nulo,
  -- Repetimos la lógica de respaldo con NVL para mostrar equivalencia funcional.
  NVL(NULL, 'respaldo_nvl') AS ejemplo_nvl
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.orders
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 1 de 5
-- MAGIC ### Crear una etiqueta limpia de proveedor
-- MAGIC
-- MAGIC **Objetivo guiado:** construir una etiqueta homogénea para proveedores que sirva en un reporte de maestro de datos.
-- MAGIC
-- MAGIC **Por qué se arma así:** necesitamos un identificador visual, un nombre formateado y una referencia corta del teléfono.
-- MAGIC
-- MAGIC **Resultado esperado:** una etiqueta tipo `000123 - Supplier#000123 - 4567`.
-- MAGIC
-- MAGIC **Error común:** olvidar convertir `s_suppkey` a texto antes de usar `LPAD`.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave del proveedor para trazabilidad.
  s_suppkey,
  -- Mostramos el nombre original del proveedor.
  s_name AS nombre_original,
  -- Mostramos el teléfono original para comparación.
  s_phone AS telefono_original,
  -- Normalizamos el nombre a formato título para mejorar legibilidad.
  INITCAP(LOWER(s_name)) AS nombre_estandarizado,
  -- Construimos una etiqueta compacta uniendo id formateado, nombre y últimos cuatro dígitos del teléfono.
  CONCAT_WS(' - ', LPAD(CAST(s_suppkey AS STRING), 6, '0'), s_name, RIGHT(s_phone, 4)) AS etiqueta_proveedor,
  -- Eliminamos guiones del teléfono para generar una variante limpia útil en integración.
  REPLACE(s_phone, '-', '') AS telefono_solo_digitos
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.supplier
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 2 de 5
-- MAGIC ### Medir antigüedad de órdenes por cliente
-- MAGIC
-- MAGIC **Objetivo guiado:** relacionar clientes con órdenes y clasificar la recencia de cada pedido.
-- MAGIC
-- MAGIC **Por qué se arma así:** combinamos `JOIN`, `DATEDIFF`, `CASE` y `DATE_FORMAT` para pasar de un dato bruto a una señal de negocio.
-- MAGIC
-- MAGIC **Resultado esperado:** cada orden aparece con nombre del cliente, días de antigüedad y una categoría temporal.
-- MAGIC
-- MAGIC **Error común:** usar el alias incorrecto en el `JOIN` o invertir el orden de los argumentos de `DATEDIFF`.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave de la orden como identificador principal del evento.
  o.o_orderkey,
  -- Incorporamos el nombre del cliente para dar contexto de negocio a la orden.
  c.c_name AS nombre_cliente,
  -- Mostramos la fecha original de la orden.
  o.o_orderdate,
  -- Calculamos cuántos días han pasado desde la fecha de la orden hasta hoy.
  DATEDIFF(CURRENT_DATE(), o.o_orderdate) AS dias_antiguedad,
  -- Clasificamos la orden por recencia para facilitar priorización comercial.
  CASE
    WHEN DATEDIFF(CURRENT_DATE(), o.o_orderdate) <= 30 THEN 'Reciente'
    WHEN DATEDIFF(CURRENT_DATE(), o.o_orderdate) <= 180 THEN 'Intermedia'
    ELSE 'Histórica'
  END AS categoria_antiguedad,
  -- Formateamos la fecha al nombre del mes para reportes narrativos.
  DATE_FORMAT(o.o_orderdate, 'MMMM') AS nombre_mes
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.orders AS o
-- Unimos una segunda tabla para enriquecer el análisis con contexto adicional.
INNER JOIN samples.tpch.customer AS c
  -- Definimos la condición exacta de unión para evitar combinaciones incorrectas.
  ON o.o_custkey = c.c_custkey
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 3 de 5
-- MAGIC ### Calcular importes finales y topes de referencia
-- MAGIC
-- MAGIC **Objetivo guiado:** convertir precio, descuento e impuesto en una cifra más interpretable para control operativo.
-- MAGIC
-- MAGIC **Por qué se arma así:** `ROUND` mejora la presentación, mientras `GREATEST` y `LEAST` ayudan a comparar contra umbrales simples.
-- MAGIC
-- MAGIC **Resultado esperado:** monto final estimado, descuento monetario y límites de referencia por fila.
-- MAGIC
-- MAGIC **Error común:** olvidar el orden de operaciones matemáticas y obtener montos incorrectos.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos orden y línea para ubicar el registro dentro del detalle de venta.
  l_orderkey,
  -- Conservamos el número de línea para evitar ambigüedad entre ítems de una misma orden.
  l_linenumber,
  -- Redondeamos el precio base para presentar la cifra con dos decimales.
  ROUND(l_extendedprice, 2) AS precio_bruto,
  -- Calculamos el descuento monetario aplicando la tasa sobre el precio y lo redondeamos.
  ROUND(l_extendedprice * l_discount, 2) AS descuento_monetario,
  -- Estimamos un monto final considerando descuento e impuesto y lo redondeamos para reporte.
  ROUND(l_extendedprice * (1 - l_discount) * (1 + l_tax), 2) AS monto_final_estimado,
  -- Tomamos la mayor tasa entre la observada y un piso de referencia para control rápido.
  GREATEST(l_tax, 0.05) AS tasa_referencia_superior,
  -- Tomamos la menor tasa entre el descuento observado y un tope de política comercial.
  LEAST(l_discount, 0.10) AS descuento_topado
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.lineitem
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 4 de 5
-- MAGIC ### Construir un descriptor analítico de producto
-- MAGIC
-- MAGIC **Objetivo guiado:** sintetizar atributos relevantes del producto en un campo legible y controlado.
-- MAGIC
-- MAGIC **Por qué se arma así:** unir marca, tipo y tamaño ayuda a validar consistencia de catálogos y simplifica exploración inicial.
-- MAGIC
-- MAGIC **Resultado esperado:** un descriptor compacto, categoría de tamaño y una conversión segura del tamaño.
-- MAGIC
-- MAGIC **Error común:** mezclar texto y números sin `CAST`, lo que puede romper la concatenación.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave de la parte para trazabilidad del producto original.
  p_partkey,
  -- Conservamos la marca original del catálogo.
  p_brand,
  -- Conservamos el tamaño numérico para compararlo con la categoría calculada.
  p_size,
  -- Conservamos el precio minorista para reutilizarlo en otras capas analíticas.
  p_retailprice,
  -- Construimos un descriptor unificado combinando marca, tipo y tamaño convertido a texto.
  CONCAT_WS(' | ', p_brand, p_type, CAST(p_size AS STRING)) AS descriptor_producto,
  -- Clasificamos el tamaño en una lógica binaria útil para demostración.
  IF(p_size >= 40, 'Grande', 'Estándar') AS categoria_tamano,
  -- Convertimos el precio a texto y usamos COALESCE para mostrar una estrategia de respaldo.
  COALESCE(CAST(p_retailprice AS STRING), 'Sin precio') AS precio_como_texto,
  -- Reconvertimos el tamaño desde texto con TRY_CAST para ilustrar una validación segura.
  TRY_CAST(CAST(p_size AS STRING) AS INT) AS tamano_reconvertido
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.part
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 8. Ejemplo guiado 5 de 5
-- MAGIC ### Generar una clave operativa de periodo y prioridad
-- MAGIC
-- MAGIC **Objetivo guiado:** crear una llave de control legible para auditorías y reportes mensuales.
-- MAGIC
-- MAGIC **Por qué se arma así:** una clave compuesta simplifica exportaciones y chequeos manuales cuando se comparte información con áreas no técnicas.
-- MAGIC
-- MAGIC **Resultado esperado:** claves como `1996-01-1-URG` junto con una alerta de valor.
-- MAGIC
-- MAGIC **Error común:** olvidar rellenar el mes con `LPAD` y producir claves inconsistentes como `1996-1` y `1996-10`.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave de orden como identificador primario de la transacción.
  o_orderkey,
  -- Conservamos el estado original para compararlo con la versión normalizada.
  o_orderstatus,
  -- Conservamos la prioridad original para contextualizar la clave creada.
  o_orderpriority,
  -- Conservamos el responsable operativo de la orden.
  o_clerk,
  -- Normalizamos el estado eliminando posibles espacios y unificando a mayúsculas.
  UPPER(TRIM(o_orderstatus)) AS estado_normalizado,
  -- Recortamos el identificador del clerk para construir una vista abreviada.
  SUBSTRING(o_clerk, 1, 8) AS prefijo_clerk,
  -- Creamos una clave compuesta con año, mes normalizado y un fragmento de la prioridad.
  CONCAT_WS('-', YEAR(o_orderdate), LPAD(CAST(MONTH(o_orderdate) AS STRING), 2, '0'), LEFT(o_orderpriority, 5)) AS clave_periodo_prioridad,
  -- Señalamos si la orden supera un umbral monetario relevante para revisión.
  CASE
    WHEN o_totalprice > 300000 THEN 'Crítica'
    ELSE 'Regular'
  END AS alerta_valor
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.orders
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 1 de 5 · Muy Fácil
-- MAGIC ### Crear una etiqueta de cliente para revisión manual
-- MAGIC
-- MAGIC **Tarea:** combina la llave, el nombre y el segmento del cliente en un solo campo legible.
-- MAGIC
-- MAGIC **Por qué esta solución es adecuada:** permite revisar calidad de forma compacta y deja visibles los atributos clave.
-- MAGIC
-- MAGIC **Resultado esperado:** una etiqueta homogénea con longitud del nombre como indicador adicional.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave del cliente como referencia principal.
  c_custkey,
  -- Conservamos el nombre original para comparar con la etiqueta compuesta.
  c_name,
  -- Conservamos el segmento original para trazabilidad de negocio.
  c_mktsegment,
  -- Construimos una etiqueta uniforme usando id rellenado y texto estandarizado.
  CONCAT_WS(' | ', LPAD(CAST(c_custkey AS STRING), 6, '0'), INITCAP(LOWER(c_name)), INITCAP(LOWER(c_mktsegment))) AS etiqueta_cliente,
  -- Medimos la longitud del nombre como apoyo a la revisión de calidad.
  LENGTH(c_name) AS longitud_nombre
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.customer
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 2 de 5 · Fácil
-- MAGIC ### Preparar una vista de calendario para órdenes
-- MAGIC
-- MAGIC **Tarea:** mostrar la fecha formateada, el día de la semana, la semana operativa y una fecha de revisión dos semanas después.
-- MAGIC
-- MAGIC **Por qué esta solución es adecuada:** transforma una sola fecha en varios atributos listos para planificación.
-- MAGIC
-- MAGIC **Resultado esperado:** una tabla pequeña de órdenes con enriquecimiento temporal.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave de la orden para referencia.
  o_orderkey,
  -- Conservamos la fecha original para validar las derivaciones temporales.
  o_orderdate,
  -- Formateamos la fecha con año, mes y día para una lectura uniforme.
  DATE_FORMAT(o_orderdate, 'yyyy-MM-dd') AS fecha_formateada,
  -- Calculamos el número de día de la semana para planificación operativa.
  DAYOFWEEK(o_orderdate) AS numero_dia_semana,
  -- Calculamos la semana del año para reportes semanales.
  WEEKOFYEAR(o_orderdate) AS semana_operativa,
  -- Sumamos catorce días para proponer una fecha de revisión.
  DATE_ADD(o_orderdate, 14) AS fecha_revision
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.orders
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 3 de 5 · Intermedio
-- MAGIC ### Comparar descuento e impuesto en detalle de venta
-- MAGIC
-- MAGIC **Tarea:** crear una señal rápida que indique si el descuento supera al impuesto y medir la brecha absoluta.
-- MAGIC
-- MAGIC **Por qué esta solución es adecuada:** resume una comparación de negocio en una etiqueta simple y una métrica interpretable.
-- MAGIC
-- MAGIC **Resultado esperado:** cada línea indica la relación entre tasas y su distancia.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la orden para contextualizar el ítem dentro del proceso comercial.
  l_orderkey,
  -- Conservamos la línea del ítem para diferenciar registros de una misma orden.
  l_linenumber,
  -- Conservamos la cantidad como insumo descriptivo adicional.
  l_quantity,
  -- Conservamos el descuento observado.
  l_discount,
  -- Conservamos el impuesto observado.
  l_tax,
  -- Clasificamos la comparación entre descuento e impuesto usando CASE.
  CASE
    WHEN l_discount > l_tax THEN 'Descuento mayor que impuesto'
    ELSE 'Impuesto mayor o igual'
  END AS comparacion_tasas,
  -- Calculamos la brecha absoluta para medir magnitud de la diferencia.
  ABS(l_discount - l_tax) AS brecha_tasas,
  -- Aplicamos MOD para distinguir líneas pares e impares como ejercicio técnico adicional.
  MOD(CAST(l_linenumber AS INT), 2) AS paridad_linea
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.lineitem
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 4 de 5 · Intermedio Alto
-- MAGIC ### Descomponer y validar teléfonos de proveedores
-- MAGIC
-- MAGIC **Tarea:** separar el teléfono en bloques y producir una lectura financiera simple del proveedor.
-- MAGIC
-- MAGIC **Por qué esta solución es adecuada:** une parsing de texto con lógica condicional y manejo básico de nulos.
-- MAGIC
-- MAGIC **Resultado esperado:** bloques del teléfono, extensión visual y un estado financiero rápido.
-- MAGIC
-- MAGIC **Error común:** usar índices equivocados en `ELEMENT_AT` después de `SPLIT`.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave del proveedor para seguimiento.
  s_suppkey,
  -- Conservamos el teléfono original para contrastar la separación en bloques.
  s_phone,
  -- Conservamos el saldo de cuenta como base para la clasificación financiera.
  s_acctbal,
  -- Extraemos el primer bloque del teléfono para representar el prefijo inicial.
  ELEMENT_AT(SPLIT(s_phone, '-'), 1) AS bloque_1,
  -- Extraemos el segundo bloque del teléfono para revisión estructural.
  ELEMENT_AT(SPLIT(s_phone, '-'), 2) AS bloque_2,
  -- Extraemos el tercer bloque del teléfono para revisión estructural.
  ELEMENT_AT(SPLIT(s_phone, '-'), 3) AS bloque_3,
  -- Mostramos los últimos cuatro caracteres como una extensión visual simple.
  RIGHT(s_phone, 4) AS extension_visual,
  -- Convertimos el saldo a texto y aplicamos un respaldo por si apareciera un nulo.
  COALESCE(CAST(s_acctbal AS STRING), 'Sin saldo') AS saldo_texto,
  -- Clasificamos el saldo para señalar proveedores que requieren revisión.
  CASE
    WHEN s_acctbal < 0 THEN 'Revisar'
    ELSE 'Aprobado'
  END AS estado_financiero
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.supplier
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 10;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 9. Ejercicio guiado 5 de 5 · Desafío guiado
-- MAGIC ### Resumen mensual de órdenes y clientes con riesgo financiero
-- MAGIC
-- MAGIC **Tarea:** integrar funciones de fecha, agregación y lógica condicional en un resumen mensual.
-- MAGIC
-- MAGIC **Por qué esta solución es adecuada:** ya no se trabaja fila a fila, sino a nivel de periodo, que es como suelen consumirse los reportes gerenciales.
-- MAGIC
-- MAGIC **Resultado esperado:** total de órdenes, ticket promedio, clientes con saldo negativo y máxima antigüedad por mes.
-- MAGIC
-- MAGIC **Error común:** olvidar repetir en `GROUP BY` la misma expresión usada para construir el periodo.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Formateamos la fecha de la orden como año-mes para construir el periodo analítico.
  DATE_FORMAT(o.o_orderdate, 'yyyy-MM') AS periodo,
  -- Contamos cuántas órdenes existen en cada periodo para medir volumen.
  COUNT(*) AS total_ordenes,
  -- Calculamos el precio promedio de las órdenes y lo redondeamos para presentación ejecutiva.
  ROUND(AVG(o.o_totalprice), 2) AS ticket_promedio,
  -- Contamos clientes distintos con saldo negativo como señal de riesgo financiero.
  COUNT(DISTINCT CASE WHEN c.c_acctbal < 0 THEN c.c_custkey END) AS clientes_con_saldo_negativo,
  -- Calculamos la mayor antigüedad observada dentro del periodo para seguimiento operativo.
  MAX(DATEDIFF(CURRENT_DATE(), o.o_orderdate)) AS maxima_antiguedad_dias
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.orders AS o
-- Unimos una segunda tabla para enriquecer el análisis con contexto adicional.
INNER JOIN samples.tpch.customer AS c
  -- Definimos la condición exacta de unión para evitar combinaciones incorrectas.
  ON o.o_custkey = c.c_custkey
-- Agrupamos por la misma expresión del periodo para consolidar correctamente los resultados.
GROUP BY DATE_FORMAT(o.o_orderdate, 'yyyy-MM')
-- Ordenamos la salida para que la revisión manual sea más clara y consistente.
ORDER BY periodo
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 12;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 10. Ejercicio individual
-- MAGIC
-- MAGIC Resuelve los siguientes retos **sin mirar las soluciones anteriores**. El nivel progresa de **Muy Fácil** a **Desafío**.
-- MAGIC
-- MAGIC ### 1. Muy Fácil
-- MAGIC En `samples.tpch.customer`, crea una columna con el nombre en mayúsculas y otra con la longitud del nombre.
-- MAGIC
-- MAGIC ### 2. Fácil
-- MAGIC En `samples.tpch.orders`, genera columnas con `YEAR`, `MONTH` y `WEEKOFYEAR` de `o_orderdate`.
-- MAGIC
-- MAGIC ### 3. Intermedio
-- MAGIC En `samples.tpch.lineitem`, calcula el monto neto con descuento usando `ROUND` y clasifícalo con `CASE` en Alto, Medio o Bajo.
-- MAGIC
-- MAGIC ### 4. Intermedio Alto
-- MAGIC En `samples.tpch.supplier`, separa `s_phone` con `SPLIT`, conserva el primer bloque y crea una etiqueta con `CONCAT_WS`.
-- MAGIC
-- MAGIC ### 5. Desafío
-- MAGIC Une `customer` y `orders` para construir un reporte por cliente con nombre normalizado, periodo de orden y una alerta cuando `o_totalprice` supere un umbral definido por ti.
-- MAGIC
-- MAGIC > **📝 Nota:** intenta dejar visibles tanto el campo original como el transformado. Esa práctica acelera la validación.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 11. Desafío
-- MAGIC
-- MAGIC Resuelve estos ejercicios como si fueras a entregar un mini reporte a tu gerente.
-- MAGIC
-- MAGIC ### 1. Muy Fácil
-- MAGIC Construye una columna de control en `part` con `LPAD` sobre `p_partkey` y una segunda columna con `LEFT(p_name, 12)`.
-- MAGIC
-- MAGIC ### 2. Fácil
-- MAGIC En `orders`, calcula cuántos días faltan o han pasado respecto a `DATE_ADD(o_orderdate, 30)` usando `DATEDIFF`.
-- MAGIC
-- MAGIC ### 3. Intermedio
-- MAGIC En `lineitem`, compara `l_discount` y `l_tax` con `GREATEST` y `LEAST`, y explica cuál usarías para una alerta conservadora.
-- MAGIC
-- MAGIC ### 4. Intermedio Alto
-- MAGIC En `customer`, usa `NULLIF`, `COALESCE` y `CAST` para preparar una salida textual robusta aunque aparezcan segmentos vacíos o especiales.
-- MAGIC
-- MAGIC ### 5. Desafío
-- MAGIC Construye un resumen mensual por `o_orderdate` con total de órdenes, promedio de `o_totalprice`, categoría de volumen y etiqueta de periodo con `CONCAT_WS`.
-- MAGIC
-- MAGIC > **📝 Nota:** en una revisión académica se valorará que justifiques por qué elegiste cada función y cómo validarías posibles errores.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 12. Resumen
-- MAGIC
-- MAGIC En este notebook aprendiste que las funciones SQL permiten transformar datos crudos en información utilizable.
-- MAGIC
-- MAGIC ### Ideas clave
-- MAGIC - Las funciones de texto ayudan a **estandarizar nombres, códigos y etiquetas**.
-- MAGIC - Las funciones numéricas sirven para **normalizar importes y comparar magnitudes**.
-- MAGIC - Las funciones de fecha convierten eventos en **indicadores temporales de negocio**.
-- MAGIC - Las funciones condicionales traducen reglas del negocio a **clasificaciones reproducibles**.
-- MAGIC - `CAST` y `TRY_CAST` son esenciales para **gobernar conversiones de tipo con seguridad**.
-- MAGIC
-- MAGIC > **📝 Nota:** una consulta analítica sólida no solo calcula; también facilita validación, trazabilidad y comunicación.
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 13. Laboratorio
-- MAGIC ### Caso aplicado: reporte de calidad de datos para DataCorp Analytics
-- MAGIC
-- MAGIC A continuación responderás tres preguntas de negocio realistas. La idea es que observes cómo varias funciones SQL se integran en entregables parecidos a los que solicitaría un gerente.
-- MAGIC
-- MAGIC **Preguntas del laboratorio:**
-- MAGIC 1. ¿Qué clientes necesitan estandarización inmediata de nombre, segmento y teléfono para un maestro comercial?
-- MAGIC 2. ¿Cómo se comporta el volumen y el valor promedio de órdenes por periodo mensual?
-- MAGIC 3. ¿Qué líneas de orden muestran mayor riesgo operativo por antigüedad de envío y combinación de descuento/impuesto?
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Laboratorio 1 de 3
-- MAGIC **Pregunta de negocio:** ¿Qué clientes deben pasar primero por una rutina de limpieza y estandarización?
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** se crea una vista tipo “antes y después” para que el gerente vea el beneficio inmediato de estandarizar atributos.
-- MAGIC
-- MAGIC **Qué esperar:** etiquetas limpias, teléfonos normalizados y prioridad de limpieza basada en longitud del nombre.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la llave del cliente para identificar el registro en el maestro.
  c_custkey,
  -- Mostramos el nombre original para auditar la transformación.
  c_name AS nombre_original,
  -- Estandarizamos el nombre a formato título para futuras salidas de negocio.
  INITCAP(LOWER(c_name)) AS nombre_estandarizado,
  -- Estandarizamos el segmento para que los valores se vean homogéneos.
  INITCAP(LOWER(c_mktsegment)) AS segmento_estandarizado,
  -- Normalizamos el teléfono quitando guiones para facilitar integraciones posteriores.
  REPLACE(c_phone, '-', '') AS telefono_normalizado,
  -- Creamos una etiqueta ejecutiva que combina id, nombre y segmento ya limpios.
  CONCAT_WS(' | ', LPAD(CAST(c_custkey AS STRING), 6, '0'), INITCAP(LOWER(c_name)), INITCAP(LOWER(c_mktsegment))) AS ficha_cliente_limpia,
  -- Asignamos una prioridad de limpieza suponiendo que nombres muy cortos requieren revisión.
  CASE
    WHEN LENGTH(c_name) < 12 THEN 'Alta'
    WHEN LENGTH(c_name) < 18 THEN 'Media'
    ELSE 'Baja'
  END AS prioridad_revision
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.customer
-- Ordenamos la salida para que la revisión manual sea más clara y consistente.
ORDER BY prioridad_revision, c_custkey
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 20;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Laboratorio 2 de 3
-- MAGIC **Pregunta de negocio:** ¿Cómo resumir el comportamiento mensual de órdenes para el tablero gerencial?
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** usa funciones temporales y numéricas para producir un agregado compacto, listo para visualizar.
-- MAGIC
-- MAGIC **Qué esperar:** periodos mensuales, volumen de órdenes, ticket promedio y categoría de demanda.
-- MAGIC
-- MAGIC **Error común:** construir el periodo en `SELECT` y luego agrupar por la fecha original en vez de por la misma expresión.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Construimos el periodo mensual que será la unidad principal del reporte.
  DATE_FORMAT(o_orderdate, 'yyyy-MM') AS periodo,
  -- Contamos cuántas órdenes integran cada periodo.
  COUNT(*) AS total_ordenes,
  -- Calculamos el ticket promedio del periodo y lo redondeamos a dos decimales.
  ROUND(AVG(o_totalprice), 2) AS ticket_promedio,
  -- Calculamos el máximo valor de orden observado en el periodo.
  ROUND(MAX(o_totalprice), 2) AS orden_maxima,
  -- Clasificamos el volumen mensual para lectura ejecutiva rápida.
  CASE
    WHEN COUNT(*) >= 1000 THEN 'Volumen alto'
    WHEN COUNT(*) >= 500 THEN 'Volumen medio'
    ELSE 'Volumen bajo'
  END AS categoria_volumen,
  -- Construimos una etiqueta descriptiva de periodo y categoría para exportaciones simples.
  CONCAT_WS(' | ', DATE_FORMAT(o_orderdate, 'yyyy-MM'), CASE WHEN COUNT(*) >= 1000 THEN 'Volumen alto' WHEN COUNT(*) >= 500 THEN 'Volumen medio' ELSE 'Volumen bajo' END) AS etiqueta_periodo
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.orders
-- Agrupamos por la misma expresión del periodo para consolidar correctamente los resultados.
GROUP BY DATE_FORMAT(o_orderdate, 'yyyy-MM')
-- Ordenamos la salida para que la revisión manual sea más clara y consistente.
ORDER BY periodo;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ### Laboratorio 3 de 3
-- MAGIC **Pregunta de negocio:** ¿Qué líneas de orden merecen revisión por tiempos amplios entre compromiso y recepción o por combinaciones sensibles de tasas?
-- MAGIC
-- MAGIC **Por qué esta consulta está escrita así:** mezcla métricas temporales, comparaciones numéricas y lógica condicional para generar una lista accionable.
-- MAGIC
-- MAGIC **Qué esperar:** una muestra priorizada con días entre hitos logísticos, monto neto y alerta operativa.
-- MAGIC
-- MAGIC **Error común:** confundir `l_commitdate` con `l_receiptdate` al calcular la brecha logística.
-- COMMAND ----------
-- Iniciamos la consulta seleccionando columnas originales y columnas transformadas.
SELECT
  -- Conservamos la orden para poder escalar la revisión al nivel transaccional.
  l_orderkey,
  -- Conservamos la línea para ubicar el ítem exacto dentro de la orden.
  l_linenumber,
  -- Conservamos las fechas logísticas originales para auditoría.
  l_commitdate,
  -- Conservamos la fecha de recepción para medir la brecha con el compromiso.
  l_receiptdate,
  -- Calculamos cuántos días separan el compromiso de la recepción del ítem.
  DATEDIFF(l_receiptdate, l_commitdate) AS dias_brecha_logistica,
  -- Calculamos el monto neto estimado tras descuento y lo redondeamos para reporte.
  ROUND(l_extendedprice * (1 - l_discount), 2) AS monto_neto,
  -- Tomamos la mayor de las dos tasas para usar una lectura conservadora del riesgo.
  GREATEST(l_discount, l_tax) AS tasa_mas_sensible,
  -- Clasificamos la línea según brecha logística y magnitud de tasas.
  CASE
    WHEN DATEDIFF(l_receiptdate, l_commitdate) > 10 OR GREATEST(l_discount, l_tax) >= 0.08 THEN 'Revisión prioritaria'
    WHEN DATEDIFF(l_receiptdate, l_commitdate) > 5 THEN 'Seguimiento'
    ELSE 'Normal'
  END AS alerta_operativa
-- Indicamos la tabla fuente desde la cual leeremos los datos del ejemplo.
FROM samples.tpch.lineitem
-- Ordenamos la salida para que la revisión manual sea más clara y consistente.
ORDER BY dias_brecha_logistica DESC, tasa_mas_sensible DESC
-- Limitamos el número de filas para facilitar aprendizaje, validación y lectura.
LIMIT 20;
-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## 14. Autoevaluación
-- MAGIC
-- MAGIC Responde sin ejecutar código adicional.
-- MAGIC
-- MAGIC 1. ¿Cuándo preferirías `TRY_CAST` en lugar de `CAST`?
-- MAGIC 2. ¿Qué diferencia práctica hay entre `TRIM`, `LTRIM` y `RTRIM`?
-- MAGIC 3. ¿En qué caso `CASE` es más conveniente que `IF`?
-- MAGIC 4. ¿Por qué conviene mantener visible la columna original junto con la transformada?
-- MAGIC 5. Si necesitas construir una etiqueta con varios campos y omitir separadores manuales, ¿usarías `CONCAT` o `CONCAT_WS`? ¿Por qué?
-- MAGIC 6. ¿Qué indicador construirías con `DATEDIFF` para tu propio contexto profesional?
-- MAGIC
-- MAGIC ### Criterio de logro sugerido
-- MAGIC - **Excelente:** puedes explicar cada función, justificar su uso y adaptar los ejemplos a otro dominio.
-- MAGIC - **Satisfactorio:** reproduces los ejemplos y entiendes su salida.
-- MAGIC - **En proceso:** aún confundes el tipo de dato o la finalidad de varias funciones.
-- MAGIC
-- MAGIC > **📝 Nota:** Si puedes modificar al menos dos consultas del laboratorio para responder nuevas preguntas del negocio, entonces ya estás usando funciones SQL con criterio analítico.
