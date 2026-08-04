# Databricks notebook source
# MAGIC %md
# MAGIC # 12 · Entornos de trabajo, tipos de datos y NumPy en Python
# MAGIC
# MAGIC Este notebook fue creado para el curso **SQL para Ciencia de Datos usando Databricks**.
# MAGIC
# MAGIC - Enfoque: uso de VS Code, GitHub Codespaces, instalación de librerías y fundamentos de Python.
# MAGIC - Objetivo: construir una base práctica para trabajar con notebooks, estructuras de datos y álgebra lineal con NumPy.

# COMMAND ----------

# MAGIC %md
# MAGIC # Contexto general
# MAGIC
# MAGIC ## Descripción
# MAGIC Este notebook introduce herramientas de trabajo y conceptos esenciales que se usan de forma recurrente en análisis de datos.
# MAGIC
# MAGIC ## Contenidos
# MAGIC - VS Code y GitHub Codespaces.
# MAGIC - Instalación de librerías en Python.
# MAGIC - Tipos de variables, secuencias y mapeos.
# MAGIC - Built-in functions más utilizadas.
# MAGIC - NumPy: creación de arreglos, métodos, funciones y álgebra lineal.
# MAGIC
# MAGIC ## Ejemplos
# MAGIC Cada sección incluye una explicación breve, un bloque de código y una demostración práctica.

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. VS Code y GitHub Codespaces
# MAGIC
# MAGIC ### Contexto
# MAGIC VS Code permite editar archivos, notebooks y scripts con extensiones para Python y Jupyter. GitHub Codespaces agrega un entorno remoto listo para programar desde el navegador o desde VS Code.
# MAGIC
# MAGIC ### Descripción
# MAGIC Ambos entornos son útiles para aprender Python porque facilitan la edición, la ejecución y el control de versiones con Git.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - Abrir un repositorio en VS Code y ejecutar un notebook localmente.
# MAGIC - Usar Codespaces para trabajar sin instalar dependencias en tu máquina.
# MAGIC - Sincronizar cambios con GitHub y revisar el historial del proyecto.

# COMMAND ----------

import os
import sys

print("Python ejecutándose desde:", sys.executable)
print("Directorio actual:", os.getcwd())

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Instalación de librerías en Python
# MAGIC
# MAGIC ### Contexto
# MAGIC En análisis de datos es común instalar librerías como NumPy, pandas o matplotlib para ampliar las capacidades del entorno.
# MAGIC
# MAGIC ### Descripción
# MAGIC En Databricks y en notebooks locales se suele usar `%pip install` dentro de una celda. En terminales o scripts también puede utilizarse `pip install`.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - Instalar una librería solo para la sesión activa del notebook.
# MAGIC - Revisar la versión de una dependencia instalada.
# MAGIC - Verificar que el módulo se importe correctamente.

# COMMAND ----------

# MAGIC %pip install numpy pandas matplotlib

# COMMAND ----------

import numpy as np
import pandas as pd
import matplotlib

print("NumPy:", np.__version__)
print("pandas:", pd.__version__)
print("matplotlib:", matplotlib.__version__)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Tipos de variables en Python
# MAGIC
# MAGIC ### Contexto
# MAGIC Python es dinámico: el tipo de una variable se define por el valor que almacena en cada momento.
# MAGIC
# MAGIC ### Descripción
# MAGIC Los tipos básicos incluyen enteros, flotantes, booleanos, cadenas, complejos y el valor especial `None`.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - `int` para conteos.
# MAGIC - `float` para medidas con decimales.
# MAGIC - `bool` para condiciones lógicas.
# MAGIC - `str` para texto.

# COMMAND ----------

entero = 42
decimal = 3.1416
bandera = True
texto = "Python para datos"
numero_complejo = 2 + 5j
sin_valor = None

variables = [entero, decimal, bandera, texto, numero_complejo, sin_valor]
for valor in variables:
    print(valor, "->", type(valor))

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Tipos de secuencias
# MAGIC
# MAGIC ### Contexto
# MAGIC Las secuencias guardan elementos en un orden definido y permiten indexación, slicing e iteración.
# MAGIC
# MAGIC ### Descripción
# MAGIC Las secuencias más comunes son listas, tuplas, rangos y cadenas de texto.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - `list` para colecciones mutables.
# MAGIC - `tuple` para colecciones inmutables.
# MAGIC - `range` para generar series de números.
# MAGIC - `str` para manipular texto.

# COMMAND ----------

lista = [10, 20, 30, 40]
tupla = ("enero", "febrero", "marzo")
serie = range(1, 6)
cadena = "analitica"

print("Lista:", lista)
print("Tupla:", tupla)
print("Range convertido a lista:", list(serie))
print("Cadena en mayusculas:", cadena.upper())
print("Primer elemento de la lista:", lista[0])
print("Ultimos dos elementos de la tupla:", tupla[-2:])

# COMMAND ----------

# MAGIC %md
# MAGIC ## 5. Tipos de mapeos
# MAGIC
# MAGIC ### Contexto
# MAGIC Los mapeos relacionan claves con valores y son muy útiles para representar registros, configuraciones o estructuras anidadas.
# MAGIC
# MAGIC ### Descripción
# MAGIC El tipo de mapeo más usado en Python es `dict`.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - Acceder a valores por clave.
# MAGIC - Agregar o actualizar información.
# MAGIC - Recorrer las claves y valores de un registro.

