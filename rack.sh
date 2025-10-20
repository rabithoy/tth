#!/bin/bash

GROUP_ID="all"
sudo rm -rf InternetIncome-main
sudo rm -rf main.zip

# 🧩 Bước 1: Tải nếu chưa có main.zip
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/rabithoy/tth/raw/a7ef3df05ba3e835133506490849cc3750f8aaea/main.zip
fi

# 🧩 Bước 2: Giải nén đè
unzip -o main.zip

# 🧩 Bước 3: Dọn dẹp và chuẩn bị môi trường InternetIncome
cd InternetIncome-main || exit 1

# 🧩 Bước 5: bật proxy trong properties
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i "s|^PROXYRACK=.*|PROXYRACK=true|" properties.conf

# Files & flags
PROXIES_FILE="proxies.txt"
PROXYRACK_FILE="proxyrack.txt"
PROXY_UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
FLAG_FILE="/tmp/proxyrack_fetch_once.flag"

# đảm bảo proxyrack file tồn tại để tránh lỗi xargs
touch "$PROXYRACK_FILE"

while true; do
  # Cập nhật proxy nếu có file
  HAS_PROXY_UPDATE=false
  if [ -f "$PROXY_UPDATE_FILE" ]; then
    echo "$(date '+%F %T') - Tìm thấy file update proxy: $PROXY_UPDATE_FILE"
    cp "$PROXY_UPDATE_FILE" "$PROXIES_FILE"
    echo "$(date '+%F %T') - Đã cập nhật $PROXIES_FILE từ $PROXY_UPDATE_FILE"
    rm -f "$PROXY_UPDATE_FILE"
    HAS_PROXY_UPDATE=true

    # xóa flag để cho phép lấy proxyrack lại sau cập nhật
    if [ -f "$FLAG_FILE" ]; then
      rm -f "$FLAG_FILE"
      echo "$(date '+%F %T') - Đã xóa flag để cho phép lấy proxyrack lại."
    fi
  fi

  # Kiểm tra proxy có đủ dòng không (nếu file không tồn tại coi là 0)
  if [ ! -f "$PROXIES_FILE" ]; then
    LINE_COUNT=0
  else
    LINE_COUNT=$(wc -l < "$PROXIES_FILE" | tr -d ' ')
  fi

  if [ "$LINE_COUNT" -lt 5 ]; then
    echo "$(date '+%F %T') - $PROXIES_FILE có ít hơn 5 dòng ($LINE_COUNT dòng), chờ 2 phút..."
    sleep 120
    continue
  else
    # Nếu >=5 thì chạy BƯỚC 4 nhưng CHỈ 1 LẦN (dùng flag)
    if [ ! -f "$FLAG_FILE" ]; then
      echo "$(date '+%F %T') - $PROXIES_FILE có $LINE_COUNT dòng (>=5) — chạy Bước 4 1 lần..."
      curl -s "http://54.36.60.95:3000/get-offline-keys?limit=12" \
        | grep -oP '"device_id"\s*:\s*"\K[^"]+' >> "$PROXYRACK_FILE"
      touch "$FLAG_FILE"
      echo "$(date '+%F %T') - Đã lấy proxyrack và tạo flag: $FLAG_FILE"
    else
      echo "$(date '+%F %T') - Đã lấy proxyrack trước đó (flag tồn tại)."
    fi
  fi

  # 🧩 Bước 6: ping tất cả device_id trong proxyrack.txt (nếu có)
  if [ -s "$PROXYRACK_FILE" ]; then
    xargs -I{} curl -s -X POST http://54.36.60.95:3000/ping -H "Content-Type: application/json" -d '{"device_id":"{}"}' < "$PROXYRACK_FILE"
  else
    echo "$(date '+%F %T') - $PROXYRACK_FILE trống, bỏ qua ping."
  fi

  # Nếu có cập nhật proxy thì restart/start InternetIncome
  if [ "$HAS_PROXY_UPDATE" = true ]; then
    sudo bash internetIncome.sh --delete
    sleep 10
    sudo bash internetIncome.sh --start
    sleep 60
  else
    echo "$(date '+%F %T') - Không có thay đổi → giữ nguyên"
  fi

  echo "⏳ Chờ 5 phút trước vòng ping tiếp theo..."
  sleep 300
done
