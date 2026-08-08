---
title: 🎓 Notebook 01: Introducción a Databricks SQL
---

Fuente original: [01_introduccion_databricks_sql.sql](https://github.com/krushev36/curso-sql-python/blob/main/sql/notebooks/01_introduccion_databricks_sql.sql)

# 🎓 Notebook 01: Introducción a Databricks SQL
## Fundamentos de Programación
### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia
**Rol narrativo del curso:** eres Analista de Datos en **DataCorp Analytics**, una empresa latinoamericana que ayuda a clientes de retail, logística y movilidad a tomar decisiones con datos.
En este primer notebook conocerás el entorno de trabajo de Databricks SQL y aprenderás a explorar los datos de ejemplo que usarás como terreno seguro antes de conectar fuentes reales del negocio.

## 1. 👋 Bienvenida
Te damos la bienvenida al primer laboratorio del curso. En esta sesión iniciarás tu trabajo en Databricks como si fuera tu primer día en el equipo de analítica de DataCorp Analytics.
La meta es simple pero estratégica: **aprender a moverte con seguridad en Databricks SQL** para que, en los siguientes notebooks, puedas responder preguntas de negocio con rapidez, trazabilidad y buenas prácticas.
> **📝 Nota:** Este notebook combina explicación conceptual, demostraciones, práctica guiada y retos individuales. La idea no es memorizar consultas, sino entender **por qué** se escriben así.

## 2. 🎯 Objetivos de aprendizaje
Al finalizar este notebook serás capaz de:
1. Explicar qué es **Databricks** y qué ofrece **Databricks Free Edition**.
2. Navegar por el **workspace** y reconocer la diferencia entre notebook, catálogo, esquema y tabla.
3. Utilizar el **SQL Editor** y ejecutar celdas en un notebook de Databricks.
4. Explorar los conjuntos de datos de ejemplo `samples.tpch` y `samples.nyctaxi`.
5. Aplicar consultas básicas como `SHOW DATABASES`, `SHOW TABLES`, `DESCRIBE TABLE` y `SELECT`.
6. Emplear correctamente la sintaxis `USE CATALOG` y `USE SCHEMA` para definir el contexto de trabajo.

## 3. 🧭 Competencias
En términos de formación de maestría, este notebook desarrolla las siguientes competencias:
| Competencia | Evidencia esperada |
|---|---|
| Alfabetización en plataformas analíticas | El estudiante reconoce componentes del ecosistema Databricks y su función. |
| Exploración inicial de datos | El estudiante identifica tablas, columnas y muestras de registros. |
| Razonamiento SQL básico | El estudiante formula consultas simples con intención clara. |
| Comunicación técnica | El estudiante documenta el análisis con celdas Markdown comprensibles. |
| Pensamiento orientado al negocio | El estudiante conecta estructuras de datos con preguntas reales de la empresa. |

## 4. 🏢 Contexto empresarial
DataCorp Analytics acaba de firmar dos iniciativas internas de aceleración:
1. **Línea de clientes y pedidos**: el equipo comercial necesita una base confiable para entrenar a nuevos analistas antes de conectarse a datos sensibles de clientes reales.
2. **Línea de movilidad urbana**: el equipo de ciudades inteligentes quiere practicar con viajes de taxi para luego analizar trayectos de reparto y demanda operativa.
Para evitar riesgos con información productiva, usarás dos fuentes seguras disponibles en Databricks:
- `samples.tpch`: tablas clásicas de negocio (clientes, pedidos, productos, proveedores, regiones).
- `samples.nyctaxi`: viajes de taxi en Nueva York para practicar exploración.
La misión de hoy en DataCorp es preparar una **guía de reconocimiento del entorno y de los datos** para futuros análisis.

## 5. 🧠 Conceptos
### 5.1 ¿Qué es Databricks?
Databricks es una plataforma unificada para ingeniería de datos, analítica, ciencia de datos e inteligencia artificial. Permite trabajar con datos y código desde una misma experiencia.
### 5.2 ¿Qué es Databricks Free Edition?
Es una edición gratuita pensada para aprender, practicar y prototipar. No reemplaza un entorno empresarial completo, pero sí permite adquirir experiencia real con notebooks, SQL y catálogos de ejemplo.
**Límites a tener en cuenta:** al ser una edición formativa, suele tener restricciones frente a ediciones pagas, por ejemplo en tiempo de cómputo disponible, capacidad del entorno, opciones administrativas y persistencia de ciertos recursos.
### 5.3 Navegación básica del workspace
```text
Workspace
├── Notebooks
├── SQL Editor
├── Catálogos
│   └── Esquemas
│       └── Tablas y vistas
└── Historial de consultas
```
### 5.4 Ideas clave
- **Catálogo**: contenedor de alto nivel.
- **Esquema o base de datos**: agrupación lógica de tablas.
- **Tabla**: estructura tabular con filas y columnas.
- **Notebook**: documento con celdas de SQL y Markdown.
- **SQL Warehouse / motor SQL**: recurso que ejecuta las consultas.
> **📝 Nota:** En Databricks, entender la jerarquía `catálogo → esquema → tabla` evita muchos errores de contexto.

### 5.5 SQL Editor, ejecución de celdas y Markdown
**SQL Editor**
- Sirve para escribir y ejecutar consultas SQL de manera rápida.
- Es útil cuando deseas trabajar consulta por consulta.
**Notebook SQL**
- Organiza consultas, explicaciones y resultados en una sola pieza reproducible.
- Es ideal para clase, documentación y análisis narrativo.
**Ejecución de una celda**
- Puedes usar el botón **Run** o el atajo del entorno.
- Una celda ejecuta únicamente el bloque actual; por eso el contexto (`USE CATALOG`, `USE SCHEMA`) importa.
**Markdown en Databricks**
- Se escribe con `%md`.
- Permite documentar supuestos, hallazgos, definiciones y conclusiones.
**Datasets disponibles en este notebook**
| Catálogo | Esquema | Tablas relevantes |
|---|---|---|
| `samples` | `tpch` | `customer`, `orders`, `lineitem`, `part`, `supplier`, `nation`, `region` |
| `samples` | `nyctaxi` | `trips` |
**Relación conceptual de TPCH**
```text
region → nation → customer
               ↘ supplier
customer → orders → lineitem ← part
```

## 6. 🪜 Explicación paso a paso
### Paso 1. Ingresar al workspace
1. Abre Databricks.
2. Ubica el panel lateral izquierdo.
3. Identifica dónde están tus notebooks y el acceso a SQL.
### Paso 2. Verificar el motor de ejecución
Antes de ejecutar SQL, confirma que exista un recurso de cómputo o warehouse activo. Sin esto, la consulta no tendrá dónde correr.
### Paso 3. Crear o abrir un notebook SQL
Un notebook permite mezclar consultas y explicación. Para un curso de maestría, esto es clave porque convierte la práctica en evidencia reproducible.
### Paso 4. Alternar entre SQL y Markdown
- Usa celdas SQL para consultar datos.
- Usa celdas Markdown para explicar decisiones y resultados.
> **📝 Nota:** La documentación no es un adorno. En equipos analíticos maduros, una consulta sin contexto pierde valor rápidamente.

### Paso 5. Definir el contexto de datos
En Databricks puedes consultar una tabla de dos formas:
1. **Nombre completo**: `samples.tpch.customer`
2. **Contexto previo + nombre corto**:
   - `USE CATALOG samples;`
   - `USE SCHEMA tpch;`
   - `SELECT * FROM customer;`
### Paso 6. Explorar antes de analizar
El orden recomendado al llegar a un conjunto de datos es:
1. Ver esquemas disponibles.
2. Ver tablas disponibles.
3. Describir una tabla.
4. Tomar una muestra con `SELECT`.
### Paso 7. Interpretar errores comunes
| Error frecuente | Causa probable | Cómo corregirlo |
|---|---|---|
| Tabla no encontrada | No se definió el catálogo o esquema correcto | Revisar `USE CATALOG` y `USE SCHEMA` |
| Columna no encontrada | Se escribió mal el nombre de la columna | Revisar `DESCRIBE TABLE` |
| Consulta ejecuta en el lugar equivocado | Otra celda cambió el contexto | Repetir el contexto explícitamente |
| Salida demasiado grande | Falta `LIMIT` | Limitar muestras al explorar |

## 7. ✅ Ejemplo completamente explicado
En esta sección cada ejemplo muestra:
- **qué** se quiere lograr,
- **por qué** la consulta está escrita de esa manera,
- **qué hace cada cláusula**,
- **qué resultado esperar**, y
- **qué error es común cometer**.
> **📝 Nota:** En este curso las consultas aparecen comentadas línea por línea por decisión pedagógica. En entornos productivos puedes resumir parte de la explicación en Markdown si el equipo ya domina la sintaxis.

### Ejemplo 1 de 5: reconocer los esquemas del catálogo `samples`
**Objetivo:** confirmar qué esquemas de ejemplo están disponibles.
**Por qué esta consulta es útil:** antes de preguntar por tablas, primero necesitas saber en qué esquemas puedes trabajar.
**Resultado esperado:** verás al menos los esquemas `tpch` y `nyctaxi`.
**Error común:** intentar listar tablas sin saber primero en qué esquema estás trabajando.

```sql
-- Seleccionamos el catálogo de trabajo para dejar explícito el contexto general.
USE CATALOG samples;

-- Mostramos los esquemas o bases de datos disponibles dentro del catálogo samples.
SHOW DATABASES;
```

### Ejemplo 2 de 5: listar tablas del esquema `tpch`
**Objetivo:** identificar las tablas disponibles para el dominio de negocio TPCH.
**Por qué está escrita así:** primero fijamos el catálogo y luego el esquema para poder usar nombres cortos de tablas.
**Qué hace cada sentencia:**
- `USE CATALOG` fija el catálogo.
- `USE SCHEMA` fija el esquema.
- `SHOW TABLES` devuelve las tablas visibles en ese esquema.
**Resultado esperado:** deberían aparecer `customer`, `orders`, `lineitem`, `part`, `supplier`, `nation` y `region`.

```sql
-- Establecemos el catálogo samples para trabajar con los datos de ejemplo.
USE CATALOG samples;

-- Establecemos el esquema tpch para no repetir el nombre completo en cada consulta.
USE SCHEMA tpch;

-- Listamos las tablas disponibles dentro del esquema actual.
SHOW TABLES;
```

### Ejemplo 3 de 5: describir la tabla `customer`
**Objetivo:** inspeccionar la estructura de la tabla antes de consultarla.
**Por qué esta consulta es importante:** consultar una tabla sin conocer sus columnas lleva a errores innecesarios y dificulta entender el significado del dato.
**Resultado esperado:** una lista de columnas, tipos de datos y metadatos básicos.
**Error común:** asumir nombres de columnas por intuición en lugar de validarlos.

```sql
-- Seleccionamos el catálogo correcto para mantener consistencia de contexto.
USE CATALOG samples;

-- Seleccionamos el esquema tpch porque allí vive la tabla customer.
USE SCHEMA tpch;

-- Describimos la estructura de la tabla customer para conocer columnas y tipos.
DESCRIBE TABLE customer;
```

### Ejemplo 4 de 5: obtener una primera muestra de clientes
**Objetivo:** ver registros reales de la tabla `customer`.
**Por qué esta consulta está escrita así:** se seleccionan pocas columnas para reducir ruido y un `LIMIT` para explorar sin traer demasiada información.
**Qué hace cada cláusula:**
- `SELECT` define las columnas a observar.
- `FROM` indica la tabla origen.
- `LIMIT` restringe el tamaño de la muestra.
**Resultado esperado:** una tabla con identificador del cliente, nombre, saldo y segmento de mercado.
**Error común:** usar `SELECT *` en las primeras exploraciones cuando todavía no sabes qué columnas te interesan.

```sql
-- Seleccionamos el catálogo samples para apuntar al entorno de práctica.
USE CATALOG samples;

-- Seleccionamos el esquema tpch para consultar la tabla customer con nombre corto.
USE SCHEMA tpch;

-- Elegimos las columnas mínimas que ayudan a perfilar al cliente.
SELECT
-- Identificador único del cliente dentro del dataset.
  c_custkey,
-- Nombre comercial o referencia textual del cliente.
  c_name,
-- Saldo de cuenta reportado para el cliente.
  c_acctbal,
-- Segmento de mercado al que pertenece el cliente.
  c_mktsegment
-- Indicamos la tabla de origen que contiene el maestro de clientes.
FROM customer
-- Limitamos la salida para obtener solo una muestra inicial.
LIMIT 10;
```

### Ejemplo 5 de 5: ver una muestra de viajes en `samples.nyctaxi.trips`
**Objetivo:** confirmar que también podemos explorar un dominio distinto al comercial, en este caso movilidad.
**Por qué esta consulta usa `SELECT *`:** al ser la primera aproximación a una tabla desconocida, ver todas las columnas de una muestra pequeña ayuda a identificar su estructura visual. Aquí es una **excepción controlada** a la recomendación general de evitar `SELECT *`, porque el objetivo no es analizar sino reconocer el inventario completo de campos.
**Resultado esperado:** una muestra de registros de viajes de taxi con múltiples columnas operativas.
**Error común:** traer demasiadas filas sin `LIMIT`, lo que hace más lenta y menos legible la exploración.

```sql
-- Seleccionamos el catálogo samples para seguir trabajando con datos de ejemplo.
USE CATALOG samples;

-- Seleccionamos el esquema nyctaxi porque allí se encuentra la tabla trips.
USE SCHEMA nyctaxi;

-- Tomamos una muestra completa de la tabla trips para reconocer sus columnas de forma visual.
SELECT
-- El asterisco indica que queremos todas las columnas disponibles en la tabla.
  *
-- Indicamos que la información proviene de la tabla de viajes trips.
FROM trips
-- Restringimos la salida a diez filas para que la inspección siga siendo manejable.
LIMIT 10;
```

## 8. 🧪 Ejemplo guiado
En esta sección ya no solo observas: ahora ejecutas consultas con una intención concreta. La idea es que leas la explicación, corras la celda y confirmes si el resultado coincide con tu expectativa.

### Ejemplo guiado 1 de 5: usar el nombre completamente calificado
**Meta:** comprobar que puedes consultar una tabla sin cambiar de esquema.
**Por qué conviene aprender esto:** cuando trabajas en notebooks largos, el nombre completo reduce ambigüedad y mejora la trazabilidad.
**Resultado esperado:** una muestra corta de clientes usando `samples.tpch.customer`.

```sql
-- Seleccionamos columnas simples para una revisión rápida del maestro de clientes.
SELECT
-- Clave única del cliente.
  c_custkey,
-- Nombre del cliente.
  c_name
-- Indicamos la tabla usando catálogo, esquema y tabla en una sola referencia.
FROM samples.tpch.customer
-- Limitamos la muestra para una inspección rápida.
LIMIT 5;
```

### Ejemplo guiado 2 de 5: inspeccionar la estructura de `orders`
**Meta:** reconocer qué campos pueden responder preguntas sobre pedidos.
**Resultado esperado:** columnas relacionadas con cliente, fecha, estado y valor total del pedido.
**Error común:** pensar que `orders` ya contiene el detalle de productos; ese detalle realmente vive en `lineitem`.

```sql
-- Seleccionamos el catálogo samples para mantener el trabajo dentro del entorno de práctica.
USE CATALOG samples;

-- Seleccionamos el esquema tpch donde está la tabla orders.
USE SCHEMA tpch;

-- Describimos la tabla orders para identificar columnas útiles para análisis posteriores.
DESCRIBE TABLE orders;
```

### Ejemplo guiado 3 de 5: leer una muestra operativa de pedidos
**Meta:** revisar algunos pedidos con sus atributos más importantes.
**Por qué esta combinación de columnas:** permite enlazar el pedido con el cliente, su estado, monto y fecha sin exceso de detalle.
**Resultado esperado:** filas con claves de pedido, cliente asociado, monto total y fecha.

```sql
-- Seleccionamos el catálogo de ejemplo para asegurar consistencia del contexto.
USE CATALOG samples;

-- Seleccionamos el esquema tpch para usar nombres cortos de tabla.
USE SCHEMA tpch;

-- Elegimos columnas que resumen la identidad y el valor del pedido.
SELECT
-- Clave única del pedido.
  o_orderkey,
-- Clave del cliente que realizó el pedido.
  o_custkey,
-- Estado del pedido dentro del proceso de negocio.
  o_orderstatus,
-- Valor monetario total del pedido.
  o_totalprice,
-- Fecha asociada al pedido.
  o_orderdate
-- Señalamos la tabla orders como fuente del resultado.
FROM orders
-- Limitamos a diez filas para leer la muestra con comodidad.
LIMIT 10;
```

### Ejemplo guiado 4 de 5: revisar el detalle transaccional de `lineitem`
**Meta:** observar cómo se ven las líneas de detalle asociadas a los pedidos.
**Por qué es relevante:** en cursos posteriores necesitarás distinguir entre una tabla cabecera (`orders`) y una tabla de detalle (`lineitem`).
**Resultado esperado:** filas con pedido, producto, proveedor, cantidad y valor extendido.

```sql
-- Seleccionamos el catálogo de ejemplo para evitar confusión con otros catálogos.
USE CATALOG samples;

-- Seleccionamos el esquema tpch donde vive la tabla lineitem.
USE SCHEMA tpch;

-- Seleccionamos columnas clave del detalle transaccional.
SELECT
-- Clave del pedido al que pertenece la línea.
  l_orderkey,
-- Clave de la parte o producto vendido.
  l_partkey,
-- Clave del proveedor asociado a la línea.
  l_suppkey,
-- Cantidad solicitada en la línea.
  l_quantity,
-- Valor monetario extendido de la línea.
  l_extendedprice
-- Leemos la información desde la tabla lineitem.
FROM lineitem
-- Tomamos una muestra pequeña para inspección inicial.
LIMIT 10;
```

### Ejemplo guiado 5 de 5: revisar la dimensión geográfica `region`
**Meta:** identificar una tabla pequeña de referencia.
**Por qué este ejemplo importa:** no todas las tablas son transaccionales; algunas sirven como catálogos de apoyo para contextualizar otras entidades.
**Resultado esperado:** una lista corta de regiones con su identificador.

```sql
-- Seleccionamos el catálogo samples para permanecer en los datos de laboratorio.
USE CATALOG samples;

-- Seleccionamos el esquema tpch porque contiene la tabla region.
USE SCHEMA tpch;

-- Consultamos la dimensión region para ver una estructura pequeña y fácil de interpretar.
SELECT
-- Identificador único de la región.
  r_regionkey,
-- Nombre descriptivo de la región.
  r_name
-- Indicamos la tabla de referencia geográfica.
FROM region
-- Limitamos la salida para mostrar únicamente una muestra breve.
LIMIT 5;
```

## 9. 🧩 Ejercicio guiado
Resuelve los siguientes ejercicios **con apoyo del docente o de tus apuntes**. La dificultad progresa de **Muy Fácil** a **Desafío**.
| # | Nivel | Consigna | Pista técnica | Validación esperada |
|---|---|---|---|---|
| 1 | Muy Fácil | Mostrar los esquemas disponibles dentro de `samples`. | Usa `USE CATALOG samples` y luego `SHOW DATABASES`. | Deben aparecer `tpch` y `nyctaxi`. |
| 2 | Fácil | Listar las tablas del esquema `tpch`. | Define primero `USE CATALOG samples` y `USE SCHEMA tpch`. | Debes ver al menos 7 tablas. |
| 3 | Intermedio | Describir la tabla `supplier`. | Usa `DESCRIBE TABLE supplier`. | Debes identificar columnas de proveedor y geografía. |
| 4 | Intermedio Alto | Mostrar 8 filas de `part` con identificador, nombre y marca. | Usa `SELECT` con columnas puntuales y `LIMIT 8`. | La salida debe incluir `p_partkey`, `p_name` y `p_brand`. |
| 5 | Desafío | Consultar 6 registros de `samples.nyctaxi.trips` sin cambiar el esquema actual. | Usa el nombre completamente calificado. | La consulta debe funcionar aunque sigas en `tpch`. |
> **📝 Nota:** Si un ejercicio falla, revisa primero el **contexto activo** y luego los nombres exactos de columnas o tablas.

## 10. ✍️ Ejercicio individual
Ahora trabaja sin mirar las soluciones anteriores. La meta es ganar autonomía técnica.
| # | Nivel | Reto individual | Producto esperado |
|---|---|---|---|
| 1 | Muy Fácil | Explica en tus palabras la diferencia entre catálogo, esquema y tabla. | Un párrafo corto en Markdown. |
| 2 | Fácil | Explora la tabla `nation` y anota qué columna parece conectar con `region`. | Una consulta `DESCRIBE TABLE nation` y una observación escrita. |
| 3 | Intermedio | Muestra 10 filas de `orders` con `o_orderkey`, `o_orderdate` y `o_totalprice`. | Una consulta legible con `LIMIT`. |
| 4 | Intermedio Alto | Muestra 10 filas de `customer` con `c_name`, `c_nationkey` y `c_mktsegment`. | Una consulta que evidencie lectura selectiva de columnas. |
| 5 | Desafío | Explora `trips` y redacta tres posibles preguntas de negocio que podrían responderse con esa tabla. | Una muestra de datos y tres preguntas en Markdown. |
**Criterio de logro:** si puedes explicar **por qué elegiste cada cláusula**, entonces ya no estás copiando SQL; estás razonando con SQL.

## 11. 🚀 Desafío
En esta sección aplicas lo aprendido a situaciones más abiertas. No necesitas resolver todo hoy, pero sí debes plantear una estrategia clara.
| # | Nivel progresivo | Desafío | Sugerencia metodológica |
|---|---|---|---|
| 1 | Muy Fácil | Crear una mini guía visual del workspace con tus propias palabras. | Usa una celda Markdown con lista jerárquica. |
| 2 | Fácil | Identificar qué tabla usarías primero para estudiar clientes y por qué. | Compara `customer` frente a `orders`. |
| 3 | Intermedio | Proponer una ruta de exploración para entender el ciclo cliente → pedido → detalle. | Enumera tablas y propósito de cada una. |
| 4 | Intermedio Alto | Diseñar una tabla de “primeras verificaciones” con columnas a revisar en `customer`, `orders` y `trips`. | Usa Markdown tabular. |
| 5 | Desafío | Redactar un protocolo de onboarding para un nuevo analista en Databricks SQL. | Incluye contexto, exploración, validación y documentación. |
> **📝 Nota:** Un desafío bien resuelto no siempre significa “tener la consulta perfecta”; a menudo significa **formular bien el problema**.

## 12. 📌 Resumen
En este notebook aprendiste que:
- Databricks es una plataforma unificada para análisis y ciencia de datos.
- Databricks Free Edition es suficiente para aprender la mecánica básica del entorno.
- El workspace organiza notebooks, editor SQL, catálogos y objetos de datos.
- La jerarquía clave es **catálogo → esquema → tabla**.
- Las consultas de arranque más importantes son `SHOW DATABASES`, `SHOW TABLES`, `DESCRIBE TABLE` y `SELECT`.
- Definir el contexto con `USE CATALOG` y `USE SCHEMA` reduce errores.
- Markdown convierte un notebook en un activo reproducible y comunicable.
**Idea fuerza:** antes de analizar, primero debes **orientarte** en la plataforma y **reconocer** la estructura de los datos.

## 13. 🧪 Laboratorio
En DataCorp Analytics te piden una primera exploración reproducible para cuatro necesidades de negocio. Cada pregunta debe responderse con SQL claro y bien documentado.
**Regla del laboratorio:** ejecuta cada consulta, observa el resultado y luego escribe una breve interpretación en Markdown.

### Laboratorio 1: preparación de una ficha maestra de clientes
**Pregunta de negocio:** el líder comercial quiere validar qué campos del maestro de clientes podrían usarse en una futura segmentación.
**Tu tarea:** inspeccionar estructura y traer una muestra corta y legible.

```sql
-- Seleccionamos el catálogo de ejemplo para trabajar con datos seguros de entrenamiento.
USE CATALOG samples;

-- Seleccionamos el esquema tpch porque allí se encuentra el maestro de clientes.
USE SCHEMA tpch;

-- Consultamos columnas representativas del cliente para una ficha inicial de negocio.
SELECT
-- Identificador del cliente que permite referencia única.
  c_custkey,
-- Nombre del cliente para identificación humana.
  c_name,
-- Clave geográfica asociada al cliente.
  c_nationkey,
-- Segmento comercial del cliente.
  c_mktsegment,
-- Saldo o balance de cuenta del cliente.
  c_acctbal
-- Indicamos la tabla customer como origen de la muestra.
FROM customer
-- Reducimos la salida a doce filas para facilitar la revisión en pantalla.
LIMIT 12;
```

### Laboratorio 2: revisión rápida del catálogo de pedidos
**Pregunta de negocio:** el equipo de revenue desea saber qué atributos básicos tiene un pedido antes de diseñar un tablero.
**Tu tarea:** describir la tabla y luego tomar una muestra breve.

```sql
-- Seleccionamos el catálogo samples para permanecer dentro del entorno de práctica.
USE CATALOG samples;

-- Seleccionamos el esquema tpch porque allí vive la tabla orders.
USE SCHEMA tpch;

-- Describimos la tabla orders para revisar la estructura que después usará el equipo de revenue.
DESCRIBE TABLE orders;
```

### Laboratorio 3: reconocimiento de datos para movilidad urbana
**Pregunta de negocio:** el área de ciudades inteligentes necesita una primera lectura de los viajes disponibles para imaginar indicadores operativos.
**Tu tarea:** explorar la tabla `trips` y documentar tres columnas que te parezcan críticas.

```sql
-- Seleccionamos el catálogo samples para acceder a los datos de entrenamiento.
USE CATALOG samples;

-- Seleccionamos el esquema nyctaxi porque contiene la tabla trips.
USE SCHEMA nyctaxi;

-- Tomamos una muestra amplia de columnas para reconocer el tipo de información operativa disponible.
SELECT
-- Usamos todas las columnas porque todavía estamos en una fase puramente exploratoria.
  *
-- Indicamos la tabla de viajes como fuente del resultado.
FROM trips
-- Limitamos la salida a ocho filas para que la revisión visual sea manejable.
LIMIT 8;
```

### Laboratorio 4: muestra de proveedores para reunión con compras
**Pregunta de negocio:** el área de abastecimiento quiere ver una muestra de proveedores y su vínculo geográfico antes de definir reglas de evaluación.
**Tu tarea:** consultar una muestra simple de la tabla `supplier`.

```sql
-- Seleccionamos el catálogo samples para seguir en el ambiente de práctica.
USE CATALOG samples;

-- Seleccionamos el esquema tpch porque contiene la dimensión supplier.
USE SCHEMA tpch;

-- Elegimos columnas que permitan reconocer al proveedor y su ubicación relativa.
SELECT
-- Identificador único del proveedor.
  s_suppkey,
-- Nombre del proveedor.
  s_name,
-- Clave de la nación asociada al proveedor.
  s_nationkey,
-- Balance de cuenta del proveedor.
  s_acctbal
-- Señalamos la tabla supplier como origen de la muestra.
FROM supplier
-- Mostramos solo diez filas para una lectura rápida en reunión.
LIMIT 10;
```

## 14. 📝 Autoevaluación
Responde sin ejecutar nuevas consultas:
1. ¿Cuál es la diferencia entre usar `samples.tpch.customer` y usar `USE CATALOG samples` + `USE SCHEMA tpch` + `FROM customer`?
2. ¿Por qué conviene ejecutar `DESCRIBE TABLE` antes de escribir una consulta más larga?
3. ¿Qué problema evita `LIMIT` durante la exploración inicial?
4. ¿En qué situación preferirías un notebook sobre el SQL Editor?
5. ¿Qué tablas del esquema `tpch` parecen pertenecer al flujo cliente → pedido → detalle?
6. ¿Qué evidencia te da una celda Markdown que una consulta sola no proporciona?

### Criterio de cierre
Considera que dominaste este notebook si puedes hacer, sin ayuda:
- Entrar a Databricks y ubicar el workspace.
- Explicar la diferencia entre catálogo, esquema y tabla.
- Explorar `samples.tpch` y `samples.nyctaxi` con consultas básicas.
- Ejecutar una celda SQL y documentar el resultado en Markdown.
- Justificar por qué una consulta está escrita de una forma y no de otra.
**Siguiente paso en la historia de DataCorp Analytics:** en el Notebook 02 comenzarás a filtrar y perfilar datos para responder preguntas operativas con mayor precisión.
