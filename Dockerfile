FROM ubuntu:16.04

ENV GRPC_RELEASE_TAG v1.8.x
ENV OPENCV_RELEASE_TAG 3.4.0
ENV OPENCV_BUILD_TYPE DEBUG

# OpenCV
RUN \
    # Install dependencies
    apt-get update && \
    apt-get install -y \
        wget \
        unzip \
        libtbb2 \
        libtbb-dev \
        build-essential \ 
        cmake \
        git \
        pkg-config \
        libjpeg8-dev \
        libtiff5-dev \
        libjasper-dev \
        libpng12-dev \
        libgtk2.0-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libv4l-dev \
        libatlas-base-dev \
        gfortran \
        libhdf5-dev \
        python3-pip && \
    # Download OpenCV
    cd ~ && \
    wget -q https://github.com/Itseez/opencv/archive/${OPENCV_RELEASE_TAG}.zip -O opencv.zip && \
    unzip -q opencv.zip && \
    mv ~/opencv-${OPENCV_RELEASE_TAG}/ ~/opencv/ && \
    rm -rf ~/opencv.zip && \
    # Download OpenCV Contrib
    cd ~ && \
    wget -q https://github.com/opencv/opencv_contrib/archive/${OPENCV_RELEASE_TAG}.zip -O opencv_contrib.zip && \
    unzip -q opencv_contrib.zip && \
    mv ~/opencv_contrib-${OPENCV_RELEASE_TAG} ~/opencv_contrib/ && \
    rm -rf ~/opencv_contrib.zip && \
    # Install python dependency
    pip3 install --upgrade pip && \
    pip3 install numpy && \
    # Compile OpenCV
    cd ~/opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=${OPENCV_BUILD_TYPE} \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D INSTALL_C_EXAMPLES=OFF \
          -D INSTALL_PYTHON_EXAMPLES=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_OPENCV_WORLD=ON \
          .. && \
    cd ~/opencv/build && \
    make -j $(nproc) && \
    make install && \
    ldconfig && \
    # Clean up
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf ~/opencv/ && \
    rm -rf ~/opencv_contrib/

# gRPC
RUN \
    # Install dependencies
    apt-get update && \
    apt-get install -y \
        build-essential \
        autoconf \
        libtool \
        git \
        pkg-config \
        curl \
        automake \
        libtool \
        curl \
        make \
        g++ \
        unzip && \
    # Download gRPC
    git clone -b ${GRPC_RELEASE_TAG} https://github.com/grpc/grpc ~/grpc && \
    cd ~/grpc && \
    git submodule update --init && \
    # Install protobuf
    cd ~/grpc/third_party/protobuf && \
    ./autogen.sh && \
    ./configure --enable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) check && \
    make install && \
    make clean && \
    ldconfig && \
    # Install gRPC
    cd ~/grpc && \
    make -j$(nproc) && \
    make install && \
    make clean && \
    ldconfig && \
    # Clean up
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf ~/grpc/

# AWS SDK
RUN \
    # Install dependencies
    apt-get update && \
    apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        uuid-dev \
        zlib1g-dev \
        libpulse-dev && \
    # Install AWS SDK for C++
    git clone https://github.com/aws/aws-sdk-cpp.git ~/aws-sdk && \
    cd ~/aws-sdk && \
    mkdir build && \
    cd build && \
    # Only install SDK for S3
    cmake -DBUILD_ONLY="s3" .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    # Clean up
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf ~/aws-sdk/

