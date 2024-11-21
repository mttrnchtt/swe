from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    # UserRegisterAPIView,
    UserRegisterAPIView,
    LogoutAPIView,
    # UserProfileAPIView,
    UserViewSet,
)
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from rest_framework_simplejwt.views import TokenBlacklistView

from rest_framework.permissions import AllowAny
from rest_framework.decorators import api_view, permission_classes
from django.views.decorators.csrf import csrf_exempt

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
    path('register/', UserRegisterAPIView.as_view(), name='user-register'),
    # path('login/', TokenObtainPairView.as_view(), name='token-obtain-pair'),
    # path('refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('logout/', TokenBlacklistView.as_view(), name='logout'),
    # path('profile/', UserProfileAPIView.as_view(), name='user-profile'),
]