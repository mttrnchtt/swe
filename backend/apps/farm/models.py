from django.db import models
from django.conf import settings

# Create your models here.
class Farm(models.Model):
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="farm")
    name = models.CharField(max_length=255, unique=True, db_index=True)
    location = models.TextField()
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name
    

class Product(models.Model):
    CATEGORY_CHOICES = [
        ('fruits', 'Fruits'),
        ('vegetables', 'Vegetables'),
        ('dairy', 'Dairy'),
        ('meat', 'Meat'),
        ('grains', 'Grains'),
        ('others', 'Others'),
    ]

    name = models.CharField(max_length=255)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField()
    description = models.TextField(blank=True, null=True)
    images = models.ImageField(upload_to='product_images/', blank=True, null=True)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name="products")

    def __str__(self):
        return self.name