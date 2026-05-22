# --- Etapa 1: Descarga e instalación de dependencias (Builder) ---
FROM python:3.10-alpine AS builder

WORKDIR /app

COPY requirements.txt .

# Modificación: Instalamos las dependencias directamente en una ruta limpia (/install)
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- Etapa 2: Entorno de ejecución ultra ligero (Production) ---
FROM python:3.10-alpine AS production

WORKDIR /app

# Copiar las librerías desde la ruta limpia /install del builder
COPY --from=builder /install /usr/local

# Configurar variables de entorno por defecto para Flask
ENV PORT=5000
ENV DEBUG=False

# Copiar todo el código fuente del Frontend
COPY . .

# CUMPLIMIENTO IE1 (SEGURIDAD): Crear un usuario del sistema sin privilegios root
RUN adduser -D flaskuser && chown -R flaskuser:flaskuser /app

# Cambiar el contexto de ejecución al usuario seguro
USER flaskuser

# Exponer el puerto nativo de la aplicación Flask
EXPOSE 5000

# Ejecutar la aplicación web
CMD ["python", "app.py"]
