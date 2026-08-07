# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "5"
# ///
# DBTITLE 1,Cabecera
# MAGIC %md
# MAGIC # Notebook 04: Análisis de datos con Pandas
# MAGIC
# MAGIC ## SQL para Ciencia de Datos usando Databricks
# MAGIC
# MAGIC ### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia
# MAGIC
# MAGIC **Objetivo del notebook:** dominar la librería Pandas para manipulación y análisis de datos, incluyendo creación de DataFrames, transformaciones, filtrado, manejo de valores nulos y operaciones de agrupación.
# MAGIC
# MAGIC - Repositorio fuente: curso adaptado para la maestría
# MAGIC - Estado: material didáctico para análisis de datos con Python

# COMMAND ----------

# DBTITLE 1,Contenido
# MAGIC %md
# MAGIC ## Contenido del notebook
# MAGIC
# MAGIC 1. Introducción a Pandas
# MAGIC 2. Crear DataFrames
# MAGIC 3. Agregar columnas
# MAGIC 4. Eliminar columnas
# MAGIC 5. Filtrar datos
# MAGIC 6. Buscar y reemplazar valores nulos
# MAGIC 7. Transformar datos
# MAGIC 8. Métodos de agrupación (GroupBy)
# MAGIC 9. Ejercicios prácticos

# COMMAND ----------

# DBTITLE 1,Imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# COMMAND ----------

# DBTITLE 1,Introducción
# MAGIC %md
# MAGIC ## 1. Introducción a Pandas
# MAGIC
# MAGIC **Contexto:** Pandas es la librería fundamental para análisis de datos en Python. Proporciona estructuras de datos flexibles y eficientes para trabajar con datos tabulares (como tablas de bases de datos o archivos Excel/CSV).
# MAGIC
# MAGIC **Necesidad:** en ciencia de datos, la mayoría del tiempo se dedica a la preparación y limpieza de datos. Pandas facilita estas tareas con funciones intuitivas para:
# MAGIC - Leer/escribir datos desde múltiples formatos (CSV, Excel, SQL, JSON, etc.)
# MAGIC - Manipular y transformar datos de forma eficiente
# MAGIC - Manejar valores faltantes
# MAGIC - Agrupar y agregar datos
# MAGIC - Unir y combinar diferentes conjuntos de datos
# MAGIC
# MAGIC **Estructuras principales:**
# MAGIC - **Series:** arreglo unidimensional etiquetado (similar a una columna de Excel)
# MAGIC - **DataFrame:** estructura bidimensional etiquetada (similar a una tabla de base de datos o una hoja de Excel)

# COMMAND ----------

# DBTITLE 1,Crear DataFrames - Introducción
# MAGIC %md
# MAGIC ## 2. Crear DataFrames
# MAGIC
# MAGIC **Contexto:** antes de analizar datos, necesitas cargarlos en una estructura que permita manipulación eficiente.
# MAGIC
# MAGIC **Necesidad:** Pandas ofrece múltiples formas de crear DataFrames dependiendo del origen de tus datos: desde diccionarios de Python, listas, archivos CSV, bases de datos SQL, etc.
# MAGIC
# MAGIC ### 2.1 Desde diccionarios
# MAGIC La forma más común de crear un DataFrame manualmente es usando un diccionario donde las llaves son nombres de columnas y los valores son listas de datos.

# COMMAND ----------

# DBTITLE 1,Crear DataFrame desde diccionario
# Crear un DataFrame desde un diccionario
data = {
    'nombre': ['Ana', 'Luis', 'Carlos', 'María', 'Pedro'],
    'edad': [25, 30, 35, 28, 32],
    'ciudad': ['Medellín', 'Bogotá', 'Cali', 'Medellín', 'Bogotá'],
    'salario': [3000000, 4500000, 5200000, 3800000, 4200000]
}

df = pd.DataFrame(data)
print(df)
print(f"\nDimensiones: {df.shape}")
print(f"Columnas: {df.columns.tolist()}")

# COMMAND ----------

# DBTITLE 1,Crear desde otros formatos
# MAGIC %md
# MAGIC ### 2.2 Desde listas de listas
# MAGIC También puedes crear un DataFrame a partir de una lista de listas, especificando los nombres de las columnas por separado.

# COMMAND ----------

# DBTITLE 1,Crear desde listas
# Crear DataFrame desde listas
datos = [
    ['Juan', 22, 'Barranquilla'],
    ['Sofia', 27, 'Cartagena'],
    ['Diego', 31, 'Medellín']
]

df_lista = pd.DataFrame(datos, columns=['nombre', 'edad', 'ciudad'])
print(df_lista)

