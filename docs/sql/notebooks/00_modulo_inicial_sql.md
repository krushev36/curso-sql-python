---
title: 🎓 Módulo 00: Introducción general a SQL
---

Fuente original: [00_modulo_inicial_sql.sql](https://github.com/krushev36/curso-sql-python/blob/main/sql/notebooks/00_modulo_inicial_sql.sql)

# 🎓 Módulo 00: Introducción general a SQL
## Historia, fundamentos y modelado de datos
**Objetivo del módulo:** comprender qué es SQL, cómo interactúan los usuarios con una base de datos y cuáles son los conceptos de modelado, estructura de datos y tipos de datos que permiten organizar la información de forma confiable.

## 1. Breve historia de SQL
**SQL significa *Structured Query Language***, o en español, **Lenguaje de Consulta Estructurada**. Se usa para definir, consultar, transformar y administrar datos almacenados en sistemas de bases de datos.
SQL nace en la década de 1970 a partir del modelo relacional propuesto por **Edgar F. Codd** en IBM.
Hitos clave:
- **1970:** publicación del modelo relacional.
- **1974–1979:** desarrollo de SEQUEL/SQL en IBM.
- **1986:** SQL se convierte en estándar ANSI.
- **1987 en adelante:** adopción ISO y evolución continua con nuevas versiones.
Desde entonces, SQL se consolidó como el lenguaje estándar para consultar, organizar y transformar datos estructurados.

## 2. ¿Cómo funciona SQL?
SQL es un lenguaje **declarativo**: el analista indica **qué quiere obtener**, y el motor de base de datos decide **cómo ejecutar** la consulta de la forma más eficiente posible.
Flujo general:
1. El usuario escribe una consulta (`SELECT`, `WHERE`, `GROUP BY`, `JOIN`, etc.).
2. El gestor de base de datos valida sintaxis, permisos y objetos usados.
3. El optimizador genera un plan de ejecución.
4. El motor accede a tablas, índices y memoria.
5. El sistema devuelve un resultado tabular al usuario o a una aplicación.
Tipos de operaciones más comunes:
- **Consulta:** `SELECT`
- **Inserción:** `INSERT`
- **Actualización:** `UPDATE`
- **Eliminación:** `DELETE`
- **Integración de datos:** `JOIN`
- **Agregación:** `GROUP BY`, `HAVING`

## ¿Cómo se aloja una base de datos en un servidor? ¿Qué es una base de datos, un esquema, una tabla, una vista y un stored procedure?
- **Base de datos:** Es un conjunto organizado de datos almacenados y gestionados por un sistema de gestión de bases de datos (DBMS). Una base de datos puede contener múltiples esquemas, tablas, vistas y otros objetos. Se aloja en un servidor, que puede ser físico, virtual o en la nube, y es accesible por usuarios o aplicaciones a través de una red.
- **Esquema:** Es una estructura lógica dentro de una base de datos que agrupa objetos relacionados, como tablas, vistas y procedimientos almacenados. Ayuda a organizar y separar los objetos según áreas funcionales o de negocio.
- **Tabla:** Es el objeto principal donde se almacenan los datos en filas y columnas. Cada columna tiene un tipo de dato definido y cada fila representa un registro.
- **Vista:** Es una consulta guardada que presenta datos de una o varias tablas como si fuera una tabla virtual. Permite simplificar consultas complejas, restringir acceso o mostrar información personalizada sin duplicar datos.
- **Stored Procedure (Procedimiento almacenado):** Es un bloque de código SQL guardado en la base de datos que puede ejecutarse para realizar tareas específicas, como insertar, actualizar o consultar datos. Permite automatizar procesos y reutilizar lógica de negocio.
![](../../images/diagrama_jerarquia_sql_server.png)

## Jerarquía de objetos en Unity Catalog
**Unity Catalog** es el sistema de gobierno y gestión de datos unificado de Databricks. Proporciona un catálogo centralizado para organizar, asegurar y auditar todos los activos de datos en una plataforma Lakehouse.
A diferencia de los sistemas tradicionales de bases de datos (como SQL Server o PostgreSQL), Unity Catalog introduce una **jerarquía de tres niveles** diseñada específicamente para entornos de datos modernos, multicloud y de gran escala.
### Jerarquía de Unity Catalog (de mayor a menor nivel)
#### 1. **Metastore**
Es el contenedor de nivel superior en Unity Catalog. Un metastore:
- Almacena metadatos sobre todos los objetos de datos (catálogos, esquemas, tablas, vistas, funciones, volúmenes).
- Puede asociarse a una o varias workspaces de Databricks.
- Define el límite de seguridad y gobierno para todos los datos que administra.
- Generalmente hay **un metastore por región** o por organización, dependiendo de la estrategia de gobierno.
#### 2. **Catalog (Catálogo)**
Es el primer nivel de organización lógica dentro de un metastore. Un catálogo:
- Agrupa esquemas relacionados según un área funcional, proyecto o entorno.
- Permite separar datos de desarrollo, pruebas y producción.
- Facilita el control de acceso a nivel de proyecto o equipo.
- Ejemplos de nombres de catálogo: `ventas`, `marketing`, `desarrollo`, `produccion`.
#### 3. **Schema (Esquema)**
Es el segundo nivel de organización dentro de un catálogo. Un esquema:
- Agrupa objetos relacionados como tablas, vistas, funciones y volúmenes.
- Equivale al concepto tradicional de "schema" o "database" en otros motores SQL.
- Permite organizar datos por área funcional específica o tema.
- Ejemplos de nombres de esquema: `clientes`, `transacciones`, `productos`, `reportes`.
#### 4. **Objetos de datos**
Dentro de cada esquema existen los objetos que realmente contienen o procesan datos:
- **Tablas:** almacenan datos estructurados en formato Delta (o Parquet, CSV, JSON, etc.).
- **Vistas:** consultas guardadas que presentan datos sin duplicarlos físicamente.
- **Vistas materializadas:** consultas precalculadas y almacenadas para mejorar el rendimiento.
- **Funciones (UDFs):** código reutilizable para transformar o calcular datos.
- **Volúmenes:** almacenamiento de archivos no tabulares (imágenes, PDFs, modelos de ML, etc.).
### Representación visual de la jerarquía
```text
Metastore (nivel regional/organizacional)
│
├─ Catalog: ventas
│  ├─ Schema: clientes
│  │  ├─ Tabla: clientes_activos
│  │  ├─ Vista: clientes_resumen
│  │  └─ Función: calcular_descuento()
│  │
│  └─ Schema: transacciones
│     ├─ Tabla: pedidos
│     ├─ Tabla: pagos
│     └─ Vista: ventas_diarias
│
├─ Catalog: marketing
│  ├─ Schema: campanas
│  │  ├─ Tabla: campanas_email
│  │  └─ Volumen: imagenes_campanas
│  │
│  └─ Schema: analisis
│     └─ Tabla: metricas_conversion
│
└─ Catalog: desarrollo
   └─ Schema: sandbox
      ├─ Tabla: prueba_datos
      └─ Vista: vista_temporal
```
![](../../images/diagrama_jerarquia_unity_catalog.png)
### Nomenclatura completa (fully qualified name)
Para referenciar un objeto en Unity Catalog se usa la notación de tres niveles:
```sql
-- Formato: catalog.schema.tabla
SELECT * FROM ventas.clientes.clientes_activos;
-- Formato: catalog.schema.vista
SELECT * FROM ventas.transacciones.ventas_diarias;
-- Formato: catalog.schema.funcion()
SELECT ventas.clientes.calcular_descuento(monto) AS descuento;
```
### Ventajas de Unity Catalog frente a sistemas tradicionales
| Aspecto | Sistemas tradicionales | Unity Catalog |
|---------|------------------------|---------------|
| **Ámbito** | Una sola base de datos o servidor | Multicloud, múltiples workspaces |
| **Gobierno** | Por base de datos | Centralizado en toda la organización |
| **Auditoría** | Limitada o manual | Automática y completa (quién, qué, cuándo) |
| **Linaje de datos** | Requiere herramientas externas | Integrado nativamente |
| **Control de acceso** | Por tabla o esquema | Granular: catalog, schema, tabla, columna, fila |
| **Compartir datos** | Copias o ETL | Delta Sharing (sin mover datos) |
| **Tipos de datos** | Solo tabulares | Tabulares + archivos (volúmenes) + funciones |
### Ejemplo práctico en este curso
En los notebooks de SQL de este curso trabajarás con:
- **Metastore:** ya configurado en tu workspace de Databricks
- **Catálogo:** `samples` (catálogo de ejemplo de Databricks) o catálogos propios
- **Esquemas:** `tpch`, `tpcds_sf1`, `wanderbricks`, etc.
- **Tablas:** `customer`, `orders`, `lineitem`, `bookings`, etc.
Por ejemplo:
```sql
-- Consultar la tabla de clientes en el esquema tpch del catálogo samples
SELECT * FROM samples.tpch.customer LIMIT 10;
```
### Diferencia clave con la jerarquía tradicional
**Jerarquía tradicional (SQL Server, PostgreSQL):**
```
Servidor → Base de datos → Esquema → Tabla
```
**Jerarquía Unity Catalog (Databricks):**
```
Metastore → Catálogo → Esquema → Tabla/Vista/Volumen/Función
```
La principal diferencia es que Unity Catalog agrega una **capa de abstracción superior** (metastore y catálogo) que permite:
- Gestionar datos a escala empresarial
- Unificar gobierno entre múltiples equipos y proyectos
- Soportar arquitecturas de datos modernas (data lakehouse)
- Compartir datos de forma segura sin duplicarlos

## 3. Comunicación entre usuario y base de datos
La interacción con una base de datos casi nunca ocurre de forma aislada. Normalmente participan un usuario, una herramienta cliente, una red, el motor SQL y el almacenamiento físico.
### Diagrama general de comunicación
![Diagrama de comunicación entre usuario y base de datos](https://raw.githubusercontent.com/krushev36/curso-sql-python/main/images/comunicacion_usuario_bd.png)
**Idea clave:** el usuario no interactúa directamente con los archivos de datos; se comunica con el motor SQL, que protege, organiza y optimiza el acceso a la información.

## 4. Esquemas, modelos y tipos de datos
Un **modelo de datos** es la representación lógica de cómo se organizan las entidades del negocio, sus atributos y sus relaciones.
Un **esquema** es la estructura concreta donde quedan definidas tablas, columnas, tipos de dato, llaves y relaciones.
### 4.1 Modelo relacional
En el **modelo relacional** la información se organiza en **tablas** compuestas por filas y columnas.
Sus características principales son:
- cada tabla representa una entidad o un tema del negocio,
- cada fila representa un registro,
- cada columna representa un atributo,
- las tablas se conectan mediante llaves primarias y foráneas.
Este modelo favorece la **consistencia**, la **integridad** y el uso de SQL para consultar la información.
### 4.2 Modelo no relacional
El **modelo no relacional** agrupa varias familias de bases de datos conocidas como **NoSQL**.
En lugar de depender siempre de tablas relacionadas, puede almacenar la información como:
- **documentos** (por ejemplo JSON),
- **pares clave-valor**,
- **grafos**,
- **columnas anchas**.
Suele usarse cuando se necesita alta escalabilidad, esquemas más flexibles o manejo de datos muy variados y cambiantes. A cambio, puede sacrificar parte de la rigidez estructural típica de los sistemas relacionales.
### 4.3 Datos estructurados y no estructurados
Los **datos estructurados** siguen un formato definido y consistente, por lo que encajan con facilidad en tablas.
Ejemplos de datos estructurados:
- número de cliente,
- fecha de compra,
- valor de una factura,
- ciudad de residencia.
Los **datos no estructurados** no siguen una estructura tabular fija y suelen presentarse como contenido libre o multimedia.
Ejemplos de datos no estructurados:
- correos electrónicos,
- documentos PDF,
- imágenes,
- audio,
- publicaciones en redes sociales.
Entre ambos extremos también existen datos **semiestructurados**, como XML o JSON, que conservan cierto orden pero no necesariamente el de una tabla relacional clásica.
### 4.4 Tipos de datos en SQL
Los **tipos de datos** indican qué clase de valor puede almacenar una columna y qué operaciones son válidas sobre ella.
Tipos comunes en SQL:
- **Numéricos:** `INT`, `BIGINT`, `DECIMAL`, `DOUBLE`
- **Texto:** `CHAR`, `VARCHAR`, `STRING`
- **Fecha y hora:** `DATE`, `TIMESTAMP`
- **Booleanos:** `BOOLEAN`
- **Binarios o especiales:** `BINARY`, y en algunos motores también `JSON`, `ARRAY`, `MAP`
Elegir bien el tipo de dato ayuda a mejorar la calidad de la información, ahorrar almacenamiento y evitar errores en cálculos, filtros y comparaciones.
### ¿Qué responde un buen modelo de datos?
- ¿Qué entidades existen? (clientes, pedidos, productos, pagos)
- ¿Qué atributos tiene cada entidad?
- ¿Cómo se relacionan entre sí?
- ¿Qué reglas garantizan calidad y consistencia?
### Niveles comunes del modelado
- **Modelo conceptual:** describe el negocio a alto nivel.
- **Modelo lógico:** define entidades, atributos y relaciones sin depender de una tecnología específica.
- **Modelo físico:** traduce el diseño a tablas reales, tipos de datos, índices y particiones.

## 5. ¿Cómo se diseña un modelo de datos?
El diseño de un modelo de datos parte de preguntas del negocio, no de la tecnología.
Proceso recomendado:
1. **Entender el proceso de negocio:** ventas, entregas, clientes, facturación, inventario.
2. **Identificar entidades principales:** por ejemplo `clientes`, `pedidos`, `productos`.
3. **Definir atributos relevantes:** nombre, fecha, monto, estado, categoría.
4. **Establecer relaciones:** qué tabla depende de otra y en qué cardinalidad.
5. **Definir llaves:** primaria, foránea y candidatas para identificar registros.
6. **Normalizar o desnormalizar según el uso:** operación transaccional vs. analítica.
7. **Validar con casos reales de consulta:** asegurar que el diseño responde preguntas del negocio.
**Diseñar bien un modelo** mejora la calidad del dato, reduce duplicidad y facilita consultas más claras.

## 6. Relaciones entre tablas
Las relaciones permiten conectar tablas sin repetir innecesariamente la información.
### 6.1 Relación uno a muchos
Es la relación más frecuente en bases de datos relacionales.
Ejemplo:
- Un **cliente** puede tener **muchos pedidos**.
- Cada **pedido** pertenece a **un solo cliente**.
```text
CLIENTES
┌───────────────┐
│ id_cliente PK │
│ nombre        │
└───────────────┘
         ▲
         │
PEDIDOS  │
┌────────────────────┐
│ id_pedido PK       │
│ id_cliente FK ─────┘
│ fecha_pedido       │
│ total              │
└────────────────────┘
```
### 6.2 Muchos a uno
Es la misma relación vista desde el lado contrario:
- Muchos **pedidos** apuntan a un solo **cliente**.
- Muchas **líneas de pedido** pueden apuntar a un solo **producto**.
**Idea clave:** una relación uno a muchos siempre puede leerse también como muchos a uno, dependiendo del punto de vista.

## 7. Llaves principales, secundarias, foráneas e índices
### 7.1 Llave primaria (*Primary Key*)
Identifica de forma **única** cada fila de una tabla.
Ejemplo:
- `id_cliente` en `clientes`
- `id_pedido` en `pedidos`
Reglas habituales:
- No se repite.
- No debe ser nula.
- Debe identificar exactamente un registro.
### 7.2 Llave candidata o alternativa
El nombre técnico más usado en bases de datos es **llave candidata** o **llave alternativa**. En algunos materiales introductorios también se menciona como **llave secundaria**, pero en este notebook priorizaremos la terminología estándar.
Ejemplos:
- `numero_documento`
- `correo_electronico`
- `codigo_producto`
Estas llaves ayudan a localizar registros y a imponer unicidad sobre atributos relevantes del negocio, pero no siempre son la llave principal elegida en el diseño final. Una tabla puede conservar su llave primaria técnica y, al mismo tiempo, exigir que campos como el correo o el número de documento también sean únicos.
### 7.3 Llave foránea (*Foreign Key*)
Es una columna que guarda el identificador de otra tabla para crear la relación entre ambas.
Ejemplo:
- `pedidos.id_cliente` referencia `clientes.id_cliente`
Su función es mantener la **integridad referencial**, es decir, evitar que existan pedidos asociados a clientes inexistentes.
### 7.4 Índices
Un **índice** es una estructura auxiliar que acelera la búsqueda de datos, similar al índice de un libro.
Casos típicos:
- Búsquedas por identificador
- Filtros frecuentes por fecha o categoría
- Uniones recurrentes entre tablas
**Importante:** un índice mejora lecturas, pero también puede aumentar el costo de inserciones y actualizaciones porque el motor debe mantener la estructura del índice cada vez que cambian los datos. Por eso conviene crear índices en columnas muy consultadas o usadas en uniones, y evitar indexar en exceso columnas con poco uso analítico.

## 8. ¿Cómo se relacionan las tablas a través de las llaves?
La conexión entre tablas ocurre cuando una **llave foránea** de una tabla apunta a la **llave primaria** de otra.
```text
CLIENTES
┌───────────────┐
│ id_cliente PK │
│ nombre        │
│ ciudad        │
└───────────────┘
         ▲
         │
PEDIDOS  │
┌────────────────────┐
│ id_pedido PK       │
│ id_cliente FK ─────┘
│ fecha_pedido       │
└────────────────────┘
```
Gracias a esta relación es posible:
- saber qué pedidos pertenecen a cada cliente,
- unir información con `JOIN`,
- evitar duplicar el nombre del cliente en cada pedido,
- conservar consistencia entre entidades.
En SQL esto habilita consultas como:
- listar clientes con sus pedidos,
- sumar ventas por cliente,
- filtrar productos comprados por región o segmento.

### Diagrama Entidad-Relación
Un **diagrama entidad-relación (ER)** es una herramienta visual que representa cómo se organizan y conectan las entidades principales de un sistema de datos. Cada entidad se muestra como un rectángulo (por ejemplo, clientes, pedidos, productos), y las relaciones entre ellas se indican con líneas que conectan los rectángulos. El diagrama ayuda a entender la estructura lógica de la base de datos, las llaves primarias y foráneas, y cómo se vinculan los datos sin duplicar información.
#### Tipos de relaciones entre entidades
- **Relación 1 a 1:** Cada registro de una entidad se asocia con un solo registro de otra entidad. Ejemplo: cada persona tiene un único pasaporte.
- **Relación 1 a N (uno a muchos):** Un registro de una entidad puede estar relacionado con varios registros de otra entidad, pero cada registro de la segunda entidad solo se asocia a uno de la primera. Ejemplo: un cliente puede tener muchos pedidos.
- **Relación N a 1 (muchos a uno):** Muchos registros de una entidad se asocian a un solo registro de otra entidad. Ejemplo: muchos pedidos pertenecen a un solo cliente.
![Diagrama Entidad Relación del Dataset TPCH](../../images/modelo_tpch.png)

### Ejemplo de Diagrama Entidad Relacion
El dataset **Wanderbricks** contiene información sobre reservas de propiedades turísticas. Cada registro representa una reserva e incluye datos como el identificador de la reserva (`booking_id`), el usuario que realiza la reserva (`user_id`), la propiedad reservada (`property_id`), fechas de check-in y check-out, número de huéspedes, monto total pagado, estado de la reserva y fechas de creación y actualización.
#### Diagrama Entidad-Relación
![](../../images/modelo_wanderbricks.png)
Este dataset sigue un **modelo relacional**: la información se organiza en tablas conectadas mediante llaves primarias y foráneas, lo que permite mantener la integridad y facilitar consultas entre entidades como usuarios, propiedades y reservas.

## 9. Modelos de datos para analítica: estrella y copo de nieve
En analítica y *data warehousing* es común organizar los datos para facilitar consultas, métricas y tableros.
### 9.1 Modelo estrella
Tiene una **tabla de hechos** en el centro y varias **dimensiones** alrededor.
- **Tabla de hechos:** almacena eventos medibles (ventas, viajes, órdenes).
- **Dimensiones:** almacenan contexto descriptivo (cliente, producto, tiempo, región).
![Diagrama de modelo estrella](https://raw.githubusercontent.com/krushev36/curso-sql-python/main/images/modelo_estrella.png)
**Ventajas del modelo estrella:**
- consultas más simples,
- buen desempeño analítico,
- fácil lectura para negocio y BI.
#### 9.1.1 Ejemplo de modelo estrella
![](../../images/modelo_tpcds_sf1.png)
### 9.2 Modelo copo de nieve
Es una variación del modelo estrella donde algunas dimensiones se descomponen en subdimensiones más normalizadas.
![Diagrama de modelo copo de nieve](https://raw.githubusercontent.com/krushev36/curso-sql-python/main/images/modelo_copo_nieve.png)
**Ventajas del copo de nieve:**
- reduce redundancia en dimensiones,
- mejora control sobre jerarquías,
- puede facilitar gobierno de datos.
**Desventaja frente al estrella:** suele requerir más `JOIN`, por lo que el análisis puede volverse más complejo para el usuario.

## 10. Principales motores y versiones SQL
Aunque SQL es estándar, cada motor agrega extensiones propias.
| Motor | Enfoque principal | Uso frecuente |
|---|---|---|
| **PostgreSQL** | Open source, robusto y extensible | Aplicaciones transaccionales, analítica, geodatos |
| **SQL Server** | Ecosistema Microsoft empresarial | BI corporativo, sistemas de negocio, data warehouse |
| **Spark SQL** | SQL distribuido sobre Apache Spark | Big Data, ETL masivo, Lakehouse |
| **MySQL** | Popular y sencillo de operar | Aplicaciones web, backend de productos |
| **Oracle Database** | Alto rendimiento y capacidades enterprise | Finanzas, telecom, sistemas críticos |
| **SQLite** | Ligero y embebido | Apps móviles, prototipos, software local |
| **BigQuery / Snowflake** | SQL en la nube y analítica escalable | Analítica moderna, ciencia de datos, BI cloud |

## 11. SQL en este curso (Databricks SQL / Spark SQL)
En este curso trabajarás en Databricks, donde SQL se ejecuta sobre el motor de Spark SQL.
Beneficios para analítica:
- Procesamiento distribuido para grandes volúmenes.
- Integración con notebooks y flujos de ciencia de datos.
- Compatibilidad con patrones SQL ampliamente conocidos.
- Facilidad para trabajar con tablas de ejemplo y entornos formativos.

## 12. Cierre del módulo
En este módulo conociste:
- El origen histórico de SQL.
- El significado de SQL como lenguaje de consulta estructurada.
- Cómo se comunica un usuario con una base de datos.
- La diferencia entre modelos relacionales y no relacionales.
- La diferencia entre datos estructurados y no estructurados.
- Qué es un modelo de datos y cómo se diseña.
- Los tipos de datos más comunes en SQL.
- Relaciones uno a muchos y muchos a uno.
- Llaves primarias, candidatas/alternativas y foráneas.
- El papel de los índices.
- Las diferencias entre modelos estrella y copo de nieve.
En el siguiente notebook comenzarás la práctica aplicada en Databricks con catálogos, esquemas, tablas y consultas básicas.
