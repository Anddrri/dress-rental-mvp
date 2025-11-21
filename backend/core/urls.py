from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.generic import RedirectView  # <--- 1. Додали імпорт

urlpatterns = [
    # 2. Додаємо переадресацію з головної ('') на '/api/'
    path('', RedirectView.as_view(url='/api/', permanent=False)),
    
    path('admin/', admin.site.urls),
    path('api/', include('shop.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)