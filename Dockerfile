# Base Image for Raspberry Pi 5 (aarch64)
FROM balenalib/raspberrypi5-python:3.11-build

# Set the working directory
WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    curl \
    i2c-tools \
    # python3-smbus \ # REMOVED
    python3-libgpiod \
    libjpeg-dev \
    zlib1g-dev \
    libtiff-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    tcl8.6-dev \
    tk8.6-dev \
    python3-tk \
    && rm -rf /var/lib/apt/lists/*

# Copy Python scripts
# These paths assume the Docker build context is the root of the project
# where etc_argon and etc_configs directories reside.
COPY argon_v5_pi_info/etc_argon/argononed.py /usr/src/app/
COPY argon_v5_pi_info/etc_argon/argoneonoled.py /usr/src/app/
COPY argon_v5_pi_info/etc_argon/argonpowerbutton.py /usr/src/app/
COPY argon_v5_pi_info/etc_argon/argonregister.py /usr/src/app/
COPY argon_v5_pi_info/etc_argon/argonsysinfo.py /usr/src/app/

# Copy OLED assets
COPY argon_v5_pi_info/etc_argon/oled/ /usr/src/app/oled/

# Copy configuration files
COPY argon_v5_pi_info/etc_configs/argononed.conf /usr/src/app/
COPY argon_v5_pi_info/etc_configs/argoneonoled.conf /usr/src/app/
COPY argon_v5_pi_info/etc_configs/argonunits.conf /usr/src/app/

# Install Python pip dependencies
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3 - \
    && python3 -m pip install --no-cache-dir "setuptools==57.5.0"
RUN SETUPTOOLS_USE_DISTUTILS=stdlib python3 -m pip install --no-cache-dir \
    luma.oled \
    Pillow \
    requests \
    smbus2 \
    gpiod
RUN python3 -c "import luma.core; import luma.oled; print('Successfully imported luma.core and luma.oled')"

# Define the command to run the application
CMD ["python3", "argononed.py", "SERVICE", "OLEDSWITCH"]