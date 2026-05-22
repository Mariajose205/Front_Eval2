# --- Etapa 1: Descarga e instalación de dependencias (Builder) ---
FROM python:3.10-alpine AS builder

# Definir el directorio de trabajo para compilar
WORKDIR /app

# Copiar el archivo de requerimientos
COPY requirements.txt .

# Instalar las dependencias en un directorio de usuario aislado para no ensuciar el sistema
RUN pip install --no-cache-dir --user -r requirements.txt


# --- Etapa 2: Entorno de ejecución ultra ligero (Production) ---
FROM python:3.10-alpine AS production

WORKDIR /app

# Copiar las librerías de Python instaladas desde la etapa anterior
COPY --from=builder /root/.local /root/.local

# Asegurar que los binarios de las librerías locales estén en el PATH de ejecución
ENV PATH=/root/.local/bin:$PATH

# Configurar variables de entorno por defecto para Flask
ENV PORT=5000
ENV DEBUG=False

# Copiar todo el código fuente del Frontend (app.py, templates, static)
COPY . .

# CUMPLIMIENTO IE1 (SEGURIDAD): Crear un usuario del sistema sin privilegios root
RUN adduser -D flaskuser && chown -R flaskuser:flaskuser /app

# Cambiar el contexto de ejecución al usuario seguro
USER flaskuser

# Exponer el puerto nativo de la aplicación Flask
EXPOSE 5000

# Ejecutar la aplicación web
CMD ["python", "app.py"]