# COMMAND ----------

# DBTITLE 1,Crear desde archivos
# MAGIC %md
# MAGIC ### 2.3 Desde archivos CSV
# MAGIC En la práctica, la mayoría de datos vienen de archivos externos. Pandas facilita la lectura con `read_csv()`.

# COMMAND ----------

# DBTITLE 1,Ejemplo lectura CSV
# Ejemplo de lectura de CSV (cuando existe el archivo)
# df_csv = pd.read_csv('datos.csv')
# df_csv = pd.read_csv('datos.csv', sep=';')  # para otro delimitador
# df_csv = pd.read_csv('datos.csv', encoding='utf-8')  # especificar encoding

print("Lectura de CSV: pd.read_csv('archivo.csv')")
print("Otros formatos: pd.read_excel(), pd.read_json(), pd.read_sql()")

# COMMAND ----------

# DBTITLE 1,Agregar columnas - Introducción
# MAGIC %md
# MAGIC ## 3. Agregar columnas
# MAGIC
# MAGIC **Contexto:** frecuentemente necesitas crear nuevas variables derivadas de las existentes (por ejemplo, calcular el salario anual a partir del mensual, o categorizar edades).
# MAGIC
# MAGIC **Necesidad:** Pandas permite agregar columnas de varias formas: asignación directa, cálculos basados en otras columnas, o aplicando funciones personalizadas.
# MAGIC
# MAGIC ### 3.1 Asignación directa
# MAGIC La forma más simple es asignar una lista o un valor constante.

# COMMAND ----------

# DBTITLE 1,Agregar columnas - ejemplos
# Agregar una columna con un valor constante
df['pais'] = 'Colombia'

# Agregar una columna basada en cálculos de otras columnas
df['salario_anual'] = df['salario'] * 12

# Agregar una columna con valores específicos
df['experiencia_años'] = [3, 8, 12, 5, 9]

print(df)

# COMMAND ----------

# DBTITLE 1,Columnas condicionales
# MAGIC %md
# MAGIC ### 3.2 Columnas con condiciones
# MAGIC Puedes crear columnas aplicando lógica condicional usando `np.where()` o el método `.apply()`.

# COMMAND ----------

# DBTITLE 1,Columnas condicionales - ejemplo
# Crear columna categórica basada en condición
df['categoria_edad'] = np.where(df['edad'] < 30, 'Joven', 'Adulto')

# Crear columna con múltiples condiciones
df['nivel_salario'] = pd.cut(df['salario'], 
                             bins=[0, 3500000, 4500000, 6000000],
                             labels=['Bajo', 'Medio', 'Alto'])

print(df[['nombre', 'edad', 'categoria_edad', 'salario', 'nivel_salario']])

# COMMAND ----------

# DBTITLE 1,Eliminar columnas - Introducción
# MAGIC %md
# MAGIC ## 4. Eliminar columnas
# MAGIC
# MAGIC **Contexto:** no todas las columnas de un dataset son relevantes para tu análisis. Eliminar las innecesarias reduce el uso de memoria y simplifica el trabajo.
# MAGIC
# MAGIC **Necesidad:** Pandas ofrece el método `.drop()` para eliminar columnas (o filas) de forma explícita, sin modificar el DataFrame original a menos que uses `inplace=True`.

# COMMAND ----------

# DBTITLE 1,Eliminar columnas - ejemplos
# Eliminar una columna (sin modificar el original)
df_sin_pais = df.drop('pais', axis=1)
print("DataFrame sin columna 'pais':")
print(df_sin_pais.head())

# Eliminar múltiples columnas
df_reducido = df.drop(['experiencia_años', 'categoria_edad'], axis=1)
print("\nDataFrame sin experiencia ni categoría:")
print(df_reducido.head())

# Eliminar columnas modificando el original (usar con cuidado)
# df.drop('columna', axis=1, inplace=True)

# También puedes usar del
# del df['columna']

# COMMAND ----------

# DBTITLE 1,Filtrar datos - Introducción
# MAGIC %md
# MAGIC ## 5. Filtrar datos
# MAGIC
# MAGIC **Contexto:** raramente trabajas con todo el dataset completo; normalmente necesitas subconjuntos que cumplan ciertas condiciones (clientes de una región, transacciones mayores a cierto monto, etc.).
# MAGIC
# MAGIC **Necesidad:** el filtrado te permite seleccionar filas basándote en condiciones lógicas, similar a la cláusula `WHERE` en SQL.
# MAGIC
# MAGIC ### 5.1 Filtrado básico
# MAGIC Usa expresiones booleanas dentro de corchetes para filtrar filas.

