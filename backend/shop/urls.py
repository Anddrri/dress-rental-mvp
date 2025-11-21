from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DressViewSet, CategoryViewSet

# Створюємо "роутер", який сам зробить посилання /api/dresses/
router = DefaultRouter()
router.register(r'dresses', DressViewSet)
router.register(r'categories', CategoryViewSet)

urlpatterns = [
    path('', include(router.urls)),
]