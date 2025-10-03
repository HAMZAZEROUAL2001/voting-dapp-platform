# Utiliser une image Python officielle
FROM python:3.9-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY backend/requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste du code backend
COPY backend/ .

# Exposer le port de l'application
EXPOSE 5000

# Commande pour lancer l'application
CMD ["python", "app.py"]
