from rest_framework import serializers
from .models import Cart, Order, OrderItem
from apps.farm.models import Product
from apps.farm.serializers import ProductSerializer


class CartItemSerializer(serializers.ModelSerializer):
    product = serializers.SlugRelatedField(slug_field='name', read_only=True)

    class Meta:
        model = Cart
        fields = ['id', 'product', 'quantity', 'added_at']


class CartCreateUpdateSerializer(serializers.ModelSerializer):
    product = serializers.PrimaryKeyRelatedField(queryset=Product.objects.all())

    class Meta:
        model = Cart
        fields = ['product', 'quantity']

    def validate(self, data):
        product = data['product']
        if product.quantity < data['quantity']:
            raise serializers.ValidationError(f"Only {product.quantity} units of {product.name} are available.")
        return data

    def create(self, validated_data):
        user = self.context['request'].user
        product = validated_data['product']
        requested_quantity = validated_data['quantity']

        cart_item, created = Cart.objects.get_or_create(user=user, product=product)

        if not created:
            total_quantity = cart_item.quantity + requested_quantity
            if total_quantity > product.quantity:
                raise serializers.ValidationError(
                    f"Total quantity in the cart ({total_quantity}) exceeds available stock ({product.quantity})."
                )
            cart_item.quantity = total_quantity
        else:
            cart_item.quantity = requested_quantity

        cart_item.save()
        return cart_item


class OrderItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer()

    class Meta:
        model = OrderItem
        fields = ['product', 'quantity']


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(source='orderitem_set', many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            'id',
            'user',
            'delivery_option',
            'payment_type',
            'address',
            'status',
            'total_price',
            'items',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['user', 'total_price', 'status', 'created_at', 'updated_at']


class OrderCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['delivery_option', 'payment_type', 'address']

    def validate(self, data):
        user = self.context['request'].user
        if not Cart.objects.filter(user=user).exists():
            raise serializers.ValidationError("Your cart is empty.")
        if data['delivery_option'] == Order.DeliveryOption.DELIVERY and not data.get('address'):
            raise serializers.ValidationError("Address is required for delivery.")
        if data['payment_type'] not in dict(Order.PaymentType.choices).keys():
            raise serializers.ValidationError("Invalid payment type.")
        return data

    def create(self, validated_data):
        user = self.context['request'].user
        cart_items = Cart.objects.filter(user=user)
        total_price = sum(item.product.price * item.quantity for item in cart_items)

        order = Order.objects.create(
            user=user,
            total_price=total_price,
            delivery_option=validated_data['delivery_option'],
            payment_type=validated_data['payment_type'],
            address=validated_data.get('address'),
            status=Order.OrderStatus.PENDING,
        )

        for cart_item in cart_items:
            OrderItem.objects.create(
                order=order,
                product=cart_item.product,
                quantity=cart_item.quantity,
            )
            cart_item.product.quantity -= cart_item.quantity
            cart_item.product.save()

        cart_items.delete()
        return order
