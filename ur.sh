#!/bin/bash
set -e

EMAIL="minhkweitei@gmail.com"
PASSWORD="Koaibiet123@"
GROUP_ID="all"

# 🧩 Xoá thư mục cũ
sudo rm -rf InternetIncome-main main.zip astrominer-V1.9.2.R5_amd64_linux.tar.gz.*
sudo rm -rf main.zip
sudo rm -rf InternetIncome-main

# 🧩 Tải main.zip nếu chưa có
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/rabithoy/tth/raw/d7c0f58b1635c5726c0e6f7bba5b368fdcb65f27/test.zip
fi

# 🧩 Giải nén đè
unzip -o main.zip
cd InternetIncome-main

# 🧩 Luôn bật proxy & thiết lập token
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i "s|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=5fCEXBYAuVVO1h7ZvSHKy5UIqQB0CFRhyMPMI4Xg0/U=|" properties.conf
sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskLEggSnhicxN|" properties.conf

# 🧩 Hàm lấy auth code
get_auth_code() {
  AUTH_CODE=$(curl -s "http://54.36.60.95:6666/get-auth" | jq -r '.auth_code')

  sudo sed -i "s|^UR_AUTH_TOKEN=.*|UR_AUTH_TOKEN='$AUTH_CODE'|" properties.conf
  echo "✅ Lấy auth_code thành công: $AUTH_CODE"
}

# 🧩 Vòng lặp chính
while true; do
  PROXY_UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
  HAS_PROXY_UPDATE=false

  # Kiểm tra file proxy update
  if [ -f "$PROXY_UPDATE_FILE" ]; then
    echo "Tìm thấy file update proxy: $PROXY_UPDATE_FILE"
    cp "$PROXY_UPDATE_FILE" proxies.txt
    echo "Đã cập nhật proxies.txt từ $PROXY_UPDATE_FILE"
    rm -f "$PROXY_UPDATE_FILE"
    HAS_PROXY_UPDATE=true
  fi

  # Nếu proxies.txt ít hơn 5 dòng → chờ
  LINE_COUNT=$(wc -l < proxies.txt || echo 0)
  if [ "$LINE_COUNT" -lt 5 ]; then
    echo "⚠️ proxies.txt có ít hơn 5 dòng ($LINE_COUNT dòng), chờ 2 phút..."
    sleep 120
    continue
  fi

  # Nếu có update → refresh token & restart
  if [ "$HAS_PROXY_UPDATE" = true ]; then
    get_auth_code
    sudo bash internetIncome.sh --delete || true
    sleep 10
    sudo bash internetIncome.sh --start
    sleep 60
  fi

  echo "⏳ Chờ 2 phút trước khi làm vòng tiếp theo..."
  sleep 120
done
