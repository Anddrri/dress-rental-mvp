from django.contrib import admin
from .models import Category, Dress, DressImage, Booking

class DressImageInline(admin.TabularInline):
    model = DressImage
    extra = 3

@admin.register(Dress)
class DressAdmin(admin.ModelAdmin):
    inlines = [DressImageInline]
    # Оновлений список полів
    list_display = ('title', 'get_categories', 'price', 'is_active', 'cleaning_days')
    # Фільтр тепер працює по полю 'categories'
    list_filter = ('categories', 'age_range')
    search_fields = ('title',)

    # Функція для красивого відображення списку категорій
    def get_categories(self, obj):
        return ", ".join([c.title for c in obj.categories.all()])
    get_categories.short_description = 'Категорії'

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('title',)

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('status', 'dress', 'start_date', 'end_date', 'client_name')
    list_filter = ('status', 'start_date')
    search_fields = ('dress__title', 'client_name')