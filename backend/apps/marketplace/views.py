from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Cart, Order
from .serializers import (
    CartItemSerializer,
    CartCreateUpdateSerializer,
    OrderSerializer,
    OrderCreateSerializer,
)
from .permissions import IsBuyer


class CartListCreateAPIView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated, IsBuyer]
    queryset = Cart.objects.all()

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return CartCreateUpdateSerializer
        return CartItemSerializer

    def get_queryset(self):
        return Cart.objects.filter(user=self.request.user)


class OrderListCreateAPIView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated, IsBuyer]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return OrderCreateSerializer
        return OrderSerializer

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user)
