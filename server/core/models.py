from django.db import models

class ImageContainer(models.Model):
    name = models.CharField(max_length=200)
    image = models.ImageField(upload_to='static/media/', null=False, blank=False)

    @property
    def image_url(self):
        if self.image:
            return self.image.url;

    def __str__(self):
        return "{}".format(self.name)