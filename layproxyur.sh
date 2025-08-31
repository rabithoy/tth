#!/bin/bash

SERVER="http://142.171.114.6:8888"
UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
COUNT=17

# ✅ Tạo tên worker duy nhất theo thời gian + UUID rút gọn
SDT="worker-$(date +%s)-$(uuidgen | cut -c1-8)"

# ✅ Hàm log có timestamp
log() {
  echo "[$(date '+%H:%M:%S')] $1"
}

log "🛠️ Worker $SDT khởi động..."

# ✅ Đảm bảo thư mục chứa update file tồn tại
mkdir -p "$(dirname "$UPDATE_FILE")"

# ===== Lấy proxy ban đầu =====
while true; do
  log "📦 Đang lấy proxy từ server..."
  
  curl -s -X POST "$SERVER/request-proxies" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"count\":$COUNT}" |
    jq -r '.proxies[]' > proxies.txt

  PROXY_COUNT=$(wc -l < proxies.txt)
  log "✅ Nhận được $PROXY_COUNT proxy."

  if [ "$PROXY_COUNT" -lt "$COUNT" ]; then
    log "⚠️ Số lượng proxy chưa đủ ($PROXY_COUNT/$COUNT). Đợi 10 phút rồi thử lại..."
    sleep 600
  else
    # Lưu proxy trước khi chạy rack.sh
    cp proxies.txt "$UPDATE_FILE"
    log "📝 Đã tạo $UPDATE_FILE"

    # Tải và chạy rack.sh
    rm -rf ur.sh
    wget -q https://raw.githubusercontent.com/rabithoy/tth/main/ur.sh
    chmod +x ur.sh
    nohup bash ./ur.sh >/dev/null 2>&1 &
    log "🚀 Đã chạy rack.sh"
    
    break  # thoát vòng lặp khi đủ proxy
  fi
done

# ===== Ping giữ kết nối =====
while true; do
  log "📶 Ping giữ kết nối cho $SDT..."

  # Đọc file proxy thành mảng JSON
  proxy_array=$(jq -Rs 'split("\n") | map(select(length > 0))' proxies.txt)

  # Gửi ping (retry 3 lần nếu lỗi mạng)
  res=$(curl -s --max-time 10 --retry 3 --retry-delay 3 -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"proxies\":$proxy_array}")

  # Nếu server trả về updated = true thì cập nhật lại danh sách
  updated=$(echo "$res" | jq -r '.updated')

  if [ "$updated" = "true" ]; then
      log "♻️ Proxy bị thay, cập nhật lại..."
      echo "$res" | jq -r '.proxies[]' | sudo tee proxies.txt > /dev/null
      sudo cp proxies.txt "$UPDATE_FILE"
      log "📝 Đã cập nhật $UPDATE_FILE"
  fi

  sleep 120
done
