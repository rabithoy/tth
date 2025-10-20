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
cd InternetIncome-main

# 🧩 Bước 4
curl -s "http://54.36.60.95:3000/get-offline-keys?limit=12" | grep -oP '"device_id"\s*:\s*"\K[^"]+' >> proxyrack.txt

# 🧩 Bước 5
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i "s|^PROXYRACK=.*|PROXYRACK=true|" properties.conf

# === 🔁 Định nghĩa Bước 6 thành hàm riêng ===
ping_server() {
  echo "📡 [$(date '+%H:%M:%S')] Đang ping về server..."
  if [ -s proxyrack.txt ]; then
    xargs -I{} curl -s -X POST http://54.36.60.95:3000/ping \
      -H "Content-Type: application/json" \
      -d '{"device_id":"{}"}' < proxyrack.txt > /dev/null
  else
    echo "⚠️ proxyrack.txt rỗng hoặc không tồn tại!"
  fi
}

# === 🔁 Vòng lặp chính ===
while true; do
  # 🧩 Bước 6
  ping_server

  # 🧩 Bước 7: Cập nhật proxy nếu có file
  PROXY_UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
  HAS_PROXY_UPDATE=false

  if [ -f "$PROXY_UPDATE_FILE" ]; then
    echo "📂 Tìm thấy file update proxy: $PROXY_UPDATE_FILE"
    cp "$PROXY_UPDATE_FILE" proxies.txt
    echo "✅ Đã cập nhật proxies.txt từ $PROXY_UPDATE_FILE"
    rm -f "$PROXY_UPDATE_FILE"
    HAS_PROXY_UPDATE=true
  fi

  # 🧩 Bước 8: Kiểm tra proxy có đủ dòng không
  LINE_COUNT=$(wc -l < proxies.txt)
  if [ "$LINE_COUNT" -lt 5 ]; then
    echo "⚠️ proxies.txt có ít hơn 5 dòng ($LINE_COUNT dòng)"
    echo "↩️ Gọi lại bước 6 để ping lại do thiếu proxy..."
    sleep 10
    ping_server   # 🔁 Gọi lại bước 6
    continue      # Quay lại vòng lặp
  fi

  # 🧩 Bước 9: Quản lý container
  if [ "$HAS_PROXY_UPDATE" = true ]; then
    echo "♻️ Có cập nhật proxy → reset container"
    sudo bash internetIncome.sh --delete
    sleep 10
    sudo bash internetIncome.sh --start
    sleep 60
  else
    echo "✅ Không có thay đổi → giữ nguyên container"
  fi

  echo "⏳ Chờ 2 phút trước vòng ping tiếp theo..."
  sleep 400
done
