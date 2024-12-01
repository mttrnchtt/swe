from django.shortcuts import render
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .permissions import IsFarmer
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Farm, Product
from .serializers import FarmSerializer, ProductSerializer


class FarmListCreateAPIView(generics.GenericAPIView):
    """
    get:
    List all farms owned by the authenticated farmer.

    post:
    Create a new farm for the authenticated farmer.
    """
    serializer_class = FarmSerializer
    permission_classes = [IsAuthenticated, IsFarmer]

    def get_queryset(self):
        if self.request.user.role == 'farmer':
            return Farm.objects.filter(owner=self.request.user)
        raise PermissionDenied("You don't have permission to view this content")
    
    def perform_create(self, serializer):
        if self.request.user.role != 'farmer':
            raise PermissionDenied("You don't have permission to view this content")
        serializer.save(owner=self.request.user)

    def get(self, request):
        queryset = self.get_queryset()
        serializer = self.serializer_class(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer=serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    

class FarmDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    """
    get:
    Retrieve details of a product owned by the farmer.

    put:
    Update a product owned by the farmer.

    delete:
    Delete a product owned by the farmer.
    """
    serializer_class = FarmSerializer
    permission_classes = [IsAuthenticated, IsFarmer]

    def get_queryset(self):
        return Farm.objects.filter(owner=self.request.user)
    

class ProductListCreateAPIView(generics.ListCreateAPIView):
    """
    get:
    List all products for the authenticated farmer's farms.

    post:
    Create a new product for a specific farm owned by the farmer.
    """
    serializer_class = ProductSerializer
    permission_classes = [IsAuthenticated, IsFarmer,]
    parser_classes = [MultiPartParser, FormParser,]

    def get_queryset(self):
        return Product.objects.filter(farm__owner=self.request.user)
    
    def perform_create(self, serializer):
        farm = serializer.validated_data.get('farm')
        if farm.owner != self.request.user:
            raise PermissionDenied("You don't own this farm")
        serializer.save()


class ProductDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    """
    get:
    Retrieve details of a product owned by the farmer.

    put:
    Update a product owned by the farmer.

    delete:
    Delete a product owned by the farmer.
    """
    serializer_class = ProductSerializer
    permission_classes = [IsAuthenticated, IsFarmer]

    def get_queryset(self):
        return Product.objects.filter(farm__owner=self.request.user)
