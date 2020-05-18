from django.urls import path

from . import views

urlpatterns = [
    path('', views.entry_point, name='entry_point'),
    path('cut_img/', views.cut_and_save_image, name='cut_and_save'),
    path('paste_img/', views.paste_img, name='paste_image'),
]
