---
title: Inicio
---

<section class="home-hero">
	<div class="home-panel">
		<img class="home-logo" src="{{ '/assets/images/logo-udea-horizontal.png' | relative_url }}" alt="Universidad de Antioquia">
		<span class="home-kicker">Maestria en Ciencia de Datos e Inteligencia de Negocios</span>
		<h1 class="home-title">Curso <strong>SQL + Python</strong> para ciencia de datos</h1>
		<p class="home-copy">El análisis de datos requiere combinar habilidades de programación con el dominio de herramientas para el manejo eficiente de la información. En este curso los estudiantes aprenderán los fundamentos de Python y SQL utilizando Databricks como plataforma de trabajo, adquiriendo las competencias necesarias para explorar datos, construir consultas, automatizar procesos y desarrollar soluciones analíticas que servirán de base para el resto de la Maestría en Ciencia de Datos e Inteligencia de Negocios.</p>
		<div class="home-actions">
			<a class="home-button home-button-primary" href="{{ '/python' | relative_url }}">Explorar bloque Python</a>
			<a class="home-button home-button-secondary" href="{{ '/sql' | relative_url }}">Explorar bloque SQL</a>
		</div>
		<div class="home-meta">
			<div class="home-stat">
				<strong>Python</strong>
				<span>Taller de 50%</span>
			</div>
			<div class="home-stat">
				<strong>SQL</strong>
				<span>Taller de 50%</span>
			</div>
			<div class="home-stat">
				<strong>32h</strong>
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
			<li><a class="home-link" href="{{ '/setup_guide' | relative_url }}">Guia de configuracion en Databricks</a></li>
			<li><a class="home-link" href="{{ '/github_codespaces_guide' | relative_url }}">Guia de GitHub y Codespaces</a></li>
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

<div class="home-callout">
	Si esta es la primera publicacion del sitio, activa GitHub Pages en Settings > Pages y deja como fuente GitHub Actions. El workflow ya esta configurado en el repositorio.
</div>
