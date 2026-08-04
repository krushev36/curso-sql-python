# Databricks notebook source
# MAGIC %md
# MAGIC # 11 · Archivos, análisis y visualización en Python
# MAGIC
# MAGIC Este notebook fue integrado y organizado para el curso **SQL para Ciencia de Datos usando Databricks**.
# MAGIC
# MAGIC - Repositorio fuente: `krushev36/curso-python-r.github.io`
# MAGIC - Archivo original: `sesion3/sesion3python.ipynb`
# MAGIC - Estado: revisado y ordenado para uso en esta ruta del curso.

# COMMAND ----------

# MAGIC %md
# MAGIC # SESION 3

# COMMAND ----------

import numpy as np
import matplotlib.pyplot as plt

# COMMAND ----------

# MAGIC %md
# MAGIC ##  OPERADORES LOGICOS
# MAGIC
# MAGIC * Mayor que: >
# MAGIC * Mayor igual que: >=
# MAGIC * Igual: ==
# MAGIC * Menor que: <
# MAGIC * Menor igual que: <=
# MAGIC * y: and, &
# MAGIC * o: or, 

# COMMAND ----------

# MAGIC %md
# MAGIC ## CONDICIONALES:
# MAGIC
# MAGIC ```python
# MAGIC if 'condicion':
# MAGIC     statement
# MAGIC
# MAGIC if 'condition':
# MAGIC     statement
# MAGIC else:
# MAGIC     statement
# MAGIC     
# MAGIC     
# MAGIC if 'condition':
# MAGIC     statement
# MAGIC     
# MAGIC elif:
# MAGIC     statement
# MAGIC     
# MAGIC else:
# MAGIC     statement
# MAGIC     
# MAGIC
# MAGIC ```

# COMMAND ----------

# MAGIC %md
# MAGIC ##  Ejemplo:

# COMMAND ----------

## USER AND PASSWORD

log="login"
psswd=12345

input_log = raw_input("Login: ")
input_psswd = input("password: ")

if (log == input_log) & (psswd==input_psswd):
    print('\naccess granted!')
else:
    print('\nwrong password or username!')


# COMMAND ----------

# MAGIC %md
# MAGIC ## CICLOS
# MAGIC
# MAGIC ```python
# MAGIC for 'variable' in 'list or array':
# MAGIC     statement;
# MAGIC
# MAGIC
# MAGIC while 'condition':
# MAGIC     statement;
# MAGIC     
# MAGIC while 'condition':
# MAGIC     statement;
# MAGIC     break
# MAGIC     statement;
# MAGIC     continue
# MAGIC
# MAGIC ```

# COMMAND ----------

# MAGIC %md
# MAGIC ### Ejemplo:

# COMMAND ----------

sum = 0
for i in range(8):
    sum = sum + i
    print(sum)

# COMMAND ----------

for i in range(100):
    print('hola '+str(i))

# COMMAND ----------

data = np.random.rand(25).reshape((5,5))
print(data)

print()

for i in range(5):
    print(data[i,i])

# COMMAND ----------

# MAGIC %md
# MAGIC ### CICLO WHILE

# COMMAND ----------

i=0
while i<10:
    print(i)
    i += 1

# COMMAND ----------

# MAGIC %md
# MAGIC ## Ejemplo:
# MAGIC * Converge la serie?

# COMMAND ----------

def sum1(n):
    sum=0
    for i in range(1,n):
        sum += 1./(3.*i - 2.)**(i + 0.5)
    return sum
    

# COMMAND ----------

sum1(100)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Ejercicio:
# MAGIC Compruebe la convergencia de las siguientes series:
# MAGIC
# MAGIC $$
# MAGIC \sum^\infty_{n=1} (-1)^n \tanh n
# MAGIC $$
# MAGIC
# MAGIC
# MAGIC $$
# MAGIC \sum^\infty_{n=1} \frac{(\tan^{-1} n)^2}{n^2+1}
# MAGIC $$
# MAGIC
# MAGIC $$
# MAGIC \sum^\infty_{n=2} \frac{\log_n (n!)}{n^3}
# MAGIC $$

# COMMAND ----------

# MAGIC %md
# MAGIC ## Ejercicio:
# MAGIC Demuestre numericamente que:
# MAGIC $$
# MAGIC \sum^\infty_{n=1} \frac{n(n+1)}{x^n} = \frac{2x^2}{(1-x)^3}
# MAGIC $$

# COMMAND ----------

# MAGIC %md
# MAGIC ### Ejemplo:  Random Walk:
# MAGIC A random walk is a mathematical object, known as a stochastic or random process, that describes a path that consists of a succession of random steps on some mathematical space such as the integers. An elementary example of a random walk is the random walk on the integer number line,  $\mathbb{Z}$￼, which starts at 0 and at each step moves +1 or −1 with equal probability.

# COMMAND ----------

