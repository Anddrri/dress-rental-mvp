from rest_framework import serializers
from .models import Dress, DressImage, Category

# 1. Серіалізатор для фото (щоб отримати просто посилання на картинку)
class DressImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = DressImage
        fields = ['id', 'image', 'is_main']

# 2. Серіалізатор для категорій
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'title', 'image']

# 3. Головний серіалізатор для Сукні
class DressSerializer(serializers.ModelSerializer):
    # Вкладаємо сюди список фото
    images = DressImageSerializer(many=True, read_only=True)
    # Вкладаємо сюди список категорій (повну інфу, а не просто ID)
    categories = CategorySerializer(many=True, read_only=True)

    class Meta:
        model = Dress
        fields = [
            'id', 
            'title', 
            'price', 
            'deposit', 
            'description', 
            'age_range', 
            'size_label', 
            'image_ratio', 
            'categories', 
            'images'
        ]