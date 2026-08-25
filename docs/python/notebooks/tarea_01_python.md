---
title: "Tarea 01: Fundamentos de Python"
layout: page
---

Fuente original: [tarea_01_python.ipynb](https://github.com/krushev36/curso-sql-python/blob/main/python/notebooks/tarea_01_python.ipynb)

# Tarea 01: Fundamentos de Python

## SQL para Ciencia de Datos usando Databricks

### Maestria en Ciencia de Datos e Inteligencia de Negocios · Universidad de Antioquia

**Instrucciones generales:**
- Complete cada ejercicio en las celdas indicadas.
- No modifique las celdas de enunciado.
- Ejecute todas las celdas antes de entregar.
- Entregue el notebook con todas las salidas visibles.

---

## Ejercicio 1 — Convergencia de la Serie Geométrica (Ciclos, matemáticas y gráfica)

**Objetivo:** Demostrar de forma numérica la convergencia de la serie geométrica y visualizar cómo la suma parcial se aproxima al valor esperado a medida que aumenta el número de términos.

La serie geométrica se define como:

$$\sum_{n=0}^{\infty} r^n = \frac{1}{1 - r}, \quad \text{para } |r| < 1$$

**Pasos:**
1. Defina una razón `r = 0.5` (con `|r| < 1`) y un número máximo de términos, por ejemplo `N = 100`.
2. Implemente una función `suma_parcial(r, n_terminos)` que calcule la suma de los primeros `n_terminos` de la serie usando un ciclo `for` o `while` (sin usar la fórmula cerrada).
3. Calcule el **valor esperado** de la serie con la fórmula cerrada $$\frac{1}{1-r}$$.
4. Para cada número de términos entre 1 y `N`, calcule la suma parcial y el **error absoluto** respecto al valor esperado: $$\text{error} = |\text{valor esperado} - \text{suma parcial}|$$
5. Genere una gráfica que muestre:
   - La evolución de la suma parcial en función del número de términos.
   - Una línea horizontal indicando el valor esperado ($$\frac{1}{1-r}$$).
   - Título, etiquetas de los ejes y leyenda.
6. Imprima el error absoluto obtenido con `N` términos.

> **Pista:** La suma parcial de los primeros `n` términos es $$S_n = \sum_{k=0}^{n-1} r^k$$. A medida que `n` crece, `S_n` debe acercarse cada vez más a $$\frac{1}{1-r}$$.

---

## Ejercicio 2 — Aproximación de sin(x) con series de Taylor (Ciclos, matemáticas y gráfica)

**Objetivo:** Aproximar la función $$\sin(x)$$ usando su expansión en serie de Taylor y comparar la aproximación con el valor real.

$$\sin(x) = \sum_{n=0}^{\infty} \frac{(-1)^n}{(2n+1)!} x^{2n+1}$$

**Pasos:**
1. Implemente una función `sin_taylor(x, terminos)` que calcule la aproximación con el número de términos indicado. Use ciclos y operaciones matemáticas básicas (no use `math.sin` dentro de la función de aproximación).
2. Para `x` en el rango $$[-2\pi, 2\pi]$$ y para `terminos = 1, 3, 5, 10`, calcule la aproximación.
3. Genere una gráfica que muestre:
   - La curva real de `math.sin(x)` o `numpy.sin(x)`.
   - Las curvas de aproximación para cada número de términos.
   - Leyenda, título y etiquetas de ejes.
4. Imprima el error absoluto máximo para `terminos = 10` en el rango evaluado.

> **Pista:** El factorial puede calcularse con un ciclo acumulativo o usando `math.factorial`. El signo alterna con `(-1)**n`.

---

## Ejercicio 3 — Convergencia de la Serie Armónica Alternante (Ciclos, matemáticas y gráfica)

**Objetivo:** Demostrar de forma numérica la convergencia de la serie armónica alternante y visualizar cómo la suma parcial se aproxima al valor esperado a medida que aumenta el número de términos.

La serie armónica alternante se define como:

$$\sum_{n=1}^{\infty} \frac{(-1)^{n+1}}{n} = 1 - \frac{1}{2} + \frac{1}{3} - \frac{1}{4} + \dots = \ln(2)$$

El **valor esperado** de esta serie es $$\ln(2) \approx 0.6931$$.

**Pasos:**
1. Defina un número máximo de términos, por ejemplo `N = 1000`.
2. Implemente una función `suma_parcial_armonica(n_terminos)` que calcule la suma de los primeros `n_terminos` de la serie usando un ciclo `for` o `while`.
3. Calcule el **valor esperado** de la serie como `math.log(2)`.
4. Para cada número de términos entre 1 y `N`, calcule la suma parcial y el **error absoluto** respecto al valor esperado: $$\text{error} = |\ln(2) - S_n|$$
5. Genere una gráfica que muestre:
   - La evolución de la suma parcial en función del número de términos.
   - Una línea horizontal indicando el valor esperado ($$\ln(2)$$).
   - Título, etiquetas de los ejes y leyenda.
6. Imprima el error absoluto obtenido con `N` términos.

> **Pista:** La suma parcial de los primeros `n` términos es $$S_n = \sum_{k=1}^{n} \frac{(-1)^{k+1}}{k}$$. Observe cómo la suma oscila alrededor de $$\ln(2)$$ y se estabiliza a medida que `n` crece.

---

## Ejercicio 4 — Análisis con Pandas (Dataset, transformaciones y gráficas)

**Objetivo:** Crear un dataset de ventas ficticias, aplicar transformaciones y generar gráficas de análisis.

### 4.1 Creación del dataset

Cree un DataFrame de pandas con al menos **50 filas** y las siguientes columnas:

| Columna | Descripción |
|---|---|
| `fecha` | Fechas diarias desde el 2024-01-01 (use `pd.date_range`) |
| `producto` | Una de: `Laptop`, `Celular`, `Tablet`, `Auriculares`, `Cargador` (asigne aleatoriamente) |
| `region` | Una de: `Norte`, `Sur`, `Oriente`, `Occidente` (asigne aleatoriamente) |
| `unidades` | Número entero aleatorio entre 1 y 20 |
| `precio_unitario` | Número decimal aleatorio entre 50.0 y 1500.0 |

### 4.2 Transformaciones

1. Agregue una columna `ingreso_total = unidades * precio_unitario`.
2. Agregue una columna `mes` extraída de la columna `fecha`.
3. Filtre las filas donde `ingreso_total > 5000` y muestre cuántas hay.
4. Calcule el ingreso total por `producto` y muéstrelo ordenado de mayor a menor.
5. Calcule el promedio de `unidades` por `region`.

### 4.3 Gráficas

1. **Gráfica de barras**: ingreso total por producto.
2. **Gráfica de torta (pie)**: distribución del ingreso total por región.
3. **Gráfica de línea**: ingreso total acumulado por día (ordenado por fecha).

> **Pista:** Use `numpy.random` para generar los datos aleatorios. Para reproducibilidad, fije la semilla con `np.random.seed(42)` al inicio.

---

## Ejercicio 5 — Manipulación de datos con `data.csv` (Parte 1)

> Extraído de: [assignments-python-2024 / assingment](https://github.com/krushev36/assignments-python-2024/tree/main/assingment)

El archivo `data.csv` contiene registros con campos separados por tabulación (`\t`). La **primera columna** es una letra (`A`–`E`) y la **segunda columna** es un número entero.

Realice las siguientes operaciones de forma **independiente**:

### 5.1 — Suma de la segunda columna

Lea el archivo y calcule e imprima la **suma total** de todos los valores de la segunda columna.

**Resultado esperado:**
```
190
```

### 5.2 — Cantidad de registros por letra

Cuente cuántos registros hay para cada letra de la primera columna, **ordenados alfabéticamente**.

**Resultado esperado:**
```
A,8
B,7
C,5
D,6
E,14
```

### 5.3 — Suma de la segunda columna por letra

Calcule la suma de los valores de la segunda columna agrupados por letra, **ordenados alfabéticamente**.

**Resultado esperado:**
```
A,37
B,36
C,27
D,23
E,67
```

> **Pista:** Puede leer el archivo con `open()` y procesar línea a línea, o usar `pandas.read_csv` con `sep='\t'` y `header=None`. Para los conteos y sumas agrupadas, puede usar un diccionario o `groupby` de pandas.

---

## Ejercicio 6 — Manipulación de datos con `data.csv` (Parte 2 — Análisis avanzado)

> Extraído de: [assignments-python-2024 / assingment](https://github.com/krushev36/assignments-python-2024/tree/main/assingment)

Continuando con el mismo archivo `data.csv`, la tercera columna contiene una **fecha**, la cuarta columna contiene una **lista de etiquetas** separadas por comas (ej. `a,f,c`), y la quinta columna contiene pares `clave:valor` separados por comas (ej. `ccc:2,ddd:0,aaa:3`).

### 6.1 — Registros por año

Extraiga el año de la tercera columna y cuente cuántos registros hay por año, **ordenados por año**.

**Resultado esperado:**
```
1997,9
1998,11
1999,20
```

### 6.2 — Etiqueta más frecuente

Encuentre e imprima cuál es la **etiqueta más frecuente** en todo el dataset.

**Resultado esperado:**
```
f
```

### 6.3 — Suma de valores por clave

Para cada clave de la quinta columna, calcule la **suma total de sus valores** en todas las filas donde aparece, **ordenado alfabéticamente por clave**.

**Resultado esperado:**
```
aaa,53
bbb,82
ccc,72
ddd,98
eee,55
fff,94
ggg,61
hhh,80
iii,86
jjj,67
```

### 6.4 — Gráfica

Genere una **gráfica de barras** que muestre la suma de valores por clave calculada en el punto 6.3.

> **Pista:** Use `str.split(',')` para separar las etiquetas/pares y `str.split(':')` para separar clave y valor. Acumule los resultados en un diccionario de Python.

---

## Challenge 1 (Opcional) — Generación del conjunto de Mandelbrot

Construya un programa en Python que permita **generar y visualizar el conjunto de Mandelbrot** sobre el plano complejo.

El conjunto de Mandelbrot se define a partir de la sucesión:

$$z_{n+1} = z_n^2 + c, \quad z_0 = 0$$

donde $$c = x + yi$$ es un número complejo. Para cada valor de $$c$$, itere la expresión y determine si la sucesión permanece acotada o escapa ($$|z_n| > 2$$). Use un **máximo de 100 iteraciones por punto**.

**Dominio:**

$$-2.5 \leq \text{Re}(c) \leq 1.0 \qquad -1.5 \leq \text{Im}(c) \leq 1.5$$

**Resultado esperado:** Una gráfica del conjunto de Mandelbrot con escala de colores que diferencie los puntos que pertenecen al conjunto de los que escapan.

**Desafío adicional:** Explore cómo cambia la visualización al modificar el número máximo de iteraciones, la resolución, el dominio o la asignación de colores.

---

## Challenge 2 (Opcional) — Juego de la Vida de Conway

Construya un programa en Python que **simule y visualice el Juego de la Vida de Conway**, un autómata celular sobre una rejilla bidimensional donde cada celda puede estar **viva** (`1`) o **muerta** (`0`).

**Reglas (aplicadas simultáneamente en cada generación):**

1. **Supervivencia:** una celda viva permanece viva si tiene exactamente 2 o 3 vecinos vivos.
2. **Muerte por soledad:** una celda viva muere si tiene menos de 2 vecinos vivos.
3. **Muerte por sobrepoblación:** una celda viva muere si tiene más de 3 vecinos vivos.
4. **Nacimiento:** una celda muerta se convierte en viva si tiene exactamente 3 vecinos vivos.

**Dominio:** Rejilla de tamaño definido por el estudiante (ej. 50×50) durante `N = 100` generaciones.

**Resultado esperado:** Una visualización o animación con `matplotlib` que muestre la evolución de la población generación a generación.

**Configuraciones iniciales sugeridas:** aleatoria, Block (estable), Blinker (oscilante), Glider (se desplaza).
