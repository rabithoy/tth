#!/bin/bash

# 🧩 Bước 1: Tải nếu chưa có main.zip
if [ ! -f "main.zip" ]; then
  wget -O https://github.com/rabithoy/tth/archive/refs/heads/main.zip
fi

# 🧩 Bước 2: Giải nén đè
unzip -o main.zip

# 🧩 Bước 3: Dọn dẹp và chuẩn bị môi trường InternetIncome
cd InternetIncome-main || exit 1

sudo docker ps -q | xargs -r -n1 sudo docker update --restart=no || true
sudo bash internetIncome.sh --delete || true
sudo rm -rf traffmonetizerdata resolv.conf proxies.txt || true

# 🧩 Bước 4: Quay lại thư mục gốc để chạy 2.sh
cd

# 🧩 Bước 5: Chạy script 2.sh (nền hoặc không tùy bạn)
nohup bash ./2.sh >/dev/null 2>&1 &

# 🧩 Bước 6: Chạy script 3.sh (nền hoặc không tùy bạn)
nohup bash ./1.sh >/dev/null 2>&1 &
