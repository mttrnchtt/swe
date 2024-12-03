from django.urls import path
from .views import (
    CartListCreateAPIView,
    OrderListCreateAPIView,
    ProductListAPIView,
)


urlpatterns = [
    path('cart/', CartListCreateAPIView.as_view(), name='cart'),
    path('orders/', OrderListCreateAPIView.as_view(), name='orders'),
    path('products/', ProductListAPIView.as_view(), name='products'),
]