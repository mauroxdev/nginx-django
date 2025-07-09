from django.contrib import admin
from django.urls import path
from django.http import HttpResponse
from . import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', views.health_check),
    path('', lambda request: HttpResponse("The install worked successfully!")),
]
