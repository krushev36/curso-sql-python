---
title: Notebook 01: Fundamentos de Python para Ciencia de Datos
---

Fuente original: [01_python_fundamentos.ipynb](https://github.com/krushev36/curso-sql-python/blob/main/python/notebooks/01_python_fundamentos.ipynb)

# Notebook 01: Fundamentos de Python para Ciencia de Datos



## SQL para Ciencia de Datos usando Databricks



### Maestria en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia



**Objetivo del notebook:** fortalecer bases de Python para analisis de datos, incluyendo tipos de datos, secuencias, funciones integradas y operaciones numericas con NumPy.

## 0. VS Code y GitHub Codespaces

### Contexto
VS Code es el editor principal para trabajar con este curso porque permite abrir notebooks, scripts y archivos de datos en un mismo entorno. GitHub Codespaces complementa ese flujo al ofrecer un espacio de desarrollo en la nube, listo para usar sin depender de una instalacion local compleja.

### Configuracion
En VS Code se recomienda instalar las extensiones de Python y Jupyter para ejecutar celdas, inspeccionar variables y trabajar con notebooks interactivos. En un Codespace, el entorno ya viene preparado con el repositorio, el sistema operativo y varias herramientas de desarrollo; normalmente solo hay que abrir el proyecto y confirmar que el interprete de Python y las extensiones necesarias estan disponibles.

### Uso
VS Code se usa para editar, ejecutar y depurar codigo localmente o conectado a un contenedor remoto. GitHub Codespaces se usa cuando se quiere trabajar desde cualquier equipo con el mismo entorno, compartir avances facilmente y evitar problemas de configuracion entre maquinas. En ambos casos, la idea es tener un flujo de trabajo reproducible para practicar Python y analizar datos con menos friccion.

## 1. Instalacion de librerias

conda  y pip son herramientas para manejar y desplegar aplicaciones, ambientes y paquetes.

Se puede usar el comando  `conda` para instalar librerias asi:
```{bash}

conda install seaborn

```

Tambien se puede usar el comando `pip` para instalar librerias asi:
```{bash}

pip install seaborn

```

Se puede forzar la instalacion de paquetes de la siguiente forma:
```{bash}

conda install -c conda-forge statsmodels

```

## 2. Importar librerias

La forma mas directa de importar una librerias es:
```{python}

import sys

import os

import numpy

```

Otra forma que puede ser mas util, es instalar y dar un alias al nombre de la libreria:
```{python}

import numpy as np

```

Igualmente se puede instalar un submodulo en vez de toda la libreria:
```{python}

import matplotlib.pyplot as plt

```

O se puede importar una o varias funciones de la libreria:
```{python}

from random import random, uniform, gauss

```

Para revisar si un modulo esta instalado:
```{python}

'numpy' in sys.modules

'scipy' in sys.modules

```

Se puede revisar si un modulo esta instalado asi:
```{python}

'numpy' in sys.modules

'scipy' in sys.modules

```

## 3. Python Kernel  

[Referencia](https://www.dummies.com/programming/python/interacting-kernel-python-programming/)

The kernel is the server that enables Python programmers to run cells within Notebook. You typically see the kernel commands in a separate command or terminal window.

Each entry shows the time the kernel executed the task, which application the command executed, the task it performed, and any resources affected. In most cases, you don't need to do anything with this window, but viewing it can be helpful when you run into problems because you often see error messages that can help you resolve an issue.

You control the kernel in a number of ways. For example, saving a file issues a command to the kernel, which carries the task out for you. However, you also find some kernel-specific commands on the Kernel menu, which are described in the following list:

* **Interrupt**: Causes the kernel to stop performing the current task without actually shutting the kernel down. You can use this option when you want to do something like stop processing a large dataset.

* **Restart**: Stops the kernel and starts it again. This option causes you to lose all the variable data. However, in some cases, this is precisely what you need to do when the environment has become dirty with old data.

* **Restart & Clear Output**: Stops the kernel, starts it again, and clears all the existing cell outputs.

* **Restart & Run All**: Stops the kernel, starts it again, and then runs every cell starting from the top cell and ending with the last cell. When Notebook reaches the bottom, it selects the last cell but doesn't insert a new one.

* **Reconnect**: Recreates the connection to the kernel. In some cases, environmental or other issues could cause the application to lose its connection, so you use this option to reestablish the connection without loss of variable data.

* **Shutdown**: Shuts the kernel down. You may perform this step in preparation for using a different kernel.

* **Change Kernel**: Selects a different kernel from the list of kernels you have installed. For example, you may want to test an application using various Python versions to ensure that it runs on all of them.

## 4. SHORTCUTS

* New cell below: "Esc+b"

* New cell above: "Esc+a"

* Delete cell: "Esc+D+D"

* Comment region:"Crtl+/" or "Ctrl+}"

* SHIFT + M = It merges multiple selected cells into one cell. 

* CTRL + SHIFT + – = It splits the current cell into two cells from where your cursor is. 


## 5. Magics

### Contexto
Las magics son comandos especiales de Jupyter que comienzan con el simbolo `%` o `%%` y permiten ejecutar tareas utiles sin escribir codigo Python completo. Son muy practicas para explorar el entorno, medir tiempos, listar contenido del sistema y configurar la visualizacion en notebooks.

### Descripcion
En un notebook, las magics funcionan como atajos para acciones frecuentes de analisis y depuracion. Algunas son magics de linea, que actuan sobre una sola instruccion, y otras son magics de celda, que afectan toda la celda. Usarlas hace mas rapido el trabajo interactivo y reduce la necesidad de escribir codigo auxiliar para tareas basicas.

### Magics utiles
- `%ls`: lista los archivos y carpetas del directorio actual.
- `%dirs`: muestra la pila de directorios activos en la sesion.
- `%lsmagic`: lista todas las magics disponibles en el entorno.
- `%matplotlib inline`: muestra graficos directamente dentro del notebook.
- `%who`: muestra los nombres de las variables definidas en la sesion actual.
- `%time`: mide el tiempo que tarda en ejecutarse una sola instruccion o expresion.

### Uso recomendado
Las magics son utiles para inspeccionar rapidamente el estado del entorno y acelerar tareas de exploracion. En ejercicios de datos conviene usarlas como apoyo, no como reemplazo del codigo principal, para mantener el notebook claro y reproducible.

```{python}

%ls

%dirs

%lsmagic

%matplotlib inline ## It allows the output of plotting command to be displayed inline i.e. in Jupyter lab UI.

%who ## will list all variables that exist in the global scope. 

%time ## will give you information about the time taken in a single run of the code in your cell.

```

## 6. [Tipos de Variable](https://docs.python.org/3/reference/datamodel.html)

### 6.1 Contexto

En Python, cada valor tiene un tipo de dato que define que operaciones se pueden aplicar y como se representa en memoria. Comprender los tipos es clave para evitar errores y para escribir codigo mas claro, eficiente y facil de mantener en analisis de datos.

### 6.2 Descripcion

Los tipos basicos mas usados son enteros (`int`), flotantes (`float`), cadenas de texto (`str`), booleanos (`bool`), bytes (`bytes`) y numeros complejos (`complex`). Python es un lenguaje de tipado dinamico: una variable puede cambiar de tipo durante la ejecucion, pero cada valor conserva siempre su tipo. Conocer estas diferencias permite elegir la estructura adecuada segun el problema, validar datos de entrada y aplicar operaciones correctas en cada caso.

### 6.3 [Enteros y Flotantes](https://docs.python.org/3/reference/datamodel.html)

```python
a=1
b=3
a+b
```

```python
a+b;
```

```python
print(a+b)
```

```python
a-1
```

```python
c=a*b
```

```python
2**(1/2.)
```

```python
int(5.5)
```

```python
float(5)
```

### 6.4 Cadenas de caracteres

* [Referencia 1](https://docs.python.org/3/library/string.html)

* [Referencia 2](https://www.programiz.com/python-programming/methods/string)



### 6.5 Contexto

Las cadenas de caracteres son fundamentales en programacion porque gran parte de los datos que analizamos o procesamos llega en formato texto: nombres, categorias, fechas, codigos, rutas de archivo y mensajes. En ciencia de datos, dominar cadenas permite limpiar, transformar y estandarizar informacion antes del analisis.



### 6.6 Descripcion

En Python, un string (`str`) es una secuencia inmutable de caracteres. Esto significa que no se modifica en el lugar: cada transformacion produce una nueva cadena. Los strings soportan operaciones como concatenacion, repeticion, indexacion, slicing y una amplia coleccion de metodos para convertir mayusculas/minusculas, reemplazar texto, separar palabras y validar contenido.



Particularmente las cadenas de caracteres en Python son clases. Sobre los strings se pueden realizar multiples operaciones para preparacion de datos, validacion de entradas y construccion de salidas legibles.

```python
"abc"+"def"
```

```python
3*"abc"
```

```python
3*"abc"+"def"
```

```python
"hola este es el curso de programacion en python".split(" ")
```

```python
"hola este es el curso de programacion en python".upper()
```

```python
"hola este es el curso de programacion en python".upper().lower()
```

```python
"hola este es el curso de programacion en python".replace("python","java")
```

```python
len("hola este es el curso de programacion en python")
```

```python
type("hola este es el curso de programacion en python")
```

## 7. [Tipos de Secuencias](https://docs.python.org/3/reference/datamodel.html)

[Referencia](https://docs.python.org/3/library/stdtypes.html#typesseq)



### 7.1 Contexto

En analisis de datos es comun trabajar con colecciones ordenadas de elementos, por ejemplo listas de registros, series de valores o secuencias de texto. Los tipos de secuencias permiten organizar estos datos y recorrerlos de forma eficiente para filtrar, transformar y resumir informacion.



### 7.2 Descripcion

En Python, una secuencia es una estructura ordenada que almacena elementos y permite operaciones como indexacion, slicing, iteracion, busqueda y calculo de longitud. Entre las secuencias mas usadas estan `list`, `tuple`, `range` y `str`. Aunque comparten operaciones comunes, cada tipo tiene un proposito diferente: las listas son mutables, las tuplas son inmutables, los rangos generan secuencias numericas de forma compacta y las cadenas representan texto.



Comprender estas diferencias ayuda a elegir la estructura adecuada segun el problema, mejorar el rendimiento y escribir codigo mas legible.



### 7.3 [Tuplas](https://docs.python.org/3/reference/datamodel.html) 

The items of a tuple are arbitrary Python objects. Tuples of two or more items are formed by comma-separated lists of expressions. A tuple of one item (a 'singleton') can be formed by affixing a comma to an expression (an expression by itself does not create a tuple, since parentheses must be usable for grouping of expressions). An empty tuple can be formed by an empty pair of parentheses.

```python
tupla1 = ("hola este es el curso de","python", "y", "R")
print(tupla1)
```

```python
tupla1[0]
```

```python
tupla1[-1]
```

```python
tupla1[1:4]
```

```python
len(tupla1)
```

```python
type(tupla1)
```

### 7.4 [Listas](https://docs.python.org/3/reference/datamodel.html)
The items of a list are arbitrary Python objects. Lists are formed by placing a comma-separated list of expressions in square brackets. (Note that there are no special cases needed to form lists of length 0 or 1.)

```python
utiles_inutiles = ["Lapiz","Borrador","Cuaderno","libro","sacapuntas","colores"]
```

```python
len(utiles_inutiles)
```

```python
utiles_inutiles[-2]
```

```python
type(utiles_inutiles)
```

# Secuencias

```python
range(1,10,1)
```

## 8. [Conjuntos](https://docs.python.org/3/tutorial/datastructures.html#sets)
Python also includes a data type for sets. A set is an unordered collection with no duplicate elements. Basic uses include membership testing and eliminating duplicate entries. Set objects also support mathematical operations like union, intersection, difference, and symmetric difference.

```python
a = {6,8,3,"hola"}
```

```python
type(a)
```

```python
a = set('abracadabra')
```

```python
a
```

```python
# Crear conjuntos
conjunto1 = {1, 2, 3, 4, 5}
conjunto2 = set([3, 4, 5, 6, 7])

# Eliminar duplicados de una lista
lista = [1, 2, 2, 3, 4, 4, 5]
conjunto_sin_duplicados = set(lista)

# Operaciones de conjuntos
union = conjunto1 | conjunto2           # Unión
interseccion = conjunto1 & conjunto2    # Intersección
diferencia = conjunto1 - conjunto2      # Diferencia
simetrica = conjunto1 ^ conjunto2       # Diferencia simétrica

# Agregar y eliminar elementos
conjunto1.add(6)
conjunto1.discard(2)

# Verificar pertenencia
existe = 3 in conjunto1

# Mostrar resultados
print("conjunto1:", conjunto1)
print("conjunto2:", conjunto2)
print("conjunto_sin_duplicados:", conjunto_sin_duplicados)
print("union:", union)
print("interseccion:", interseccion)
print("diferencia:", diferencia)
print("simetrica:", simetrica)
print("existe 3 en conjunto1:", existe)
```

## 9. [Tipos de Mapeo](https://docs.python.org/3/reference/datamodel.html)
These represent finite sets of objects indexed by arbitrary index sets. The subscript notation a[k] selects the item indexed by k from the mapping a; this can be used in expressions and as the target of assignments or del statements. The built-in function len() returns the number of items in a mapping.

### 9.1 [Diccionarios](https://docs.python.org/3/library/stdtypes.html#typesmapping)
These represent finite sets of objects indexed by nearly arbitrary values. The only types of values not acceptable as keys are values containing lists or dictionaries or other mutable types that are compared by value rather than by object identity, the reason being that the efficient implementation of dictionaries requires a key’s hash value to remain constant. Numeric types used for keys obey the normal rules for numeric comparison: if two numbers compare equal (e.g., 1 and 1.0) then they can be used interchangeably to index the same dictionary entry.

```python
dict_utils = {"cuadernos":12,"colores":24,"lapiz":1,"borrador":2,"libros":12}
```

```python
dict_utils["cuadernos"]
```

```python
dict_utils.items()
```

```python
dict_utils.keys()
```

```python
dict_utils.pop('colores')
```

```python
# Crear dos diccionarios
dict1 = {"a": 1, "b": 2}
dict2 = {"b": 3, "c": 4}

# Extender dict1 con dict2 (agrega/actualiza claves)
dict1.update(dict2)

# Agregar múltiples elementos usando update con otro diccionario
dict1.update({"d": 5, "e": 6})

# Actualizar un valor específico
dict1["a"] = 10

# Ejemplo usando | para actualizar un diccionario (Python 3.9+)
dict3 = dict1 | {"f": 7, "b": 8}

# Mostrar resultados
print("dict1 extendido y actualizado:", dict1)
print("dict3 usando |:", dict3)
```

```python
# Ejemplo básico de get en un diccionario
d = {"a": 1, "b": 2, "c": 3}

# Obtener valor existente
valor_a = d.get("a")  # Devuelve 1

# Obtener valor inexistente sin valor por defecto
valor_x = d.get("x")  # Devuelve None

# Obtener valor inexistente con valor por defecto
valor_y = d.get("y", 100)  # Devuelve 100

# Usar get para evitar errores al acceder a claves faltantes
clave = "z"
resultado = d.get(clave, "No existe")

# Mostrar resultados
print("valor_a:", valor_a)
print("valor_x:", valor_x)
print("valor_y:", valor_y)
print("resultado:", resultado)
```

## 10. Example (standard input): 
Read two integers from STDIN and print three lines where:

* The first line contains the sum of the two numbers.
* The second line contains the difference of the two numbers (first - second).
* The third line contains the product of the two numbers.

```python
if __name__ == '__main__':
    a = int(input())
    b = int(input())
```

## 11. Task

Read two integers and print two lines. The first line should contain integer division,  // . The second line should contain float division,  / .

Note: You don't need to perform any rounding or formatting operations.

```python
if __name__ == '__main__':
    a = int(input())
    b = int(input())
```

## 12. Funciones integradas de Python (Built-in Functions)

### Contexto
Python incluye un conjunto de funciones integradas que estan disponibles sin importar librerias adicionales. Estas funciones se usan a diario para inspeccionar datos, convertir tipos, resumir colecciones, recorrer estructuras y construir soluciones mas cortas y legibles.

### Descripcion
Las built-in functions forman parte del lenguaje y cubren tareas basicas pero esenciales. En analisis de datos son especialmente utiles para validar valores, preparar colecciones y hacer operaciones simples antes de usar librerias mas especializadas como NumPy o pandas. Conocerlas bien mejora la claridad del codigo y reduce la necesidad de escribir logica repetitiva.

### 10 funciones mas utilizadas
- `len()`: devuelve la cantidad de elementos de una coleccion, cadena o estructura indexable.
- `type()`: indica el tipo de un objeto y ayuda a inspeccionar valores durante la depuracion.
- `print()`: muestra informacion en pantalla o en la salida de una celda.
- `input()`: solicita datos al usuario desde la entrada estandar.
- `range()`: genera una secuencia de numeros para recorridos o repeticiones controladas.
- `sum()`: calcula la suma de los elementos numericos de una coleccion.
- `min()`: obtiene el valor mas pequeno de una secuencia.
- `max()`: obtiene el valor mas grande de una secuencia.
- `sorted()`: devuelve una nueva lista con los elementos ordenados.
- `enumerate()`: recorre una coleccion y entrega indice y valor en cada iteracion.
- `zip()`: combina dos o mas colecciones en pares o tuplas para recorrerlas al mismo tiempo.

### Ejemplo general
En los bloques siguientes se muestran varias de estas funciones en accion sobre enteros, cadenas, listas y conversiones de tipo.

```python
type(c)
```

```python
d=a/b
```

```python
type(d)
```

```python
word='hola mundo!'
print(word)
```

```python
type(word)
```

```python
str(a)
```

```python
float(a)
```

## 13. [Biblioteca NumPy](https://numpy.org/devdocs/user/quickstart.html)

### Contexto
NumPy es la base del calculo numerico en Python. Se usa para representar datos de forma vectorizada, realizar operaciones matematicas sobre arreglos y construir soluciones eficientes cuando se trabaja con grandes volumenes de informacion numerica.

### Descripcion
NumPy ofrece una estructura central llamada `ndarray` y un conjunto amplio de funciones para manipulacion de datos, algebra lineal, transformaciones matematicas y generacion de valores. Su principal ventaja es que permite trabajar con datos homogeneos de manera rapida y expresiva, evitando bucles innecesarios y aprovechando operaciones optimizadas internamente.

### ¿Por que usar NumPy?
- Permite trabajar con arreglos numericos de manera eficiente.
- Facilita operaciones matematicas sobre vectores y matrices.
- Sirve como base para librerias como pandas, SciPy y scikit-learn.
- Mejora la legibilidad y el rendimiento del codigo cientifico.
- Incluye herramientas para algebra lineal, funciones matematicas y generacion de datos.

### Elemento principal
El objeto central de NumPy es el arreglo multidimensional (`ndarray`), que almacena elementos del mismo tipo y permite indexacion, slicing y operaciones vectorizadas sobre sus valores.

```python
import numpy as np
```

## 14. [Arrays](https://docs.scipy.org/doc/numpy/reference/arrays.html)

### Contexto
Los arrays de NumPy se usan para representar datos numericos de forma compacta y consistente. Son muy utiles cuando se quiere analizar informacion que llega como listas, tablas o matrices y se necesita aplicar transformaciones rapidas sobre todos sus elementos.

### Descripcion
Un `ndarray` es una estructura multidimensional homogenea, es decir, todos sus elementos comparten el mismo tipo de dato y ocupan un bloque de memoria uniforme. Esto permite realizar operaciones sobre filas, columnas o sobre todo el arreglo con sintaxis sencilla y mejor rendimiento que las estructuras basadas en listas de Python.

### Caracteristicas principales
- Soporta arreglos de una, dos o mas dimensiones.
- Permite indexacion y slicing para acceder a subconjuntos de datos.
- Facilita operaciones vectorizadas sin escribir ciclos manuales.
- Conserva un tipo de dato uniforme en todos sus elementos.
- Se adapta bien a tareas de calculo numerico y manipulacion matricial.

### Uso practico
Los arrays son la base para representar vectores, matrices e incluso tensores en tareas de ciencia de datos. Por eso aparecen en operaciones de limpieza, exploracion, estadistica y modelado matematico.

```python
x=np.array([1,2,3])
x.view()
```

```python
x=np.array([[1,2,3],[5,6,7],[8,9,10]])
x.view()
```

```python
y=np.arange(0,9)
y.view()
```

```python
np.zeros(5)
```

```python
np.ones(10)
```

```python
np.eye(4)
```

### 14.1 Atributos y metodos del array

```python
y.size
```

```python
y.shape
```

```python
y.reshape((3,3))
```

```python
y = np.arange(0,9).reshape((3,3))
y.view()
```

### 14.2 Operaciones basicas con arrays

```python
x+y
```

```python
y/x
```

```python
np.matmul(x,y)
```

## 15. [Rutinas de NumPy](https://docs.scipy.org/doc/numpy/reference/routines.html)

### Contexto
Ademas de crear arreglos, NumPy incluye rutinas especializadas para trabajar con numeros, estadistica, algebra lineal y funciones matematicas. Estas herramientas evitan tener que implementar manualmente operaciones comunes en analisis cuantitativo.

### Descripcion
Las rutinas de NumPy agrupan submodulos y funciones listas para usar, como `random`, `linalg`, `fft`, `testing` y `matlib`. Cada uno resuelve una familia de problemas frecuentes: generar numeros aleatorios, operar con matrices, calcular transformadas o validar resultados.

### Rutinas frecuentes
- `random`: genera valores aleatorios y simulaciones.
- `linalg`: contiene operaciones de algebra lineal.
- `fft`: permite trabajar con transformadas de Fourier.
- `testing`: ofrece utilidades para probar comparaciones numericas.
- `matlib`: incluye funciones orientadas a matrices.

### Uso recomendado
Estas rutinas son utiles cuando el analisis requiere simulacion, validacion matematica o manipulacion avanzada de matrices y señales. La ventaja es que ya vienen optimizadas y documentadas dentro del ecosistema NumPy.

```python
np.sin(0)
```

```python
np.cos(0)
```

```python
np.exp(0)
```

```python
np.linspace(0,10,30)
```

```python
np.sin(np.linspace(0,2*np.pi,50))
```

### 15.1 Algebra lineal con NumPy

### Contexto
El algebra lineal es fundamental en ciencia de datos, aprendizaje automatico, optimizacion y analisis numerico. NumPy ofrece funciones para trabajar con matrices, resolver sistemas de ecuaciones, calcular determinantes, inversas y eigenvalores.

### Descripcion
El submodulo `numpy.linalg` reune operaciones de algebra lineal pensadas para vectores y matrices. Sus funciones permiten resolver problemas matematicos directamente en Python sin depender de implementaciones manuales, lo que mejora la claridad y reduce errores.

### Operaciones frecuentes
- `np.linalg.inv()`: calcula la inversa de una matriz cuadrada.
- `np.linalg.det()`: calcula el determinante.
- `np.linalg.solve()`: resuelve sistemas lineales del tipo `A x = b`.
- `np.linalg.eig()`: obtiene eigenvalores y eigenvectores.
- `np.linalg.norm()`: calcula normas vectoriales o matriciales.

### Uso recomendado
Estas operaciones son especialmente utiles cuando el problema puede formularse como una matriz o un sistema lineal. En aplicaciones reales aparecen en regresion, redes neuronales, optimizacion y analisis de correlacion entre variables.

```python
np.linalg.inv(x)
```

```python
np.linalg.det(x)
```

### 15.2 `np.linalg.det()`

Calcula el determinante de una matriz cuadrada. El determinante permite saber si una matriz es invertible y se usa en muchas formulaciones de algebra lineal y geometria.

```python
np.linalg.det([[1 , 2], [2, 1]])       #Output : -3.0
```

### 15.3 `np.linalg.eig()`

Calcula los eigenvalores y eigenvectores de una matriz cuadrada. Esta funcion es util para analisis de estabilidad, reduccion de dimension y descomposiciones matriciales.

```python
vals, vecs = np.linalg.eig([[1 , 2], [2, 1]])
print(vals)                                      #Output : [ 3. -1.]
print(vecs)                                      #Output : [[ 0.70710678 -0.70710678]
                                                #          [ 0.70710678  0.70710678]]
```

### 15.4 `np.linalg.inv()`

Calcula la inversa multiplicativa de una matriz cuadrada. Se usa cuando se necesita despejar variables en sistemas lineales o reconstruir transformaciones matriciales.

```python
np.linalg.inv([[1 , 2], [2, 1]])       #Output : [[-0.33333333  0.66666667]
                                                #          [ 0.66666667 -0.33333333]]
```

## 16. Task:
Solve the following operations: $\mathbf{A+B}$, $\mathbf{A-B}$, $\mathbf{AB}$, $\mathbf{A(BC)}$, $\mathbf{(AB)C}$, 

$$
A=
\begin{pmatrix}
0 & 1 & -2 \\
3 & 4 & 5 \\
-6 & 7 & 15 
\end{pmatrix}
\quad, B=
\begin{pmatrix}
0 & -5 & 3 \\
5 & 2 & -1 \\
-4 & 2 & 0 
\end{pmatrix}
\quad, C=
\begin{pmatrix}
6 & -2 & -3 \\
2 & 0 & 1 \\
0 & 5 & 7 
\end{pmatrix}
$$

## 17. Task:

Solve the following equation systems
\begin{align}
2 x_1 - 5 x_2 & = 3 \\
5 x_1 + 8 x_2 & = 5 
\end{align}

Solve the following equation systems
\begin{align}
2 x_1 + 2 x_2 - x_3 =  2 \\
  x_1 - 3 x_2 + x_3 = 0 \\
3 x_1 + 4 x_2 - x_3 = 1
\end{align}

```python
#A = np.array([[0, 1, -2],[3, 4, 5],[-6, 7, 15]])
A = np.array([[2, 2,-1],[1,-3,1],[3,4,-1]])
b = np.array([2,0,1])
A.view()
```

```python
np.linalg.det(A)
```

```python
x=np.linalg.solve(A,b)
```

```python
x.view()
```

## 18. Ejercicio final: colas en programacion

### Contexto
En programacion, una cola es una estructura de datos que sigue la regla FIFO: el primer elemento en entrar es el primero en salir. Este comportamiento aparece en sistemas de atencion, impresoras, tareas pendientes y simulaciones de procesos.

### Descripcion
Construye una cola simple usando una lista de Python y usa funciones basicas para revisar su comportamiento. El objetivo es entender como entran y salen elementos de forma ordenada, sin usar librerias externas.

### Actividad
1. Crea una lista llamada `cola` con al menos cinco elementos que representen personas, tareas o solicitudes.
2. Usa `len()` para mostrar cuantas personas o tareas hay en la cola.
3. Agrega un nuevo elemento al final con `append()`.
4. Retira el primer elemento con `pop(0)` para simular la salida de la cola.
5. Recorre la cola con `enumerate()` para mostrar el orden de atencion.
6. Si los elementos son numeros, usa `sum()` para obtener su total.

### Preguntas
- ¿Que elemento entro primero y cual salio primero?
- ¿Que ocurre con el orden de los elementos despues de usar `append()` y `pop(0)`?
- ¿Por que una cola se relaciona con el principio FIFO?
- ¿En que casos de la vida real podria ser util esta estructura?

### Sugerencia
Intenta resolver el ejercicio primero con una lista normal y luego describe con tus palabras la diferencia entre agregar elementos al final y retirar elementos del inicio.

```python
cola = ["Ana", "Luis", "Maria", "Carlos", "Sofia"]

print("Cola inicial:", cola)
print("Cantidad inicial:", len(cola))

cola.append("Andres")
print("Despues de append:", cola)

atendido = cola.pop(0)
print("Atendido primero:", atendido)
print("Cola despues de pop(0):", cola)

print("Orden de atencion restante:")
for posicion, persona in enumerate(cola, start=1):
    print(posicion, persona)

numeros_en_cola = [10, 20, 30, 40, 50]
print("Suma de valores numericos:", sum(numeros_en_cola))

print("Cantidad final de personas en cola:", len(cola))
```
