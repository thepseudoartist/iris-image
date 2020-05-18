# Iris

Iris is a AI based tool to extract elements from environment using Flutter [app](/app) to a editing software like Adobe Photoshop.

## Cloning Repository

This repository depends on submodules.

  ```bash
  git clone --recursive [GIT REPO LINK]
  ```

## Components

- **Flutter Application**

  - Setup

    Change BASE_URL in `app/lib/core/server.dart` to the IP in which server is running i.e. `host_url` (mentioned below) else you can run the app directly and change the IP from the `Options` menu

    ```dart
    const String BASE_URL = 'http://192.168.43.70:8080/';
    ```

  - Running Application

    ```bash
    flutter run
    ```

- **Photoshop Configuration**

  - Go to "Edit > Preferences > Plug-Ins" and enable Photoshop Connection and set a password.
  - Make sure that you Photoshop Connection password is same as in `server/core/views.py`

    ```python
    ps_passkey = 'secret'
    ```

  - Make sure that your canvas has some objects or background as it will help ORB to find correct location to paste the cut image.

- **Server**
  It acts a bridge between Adobe Photoshop and Flutter Application. It finds where the camera is pointing at and paste the image there with help of Adobe Photoshop scripts. Core technique used to find the centroid is [ORB](https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_feature2d/py_orb/py_orb.html) detector and Brute Force Matcher.

  - Install the requirements

    ```bash
    pip install -r requirements.txt
    ```

  - Go to `server/core/views.py` and change `host_url` and `base_url`, `host_url` is IP where server is going to run and `base_url` is IP where BASNet service is running. Make sure they are running on separate ports if both BASNet service and server is running on same machine.

    ```python
    base_url = 'http://192.168.43.70:8000/'
    host_url = 'http://192.168.43.70:9000/'
    ```

  - Run server

    ```bash
    python manage.py runserver [host_url]
    ```

- **BASNet Wrapper Server**
  It is recommended to use CUDA enabled Nvidia GPU to run this module else the response time will be much slow.

  - BASNet (Boundary Aware Salient Object Detection) generates a mask which is later used to extract objects from the Image. [Official Implementation](https://github.com/NathanUA/BASNet)

  - Download pre-trained [model](https://drive.google.com/open?id=1s52ek_4YTDRt_EOkx1FS53u-vJa0c4nu) and save it to `basenetwrapper/BASNet/trained_models/`
  - Install the requirements for the module and run server.

    ```bash
    pip install -r requirements.txt
    python manage.py runserver [base_url]
    ```

## Bugs and To-Dos

- Calculated centroid needs to be offset correctly to paste image in a particular point.
- Make Flutter App independent of `BASNet wrapper server` by using mobile Machine Learning.
- Convert `server` into some desktop application to make it easily usable.
- Paste images to Photoshop from `history` page in app.
- Use state management like BLoC for Flutter Application.
