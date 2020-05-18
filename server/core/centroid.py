import logging

import cv2 as cv
import numpy as np

MIN_MATCHES_COUNT = 10

def project(view, screen, debug=False, PIL=True):
    
    if PIL:
        # * In case of PIL Images do color conversion
        view = cv.cvtColor(view, cv.COLOR_RGB2BGR)
        screen = cv.cvtColor(screen, cv.COLOR_RGB2BGR)

    # * Create ORB and Brute Force matcher object using Hamming distance
    orb = cv.ORB_create()

    view = np.rot90(view, 3)
    screen = np.rot90(screen, 3)

    # * Find key point and descriptors with ORB
    kp_view, dest_view = orb.detectAndCompute(view, None)
    kp_screen, dest_screen = orb.detectAndCompute(screen, None)

    # * Matching keypoints and sorting them using distance
    bf_matcher = cv.BFMatcher_create(normType=cv.NORM_HAMMING, crossCheck=True)

    matches = bf_matcher.match(dest_view, dest_screen)
    matches = sorted(matches, key=lambda x: x.distance)

    if len(matches) < MIN_MATCHES_COUNT:
        logging.debug('Not enough point matches.')
        return -1, -1


    # * Extract matched keypoints
    view_points = np.float32(
        [kp_view[m.queryIdx].pt for m in matches]).reshape(-1, 1, 2)

    screen_points = np.float32(
        [kp_screen[m.trainIdx].pt for m in matches]).reshape(-1, 1, 2)

    # * Finding homography matrix and find perspective transform
    height, width = view.shape[:2]
    M, mask = cv.findHomography(view_points, screen_points, cv.RANSAC, 5.0)

    points = np.float32(
        [[(width - 1) * 0.5, (height - 1) * 0.5]]).reshape(-1, 1, 2)

    dest = cv.perspectiveTransform(points, M)

    x, y = np.int32(dest[0][0])

    print("CAL POINTS:", x, y)

    if debug:
        debug_image = _get_debug_image(
            x, y, view, screen, mask, M, kp_view, kp_screen, matches)

        return x, y, debug_image

    else:
        return x, y


def _get_debug_image(x, y, view, screen, mask, M, kp_view, kp_screen, matches):
    matches_mask = mask.ravel().tolist()

    drawing_params = {
        "matchColor": (0, 255, 0),
        "singlePointColor": None,
        "matchesMask": matches_mask,
        "flags": 2
    }

    # * Draw found regions and match lines 
    debug_image = cv.drawMatches(
        screen, kp_screen, view, kp_view, matches, None, **drawing_params)

    cy = int(view.shape[0] * 0.5)
    cx = int(view.shape[1] * 0.5 + screen.shape[1])

    cv.rectangle(debug_image, (screen.shape[1], 0),
                 (debug_image.shape[1] - 2, debug_image.shape[0] - 2), (0, 255, 255), 2)

    cv.polylines(debug_image, [np.int32([(x, y), (cx, cy)])],
                 True, (100, 100, 255), 1, cv.LINE_AA)

    cv.circle(debug_image, (x, y), 10, (0, 0, 255), -1)
    cv.drawMarker(debug_image, (cx, cy), (0, 0, 255), cv.MARKER_STAR, 30, 2)

    return debug_image


if __name__ == "__main__":
    view = cv.imread('../static/sample/view.jpg')
    screen = cv.imread('../static/sample/screen.png')

    print(view)

    x, y, debug_image = project(view, screen, debug=True, PIL=False)
    cv.imwrite('../static/media/debug-test-centroid.jpg', debug_image)
