# 🎓 SQL para Ciencia de Datos usando Databricks

> **Curso universitario completo — Maestría en Ciencia de Datos e Inteligencia de Negocios**

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Databricks_Free_Edition-FF3621)](https://community.cloud.databricks.com)
[![Language](https://img.shields.io/badge/Language-SQL-informational)](sql/notebooks/)
[![Level](https://img.shields.io/badge/Level-Masters-green)](docs/)

---

## 📋 Descripción del Curso

Este curso está diseñado para estudiantes de la **Maestría en Ciencia de Datos e Inteligencia de Negocios** que desean dominar SQL en un entorno moderno de Big Data utilizando **Databricks Free Edition**.

**Duración:** 14–16 horas  
**Plataforma:** Databricks Community Edition (gratuito)  
**Datasets:** Exclusivamente tablas de ejemplo integradas en Databricks (`samples.tpch`, `samples.nyctaxi`)  
**Idioma:** Español  

> **⚠️ Este NO es un curso tradicional de bases de datos.**  
> No cubre administración de BD, normalización, triggers, procedimientos almacenados ni índices.  
> El enfoque es **100% práctico y orientado al análisis de datos**.

---

## 🎯 Objetivos del Curso

Al finalizar el curso, el estudiante será capaz de:

| # | Objetivo |
|---|----------|
| 1 | Consultar información mediante SQL en Databricks |
| 2 | Analizar datos con consultas avanzadas |
| 3 | Transformar datos usando funciones SQL |
| 4 | Construir consultas analíticas complejas |
| 5 | Resolver preguntas de negocio reales |
| 6 | Preparar datasets para Machine Learning |
| 7 | Integrar SQL con Python y Spark |

---

## 🏢 Narrativa del Curso

A lo largo del curso, el estudiante asume el rol de **Data Analyst en DataCorp Analytics**, una empresa ficticia latinoamericana de comercio internacional. Cada notebook representa una nueva necesidad del negocio, construyendo de manera progresiva las habilidades analíticas del estudiante.

---

## 📁 Estructura del Repositorio

```
curso-sql-python/
│
├── README.md                          # Este archivo
├── LICENSE                            # Apache 2.0
│
├── docs/                              # Documentación del curso
│   ├── syllabus.md                    # Programa del curso
│   ├── datasets_guide.md              # Guía de los datasets
│   └── setup_guide.md                 # Guía de configuración Databricks
│
├── sql/
│   ├── notebooks/                     # Notebooks principales (SQL)
│   │   ├── 01_introduccion_databricks_sql.sql
│   │   ├── 02_select_consultas_basicas.sql
│   │   ├── 03_funciones_sql.sql
│   │   ├── 04_agregaciones.sql
│   │   ├── 05_join.sql
│   │   ├── 06_subconsultas_cte.sql
│   │   ├── 07_window_functions.sql
│   │   └── 08_proyecto_integrador.sql
│   ├── labs/                          # Laboratorios adicionales
│   └── solutions/                     # Soluciones de ejercicios
│
├── python/
│   ├── notebooks/                     # Notebooks Python/PySpark (próxima fase)
│   ├── labs/                          # Laboratorios Python
│   └── solutions/                     # Soluciones Python
│
└── images/                            # Diagramas e imágenes del curso
```

---

## 📚 Contenido del Curso

| # | Notebook | Tema | Duración |
|---|----------|------|----------|
| 01 | `01_introduccion_databricks_sql.sql` | Introducción a Databricks SQL | ~1.5 hrs |
| 02 | `02_select_consultas_basicas.sql` | SELECT y Consultas Básicas | ~2 hrs |
| 03 | `03_funciones_sql.sql` | Funciones SQL | ~2 hrs |
| 04 | `04_agregaciones.sql` | Agregaciones y GROUP BY | ~2 hrs |
| 05 | `05_join.sql` | JOIN entre tablas | ~2 hrs |
| 06 | `06_subconsultas_cte.sql` | Subconsultas y CTE | ~2 hrs |
| 07 | `07_window_functions.sql` | Window Functions | ~2 hrs |
| 08 | `08_proyecto_integrador.sql` | Proyecto Integrador | ~2 hrs |

**Total: 15.5 horas**

---

## 🚀 Cómo Empezar

### Paso 1: Crear una cuenta en Databricks Community Edition

1. Ir a [https://community.cloud.databricks.com](https://community.cloud.databricks.com)
2. Hacer clic en **"Get started for free"**
3. Registrarse con correo electrónico
4. Confirmar el correo y acceder al workspace

### Paso 2: Importar un notebook

1. En Databricks, ir al menú lateral → **Workspace**
2. Hacer clic en el ícono **⊕** → **Import**
3. Seleccionar **"File"** y subir el archivo `.sql` del notebook
4. El notebook quedará listo para ejecutar

### Paso 3: Crear un cluster

1. Ir a **Compute** → **Create compute**
2. Seleccionar la configuración por defecto (Single Node)
3. Hacer clic en **Create compute**
4. Esperar que el cluster esté en estado **Running**

### Paso 4: Conectar y ejecutar

1. Abrir el notebook importado
2. Conectarlo al cluster creado
3. Ejecutar las celdas con `Shift + Enter` o `Ctrl + Enter`

---

## 📊 Datasets Utilizados

Todos los datos provienen de las tablas de ejemplo integradas en Databricks:

### `samples.tpch` — Base de datos TPC-H (Comercio Internacional)

| Tabla | Descripción | Filas aprox. |
|-------|-------------|--------------|
| `customer` | Clientes | 150,000 |
| `orders` | Órdenes de compra | 1,500,000 |
| `lineitem` | Líneas de orden | 6,000,000 |
| `part` | Partes/Productos | 200,000 |
| `supplier` | Proveedores | 10,000 |
| `nation` | Naciones | 25 |
| `region` | Regiones del mundo | 5 |

### `samples.nyctaxi` — Viajes de Taxi en Nueva York

| Tabla | Descripción | Filas aprox. |
|-------|-------------|--------------|
| `trips` | Viajes de taxi | Millones |

---

## 🛠️ Tecnologías

- **Databricks Free Edition** — Plataforma de análisis
- **SQL** — Lenguaje principal del curso
- **Delta Lake** — Formato de almacenamiento
- **Apache Spark** — Motor de procesamiento subyacente

---

## 📐 Estructura de cada Notebook

Cada notebook sigue exactamente esta estructura pedagógica:

```
📓 Notebook
├── 👋 Bienvenida
├── 🎯 Objetivos de Aprendizaje
├── 💡 Competencias
├── 🏢 Contexto Empresarial
├── 📖 Conceptos
├── 🔍 Explicación Paso a Paso
├── ✅ Ejemplos Completamente Explicados (mín. 5)
├── 🤝 Ejemplos Guiados (mín. 5)
├── ✏️ Ejercicios Guiados (mín. 5)
├── 🧩 Ejercicios Individuales (mín. 5)
├── 🏆 Desafíos (mín. 5)
├── 📝 Resumen
├── 🔬 Laboratorio
└── 📊 Autoevaluación
```

---

## 📈 Progresión de Dificultad

Los ejercicios en cada notebook progresan de forma gradual:

```
🟢 Muy Fácil    → Familiarización con la sintaxis
🔵 Fácil        → Aplicación directa del concepto
🟡 Intermedio   → Combinación de conceptos
🟠 Inter. Alto  → Lógica de negocio compleja
🔴 Desafío      → Problemas analíticos avanzados
```

---

## 📜 Licencia

Este proyecto está bajo la licencia [Apache 2.0](LICENSE).

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abrir un Issue o Pull Request con mejoras, correcciones o nuevos ejemplos.

---

*Material diseñado para uso académico universitario. Todos los datos son públicos y de ejemplo proporcionados por Databricks.*

