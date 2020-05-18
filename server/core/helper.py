import os
import time
import json
import logging

from photoshop import PhotoshopConnection

logging.basicConfig(level=logging.INFO)

SCREEN_PIXELS_DENSITY = 1
DOC_OFFSET_X = 10 * SCREEN_PIXELS_DENSITY
DOC_OFFSET_Y = 130 * SCREEN_PIXELS_DENSITY
DOC_WIDTH = 2121
DOC_HEIGHT = 1280

def paste_image(file, name, x, y, passkey="secret"):
    start = time.time()
    file = file.replace("\\", "/")

    with PhotoshopConnection(password=passkey) as connection:
        x -= DOC_WIDTH * 0.5
        y -= DOC_HEIGHT * 0.5

        print("Coord: ", x, y)

        script = open(os.path.join(os.getcwd(), 'core', 'script', 'script.js'), 'r').read()
        script += f'pasteImage("{file}", "{name}", {x}, {y});'

        result = connection.execute(script=script, receive_output=False)

        print(result)
        logging.info(f'Pasting script execution done in {time.time() - start:.5f}s.')

        if result['status'] == 0:
            result = None

    return result

if __name__ == "__main__":
    paste_image("F:/server/media/res-9oVPCPYNTu3lIofU3QjQ.PNG", "file", 40, 40)
