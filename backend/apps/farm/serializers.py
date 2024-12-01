from rest_framework import serializers
from .models import Farm, Product,ProductImage


class FarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farm
        fields = [
            'id',
            'owner',
            'name',
            'location',
            'description',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['owner']



class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']


class ProductSerializer(serializers.ModelSerializer):
    print('serializer accessed')
    farm = serializers.SlugRelatedField(slug_field='name', queryset=Farm.objects.all())
    images = ProductImageSerializer(many=True, required=False)

    class Meta:
        model = Product
        fields = [
            'id',
            'name',
            'category',
            'price',
            'quantity',
            'description',
            'farm',
            'images',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['created_at', 'updated_at']

    def create(self, validated_data):
        print(self.context['request'].FILES)
        images_data = self.context['request'].FILES.getlist('images')
        print('images_data:', images_data)
        product = Product.objects.create(**validated_data)
        for image in images_data:
            print(image)
            ProductImage.objects.create(product=product, image=image)
        return product
    
    def update(self, instance, validated_data):
        images_data = self.context['request'].FILES.getlist('images', None)
        instance.name = validated_data.get('name', instance.name)
        instance.category = validated_data.get('category', instance.category)
        instance.price = validated_data.get('price', instance.price)
        instance.quantity = validated_data.get('quantity', instance.quantity)
        instance.description = validated_data.get('description', instance.description)
        instance.farm = validated_data.get('farm', instance.farm)
        instance.save()

        if images_data is not None:
            instance.images.all().delete()  # Remove old images
            for image in images_data:
                ProductImage.objects.create(product=instance, image=image)

        return instance

    def validate_category(self, value):
        allowed_categories = dict(Product.CATEGORY_CHOICES).keys()
        if value not in allowed_categories:
            raise serializers.ValidationError("Invalid Category")
        return value
        