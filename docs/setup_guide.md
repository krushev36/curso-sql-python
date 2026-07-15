# ⚙️ Guía de Configuración — Databricks Free Edition

Esta guía te lleva paso a paso desde cero hasta tener tu entorno listo para ejecutar los notebooks del curso.

---

## 1️⃣ Crear Cuenta en Databricks Community Edition

### Paso 1: Registrarse

1. Ir a: **https://community.cloud.databricks.com**
2. Hacer clic en **"Try Databricks"** o **"Get started for free"**
3. Completar el formulario:
   - Nombre y apellido
   - Correo electrónico (recomendado: correo universitario)
   - Empresa/Universidad
   - País
4. Seleccionar **"Community Edition"** (la opción gratuita)
5. Verificar el correo electrónico

> **📝 Nota:** Community Edition es completamente gratuita y no requiere tarjeta de crédito.

---

## 2️⃣ Navegar por el Workspace

Al ingresar por primera vez verás el menú lateral izquierdo:

```
┌─────────────────────┐
│  🏠 Home            │
│  📁 Workspace       │  ← Notebooks y archivos
│  📊 Data            │  ← Explorador de datos
│  💻 Compute         │  ← Clusters
│  🔄 Workflows       │  
│  🛒 Marketplace     │
└─────────────────────┘
```

---

## 3️⃣ Crear un Cluster

Un cluster es el motor de cómputo que ejecuta tus consultas SQL.

### Pasos:

1. Ir a **Compute** en el menú lateral
2. Hacer clic en **"Create compute"**
3. Configuración recomendada:
   - **Name:** `cluster-curso-sql`
   - **Cluster Mode:** Single Node
   - **Databricks Runtime:** 13.x LTS (o la versión más reciente LTS)
   - **Node Type:** dejar por defecto
4. Hacer clic en **"Create compute"**
5. Esperar ~5 minutos hasta que el estado sea **🟢 Running**

> **⚠️ Advertencia:** En Community Edition, el cluster se detiene automáticamente después de 2 horas de inactividad. Simplemente reinícialo cuando lo necesites.

---

## 4️⃣ Importar un Notebook

### Método A: Importar desde archivo

1. Ir a **Workspace** en el menú lateral
2. Navegar a tu carpeta personal o crear una nueva:
   - Clic en **⊕ Add** → **Folder** → Nombrar `curso-sql`
3. Dentro de la carpeta, hacer clic en **⊕ Add** → **Import**
4. Seleccionar **"File"**
5. Subir el archivo `.sql` del notebook (ej: `01_introduccion_databricks_sql.sql`)
6. Hacer clic en **"Import"**

### Método B: Importar desde URL (GitHub)

1. En el diálogo de Import, seleccionar **"URL"**
2. Pegar la URL raw del archivo en GitHub
3. Hacer clic en **"Import"**

---

## 5️⃣ Ejecutar un Notebook

### Conectar el Notebook al Cluster

1. Abrir el notebook importado
2. En la parte superior derecha, hacer clic en el selector de cluster
3. Seleccionar `cluster-curso-sql`
4. Esperar a que aparezca el ícono verde de conexión

### Ejecutar Celdas

| Acción | Atajo de Teclado |
|--------|-----------------|
| Ejecutar celda actual | `Shift + Enter` |
| Ejecutar celda y quedarse en ella | `Ctrl + Enter` |
| Ejecutar todo el notebook | Menú **Run** → **Run All** |
| Detener ejecución | Botón **Interrupt** |

### Tipos de Celdas

- **Celda SQL:** contiene código SQL que se ejecuta directamente
- **Celda Markdown:** contiene texto formateado (no se ejecuta)

> **📝 Nota:** En los notebooks de este curso, las celdas SQL no llevan el magic `%sql` porque el notebook está configurado como tipo SQL. Las celdas Markdown sí llevan `%md`.

---

## 6️⃣ Explorar los Datasets de Ejemplo

Una vez conectado el cluster, ejecuta estas consultas para confirmar acceso a los datos:

```sql
-- Verificar catálogos disponibles
SHOW CATALOGS;
```

Deberías ver `samples` en la lista.

```sql
-- Ver schemas en el catálogo samples
SHOW SCHEMAS IN samples;
```

Deberías ver: `tpch`, `nyctaxi`, `bakehouse`, entre otros.

```sql
-- Ver tablas del schema tpch
SHOW TABLES IN samples.tpch;
```

Deberías ver: `customer`, `lineitem`, `nation`, `orders`, `part`, `region`, `supplier`.

```sql
-- Probar una consulta básica
SELECT * FROM samples.tpch.customer LIMIT 5;
```

Si ves datos, ¡tu entorno está listo! ✅

---

## 7️⃣ Solución de Problemas Comunes

### Error: "Cluster not found" o "No cluster attached"
**Solución:** Conectar el notebook a un cluster activo (ver Paso 5).

### Error: "Table not found: samples.tpch.customer"
**Solución:** 
1. Verificar que el cluster esté en estado **Running**
2. Ejecutar: `SHOW CATALOGS;` para verificar que `samples` está disponible
3. Si no aparece, reiniciar el cluster

### Error: "Cluster terminated"
**Solución:** El cluster se detuvo por inactividad. Ir a **Compute**, hacer clic en el cluster y luego en **Start**.

### El notebook está lento
**Causas comunes:**
- El cluster está iniciando (esperar ~3 minutos)
- La consulta está procesando millones de filas (normal en `lineitem`)
- Agregar `LIMIT 1000` para pruebas rápidas

---

## 8️⃣ Atajos y Consejos de Productividad

### Atajos del Editor SQL

| Acción | Atajo |
|--------|-------|
| Autocompletar | `Ctrl + Space` |
| Comentar línea | `Ctrl + /` |
| Formatear SQL | `Ctrl + Shift + F` |
| Buscar en notebook | `Ctrl + F` |

### Buenas Prácticas

```sql
-- ✅ BUENO: Siempre limitar resultados durante el desarrollo
SELECT * FROM samples.tpch.lineitem LIMIT 100;

-- ✅ BUENO: Usar alias descriptivos
SELECT
  c.c_name        AS nombre_cliente,
  o.o_totalprice  AS precio_total
FROM samples.tpch.customer c
JOIN samples.tpch.orders o ON c.c_custkey = o.o_custkey
LIMIT 10;

-- ⚠️ CUIDADO: Esta consulta puede demorar en una tabla de 6M filas
SELECT * FROM samples.tpch.lineitem;  -- Sin LIMIT
```

---

## 9️⃣ Estructura del Catálogo Samples

```
samples (catálogo)
│
├── tpch (schema)
│   ├── customer      (150,000 filas)
│   ├── orders      (1,500,000 filas)
│   ├── lineitem    (6,000,000 filas)
│   ├── part          (200,000 filas)
│   ├── supplier       (10,000 filas)
│   ├── nation             (25 filas)
│   └── region              (5 filas)
│
├── nyctaxi (schema)
│   └── trips         (millones de filas)
│
└── bakehouse (schema)
    └── ...
```

---

## 🔗 Recursos Adicionales

- [Documentación oficial Databricks](https://docs.databricks.com/)
- [Databricks SQL Language Reference](https://docs.databricks.com/sql/language-manual/)
- [Databricks Community Forum](https://community.databricks.com/)
- [Databricks Academy (cursos oficiales)](https://www.databricks.com/learn/training)

---

*Guía válida para Databricks Community Edition — 2024*
