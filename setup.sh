#!/bin/bash
set -e

# Xóa thư mục cũ
rm -rf *

# Tải Chromium portable (ungoogled)
wget https://github.com/macchrome/linchrome/releases/download/v140.7339.137-M140.0.7339.137-r1496484-portable-ungoogled-Lin64/ungoogled-chromium_140.0.7339.137_1.vaapi_linux.tar.xz

# Giải nén
tar -xJf ungoogled-chromium_140.0.7339.137_1.vaapi_linux.tar.xz

# Cài các thư viện cần thiết
sudo yum install -y \
  nss \
  nspr \
  alsa-lib \
  atk \
  at-spi2-atk \
  cups-libs \
  gtk3 \
  libdrm \
  libXcomposite \
  libXcursor \
  libXdamage \
  libXext \
  libXi \
  libXrandr \
  libXScrnSaver \
  libXtst \
  pango \
  xorg-x11-fonts-100dpi \
  xorg-x11-fonts-75dpi \
  xorg-x11-utils \
  xorg-x11-fonts-cyrillic \
  xorg-x11-fonts-Type1 \
  xorg-x11-fonts-misc

# Cài npm packages
npm install puppeteer-core puppeteer-extra puppeteer-extra-plugin-stealth
npm i clipboardy
# Xóa file tar
rm -rf ungoogled-chromium_140.0.7339.137_1.vaapi_linux.tar.xz

echo "✅ Cài đặt Chromium và dependencies hoàn tất!"