# COMMAND ----------

# DBTITLE 1,Filtrar - ejemplos básicos
# Filtrar personas mayores de 30 años
df_mayores = df[df['edad'] > 30]
print("Personas mayores de 30:")
print(df_mayores)

# Filtrar por ciudad específica
df_medellin = df[df['ciudad'] == 'Medellín']
print("\nPersonas de Medellín:")
print(df_medellin)

# Filtrar con múltiples condiciones (AND)
df_filtro_and = df[(df['edad'] > 25) & (df['salario'] > 4000000)]
print("\nEdad > 25 Y salario > 4M:")
print(df_filtro_and)

# Filtrar con condición OR
df_filtro_or = df[(df['ciudad'] == 'Bogotá') | (df['ciudad'] == 'Cali')]
print("\nPersonas de Bogotá o Cali:")
print(df_filtro_or)

# COMMAND ----------

# DBTITLE 1,Filtrado avanzado
# MAGIC %md
# MAGIC ### 5.2 Filtrado avanzado
# MAGIC Puedes usar métodos como `.isin()`, `.str.contains()` para filtros más sofisticados.

# COMMAND ----------

# DBTITLE 1,Filtrado avanzado - ejemplos
# Filtrar con lista de valores usando isin()
ciudades_interes = ['Medellín', 'Bogotá']
df_ciudades = df[df['ciudad'].isin(ciudades_interes)]
print("Filtrado con isin():")
print(df_ciudades)

# Filtrar texto que contiene una palabra
df_contiene_m = df[df['ciudad'].str.contains('e')]
print("\nCiudades que contienen 'e':")
print(df_contiene_m)

# Negar una condición (NOT)
df_no_medellin = df[~(df['ciudad'] == 'Medellín')]
print("\nPersonas NO de Medellín:")
print(df_no_medellin)

# COMMAND ----------

# DBTITLE 1,Valores nulos - Introducción
# MAGIC %md
# MAGIC ## 6. Buscar y reemplazar valores nulos
# MAGIC
# MAGIC **Contexto:** los datos reales casi siempre tienen valores faltantes (NaN, None, NULL). Ignorarlos puede sesgar tus análisis o causar errores en modelos predictivos.
# MAGIC
# MAGIC **Necesidad:** Pandas proporciona herramientas para detectar, cuantificar y manejar valores nulos: puedes eliminarlos, reemplazarlos por un valor específico, o usar métodos de imputación.
# MAGIC
# MAGIC ### 6.1 Detectar valores nulos

# COMMAND ----------

# DBTITLE 1,Crear DataFrame con nulos
# Crear un DataFrame con algunos valores nulos
data_nulos = {
    'producto': ['A', 'B', 'C', 'D', 'E'],
    'precio': [100, np.nan, 150, 200, np.nan],
    'cantidad': [10, 20, np.nan, 15, 25],
    'categoria': ['X', 'Y', np.nan, 'X', 'Z']
}

df_nulos = pd.DataFrame(data_nulos)
print("DataFrame con valores nulos:")
print(df_nulos)

# COMMAND ----------

# DBTITLE 1,Detectar nulos
# Identificar valores nulos
print("\nValores nulos por columna:")
print(df_nulos.isnull().sum())

# Ver filas con al menos un valor nulo
print("\nFilas con valores nulos:")
print(df_nulos[df_nulos.isnull().any(axis=1)])

# Porcentaje de nulos
print("\nPorcentaje de nulos:")
print((df_nulos.isnull().sum() / len(df_nulos) * 100).round(2))

# COMMAND ----------

# DBTITLE 1,Manejar nulos
# MAGIC %md
# MAGIC ### 6.2 Reemplazar y eliminar valores nulos

# COMMAND ----------

# DBTITLE 1,Reemplazar y eliminar nulos
# Opción 1: Eliminar filas con valores nulos
df_sin_nulos = df_nulos.dropna()
print("DataFrame sin filas con nulos:")
print(df_sin_nulos)

# Opción 2: Eliminar columnas con nulos
df_sin_col_nulos = df_nulos.dropna(axis=1)
print("\nDataFrame sin columnas con nulos:")
print(df_sin_col_nulos)

# Opción 3: Reemplazar nulos con un valor específico
df_relleno = df_nulos.fillna(0)
print("\nNulos reemplazados por 0:")
print(df_relleno)

# Opción 4: Reemplazar con la media (para columnas numéricas)
df_nulos['precio'] = df_nulos['precio'].fillna(df_nulos['precio'].mean())
print("\nPrecio con media:")
print(df_nulos)

