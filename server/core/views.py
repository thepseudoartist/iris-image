import io
import os
import time
import random
import logging
import string
import datetime

import requests
import numpy as np
import pyscreenshot
from PIL import Image

from . import helper
from .centroid import project
from .models import ImageContainer
from .serializers import ImageContainerSerializer

from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view

from django.http import HttpResponse, JsonResponse

logging.basicConfig(level=logging.INFO)

base_url = 'http://192.168.43.70:8000/'
host_url = 'http://192.168.43.70:9000/'

ps_passkey = 'secret'

image_path = 'media/debug.jpg'


max_ss_size = 1200
max_view_size = 700


@api_view(['GET'])
def entry_point(request):
    return Response({'message': 'Welcome to Iris backend!'}, status=status.HTTP_200_OK)


@api_view(['POST'])
def cut_and_save_image(request):
    start = time.time()
    data = ImageContainerSerializer(data=request.data)

    try:
        data.is_valid(raise_exception=True)

        image = data.validated_data['image']
        name = data.validated_data['name']

        image = Image.open(image)
        image.save(image_path)

        logging.info('>> Sending to BASNet wrapper server.')

        files = {'image': open(image_path, 'rb')}
        values = {'name': data.validated_data['name']}

        result = requests.post(url=base_url + 'mask/',
                               files=files, data=values)
        logging.info('>> Saving mask.')

        if result.status_code != 200:
            return HttpResponse({'message': 'BASNet Wrapper Server Error.'},
                                status=status.HTTP_424_FAILED_DEPENDENCY)
        else:
            logging.info('>> Opening response mask.')
            mask = Image.open(io.BytesIO(result.content)).convert("L")
            mask = mask.resize(image.size)

            logging.info(
                '>> Compositing result image by applying mask to image.')
            empty = Image.new("RGBA", image.size)
            image = Image.composite(image, empty, mask)
            image = image.resize(
                (int(image.width * 0.4), int(image.height * 0.4)))

            rand_str = ''.join(random.choices(
                string.ascii_uppercase + string.digits + string.ascii_lowercase, k=20))

            res_path = f'media/res-{rand_str}.PNG'
            image.save(res_path, 'PNG')

    except Exception as e:
        logging.error(str(e))

        errors = data.errors
        error_message = ''

        for error in errors:
            error_message += 'Error in field: ' + \
                str(error) + ': ' + str(errors[error][0])

        success = False
        message = error_message
        url = 'None'
        r_status = status.HTTP_400_BAD_REQUEST

    else:
        # data.save()
        success = True
        message = 'Object Extraction Done.'
        url = host_url + res_path
        r_status = status.HTTP_200_OK

    logging.info(f'Background removal done in {time.time() - start:.5f}s')

    return JsonResponse({
        'success': success,
        'message': message,
        'url': url,
    }, status=r_status)


@api_view(['POST'])
def paste_img(request):
    start = time.time()
    data = ImageContainerSerializer(data=request.data)

    try:
        data.is_valid(raise_exception=True)

        cut_image_name = data.validated_data['name']
        view = data.validated_data['image']

        logging.info('>> Loading Image.')
        view = Image.open(view)

        ss_path = f'media/ss.png'
        view.save(ss_path, 'PNG')

        if view.size[0] > max_view_size or view.size[1] > max_view_size:
            view.thumbnail((max_view_size, max_view_size))

        logging.info('>> Grabbing screenshot.')
        screen = pyscreenshot.grab()

        width, height = screen.size

        if screen.size[0] > max_ss_size or screen.size[1] > max_ss_size:
            screen.thumbnail((max_ss_size, max_ss_size))

        logging.info('>> Finding Projection Centroid.')

        x, y = project(np.array(view), np.rot90(np.array(screen)), False)

        if x != -1 and y != -1:
            # x = int(x / screen.size[0] * width)
            # y = int(y / screen.size[1] * height)

            logging.info('>> Sending picture to Photoshop.')

            name = datetime.date.today().strftime("%Y-%m-%d %H:%M:%S")

            error = helper.paste_image(
                os.getcwd() + '\\media\\' + cut_image_name, name, x, y, passkey=ps_passkey)

            if error is not None:
                message = 'Error sending data to Photoshop.'
                r_status = status.HTTP_424_FAILED_DEPENDENCY

                logging.error(f'{message}\n{str(error)}')

        else:
            message = 'Screen not found.'
            logging.error(f'{message}')

    except Exception as e:
        logging.error(str(e))

        r_status = status.HTTP_400_BAD_REQUEST
        message = 'Some error occurred on server side.'

    else:
        r_status = status.HTTP_200_OK
        message = 'Success'
    logging.info(
        f'Pasting operation to Photshop done in {time.time() - start:.5f}s')
    return JsonResponse({'message': message}, status=r_status)
