#!/bin/bash
set -e

EMAIL="minhkweitei@gmail.com"
PASSWORD="Koaibiet123@"
GROUP_ID="all"

# 🧩 Xoá thư mục cũ
sudo rm -rf InternetIncome-main
sudo rm -rf main.zip

# 🧩 Bước 1: Tải main.zip nếu chưa có
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/rabithoy/tth/raw/d7c0f58b1635c5726c0e6f7bba5b368fdcb65f27/test.zip
fi

# 🧩 Bước 2: Giải nén đè
unzip -o main.zip
cd InternetIncome-main

# 🧩 Luôn bật proxy
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i "s|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=1QAj0JfAZYtg45rfa+Fc8AnG07prAolPc5mbmXX9lk8=|" properties.conf
sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskfAkzBSp8YhU|" properties.conf


# 🧩 Hàm lấy token mới
get_auth_code() {
  TOKEN=$(curl -s -X POST https://api.bringyour.com/auth/login-with-password \
    -H "Content-Type: application/json" \
    -d "{\"user_auth\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.network.by_jwt')

  if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "❌ Login thất bại, không lấy được JWT token"
    exit 1
  fi

  AUTH_CODE=$(curl -s -X POST https://api.bringyour.com/auth/code-create \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"duration_minutes":15,"uses":30}' | jq -r '.auth_code')

  if [ -z "$AUTH_CODE" ] || [ "$AUTH_CODE" == "null" ]; then
    echo "❌ Không tạo được auth_code"
    exit 1
  fi

  # Ghi vào properties.conf (đưa vào '')
  sed -i "s|^UR_AUTH_TOKEN=.*|UR_AUTH_TOKEN='$AUTH_CODE'|" properties.conf
  echo "✅ Lấy auth_code thành công: $AUTH_CODE"
}

# 🧩 Vòng lặp chính
while true; do
  # Nếu proxies.txt ít hơn 5 dòng thì chờ
  LINE_COUNT=$(wc -l < proxies.txt || echo 0)
  if [ "$LINE_COUNT" -lt 5 ]; then
    echo "⚠️ proxies.txt có ít hơn 5 dòng ($LINE_COUNT dòng), chờ 2 phút..."
    sleep 120
    continue
  fi

  # Refresh token & restart InternetIncome
  get_auth_code
  sudo bash internetIncome.sh --delete || true
  sleep 10
  sudo bash internetIncome.sh --start

  echo "⏳ Chờ 2 phút trước khi làm mới token..."
  sleep 120
done