# COMMAND ----------

estudiante = {
    "nombre": "Ana",
    "edad": 22,
    "carrera": "Ingenieria",
    "notas": [4.5, 4.8, 4.2]
}

print("Nombre:", estudiante["nombre"])
print("Promedio:", sum(estudiante["notas"]) / len(estudiante["notas"]))

estudiante["ciudad"] = "Bogota"
for clave, valor in estudiante.items():
    print(clave, "=>", valor)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 6. Built-in functions
# MAGIC
# MAGIC ### Contexto
# MAGIC Python incluye funciones internas que simplifican tareas comunes sin instalar nada adicional.
# MAGIC
# MAGIC ### Descripción
# MAGIC Estas funciones permiten contar, resumir, ordenar, convertir, recorrer y combinar datos con poco código.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - `len()` para longitud.
# MAGIC - `sum()`, `min()`, `max()` para agregaciones básicas.
# MAGIC - `sorted()`, `enumerate()` y `zip()` para trabajar con colecciones.
# MAGIC - `type()` y `help()` para inspeccionar objetos.

# COMMAND ----------

datos = [12, 7, 19, 7, 25]
nombres = ["luz", "sol", "mar"]
edades = [21, 25, 19]

print("Longitud:", len(datos))
print("Suma:", sum(datos))
print("Minimo y maximo:", min(datos), max(datos))
print("Ordenados:", sorted(datos))
print("Enumerate:")
for indice, valor in enumerate(nombres, start=1):
    print(indice, valor)

print("Zip:")
for nombre, edad in zip(nombres, edades):
    print(nombre, edad)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 7. NumPy: arreglos, métodos y funciones
# MAGIC
# MAGIC ### Contexto
# MAGIC NumPy es la base del trabajo numérico en Python y ofrece estructuras eficientes para datos vectoriales y matriciales.
# MAGIC
# MAGIC ### Descripción
# MAGIC Con NumPy se crean arreglos homogéneos, se aplican operaciones vectorizadas y se ejecutan transformaciones sin bucles explícitos.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - Crear arreglos con `array()`, `arange()` y `linspace()`.
# MAGIC - Revisar atributos como `ndim`, `shape` y `dtype`.
# MAGIC - Aplicar métodos como `reshape()` y funciones como `mean()` o `unique()`.

# COMMAND ----------

vector = np.array([1, 2, 3, 4, 5])
matriz = np.arange(1, 13).reshape(3, 4)
muestra = np.linspace(0, 1, 5)

print("Vector:", vector)
print("Matriz:\n", matriz)
print("Muestra:", muestra)
print("ndim, shape, dtype:", vector.ndim, vector.shape, vector.dtype)
print("Suma:", vector.sum())
print("Promedio:", vector.mean())
print("Desviacion estandar:", vector.std())
print("Matriz transpuesta:\n", matriz.T)

# COMMAND ----------

valores = np.array([3, 3, 5, 7, 7, 7, 9])
temperaturas = np.array([18.5, 20.1, 19.8, 21.3])

print("Valores unicos:", np.unique(valores))
print("Minimo:", np.min(valores))
print("Maximo:", np.max(valores))
print("Indice del maximo:", np.argmax(valores))
print("Temperaturas redondeadas:", np.round(temperaturas, 1))
print("Temperaturas limitadas a 20.0 minimo:", np.clip(temperaturas, 20.0, None))

# COMMAND ----------

# MAGIC %md
# MAGIC ## 8. Álgebra lineal con NumPy
# MAGIC
# MAGIC ### Contexto
# MAGIC Muchas tareas de ciencia de datos usan matrices, sistemas de ecuaciones y operaciones lineales.
# MAGIC
# MAGIC ### Descripción
# MAGIC NumPy incluye funciones para producto punto, multiplicación matricial, normas, determinantes y resolución de sistemas.
# MAGIC
# MAGIC ### Ejemplos
# MAGIC - `np.dot()` y `@` para productos matriciales.
# MAGIC - `np.linalg.norm()` para calcular normas.
# MAGIC - `np.linalg.solve()` para resolver sistemas lineales.
# MAGIC - `np.linalg.det()` y `np.linalg.inv()` para análisis matricial.

# COMMAND ----------

A = np.array([[2, 1], [1, 3]], dtype=float)
B = np.array([[1, 2], [3, 4]], dtype=float)
b = np.array([5, 7], dtype=float)

print("A:\n", A)
print("B:\n", B)
print("Producto punto A @ B:\n", A @ B)
print("Producto punto con np.dot:\n", np.dot(A, B))
print("Norma de A:", np.linalg.norm(A))
print("Determinante de A:", np.linalg.det(A))
print("Inversa de A:\n", np.linalg.inv(A))
print("Solucion del sistema A x = b:", np.linalg.solve(A, b))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Ejercicios propuestos
# MAGIC
# MAGIC 1. Crea un diccionario con información de un curso, incluyendo nombre, duración, instructor y lista de temas. Muestra sus claves, valores y elementos completos.
# MAGIC 2. Construye una lista de valores numéricos y usa al menos cinco built-in functions para resumirla: longitud, suma, mínimo, máximo, ordenamiento, `enumerate()` o `zip()`.
# MAGIC 3. Con NumPy, crea una matriz 3x3, calcula su transpuesta, su determinante y resuelve un sistema lineal sencillo asociado a esa matriz.
