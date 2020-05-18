import os
import glob

def clear_cache():
    files = glob.glob('media/*')

    for f in files:
        os.remove(f)


if __name__ == "__main__":
    clear_cache()