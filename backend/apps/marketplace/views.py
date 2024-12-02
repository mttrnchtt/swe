from django.shortcuts import render
from rest_framework import generics, status
from rest_framework.response import Response

# Create your views here.
class HelloWorld(generics.GenericAPIView):
    def get(self, request):
        return Response({'message': 'Hello World!'}, status=status.HTTP_200_OK)