---
title: Notebook 02: Funciones, estructuras y librerías base en Python
---

Fuente original: [02_python_funciones_librerias.ipynb](https://github.com/krushev36/curso-sql-python/blob/main/python/notebooks/02_python_funciones_librerias.ipynb)

# Notebook 02: Funciones, estructuras y librerías base en Python

## SQL para Ciencia de Datos usando Databricks

### Maestría en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia

**Objetivo del notebook:** afianzar el uso de funciones, indexación de arreglos con NumPy y librerías de visualización en Python para el análisis de datos.

- Repositorio fuente: `krushev36/curso-python-r.github.io`
- Archivo original: `sesion2/sesion2python.ipynb`
- Estado: revisado y ordenado para uso en esta ruta del curso.

## 1. Ayuda y documentación en Python: [`help()`](https://docs.python.org/3/library/functions.html#help)

**Contexto:** como Analista de Datos, trabajarás todo el tiempo con funciones y librerías que no siempre conoces a fondo (`numpy`, `pandas`, funciones nativas como `range` o `print`, etc.). Antes de usar una función dentro de un análisis o un pipeline de datos, necesitas confirmar qué parámetros recibe, qué devuelve y cómo se comporta.

**Necesidad:** no siempre es práctico interrumpir el trabajo para buscar en internet la documentación de cada función. Python incluye herramientas para consultarla directamente desde el mismo entorno de trabajo, sin salir del notebook.

La función `help()` muestra la documentación (docstring) de un módulo, clase, función o variable. En Jupyter/IPython también puedes escribir `?` antes o después de un objeto (por ejemplo `?print` o `input?`) para obtener la misma información de forma más rápida.

```python
help(range)
```

```python
?print
```

```python
input?
```

## 2. Manejo de índices en arreglos de NumPy: [Indexación de arreglos](https://numpy.org/doc/stable/reference/arrays.indexing.html)

**Contexto:** en análisis de datos es habitual trabajar con matrices y arreglos multidimensionales, por ejemplo una tabla de ventas organizada por región y mes. Extraer filas, columnas o subconjuntos específicos de esos datos es una tarea del día a día para cualquier Analista o Científico de Datos.

**Necesidad:** recorrer manualmente cada elemento de un arreglo para filtrar valores es lento e ineficiente, especialmente con grandes volúmenes de datos. NumPy permite seleccionar datos de forma directa mediante la sintaxis `x[obj]`, donde `x` es el arreglo y `obj` define la selección deseada.

Existen tres tipos de indexación sobre un `ndarray`:
- **Acceso por campo (field access):** para arreglos estructurados con nombres de columna.
- **Slicing básico (basic slicing):** selección de rangos usando `:`, de forma similar a las listas de Python.
- **Indexación avanzada (advanced indexing):** selección usando listas de índices o condiciones.

El tipo de indexación que se aplica depende de cómo se escriba `obj`.

```python
import numpy as np

x = np.arange(0,16).reshape((4,4))
x.view()
```

```python
x[1,1]
```

```python
x[:,0]
```

```python
x[:,1]
```

```python
x[-1,-1]
```

```python
x[[0,1],:]
```

```python
x[:,0:-1]
```

```python
x[:,0:-2]
```

```python
x[:,0:-3].T
```

## 3. Números aleatorios con NumPy: [`numpy.random`](https://numpy.org/doc/stable/reference/random/index.html)

**Contexto:** en ciencia de datos es habitual necesitar datos simulados, por ejemplo para probar un análisis antes de tener datos reales, validar un modelo estadístico o generar un dataset de prueba con propiedades conocidas.

**Necesidad:** generar valores "a mano" no garantiza que sigan una distribución concreta (uniforme, normal, etc.) ni que el experimento sea reproducible. El módulo `numpy.random` resuelve esto combinando un **BitGenerator** (genera secuencias de números) con un **Generator** (transforma esas secuencias en muestras de distintas distribuciones estadísticas).

Por compatibilidad con versiones anteriores, los métodos de la clase `RandomState` también quedan disponibles directamente en el namespace `numpy.random`.

```python
x = np.random.rand(16).reshape((4,4))
x
```

```python
x.mean()
```

```python
x.min()
```

```python
x.max()
```

```python
x.argmax()
```

```python
x.shape
```

```python
x.nonzero()
```

```python
x.ravel()
```

```python
z=np.ones((3,3,3,3))
z
```

```python
z[1,1,1,1]
```

## 4. Markdown: sintaxis básica

**Contexto:** al documentar notebooks, análisis o reportes técnicos necesitas dar formato al texto (títulos, énfasis, tablas, bloques de código) sin depender de un editor de texto enriquecido. Markdown es el estándar usado en Jupyter, GitHub y Databricks para escribir documentación legible tanto en texto plano como en HTML.

Markdown es una herramienta de conversión de texto a HTML pensada para quienes escriben en la web: permite redactar en un formato de texto plano fácil de leer y escribir, que luego se convierte en HTML válido.

Por lo tanto, "Markdown" es dos cosas: (1) una sintaxis de formato en texto plano; y (2) una herramienta de software, escrita originalmente en Perl, que convierte ese texto plano a HTML.

### 4.1 Tipos de énfasis

Énfasis (cursiva) con *asteriscos* o _guiones bajos_.

Énfasis fuerte (negrita) con **asteriscos** o __guiones bajos__.

Énfasis combinado con **asteriscos y _guiones bajos_**.

Texto tachado con dos virgulillas. ~~Texto tachado.~~

[Enlace en línea](https://www.google.com)

### 4.2 Resaltado de código
Un ejemplo de resaltado en javascript:
```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```
Un ejemplo de resaltado en python:
```python
s = "Resaltado de sintaxis en Python"
print(s)
```
Otros lenguajes como bash, perl o html también se pueden resaltar.

### 4.3 Tablas

Los dos puntos permiten alinear columnas.

| Tablas        | Son           | Geniales  |
| ------------- |:-------------:| -----:|
| la columna 3  | está alineada a la derecha | $1600 |
| la columna 2  | está centrada | $12 |
| filas cebra   | se ven bien   |    $1 |

Debe haber al menos 3 guiones separando cada celda del encabezado. Las barras verticales externas (`|`) son opcionales y no es necesario alinear el Markdown de forma prolija.

Markdown | Menos | Bonito
--- | --- | ---
*Aún* | `se renderiza` | **bien**
1 | 2 | 3

## 5. Funciones definidas por el usuario (User Defined Functions)

**Contexto:** hasta ahora hemos usado funciones ya construidas en Python o en NumPy (`help()`, `np.random.rand()`, `x.mean()`, etc.). En un proyecto real de análisis de datos también necesitarás encapsular tu propia lógica —una fórmula matemática, una regla de negocio o una transformación que se repite— en una función reutilizable.

**Necesidad:** copiar y pegar el mismo cálculo en varias celdas hace el código difícil de mantener y propenso a errores. Definir tus propias funciones te permite escribir la lógica una sola vez, darle un nombre descriptivo y reutilizarla cuantas veces sea necesario con distintos valores de entrada.

**¿Cómo se construye una función en Python?**

```python
def nombre_funcion(parametro1, parametro2):
    # cuerpo de la función: la lógica que transforma los parámetros
    resultado = ...
    return resultado
```

- `def` inicia la definición de la función.
- `nombre_funcion` es el identificador con el que la llamarás después.
- Los parámetros entre paréntesis (`parametro1`, `parametro2`) son los valores de entrada.
- El cuerpo, indentado, contiene las operaciones que se ejecutan cada vez que se llama la función.
- `return` indica el valor que la función entrega como resultado.

A continuación se definen tres funciones matemáticas que usaremos más adelante para graficar: `func` (una función trigonométrica), `logit` (usada en modelos de regresión logística) y `GaussDist` (la función de densidad de la distribución normal).

### 5.1 Funciones `lambda`: una alternativa a `def`

**Contexto:** muchas veces necesitas una función muy simple, de una sola línea, que solo vas a usar una vez o como argumento de otra función (por ejemplo, para ordenar una lista o transformar cada elemento de un arreglo). Definir una función completa con `def` para algo tan corto puede ser innecesario.

**Necesidad:** `lambda` te permite crear una función **anónima** (sin nombre) en una sola línea, justo en el lugar donde la necesitas, evitando escribir un bloque `def` completo para lógica trivial.

```python
lambda parametro1, parametro2: expresion
```

- No lleva la palabra `return`: el resultado de la expresión se devuelve automáticamente.
- Solo puede contener **una expresión**, no múltiples líneas ni sentencias (`if`/`for` como statement, asignaciones, etc.).
- Puede asignarse a una variable (aunque no es su uso más común) o pasarse directamente como argumento.

**Ejemplo equivalente con `def` y con `lambda`:**

```python
# Con def
def cuadrado(x):
    return x ** 2

# Con lambda (equivalente)
cuadrado_lambda = lambda x: x ** 2
```

**Diferencias clave entre `def` y `lambda`:**

| Aspecto | `def` | `lambda` |
| --- | --- | --- |
| Nombre | Siempre tiene nombre | Anónima (a menos que se asigne a una variable) |
| Cuerpo | Puede tener varias líneas, `if`, `for`, docstrings | Una sola expresión |
| Uso típico | Lógica reutilizable y compleja | Lógica corta, de un solo uso |
| Legibilidad | Mejor para funciones con varios pasos | Mejor para operaciones simples "en línea" |

**Casos de uso comunes de `lambda`:**
- Como `key` en funciones de ordenamiento: `sorted(datos, key=lambda fila: fila[1])`.
- Con `map()` y `filter()`: `list(map(lambda x: x * 2, valores))`.
- Como argumento rápido en `pandas` (`df["col"].apply(lambda x: x.upper())`) o al graficar transformaciones puntuales.

Cuando la lógica crece (varias líneas, validaciones, reutilización en distintos puntos del notebook), es mejor usar `def`; para una transformación breve y de un solo uso, `lambda` resulta más compacta.

```python
# Ejemplo de lambda equivalente a una función simple con def
cuadrado_lambda = lambda x: x ** 2
cuadrado_lambda(5)
```

```python
# Caso de uso: lambda como argumento de otra función (sorted y map)
ventas = [("producto_a", 120), ("producto_b", 45), ("producto_c", 300)]

ventas_ordenadas = sorted(ventas, key=lambda fila: fila[1])
totales_con_iva = list(map(lambda fila: (fila[0], fila[1] * 1.19), ventas))

print(ventas_ordenadas)
print(totales_con_iva)
```

```python
def func(x):
    return x*np.sin(x)
```

```python
def logit(x):
    return np.log(x/(1.- x))
```

```python
def GaussDist(x,sigma,mu):
    return np.exp(-((x-mu)**2.)/(2.*sigma**2.))/(sigma*np.sqrt(2.*np.pi))
```

## 6. Librerías de graficación en Python

**Contexto:** un resultado numérico o una tabla no siempre comunican de forma efectiva un hallazgo. Como Analista de Datos necesitas **visualizar** tendencias, comparar grupos, detectar valores atípicos o distribuciones, tanto para tu propio análisis exploratorio como para presentar resultados a un negocio o a un equipo técnico.

**Necesidad:** cada tipo de tarea de visualización tiene requisitos distintos: un reporte estático para un PDF no necesita lo mismo que un tablero interactivo para explorar datos en un navegador. Python ofrece varias librerías de graficación, cada una pensada para un caso de uso diferente. Algunas de las más importantes son:

- **[Matplotlib](https://matplotlib.org/):** librería base de graficación 2D en Python. Genera figuras de calidad de publicación en múltiples formatos (PNG, PDF, SVG, etc.) y funciona en scripts, la consola de Python/IPython, notebooks de Jupyter, servidores web y distintas interfaces gráficas. **Caso de uso:** gráficos estáticos y control fino de cada elemento visual (ejes, colores, anotaciones), ideal para reportes y publicaciones.
- **[Seaborn](https://seaborn.pydata.org/):** construida sobre Matplotlib, ofrece una interfaz de alto nivel para gráficos estadísticos atractivos con poco código. **Caso de uso:** análisis exploratorio rápido (distribuciones, correlaciones, comparaciones entre grupos) sin configurar manualmente cada detalle.
- **[HoloViews](http://holoviews.org/):** librería de visualización declarativa que permite expresar lo que se quiere graficar en pocas líneas, dejando que la herramienta se encargue del proceso de graficado. **Caso de uso:** exploración rápida de datos multidimensionales cuando se prioriza la velocidad de iteración sobre el control detallado del gráfico.
- **[Bokeh](https://docs.bokeh.org/en/latest/index.html):** librería de visualización interactiva pensada para el navegador. Permite construir gráficos, dashboards y aplicaciones de datos con alto desempeño incluso sobre datasets grandes o en streaming. **Caso de uso:** tableros interactivos y aplicaciones web de datos donde el usuario final necesita explorar (zoom, filtros, hover) el gráfico.

En este notebook usaremos **Matplotlib**, por ser la librería base del ecosistema científico de Python y la más usada como fundamento de las demás.

## 7. Matplotlib

```python
import matplotlib.pyplot as plt
```

### 7.1 Curvas

```python
x = np.linspace(0,2*np.pi,5000)
y = np.sin(x)

plt.figure()
plt.plot(x,y)

plt.show()
```

```python
x = np.linspace(0.001,0.999,5000)
y = logit(x)

plt.figure()
plt.plot(x,y,'r--')
plt.show()
```

```python
x = np.linspace(-5,5,5000)
y = GaussDist(x,0.1,0.)
plt.figure(figsize=(6,4))
plt.plot(x,y,'k-.',lw=3)
plt.xlabel('x',fontsize=20)
plt.ylabel('y',fontsize=40,color='r')
plt.xlim(-5,2)
plt.show()
```

### 7.2 Histogramas

```python
x=np.random.rand(1000)
plt.hist(x,100)
plt.show()
```

```python
x = np.linspace(-5,5,5000)
y = GaussDist(x,0.1,0.)
dydx = np.gradient(y)


plt.figure(figsize=(6,4))
plt.plot(x,y,'k-.',lw=3)
plt.xlabel('x',fontsize=20)
plt.ylabel('y',fontsize=40,color='r')
plt.xlim(-5,2)
plt.show()
```

```python
plt.figure(figsize=(8,8))
plt.plot(x,np.gradient(y))
plt.show()
```

### 7.3 Ejercicio: costos de producción
Una empresa fabrica estantes para computadoras personales. Para cierto modelo, el costo total c (en miles de dólares) cuando se producen $\textbf{q}$ _cientos_ de estantes, está dado por
\begin{equation}
c=2q^3-9q^2+12q+20
\end{equation}
* La empresa tiene actualmente capacidad para producir entre 75 y 600 (inclusive) estantes por semana. Determine el número de estantes que debe producir por semana para minimizar el costo total y encuentre el correspondiente costo promedio por estante.

```python
def c(q):
    out=2.*q**3. - 9.*q**2. + 12.*q + 20.
    return out
```

```python
q=np.linspace(.75,6.01,10000)
total_cost=c(q)

dcdq=np.gradient(total_cost)

plt.figure()
plt.plot(q,total_cost)
plt.show()


plt.figure()
plt.plot(q,dcdq)
plt.show()
```

```python
total_cost[dcdq.argmin()]
q[dcdq.argmin()]
```

```python
c(600)
```

### 7.4 Subplot

```python
plt.figure(figsize=(16,8))

plt.subplot(1,2,1,)
plt.plot(q,total_cost)

plt.subplot(1,2,2)
plt.plot(q,dcdq)

plt.show()
```

* Suponga que deben producirse entre 300 y 600 estantes. ¿Cuántos deberían producirse ahora para minimizar el costo total?

### 7.5 Ejercicio: elasticidad de la demanda
 La ecuación de demanda de un producto es
\begin{equation}
q=\sqrt{2500-p^2}
\end{equation}
Encuentre la elasticidad puntual de la demanda cuando p= 30. Si el precio de 30 disminuye 23%, ¿cuál es el cambio aproximado en la demanda?

Teniendo en cuenta que la elasticidad puntual esta dada por:
\begin{equation}
\eta = \frac{p/q}{dp/dq}
\end{equation}

### 7.6 Scatter Plot

```python
nsize = 1000
x = np.linspace(0,3*np.pi,nsize)
y = np.sin(x) + 0.3*np.random.rand(nsize)
```

```python
plt.figure(figsize=(16,12))
plt.title()
plt.scatter(x,y,c='k',alpha=0.5,lw=5)
plt.show()
```
