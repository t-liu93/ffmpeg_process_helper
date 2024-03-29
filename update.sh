#!/bin/bash

FFMPEG="$HOME/ffmpeg"
FFBUILD="$HOME/ffmpeg_build"

# remove
sudo rm -rf $FFBUILD $FFMPEG/bin/{ffmpeg,ffprobe,ffplay,x264,x265} $FFMPEG/ffmpeg_sources

#sudo apt-get -y remove libx265-dev

# Update dependencies
sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev

mkdir -p $FFMPEG/ffmpeg_sources $FFMPEG/bin

# some assembler
sudo apt-get -y install nasm yasm

# libx264
cd $FFMPEG/ffmpeg_sources && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
cd x264 && \
PATH="$FFMPEG/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$FFMPEG/bin" --enable-static --enable-pic && \
PATH="$FFMPEG/bin:$PATH" make -j $(nproc) && \
make install && \

# libx265
#sudo apt-get -y install libx265-dev libnuma-dev && \
sudo apt-get install libnuma-dev && \
cd $FFMPEG/ffmpeg_sources && \
git -C x265_git pull 2> /dev/null || git clone https://bitbucket.org/multicoreware/x265_git && \
cd x265_git/build/linux && \
PATH="$FFMPEG/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off ../../source && \
PATH="$FFMPEG/bin:$PATH" make -j $(nproc) && \
make install && \
cp "$HOME/ffmpeg_build/bin/x265" "$FFMPEG/bin" && \

# libvpx
cd $FFMPEG/ffmpeg_sources && \
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
cd libvpx && \
PATH="$FFMPEG/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
PATH="$FFMPEG/bin:$PATH" make -j $(nproc) && \
make install

# libfdk-aac
cd $FFMPEG/ffmpeg_sources && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
make -j $(nproc) && \
make install

# libopus
cd $FFMPEG/ffmpeg_sources && \
git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
cd opus && \
./autogen.sh && \
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
make -j $(nproc) && \
make install

# Complication
cd $FFMPEG/ffmpeg_sources && \
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg && \
PATH="$FFMPEG/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="$FFMPEG/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$FFMPEG/bin:$PATH" make -j $(nproc) && \
make install && \
hash -r

sudo chown -R tianyu:tianyu $FFMPEG/bin