nsize=1000
x = np.zeros(nsize)
y = np.zeros(nsize)

for i in range(1,nsize):
    x[i] = i
    prob = np.random.rand()
    if prob<=0.5:
        y[i] = y[i-1] -1.
    else:
        y[i] = y[i-1] + 1.
        
plt.figure()
plt.plot(x,y)
plt.show()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Ejemplo: Conjunto de Mandelbrot

# COMMAND ----------

from pylab import *
from numpy import NaN
 
def m(a):
    z = 0
    for n in range(1, 100):
        z = z**2 + a
        if abs(z) > 2:
            return n
    return NaN
 
X = arange(-2, .5, .002)
Y = arange(-1,  1, .002)
Z = zeros((len(Y), len(X)))
 
for iy, y in enumerate(Y):
    for ix, x in enumerate(X):
        Z[iy,ix] = m(x + 1j * y)
figure(figsize=(8,8))
imshow(Z, cmap = plt.cm.prism, interpolation = 'none', extent = (X.min(), X.max(), Y.min(), Y.max()))
xlabel("Re(c)")
ylabel("Im(c)")
colorbar()
savefig("mandelbrot_python.svg")
show()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Write Files: Numpy

# COMMAND ----------

x = x.reshape((len(x),1))
y = y.reshape((len(y),1))


data = np.concatenate((x,y),axis=1)
print(data.shape)

np.savetxt('random-walk.tsv',data)

# COMMAND ----------

# MAGIC %md
# MAGIC ## [Libreria OS ](https://docs.python.org/3/library/os.html)
# MAGIC This module provides a portable way of using operating system dependent functionality. If you just want to read or write a file see open(), if you want to manipulate paths, see the os.path module, and if you want to read all the lines in all the files on the command line see the fileinput module. For creating temporary files and directories see the tempfile module, and for high-level file and directory handling see the shutil module.

# COMMAND ----------

## comandos del os
os.getcwd()

# COMMAND ----------


os.listdir('.')

# COMMAND ----------

os.fchdir("path")

# COMMAND ----------

os.mkdir("path")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Read Files: 

# COMMAND ----------

# Creamos un archivo de texto con dos columnas y varias lineas

file = open('datafile.txt','r')

count=0
for lines in file:
    strings = lines.split(" ")
    print(strings[0]+' '+strings[1])
    count+=1
    
print('total lines: '+str(count))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Read Files: Numpy

# COMMAND ----------

newdata = np.loadtxt('random-walk.tsv')

# COMMAND ----------

x1, x2 = np.loadtxt('random-walk.tsv', usecols=(0,1),unpack=True, delimiter=' ')


plt.figure()
plt.plot(x1,x2)
plt.show()

# COMMAND ----------

# MAGIC %md
# MAGIC # [Libreria Pandas](https://pandas.pydata.org/)
# MAGIC pandas aims to be the fundamental high-level building block for doing practical, real world data analysis in Python. Additionally, it has the broader goal of becoming the most powerful and flexible open source data analysis / manipulation tool available in any language.
# MAGIC ## READ DATAFILE WITH PANDAS

# COMMAND ----------

# CREE UN ARCHIVO DE DATOS FORMADO POR COLUMNAS DE DIFERENTES TIPOS DE VARIABLES, STRINGS, INT, FLOATS
import pandas as pd
df = pd.read_csv('datafile2.txt',header=0,sep=" ")

# COMMAND ----------

df

# COMMAND ----------

df.iloc[:,0]

# COMMAND ----------

df.describe()

# COMMAND ----------

df2 = pd.DataFrame({'lista':np.linspace(1,100,200)}) 
df2.head(3)

# COMMAND ----------

df2.dtypes

# COMMAND ----------

# MAGIC %md
# MAGIC ## [Clases](https://docs.python.org/3/tutorial/classes.html)
# MAGIC El mecanismo de clases de Python agrega clases al lenguaje con un mínimo de nuevas sintaxis y semánticas. Es una mezcla de los mecanismos de clase encontrados en C++ y Modula-3. Como es cierto para los módulos, las clases en Python no ponen una barrera absoluta entre la definición y el usuario, sino que más bien se apoya en la cortesía del usuario de no “forzar la definición”. Sin embargo, se mantiene el poder completo de las características más importantes de las clases: el mecanismo de la herencia de clases permite múltiples clases base, una clase derivada puede sobreescribir cualquier método de su(s) clase(s) base, y un método puede llamar al método de la clase base con el mismo nombre. Los objetos pueden tener una cantidad arbitraria de datos.

# COMMAND ----------

class objeto:
    """
    Notas para manual de referencia
    """
    def __init__(self, name,age,gender):
        self.name = name
        self.age = age
        self.gender = gender
    def func(self):
        print('hola mundo')


# COMMAND ----------

?objeto

# COMMAND ----------

x.name

# COMMAND ----------

x.age
