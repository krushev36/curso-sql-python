---
title: Inicio
---

<section class="home-hero">
	<div class="home-panel">
		<img class="home-logo" src="{{ '/assets/images/logo-udea-horizontal.png' | relative_url }}" alt="Universidad de Antioquia">
		<span class="home-kicker">Maestria en Ciencia de Datos e Inteligencia de Negocios</span>
		<h1 class="home-title">Curso <strong>SQL + Python</strong> para ciencia de datos</h1>
		<p class="home-copy">Portada inspirada en la identidad visual de la Universidad de Antioquia y de la pagina oficial de la maestria. Desde aqui puedes entrar al bloque de Python, al bloque de SQL y a las guias operativas del curso en un solo recorrido publico para GitHub Pages.</p>
		<div class="home-actions">
			<a class="home-button home-button-primary" href="{{ '/python' | relative_url }}">Explorar bloque Python</a>
			<a class="home-button home-button-secondary" href="{{ '/sql' | relative_url }}">Explorar bloque SQL</a>
		</div>
		<div class="home-meta">
			<div class="home-stat">
				<strong>4</strong>
				<span>recursos del bloque Python</span>
			</div>
			<div class="home-stat">
				<strong>9</strong>
				<span>notebooks y modulos SQL</span>
			</div>
			<div class="home-stat">
				<strong>22-24h</strong>
				<span>duracion estimada del curso</span>
			</div>
		</div>
	</div>
</section>

<section class="home-grid">
	<article class="home-card">
		<h3>Ruta de aprendizaje</h3>
		<p>La estructura esta organizada para que el estudiante entre por fundamentos, pase a analisis con Python y luego recorra SQL hasta llegar a un proyecto integrador.</p>
		<ol class="home-list">
			<li><a class="home-link" href="{{ '/python' | relative_url }}">Python</a>: fundamentos, funciones, archivos, visualizacion y Pandas.</li>
			<li><a class="home-link" href="{{ '/sql' | relative_url }}">SQL</a>: introduccion, SELECT, funciones, agregaciones, JOIN, CTE y ventanas.</li>
			<li><a class="home-link" href="{{ '/syllabus' | relative_url }}">Syllabus</a>: sesiones, duracion y criterios de evaluacion.</li>
		</ol>
	</article>

	<article class="home-card">
		<h3>Accesos rapidos</h3>
		<p>Las guias de apoyo quedan visibles desde la portada para reducir friccion de uso en clase y en estudio autonomo.</p>
		<ul class="home-list">
			<li><a class="home-link" href="{{ '/datasets_guide' | relative_url }}">Guia de datasets</a></li>
			<li><a class="home-link" href="{{ '/setup_guide' | relative_url }}">Guia de configuracion en Databricks</a></li>
			<li><a class="home-link" href="https://github.com/krushev36/curso-sql-python">Repositorio fuente</a></li>
		</ul>
	</article>

	<article class="home-card">
		<h3>Bloque Python</h3>
		<p>Material inicial para lectura, simulacion, archivos, visualizacion y analisis tabular.</p>
		<ul class="home-list">
			<li><a class="home-link" href="{{ '/python/notebooks/01_python_fundamentos' | relative_url }}">docs/python/notebooks/01_python_fundamentos.md</a></li>
			<li><a class="home-link" href="{{ '/python/notebooks/02_python_funciones_librerias' | relative_url }}">docs/python/notebooks/02_python_funciones_librerias.md</a></li>
			<li><a class="home-link" href="{{ '/python/notebooks/03_python_archivos_visualizacion' | relative_url }}">docs/python/notebooks/03_python_archivos_visualizacion.md</a></li>
			<li><a class="home-link" href="{{ '/python/notebooks/04_python_pandas' | relative_url }}">docs/python/notebooks/04_python_pandas.md</a></li>
		</ul>
	</article>

	<article class="home-card">
		<h3>Bloque SQL</h3>
		<p>Recorrido progresivo desde fundamentos relacionales hasta un entregable analitico completo.</p>
		<ul class="home-list">
			<li><a class="home-link" href="{{ '/sql/notebooks/00_modulo_inicial_sql' | relative_url }}">docs/sql/notebooks/00_modulo_inicial_sql.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/01_introduccion_databricks_sql' | relative_url }}">docs/sql/notebooks/01_introduccion_databricks_sql.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/02_select_consultas_basicas' | relative_url }}">docs/sql/notebooks/02_select_consultas_basicas.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/03_join' | relative_url }}">docs/sql/notebooks/03_join.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/04_funciones_sql' | relative_url }}">docs/sql/notebooks/04_funciones_sql.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/05_agregaciones' | relative_url }}">docs/sql/notebooks/05_agregaciones.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/06_subconsultas_cte' | relative_url }}">docs/sql/notebooks/06_subconsultas_cte.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/07_window_functions' | relative_url }}">docs/sql/notebooks/07_window_functions.md</a></li>
			<li><a class="home-link" href="{{ '/sql/notebooks/08_proyecto_integrador' | relative_url }}">docs/sql/notebooks/08_proyecto_integrador.md</a></li>
		</ul>
	</article>
</section>

## Rutas Markdown de Python

- [docs/python/notebooks/01_python_fundamentos.md]({{ '/python/notebooks/01_python_fundamentos' | relative_url }})
- [docs/python/notebooks/02_python_funciones_librerias.md]({{ '/python/notebooks/02_python_funciones_librerias' | relative_url }})
- [docs/python/notebooks/03_python_archivos_visualizacion.md]({{ '/python/notebooks/03_python_archivos_visualizacion' | relative_url }})
- [docs/python/notebooks/04_python_pandas.md]({{ '/python/notebooks/04_python_pandas' | relative_url }})

## Rutas Markdown de SQL

- [docs/sql/notebooks/00_modulo_inicial_sql.md]({{ '/sql/notebooks/00_modulo_inicial_sql' | relative_url }})
- [docs/sql/notebooks/01_introduccion_databricks_sql.md]({{ '/sql/notebooks/01_introduccion_databricks_sql' | relative_url }})
- [docs/sql/notebooks/02_select_consultas_basicas.md]({{ '/sql/notebooks/02_select_consultas_basicas' | relative_url }})
- [docs/sql/notebooks/03_join.md]({{ '/sql/notebooks/03_join' | relative_url }})
- [docs/sql/notebooks/04_funciones_sql.md]({{ '/sql/notebooks/04_funciones_sql' | relative_url }})
- [docs/sql/notebooks/05_agregaciones.md]({{ '/sql/notebooks/05_agregaciones' | relative_url }})
- [docs/sql/notebooks/06_subconsultas_cte.md]({{ '/sql/notebooks/06_subconsultas_cte' | relative_url }})
- [docs/sql/notebooks/07_window_functions.md]({{ '/sql/notebooks/07_window_functions' | relative_url }})
- [docs/sql/notebooks/08_proyecto_integrador.md]({{ '/sql/notebooks/08_proyecto_integrador' | relative_url }})

<div class="home-callout">
	Si esta es la primera publicacion del sitio, activa GitHub Pages en Settings > Pages y deja como fuente GitHub Actions. El workflow ya esta configurado en el repositorio.
</div>
