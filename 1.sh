#!/bin/bash

SERVER="http://142.171.114.6:8888"
SDT="worker-$(date +%s)"
COUNT=30
UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"

echo "🛠️ Worker $SDT khởi động..."

# ✅ Đảm bảo thư mục chứa update file tồn tại
mkdir -p "$(dirname "$UPDATE_FILE")"

# ✅ Vòng lặp để lấy proxy ban đầu đủ số lượng yêu cầu
while true; do
  echo "📦 Đang lấy proxy từ server..."
  curl -s -X POST "$SERVER/request-proxies" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"count\":$COUNT}" |
    jq -r '.proxies[]' > proxies.txt

  PROXY_COUNT=$(wc -l < proxies.txt)
  echo "✅ Nhận được $PROXY_COUNT proxy."

  if [ "$PROXY_COUNT" -lt "$COUNT" ]; then
    echo "⚠️ Số lượng proxy chưa đủ ($PROXY_COUNT/$COUNT). Đợi 10 phút rồi thử lại..."
    sleep 600
  else
    break
  fi
done

# ✅ Lưu proxy lần đầu
cp proxies.txt "$UPDATE_FILE"
echo "📝 Đã tạo $UPDATE_FILE"

# ✅ Gửi ping 2 phút/lần, gửi kèm proxy đang dùng
while true; do
  echo "📶 Ping giữ kết nối cho $SDT..."

  proxy_array=$(jq -Rs 'split("\n") | map(select(length > 0))' proxies.txt)

  res=$(curl -s -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"proxies\":$proxy_array}")

  updated=$(echo "$res" | jq -r '.updated')

  if [ "$updated" = "true" ]; then
    echo "♻️ Proxy bị thay, cập nhật lại..."
    echo "$res" | jq -r '.proxies[]' > proxies.txt
    cp proxies.txt "$UPDATE_FILE"
    echo "📝 Đã cập nhật $UPDATE_FILE"
  fi

  sleep 120
done

