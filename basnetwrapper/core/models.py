from django.db import models

class ImageContainer(models.Model):
    name = models.CharField(max_length=200)
    image = models.ImageField(upload_to='images/', null=False, blank=False)

    def __str__(self):
        return "{}".format(self.name)