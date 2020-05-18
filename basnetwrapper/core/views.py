import io
import os
import time
import base64
import logging

import numpy as np
from PIL import Image

from . import basnet

from .models import ImageContainer
from .serializers import ImageContainerSerializer

from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.http import HttpResponse, JsonResponse

logging.basicConfig(level=logging.INFO)


@api_view(['GET'])
def entry_point(request):
    return Response({'message': 'Welcome to Iris!'}, status=status.HTTP_200_OK)


@api_view(['POST'])
def get_image_mask(request):
    start = time.time()
    data = ImageContainerSerializer(data=request.data)

    try:
        data.is_valid(raise_exception=True)
        image = data.validated_data['image']
        image = Image.open(image)
        
        if image.size[0] > 1024 or image.size[1] > 1024:
            image.thumbnail((1024, 1024))

        image = basnet.run(np.array(image))
        
        buffer = io.BytesIO()
        image.save(buffer, 'PNG')
        buffer.seek(0)

    except Exception as e:
        errors = data.errors
        error_message = ''

        for error in errors:
            error_message += 'Error in field: ' + \
                str(error) + ': ' + str(errors[error][0])
        
        message = error_message
        r_status = status.HTTP_400_BAD_REQUEST
    
    else:
        #data.save()
        
        message = 'Processing of Image successful'
        r_status = status.HTTP_200_OK

    logging.info(f'Task completed in time {time.time() - start:.5f}')

    return HttpResponse(buffer, content_type='image/png')