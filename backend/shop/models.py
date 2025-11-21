from django.db import models
from django.core.exceptions import ValidationError

# --- 1. КАТЕГОРІЇ ---
class Category(models.Model):
    title = models.CharField(max_length=100, verbose_name="Назва категорії")
    image = models.ImageField(upload_to='categories/', verbose_name="Фото категорії")
    
    def __str__(self):
        return self.title

    class Meta:
        verbose_name = "Категорія"
        verbose_name_plural = "Категорії"


# --- 2. СУКНІ ---
class Dress(models.Model):
    # ЗМІНЕНО: ManyToManyField замість ForeignKey
    # Тепер можна вибрати кілька категорій (наприклад: "Дорослі" + "Розпродаж")
    categories = models.ManyToManyField(Category, related_name='dresses', verbose_name="Категорії")
    
    title = models.CharField(max_length=200, verbose_name="Назва сукні")
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Ціна за добу (грн)")
    deposit = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name="Застава (грн)")
    description = models.TextField(blank=True, verbose_name="Опис")
    
    age_range = models.CharField(max_length=50, verbose_name="Вік (напр. 3-4 роки)")
    size_label = models.CharField(max_length=50, blank=True, verbose_name="Розмір на бірці")
    
    image_ratio = models.FloatField(default=1.0, verbose_name="Пропорція фото (для сітки)")

    cleaning_days = models.PositiveIntegerField(
        default=2, 
        verbose_name="Авто-хімчистка (днів)",
        help_text="Скільки днів автоматично додавати після оренди"
    )
    
    is_active = models.BooleanField(default=True, verbose_name="Відображати на сайті")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.age_range})"

    class Meta:
        verbose_name = "Сукня"
        verbose_name_plural = "Сукні"


# --- 3. ФОТО СУКОНЬ ---
class DressImage(models.Model):
    dress = models.ForeignKey(Dress, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='dresses/', verbose_name="Фото")
    is_main = models.BooleanField(default=False, verbose_name="Головне фото")

    class Meta:
        verbose_name = "Фото сукні"
        verbose_name_plural = "Фото суконь"


# --- 4. КАЛЕНДАР ---
class Booking(models.Model):
    STATUS_CHOICES = [
        ('new', 'Нове замовлення'),
        ('confirmed', 'Підтверджено'),
        ('active', 'В оренді'),
        ('completed', 'Завершено'),
        ('canceled', 'Скасовано'),
        ('maintenance', '🔴 ТЕХНІЧНЕ БЛОКУВАННЯ (Ремонт/Хімчистка)'),
    ]

    dress = models.ForeignKey(Dress, on_delete=models.CASCADE, related_name='bookings', verbose_name="Сукня")
    start_date = models.DateField(verbose_name="Початок")
    end_date = models.DateField(verbose_name="Кінець")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='new', verbose_name="Статус")
    client_name = models.CharField(max_length=100, blank=True, verbose_name="Ім'я клієнта")
    client_phone = models.CharField(max_length=20, blank=True, verbose_name="Телефон")
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        if self.start_date and self.end_date and self.start_date > self.end_date:
            raise ValidationError("Дата початку не може бути пізніше дати закінчення.")

    def __str__(self):
        if self.status == 'maintenance':
            return f"🔴 РЕМОНТ: {self.dress.title}"
        return f"Оренда: {self.client_name} ({self.dress.title})"

    class Meta:
        verbose_name = "Бронювання"
        verbose_name_plural = "Календар зайнятості"