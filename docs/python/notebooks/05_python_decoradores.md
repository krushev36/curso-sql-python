---
title: "Notebook 05: Decoradores en Python"
---

Fuente original: [05_python_decoradores.ipynb](https://github.com/krushev36/curso-sql-python/blob/main/python/notebooks/05_python_decoradores.ipynb)

# Notebook 05: Decoradores en Python

## SQL para Ciencia de Datos usando Databricks

### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia

**Objetivo del notebook:** comprender qué son los decoradores en Python, cómo funcionan, y aplicarlos en ejemplos de nivel básico e intermedio relevantes para el análisis de datos.

- Repositorio fuente: `krushev36/curso-sql-python`
- Estado: nuevo material para el bloque de Python avanzado.

---

## 1. ¿Qué es un decorador?

**Contexto:** en Python, las funciones son *objetos de primera clase* (first-class objects). Esto significa que una función puede ser asignada a una variable, pasada como argumento a otra función y devuelta como resultado de otra función. Esta característica es el fundamento de los decoradores.

Un **decorador** es una función que recibe otra función como argumento, le agrega o modifica comportamiento, y devuelve una nueva función con ese comportamiento extendido. Se aplica usando la sintaxis `@nombre_decorador` justo antes de la definición de la función a decorar.

**¿Para qué sirven?**  
Los decoradores permiten reutilizar lógica transversal (logging, validación, temporización, autenticación, caché, etc.) sin modificar el cuerpo de cada función. Son ampliamente usados en frameworks como Flask, FastAPI y Django.

**Sintaxis general:**

```python
@mi_decorador
def mi_funcion():
    ...
```

Es equivalente a escribir:

```python
def mi_funcion():
    ...
mi_funcion = mi_decorador(mi_funcion)
```

---

## 2. Prerequisito: funciones que retornan funciones

Antes de escribir un decorador, es importante entender que en Python es válido definir una función dentro de otra y devolverla.

```python
def exterior():
    def interior():
        print("Soy la función interior")
    return interior  # devuelve la función, no la llama

f = exterior()  # f ahora apunta a interior
f()             # llamamos a interior a través de f
```

---

## 3. Ejemplo básico 1: decorador de saludo

El decorador más sencillo: envuelve una función e imprime un mensaje antes y después de ejecutarla.

```python
def decorador_saludo(funcion):
    def envoltura():
        print("--- Iniciando ejecución ---")
        funcion()
        print("--- Ejecución finalizada ---")
    return envoltura

@decorador_saludo
def saludar():
    print("¡Hola desde la función decorada!")

saludar()
```

**Salida esperada:**
```
--- Iniciando ejecución ---
¡Hola desde la función decorada!
--- Ejecución finalizada ---
```

---

## 4. Ejemplo básico 2: decorador con argumentos usando `*args` y `**kwargs`

Para que el decorador funcione con cualquier función (sin importar cuántos argumentos reciba), se usan `*args` y `**kwargs` en la función envolvente.

```python
def decorador_log(funcion):
    def envoltura(*args, **kwargs):
        print(f"Llamando a '{funcion.__name__}' con args={args}, kwargs={kwargs}")
        resultado = funcion(*args, **kwargs)
        print(f"'{funcion.__name__}' retornó: {resultado}")
        return resultado
    return envoltura

@decorador_log
def sumar(a, b):
    return a + b

@decorador_log
def saludar_persona(nombre, saludo="Hola"):
    return f"{saludo}, {nombre}!"

sumar(3, 7)
saludar_persona("Ana", saludo="Buenos días")
```

**Salida esperada:**
```
Llamando a 'sumar' con args=(3, 7), kwargs={}
'sumar' retornó: 10
Llamando a 'saludar_persona' con args=('Ana',), kwargs={'saludo': 'Buenos días'}
'saludar_persona' retornó: Buenos días, Ana!
```

---

## 5. Ejemplo intermedio 1: decorador para medir tiempo de ejecución

**Contexto:** en análisis de datos es importante conocer el tiempo que tarda una función (por ejemplo una transformación sobre un DataFrame grande). Un decorador de temporización reutilizable evita duplicar el código de medición en cada función.

```python
import time
import functools

def medir_tiempo(funcion):
    @functools.wraps(funcion)  # preserva el nombre y docstring originales
    def envoltura(*args, **kwargs):
        inicio = time.perf_counter()
        resultado = funcion(*args, **kwargs)
        fin = time.perf_counter()
        print(f"[{funcion.__name__}] Tiempo de ejecución: {fin - inicio:.6f} s")
        return resultado
    return envoltura

@medir_tiempo
def procesar_lista(n):
    """Genera una lista de cuadrados hasta n."""
    return [x ** 2 for x in range(n)]

resultado = procesar_lista(500_000)
print(f"Primeros 5 elementos: {resultado[:5]}")
print(f"Nombre de la función: {procesar_lista.__name__}")  # gracias a functools.wraps
```

**Salida esperada (el tiempo varía según la máquina):**
```
[procesar_lista] Tiempo de ejecución: 0.042301 s
Primeros 5 elementos: [0, 1, 4, 9, 16]
Nombre de la función: procesar_lista
```

---

## 6. Ejemplo intermedio 2: decorador de validación de tipos

**Contexto:** al construir pipelines de datos es frecuente necesitar que ciertos argumentos tengan el tipo correcto antes de procesar. Un decorador de validación centraliza esa lógica.

```python
import functools

def validar_numeros(funcion):
    """Verifica que todos los argumentos posicionales sean numéricos (int o float)."""
    @functools.wraps(funcion)
    def envoltura(*args, **kwargs):
        for i, arg in enumerate(args):
            if not isinstance(arg, (int, float)):
                raise TypeError(
                    f"Argumento #{i+1} debe ser int o float, se recibió {type(arg).__name__}"
                )
        return funcion(*args, **kwargs)
    return envoltura

@validar_numeros
def calcular_promedio(*valores):
    return sum(valores) / len(valores)

# Caso válido
print(calcular_promedio(10, 20, 30))   # 20.0

# Caso inválido
try:
    calcular_promedio(10, "veinte", 30)
except TypeError as e:
    print(f"Error capturado: {e}")
```

**Salida esperada:**
```
20.0
Error capturado: Argumento #2 debe ser int o float, se recibió str
```

---

## 7. `functools.wraps` — buenas prácticas

Cuando defines un decorador, la función `envoltura` reemplaza a la función original. Esto puede causar que se pierda el nombre (`__name__`) y la documentación (`__doc__`) de la función original. `functools.wraps` corrige ese problema copiando los metadatos.

```python
import functools

def decorador_simple(funcion):
    def envoltura(*args, **kwargs):
        return funcion(*args, **kwargs)
    return envoltura

def decorador_con_wraps(funcion):
    @functools.wraps(funcion)
    def envoltura(*args, **kwargs):
        return funcion(*args, **kwargs)
    return envoltura

@decorador_simple
def funcion_a():
    """Esta es la docstring de funcion_a."""
    pass

@decorador_con_wraps
def funcion_b():
    """Esta es la docstring de funcion_b."""
    pass

print(f"Sin wraps  → __name__: {funcion_a.__name__}, __doc__: {funcion_a.__doc__}")
print(f"Con wraps  → __name__: {funcion_b.__name__}, __doc__: {funcion_b.__doc__}")
```

**Salida esperada:**
```
Sin wraps  → __name__: envoltura, __doc__: None
Con wraps  → __name__: funcion_b, __doc__: Esta es la docstring de funcion_b.
```

---

## 8. Ejercicios propuestos

### Ejercicio 1: decorador `@solo_positivos`

Crea un decorador llamado `solo_positivos` que verifique que todos los argumentos numéricos posicionales sean **estrictamente positivos** (> 0) antes de ejecutar la función decorada. Si alguno no cumple la condición, debe lanzar un `ValueError` con un mensaje descriptivo.

Prueba el decorador con la siguiente función:

```python
@solo_positivos
def calcular_raiz_cuadrada(n):
    return n ** 0.5
```

Casos de prueba esperados:
- `calcular_raiz_cuadrada(25)` → `5.0`
- `calcular_raiz_cuadrada(-4)` → `ValueError`
- `calcular_raiz_cuadrada(0)` → `ValueError`

```python
# Tu solución aquí
import functools

def solo_positivos(funcion):
    # Completa el decorador
    pass

@solo_positivos
def calcular_raiz_cuadrada(n):
    return n ** 0.5

# Prueba tus casos aquí
```

---

### Ejercicio 2: decorador `@contar_llamadas`

Crea un decorador llamado `contar_llamadas` que registre cuántas veces ha sido invocada la función decorada. Cada vez que se llame, debe imprimir un mensaje del tipo:

```
'nombre_funcion' ha sido llamada 1 vez(ces).
```

El contador debe ser persistente entre llamadas (pista: usa un atributo en la función `envoltura`).

Prueba el decorador con:

```python
@contar_llamadas
def cargar_datos(fuente):
    return f"Datos cargados desde {fuente}"
```

Resultado esperado al llamar tres veces:
```
'cargar_datos' ha sido llamada 1 vez(ces).
'cargar_datos' ha sido llamada 2 vez(ces).
'cargar_datos' ha sido llamada 3 vez(ces).
```

```python
# Tu solución aquí
import functools

def contar_llamadas(funcion):
    # Completa el decorador
    pass

@contar_llamadas
def cargar_datos(fuente):
    return f"Datos cargados desde {fuente}"

# Prueba tus casos aquí
```
