from rest_framework.routers import DefaultRouter
from .views import DataPEFeatureViewSet
from django.urls import path, include

urlpatterns = [
    path('api/predict/', DataPEFeatureViewSet.as_view({'post': 'predict'}), name='pe-file-predict')
]

