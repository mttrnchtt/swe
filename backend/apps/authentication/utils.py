from django.core.mail import EmailMessage
from django.conf import settings
from datetime import datetime, timedelta
import jwt

class Util:
    @staticmethod
    def send_email(data):
        email = EmailMessage(
            subject=data['email_subject'],
            body=data['email_body'],
            to=[
                data['email_to'],
            ],
        )
        email.send()

    @staticmethod
    def generate_email_verification_token(user):
        payload = {
            'user_id': user.id,
            'exp': datetime.now() + timedelta(hours=24),  # Token expires in 24 hours
            'iat': datetime.now(),
        }
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')
        return token
