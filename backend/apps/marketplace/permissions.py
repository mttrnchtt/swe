from rest_framework.permissions import BasePermission

class IsBuyer(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and hasattr(request.user, 'role') and request.user.role == 'buyer'
