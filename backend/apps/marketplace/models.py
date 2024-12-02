from django.db import models
from django.conf import settings
from apps.farm.models import Product

class Cart(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"{self.user.username}'s cart"

class Order(models.Model):
    class DeliveryOption(models.TextChoices):
        SELF_PICKUP = 'self_pickup', 'Self Pickup'
        DELIVERY = 'delivery', 'Delivery'

    class OrderStatus(models.TextChoices):
        PENDING = 'pending', 'Pending'
        CONFIRMED = 'confirmed', 'Confirmed'
        DELIVERED = 'delivered', 'Delivered'
    
    class PaymentType(models.TextChoices):
        CASH_ON_DELIVERY = 'cash_on_delivery', 'Cash on Delivery'
        CREDIT_CARD = 'credit_card', 'Credit Card'
        MOBILE_PAYMENT = 'mobile_payment', 'Mobile Payment'

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    products = models.ManyToManyField(Product, through='OrderItem')
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=OrderStatus.choices, default=OrderStatus.PENDING)
    delivery_option = models.CharField(max_length=20, choices=DeliveryOption.choices)
    payment_type = models.CharField(max_length=20, choices=PaymentType.choices, default=PaymentType.CASH_ON_DELIVERY)
    address = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()
