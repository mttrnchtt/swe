from django.shortcuts import render
from django.contrib.sites.shortcuts import get_current_site
from django.urls import reverse
from django.conf import settings
from rest_framework import generics, status, views
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
import jwt
from .serializers import (
    RegisterSerializer,
    EmailVerificationSerializer,
    LoginSerializer,
)
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample
from .models import User
from .utils import Util

class RegisterView(generics.GenericAPIView):
    serializer_class = RegisterSerializer

    def post(self, request):
        user = request.data
        serializer = self.serializer_class(data=user)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        user_data = serializer.data
        user = User.objects.get(email=user_data['email'])

        token = RefreshToken.for_user(user).access_token

        current_site = get_current_site(request).domain
        print(current_site)
        relative_link = reverse('email-verify')
        abs_url = 'http://' + current_site + relative_link + "?token=" + str(token)
        email_body = 'Hi ' + user.username + '! Use the link below to verify your email. \n' + abs_url
        data = {
            'email_subject': 'Verify your email',
            'email_body': email_body,
            'email_to': user.email,
            'domain': current_site,
        }
        Util.send_email(data)

        return Response(user_data, status=status.HTTP_201_CREATED)
    

class VerifyEmail(views.APIView):
    serializer_class = EmailVerificationSerializer

    @extend_schema(
        parameters=[
            OpenApiParameter(
                name='token',
                description='JWT token for email verification',
                required=True,
                type=str,
                location=OpenApiParameter.QUERY,
            )
        ],
        responses={
            200: {'description': 'Successfully activated'},
            400: {'description': 'Activation Expired or Invalid token'},
        },
    )
    def get(self, request):
        token = request.GET.get('token')
        print('\n', token, '\n')
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
            print('payload 1 ' + str(payload))
            user = User.objects.get(id=payload['user_id'])
            if not user.is_active:
                user.is_active = True
                user.save()
            if not user.is_verified:
                user.is_verified = True
                user.save()
            return Response({'message': 'Your account is activated'}, status=status.HTTP_200_OK)
        except jwt.ExpiredSignatureError as identifier:
            return Response({'message': 'Activation link is expired'}, status=status.HTTP_400_BAD_REQUEST)
        except jwt.exceptions.DecodeError as identifier:
            return Response({'message': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)


class LoginAPIView(generics.GenericAPIView):
    serializer_class = LoginSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        print('serializer.data is', serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK)