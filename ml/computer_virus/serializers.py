from rest_framework import serializers
from .models import DataPEFeature

class DataPEFeatureSerializer(serializers.ModelSerializer):
    class Meta:
        model = DataPEFeature
        fields = ['id', 'features', 'label', 'created_at']
    
    def create(self, validated_data):
        features = validated_data.pop('features', None)
        instance = DataPEFeature(**validated_data)
        instance.set_features(features)
        instance.save()
        return instance
    
    def to_presentation(self, instance):
        ret = super().to_presentation(instance)
        ret['features'] = instance.get_features()
        return ret
    
class RequestPEFileSerializer(serializers.Serializer):
    pe_file = serializers.FileField(required=True)
    class Meta:
        fields = ['pe_file']