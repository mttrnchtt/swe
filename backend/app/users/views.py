from django.shortcuts import render
from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser, DjangoModelPermissions
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework import status
from rest_framework import viewsets, permissions, generics
from rest_framework.authtoken.models import Token
from rest_framework.viewsets import ModelViewSet
from rest_framework.decorators import permission_classes
from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiExample
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import User
from .serializers import (
    UserSerializer,
    UserRegisterSerializer,
    UserLoginSerializer,
    GroupSerializer,
    # LogoutSerializer,
    # UserProfileSerializer
)
from django.contrib.auth.models import Group


class UserRegisterAPIView(generics.CreateAPIView):
    """
    API view for user registration
    """
    permission_classes = (AllowAny,)
    serializer_class = UserRegisterSerializer

    def post(self, request):
        serializer = UserRegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user': UserRegisterSerializer(user).data},
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = [AllowAny]  # Allow anyone to access the login endpoint


# TODO: after deploy remove and use token-based auth
class UserLoginAPIView(APIView):
    """
    API view for user login
    """
    permission_classes = [AllowAny,]
    @extend_schema(
        request=UserLoginSerializer,
        responses={201: 'Token generated successfully', 401: 'Invalid credentials'},
        examples=[
            OpenApiExample(
                "Login Example",
                value={"username": "testuser", "password": "password123"},
            ),
        ],
    )
    def post(self, request, *args, **kwargs):
        serializer = UserLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        username = serializer.validated_data['username']
        password = serializer.validated_data['password']
        user = authenticate(username=username, password=password)
        if user:
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key, 'user': UserSerializer(user).data})
        return Response({'error': 'Invalid Credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    

class LogoutAPIView(APIView):
    permission_classes = [IsAuthenticated]
    # serializer_class = LogoutSerializer

    def post(self, request):
        try:
            print("\nlogout\n")
            # Extract the refresh token from the request body
            refresh_token = request.data.get("refresh")
            token = RefreshToken(refresh_token)
            # Blacklist the token
            token.blacklist()
            return Response({"message": "Logout successful"}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": "Invalid token or token already blacklisted"}, status=status.HTTP_400_BAD_REQUEST)
    

class UserProfileAPIView(APIView):
    """
    API view for viewing and updating the user's profile
    """
    permission_classes = [IsAuthenticated]
    # serializer_class = UserProfileSerializer
    
    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

class UserViewSet(ModelViewSet):
    """
    Viewset for managing users (admin or superuser can use this)
    """
    permission_classes = [IsAuthenticated]
    queryset = User.objects.all()
    serializer_class = UserSerializer
    # permission_classes = [IsAuthenticated]


class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class GroupViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows groups to be viewed or edited.
    """

    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        """
        Customize permissions based on actions.
        - Admins can list, create, update, and delete users.
        """
        if self.action in ['list', 'retrieve', 'update', 'partial_update', 'destroy']:
            self.permission_classes = [IsAdminUser]
        elif self.action == 'create':
            self.permission_classes = [DjangoModelPermissions]
        return [permission() for permission in self.permission_classes]
