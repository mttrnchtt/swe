from rest_framework import serializers
from .models import Farm, Product


class FarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farm
        fields = [
            'id',
            'owner',
            'name',
            'location',
            'description',
        ]
        read_only_fields = ['owner']



class ProductSerializer(serializers.ModelSerializer):
    farm = serializers.SlugRelatedField(slug_field='name', queryset=Farm.objects.all())
    images = serializers.ImageField(required=False)
    
    class Meta:
        model = Product
        fields = [
            'id',
            'name',
            'category',
            'price',
            'quantity',
            'description',
            'images',
            'farm',
        ]

        def validate_category(self, value):
            allowed_categories = dict(Product.CATEGORY_CHOICES).keys()
            if value not in allowed_categories:
                raise serializers.ValidationError("Invalid Category")
            return value
        