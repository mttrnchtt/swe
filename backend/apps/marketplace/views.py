from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Cart, Order
from apps.farm.models import Product
from apps.farm.serializers import ProductSerializer
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
    

class ProductListAPIView(generics.ListAPIView):
    """
    Retrieve all available products with optional filtering by name and category.
    """
    permission_classes = [IsAuthenticated,]  # Open access for all users
    serializer_class = ProductSerializer

    def get_queryset(self):
        """
        Filters available products by name, category, or other parameters.
        """
        queryset = Product.objects.all()

        # Optional Filters
        name_query = self.request.query_params.get('name', None)
        category_query = self.request.query_params.get('category', None)

        if name_query:
            queryset = queryset.filter(name__icontains=name_query)

        if category_query:
            queryset = queryset.filter(category=category_query)

        return queryset