# Opción 5: Forward fill (rellenar con el valor anterior)
df_nulos['cantidad'] = df_nulos['cantidad'].fillna(method='ffill')
print("\nCantidad con forward fill:")
print(df_nulos)

# COMMAND ----------

# DBTITLE 1,Transformar datos - Introducción
# MAGIC %md
# MAGIC ## 7. Transformar datos
# MAGIC
# MAGIC **Contexto:** los datos raramente vienen en el formato ideal para análisis. Necesitas normalizarlos, estandarizarlos, convertir tipos de datos o aplicar funciones personalizadas.
# MAGIC
# MAGIC **Necesidad:** las transformaciones permiten preparar los datos para visualización, modelado o análisis estadístico.
# MAGIC
# MAGIC ### 7.1 Aplicar funciones a columnas

# COMMAND ----------

# DBTITLE 1,Apply - ejemplos
# Volver a crear el DataFrame original
df = pd.DataFrame({
    'nombre': ['Ana', 'Luis', 'Carlos', 'María', 'Pedro'],
    'edad': [25, 30, 35, 28, 32],
    'ciudad': ['Medellín', 'Bogotá', 'Cali', 'Medellín', 'Bogotá'],
    'salario': [3000000, 4500000, 5200000, 3800000, 4200000]
})

# Aplicar función a una columna
df['nombre_mayusculas'] = df['nombre'].apply(lambda x: x.upper())
print("Nombres en mayúsculas:")
print(df[['nombre', 'nombre_mayusculas']])

# Aplicar función que usa múltiples columnas
def clasificar_persona(row):
    if row['edad'] < 30 and row['salario'] < 4000000:
        return 'Junior'
    elif row['edad'] >= 30 and row['salario'] >= 4500000:
        return 'Senior'
    else:
        return 'Mid-level'

df['nivel'] = df.apply(clasificar_persona, axis=1)
print("\nClasificación de nivel:")
print(df[['nombre', 'edad', 'salario', 'nivel']])

# COMMAND ----------

# DBTITLE 1,Transformaciones matemáticas
# MAGIC %md
# MAGIC ### 7.2 Transformaciones matemáticas y estadísticas

# COMMAND ----------

# DBTITLE 1,Transformaciones numéricas
# Normalización (escala 0-1)
df['salario_normalizado'] = (df['salario'] - df['salario'].min()) / (df['salario'].max() - df['salario'].min())

# Estandarización (media=0, desv.std=1)
df['edad_estandarizada'] = (df['edad'] - df['edad'].mean()) / df['edad'].std()

# Transformación logarítmica
df['log_salario'] = np.log(df['salario'])

print("Transformaciones aplicadas:")
print(df[['salario', 'salario_normalizado', 'log_salario']].round(3))

# COMMAND ----------

# DBTITLE 1,GroupBy - Introducción
# MAGIC %md
# MAGIC ## 8. Métodos de agrupación (GroupBy)
# MAGIC
# MAGIC **Contexto:** uno de los patrones más comunes en análisis de datos es el "split-apply-combine": dividir los datos en grupos según algún criterio, aplicar una función de agregación a cada grupo, y combinar los resultados.
# MAGIC
# MAGIC **Necesidad:** GroupBy es equivalente al `GROUP BY` de SQL y permite calcular estadísticas por categorías: ventas totales por región, promedio de edad por ciudad, conteo de transacciones por cliente, etc.
# MAGIC
# MAGIC ### 8.1 Agrupación básica

# COMMAND ----------

# DBTITLE 1,GroupBy - ejemplos básicos
# Agrupar por ciudad y calcular promedio de salario
promedio_por_ciudad = df.groupby('ciudad')['salario'].mean()
print("Salario promedio por ciudad:")
print(promedio_por_ciudad)

# Contar personas por ciudad
conteo_por_ciudad = df.groupby('ciudad').size()
print("\nConteo de personas por ciudad:")
print(conteo_por_ciudad)

# Múltiples agregaciones a la vez
estadisticas = df.groupby('ciudad')['salario'].agg(['mean', 'min', 'max', 'count'])
print("\nEstadísticas de salario por ciudad:")
print(estadisticas)

# COMMAND ----------

# DBTITLE 1,GroupBy avanzado
# MAGIC %md
# MAGIC ### 8.2 Agrupación avanzada

# COMMAND ----------

