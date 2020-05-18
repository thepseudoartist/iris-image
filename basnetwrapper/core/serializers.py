from rest_framework import serializers
from .models import ImageContainer

class ImageContainerSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImageContainer
        fields = '__all__'
