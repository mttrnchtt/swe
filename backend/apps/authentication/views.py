from django.contrib.sites.shortcuts import get_current_site
from django.urls import reverse
from django.conf import settings
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import smart_str, smart_bytes, DjangoUnicodeDecodeError
from rest_framework import generics, status, views
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated, IsAdminUser
import jwt
from .serializers import (
    RegisterSerializer,
    EmailVerificationSerializer,
    LoginSerializer,
    ResetPasswordRequestEmailSerializer,
    SetNewPasswordSerializer,
    LogoutSerializer,
    ProfileSerializer,
    ApproveFarmerSerializer,
)
from drf_spectacular.utils import extend_schema, OpenApiParameter
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
        relative_link = reverse('email-verify')
        abs_url = 'http://' + current_site + relative_link + "?token=" + str(token)
        email_body = f"""
            Dear {user.username},

            Thank you for registering on our platform!

            """
        if user.role == 'farmer':
            email_body += """
            Your farmer account approval will be considered soon. 
            Once approved, you will receive a notification email.
            """
        email_body += f"""
            Use the link below to activate your email.
            {abs_url}
        """
        data = {
            'email_subject': 'Activate your email',
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
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
            user = User.objects.get(id=payload['user_id'])
            if not user.is_active:
                user.is_active = True
                user.save()
            # TODO: Remove it for admin's regulation
            # if not user.is_verified:
            #     user.is_verified = True
            #     user.save()
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
        return Response(serializer.data, status=status.HTTP_200_OK)
    

class RequestPasswordResetEmail(generics.GenericAPIView):
    serializer_class = ResetPasswordRequestEmailSerializer
    
    def post(self, request):
        serializer = self.serializer_class(data=request.data)

        email = request.data.get('email', '')
        if User.objects.filter(email=email).exists():
            user = User.objects.get(email=email)
            uidb64 = urlsafe_base64_encode(smart_bytes(user.id))
            token = PasswordResetTokenGenerator().make_token(user)

            current_site = get_current_site(request=request).domain
            relative_link = reverse('password-reset-confirm', kwargs={'uidb64': uidb64, 'token': token})
            abs_url = 'http://' + current_site + relative_link
            email_body = 'Hi!\n' + 'Use the link below to reset your password. \n' + abs_url
            data = {
                'email_subject': 'Reset your password',
                'email_body': email_body,
                'email_to': user.email,
                'domain': current_site,
            }
            Util.send_email(data)
        return Response({'message': 'Password reset link is sent'}, status=status.HTTP_200_OK)


class PasswordTokenCheckAPI(generics.GenericAPIView):
    serializer_class = SetNewPasswordSerializer

    def get(self, request, uidb64, token):
        try:
            id=smart_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(id=id)
            if not PasswordResetTokenGenerator().check_token(user, token):
                return Response({'message': 'Token is invalid, request a new one'}, status=status.HTTP_401_UNAUTHORIZED)
            return Response({
                    'message': 'Credentials are valid',
                    'uidb64': uidb64,
                    'token': token
                },
                status=status.HTTP_200_OK
            )
        except DjangoUnicodeDecodeError:
            return Response({'message': 'Token is invalid, request a new one'}, status=status.HTTP_401_UNAUTHORIZED)
        

class SetNewPasswordAPIView(generics.GenericAPIView):
    serializer_class = SetNewPasswordSerializer

    def patch(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({'success': True, 'message': 'Password reset success'}, status=status.HTTP_200_OK)



class LogoutAPIView(generics.GenericAPIView):
    serializer_class = LogoutSerializer
    permission_classes = [IsAuthenticated,]

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        
        return Response(status=status.HTTP_204_NO_CONTENT)
    

class ProfileAPIView(generics.GenericAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticated,]

    def get(self, request):
        serializer = self.serializer_class(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def put(self, request):
        serializer = self.serializer_class(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ApproveFarmerAPIView(generics.GenericAPIView):
    serializer_class = ApproveFarmerSerializer
    permission_classes = [IsAdminUser,]

    def post(self, request):
        try:
            email = request.data.get('email', '')
            user = User.objects.get(email=email, role='farmer')
        except User.DoesNotExist:
            return Response({'error': 'Farmer not found'}, status=status.HTTP_404_NOT_FOUND)
        
        if user.is_verified:
            return Response({'message': 'Farmer is already verified'}, status=status.HTTP_400_BAD_REQUEST)
        
        user.is_verified = True
        user.save()

        email_data = {
            'email_subject': 'Account Approval Notification',
            'email_body': f"""
            Dear {user.username},
            
            Congratulations! Your farmer account has been approved by the admin. You can now access all farmer-specific features on our platform.

            Thank you for being a part of our community!
            
            Best regards,
            Arbashop Team
            """,
            'email_to': user.email,
        }

        Util.send_email(email_data)
        return Response(status=status.HTTP_204_NO_CONTENT)