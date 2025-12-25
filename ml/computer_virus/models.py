from django.db import models
import json

# Create your models here.
class DataPEFeature(models.Model):
    features = models.JSONField()
    label = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    def set_features(self, features):
        self.features = features
        print("FEATURES BEING SAVED:", repr(features))
        
        
    def get_features(self):
        return json.loads(self.features)
    
    class Meta:
        db_table = '"DATA_PE_FEATURE"'
        
class UserModel(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    date_joined = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = '"USERS"'