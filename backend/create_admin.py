# backend/create_admin.py (Скрипт з тимчасовим хардкодом)

import os
import django

# --- ВАЖЛИВО: ЗМІНІТЬ ЦІ ЗНАЧЕННЯ НА ВЛАСНІ ТА ЗАПАМ'ЯТАЙТЕ ЇХ! ---
USERNAME = 'mvpadmin' 
EMAIL = 'andrri964@gmail.com'
PASSWORD = '1964' 
# ------------------------------------------------------------------

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth.models import User
from django.db import IntegrityError

try:
    if not User.objects.filter(username=USERNAME).exists():
        print("--- Створення суперкористувача через тимчасовий скрипт ---")
        User.objects.create_superuser(USERNAME, EMAIL, PASSWORD)
        print(f"--- Суперкористувач {USERNAME} успішно створений. ---")
    else:
        print(f"--- Суперкористувач {USERNAME} вже існує. Створення пропущено. ---")
except IntegrityError:
    # Запобігання помилкам, якщо проект вже мав користувача
    print("--- Помилка цілісності: Користувач існує, або проблема з міграцією. ---")
except Exception as e:
    print(f"--- Критична помилка створення адміна: {e} ---")