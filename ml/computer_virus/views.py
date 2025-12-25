from django.shortcuts import render
from rest_framework.response import Response
from rest_framework import viewsets
from rest_framework.parsers import MultiPartParser, FormParser
from .models import DataPEFeature
from .serializers import RequestPEFileSerializer, DataPEFeatureSerializer

from .features import PEFeatureExtractor
import lightgbm as lgb
import numpy as np
from pathlib import Path

import json

# Create your views here.
class DataPEFeatureViewSet(viewsets.ViewSet):
    
    parser_classes = [MultiPartParser, FormParser]
    def predict(self, request):
        serializer = RequestPEFileSerializer(data=request.data)
        
        if serializer.is_valid():
            pe_file = serializer.validated_data['pe_file']
            # Here you would add your logic to process the PE file and make predictions
            # For demonstration, we will just return a dummy response
            
            extractor = PEFeatureExtractor(feature_version=2)

            bytez = pe_file.read()

            features = extractor.feature_vector(bytez)
            print("Extracted feature shape:", features.shape)
            
            BASE_DIR = Path(__file__).resolve().parent.parent  # /app
            MODEL_PATH = BASE_DIR / "computer_virus_detection_ember_lightGBM.txt"
            
            model = lgb.Booster(model_file=MODEL_PATH)
            

            prediction_prob = model.predict(np.array([features]))[0]
            features_list = [float(x) for x in features.tolist()] 
            prediction_label = 1 if prediction_prob >= 0.5 else 0  # 1=MALWARE, 0=BENIGN

            print("\n====== RESULT ======")
            print("Malware probability:", prediction_prob)
            print("Malware verdict:", "MALWARE" if prediction_label == 1 else "BENIGN")
            print("====================")
            
            d_features = {
                f'F{i+1}':v
                for i,v in enumerate(features_list)
            }
            print(len(d_features))
            
            data_instance = DataPEFeatureSerializer(data={
                'features': d_features,  # ensure JSON serializable
                'label': 1
            })
            if data_instance.is_valid():
                data_instance.save()
            else:
                print("Serializer error:", data_instance.errors)

            response_data = {
                'filename': pe_file.name,
                'prediction': "MALWARE" if prediction_label == 1 else "BENIGN",
                "Malware probability": prediction_prob,
                "feature": d_features
            }
            return Response(response_data, status=200)
        
        return Response("invalid")