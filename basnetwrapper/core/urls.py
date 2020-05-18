from django.urls import path

from . import views

urlpatterns = [
    path('', views.entry_point, name='entry_point'),
    path('mask/', views.get_image_mask, name='mask_image')
]
