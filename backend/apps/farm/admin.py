from django.contrib import admin
from .models import Farm, Product, ProductImage


admin.site.register(Farm)
admin.site.register(Product)
admin.site.register(ProductImage)