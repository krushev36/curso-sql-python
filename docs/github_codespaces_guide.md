---
title: Guia de GitHub y Codespaces
---

# 🐙 Guía de Registro en GitHub y Uso de GitHub Codespaces

Esta guía explica cómo crear tu cuenta de GitHub y cómo usar GitHub Codespaces para trabajar el curso sin configuraciones locales complejas.

---

## 1️⃣ Crear una cuenta en GitHub

### Paso 1: Registro

1. Ir a: **https://github.com/signup**
2. Escribir correo electrónico, contraseña y nombre de usuario.
3. Completar la verificación solicitada por GitHub.
4. Confirmar el correo electrónico desde tu bandeja de entrada.

### Paso 2: Configuración inicial recomendada

1. Ir a **Settings** en tu perfil.
2. Agregar tu nombre completo en **Public profile**.
3. Activar verificación en dos pasos en **Password and authentication**.
4. Opcional: cargar foto de perfil para facilitar trabajo en equipo.

---

## 2️⃣ Fork y acceso al repositorio del curso

1. Abrir el repositorio del curso:
   - **https://github.com/krushev36/curso-sql-python**
2. Hacer clic en **Fork** para crear una copia en tu cuenta.
3. Entrar al fork creado (por ejemplo `tu-usuario/curso-sql-python`).

---

## 3️⃣ Crear un Codespace

1. Dentro de tu fork, haz clic en **Code**.
2. Ve a la pestaña **Codespaces**.
3. Clic en **Create codespace on main**.
4. Espera a que inicie VS Code en el navegador.

> **📝 Nota:** Codespaces usa un entorno Linux en la nube con terminal, Git y extensiones. No necesitas instalar Python, Git o VS Code en tu computador para comenzar.

---

## 4️⃣ Flujo básico de trabajo en Codespaces

1. Edita archivos del curso desde el panel de VS Code.
2. Guarda cambios con frecuencia.
3. Usa Git desde la terminal:

```bash
git status
git add .
git commit -m "Actualiza notebook o guia"
git push
```

4. Si trabajas en equipo, abre un Pull Request desde GitHub.

---

## 5️⃣ Buenas prácticas para el curso

- Crea ramas por tarea (por ejemplo `feature/notebook-03`).
- Haz commits pequeños y descriptivos.
- No subas credenciales, tokens o contraseñas.
- Apaga Codespaces cuando no lo uses para optimizar consumo.

---

## 6️⃣ Solución de problemas comunes

### No veo la opción de Codespaces

- Verifica que estés dentro de tu fork o del repositorio correcto.
- Revisa que tu cuenta GitHub tenga habilitado Codespaces.

### El entorno tarda en iniciar

- Espera unos minutos; la primera creación suele tardar más.
- Si falla, elimina el Codespace y créalo nuevamente.

### No puedo hacer push

- Confirma que estás trabajando en tu fork.
- Ejecuta `git remote -v` para validar el remoto.
- Si es necesario, autentícate de nuevo con GitHub.

---

## 🔗 Recursos útiles

- [GitHub Docs](https://docs.github.com/)
- [GitHub Codespaces Docs](https://docs.github.com/codespaces)
- [GitHub Skills](https://skills.github.com/)
