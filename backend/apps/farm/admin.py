from django.contrib import admin
from .models import Farm, Product, ProductImage

class FarmAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']


class ProductAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'farm']


admin.site.register(Farm, FarmAdmin)
admin.site.register(Product, ProductAdmin)
admin.site.register(ProductImage)