# DBTITLE 1,GroupBy múltiple y agregaciones
# Crear un DataFrame más completo para ejemplos avanzados
data_ventas = {
    'region': ['Norte', 'Sur', 'Norte', 'Sur', 'Centro', 'Norte', 'Centro', 'Sur'],
    'producto': ['A', 'A', 'B', 'B', 'A', 'A', 'B', 'A'],
    'ventas': [100, 150, 200, 180, 120, 110, 190, 160],
    'unidades': [10, 15, 8, 12, 11, 9, 10, 14]
}

df_ventas = pd.DataFrame(data_ventas)
print("DataFrame de ventas:")
print(df_ventas)

# Agrupar por múltiples columnas
ventas_region_producto = df_ventas.groupby(['region', 'producto'])['ventas'].sum()
print("\nVentas totales por región y producto:")
print(ventas_region_producto)

# Aplicar diferentes funciones a diferentes columnas
agregaciones = df_ventas.groupby('region').agg({
    'ventas': ['sum', 'mean'],
    'unidades': ['sum', 'max']
})
print("\nAgregaciones múltiples:")
print(agregaciones)

# COMMAND ----------

# DBTITLE 1,GroupBy con transformaciones
# MAGIC %md
# MAGIC ### 8.3 Transform y Filter con GroupBy

# COMMAND ----------

# DBTITLE 1,Transform y Filter
# Transform: agregar estadística del grupo a cada fila
df_ventas['ventas_promedio_region'] = df_ventas.groupby('region')['ventas'].transform('mean')
df_ventas['desviacion_promedio'] = df_ventas['ventas'] - df_ventas['ventas_promedio_region']
print("DataFrame con promedio por región:")
print(df_ventas)

# Filter: mantener solo grupos que cumplen una condición
# Por ejemplo, regiones con ventas totales > 300
grupos_grandes = df_ventas.groupby('region').filter(lambda x: x['ventas'].sum() > 300)
print("\nRegiones con ventas totales > 300:")
print(grupos_grandes)

# COMMAND ----------

# DBTITLE 1,Ejercicios prácticos
# MAGIC %md
# MAGIC ## 9. Ejercicios prácticos
# MAGIC
# MAGIC ### Ejercicio 1: Dataset de empleados
# MAGIC Crea un DataFrame con información de empleados (nombre, departamento, salario, años de experiencia) y realiza las siguientes tareas:
# MAGIC 1. Calcula el salario promedio por departamento
# MAGIC 2. Identifica empleados con salario superior al promedio de su departamento
# MAGIC 3. Crea una nueva columna con el salario ajustado (salario + 5% por año de experiencia)
# MAGIC
# MAGIC ### Ejercicio 2: Análisis de ventas
# MAGIC Carga o crea un dataset de ventas con fecha, producto, región, cantidad y monto. Luego:
# MAGIC 1. Filtra solo las ventas del último trimestre
# MAGIC 2. Calcula las ventas totales por región y producto
# MAGIC 3. Identifica los 3 productos más vendidos en cada región
# MAGIC 4. Maneja cualquier valor nulo apropiadamente
# MAGIC
# MAGIC ### Ejercicio 3: Transformación de datos
# MAGIC Partiendo de un DataFrame con datos crudos:
# MAGIC 1. Normaliza las variables numéricas
# MAGIC 2. Convierte variables categóricas a one-hot encoding usando `pd.get_dummies()`
# MAGIC 3. Elimina columnas con más del 50% de valores nulos
# MAGIC 4. Rellena los nulos restantes con la mediana del grupo correspondiente

# COMMAND ----------

# DBTITLE 1,Recursos adicionales
# MAGIC %md
# MAGIC ## Recursos adicionales
# MAGIC
# MAGIC **Documentación oficial de Pandas:**
# MAGIC - [Pandas User Guide](https://pandas.pydata.org/docs/user_guide/index.html)
# MAGIC - [API Reference](https://pandas.pydata.org/docs/reference/index.html)
# MAGIC
# MAGIC **Temas avanzados para explorar:**
# MAGIC - Merge, join y concatenación de DataFrames
# MAGIC - Manejo de series de tiempo (time series)
# MAGIC - Pivot tables y cross-tabulations
# MAGIC - Indexación multinivel (MultiIndex)
# MAGIC - Optimización de rendimiento con Categorical data
# MAGIC - Integración con SQL y Spark
# MAGIC
# MAGIC **Buenas prácticas:**
# MAGIC - Usa métodos vectorizados en lugar de loops cuando sea posible
# MAGIC - Verifica tipos de datos con `df.dtypes` y convierte cuando sea necesario
# MAGIC - Para datasets grandes, considera usar `chunks` en `read_csv()` o Spark
# MAGIC - Documenta tus transformaciones para reproducibilidad

# COMMAND ----------

