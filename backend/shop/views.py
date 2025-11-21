from rest_framework import viewsets
from .models import Dress, Category
from .serializers import DressSerializer, CategorySerializer

# Цей клас каже: "Візьми всі активні сукні і перетвори їх в JSON"
class DressViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Dress.objects.filter(is_active=True).order_by('-created_at')
    serializer_class = DressSerializer

# Цей клас віддає список категорій
class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer