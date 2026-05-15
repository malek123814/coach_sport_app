# Coach Sport App

Application mobile de coaching sportif développée avec :

- Flutter (Frontend)
- Django REST Framework (Backend)
- MySQL (Base de données)

---

# Structure du projet

```bash
coach_sport_app/
│
├── backend/      # Backend Django
├── frontend/     # Application Flutter
├── database.sql  # Export MySQL
└── README.md
```

---

# Installation Backend Django

## 1. Aller dans le backend

```bash
cd backend
```

## 2. Créer un environnement virtuel

```bash
python -m venv venv
```

## 3. Activer l'environnement virtuel

Linux :

```bash
source venv/bin/activate
```

Windows :

```bash
venv\Scripts\activate
```

## 4. Installer les dépendances

```bash
pip install -r requirements.txt
```

## 5. Faire les migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

## 6. Lancer le serveur Django

```bash
python manage.py runserver
```

Backend :

```text
http://127.0.0.1:8000/
```

---

# Installation Frontend Flutter

## 1. Aller dans le frontend

```bash
cd frontend
```

## 2. Installer les packages Flutter

```bash
flutter pub get
```

## 3. Lancer l'application

```bash
flutter run
```

---

# Base de données MySQL

## Créer la base de données

```sql
CREATE DATABASE coach_sport_db;
```

## Importer la base

```bash
mysql -u root -p coach_sport_db < database.sql
```

---

# Fonctionnalités

- Authentification Coach / Client
- Création de plans sportifs
- Upload d'images
- Gestion des profils coach
- Filtrage des catégories
- Communication client / coach
- API REST Django

---

# Technologies utilisées

## Backend
- Django
- Django REST Framework
- MySQL

## Frontend
- Flutter
- Dart

---

# Auteur

Malek Bejaoui
