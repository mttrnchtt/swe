from django.urls import path
from .views import (
    FarmListCreateAPIView,
    ProductListCreateAPIView,
    ProductDetailAPIView,
    FarmDetailAPIView,
)


urlpatterns = [
    path('', FarmListCreateAPIView.as_view(), name='farm-list-create'),
    path('<int:pk>/', FarmDetailAPIView.as_view(), name='farm-detail'),
    path('products/', ProductListCreateAPIView.as_view(), name='product-list-create'),
    path('products/<int:pk>/', ProductDetailAPIView.as_view(), name='product-detail'),
    # path('<int:pk>/', ProductDetailAPIView.as_view(), name='product-detail'),
]