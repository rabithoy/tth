#!/bin/bash
set -e

SERVER_IP="54.36.60.95"
SERVER_PORT=7777
URNETWORK_DATA_FOLDER="urnetwork_data"

# 🎨 màu log
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

log() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

rm -rf urnetwork_data
# 🟡 xin auth_code từ server
AUTH_CODE=$(curl -s "http://$SERVER_IP:$SERVER_PORT/get-auth" | jq -r '.auth_code')

if [ -z "$AUTH_CODE" ] || [ "$AUTH_CODE" == "null" ]; then
  log "${RED}❌ Không lấy được auth_code từ server"
  exit 1
fi

log "${GREEN}✅ Lấy được AUTH_CODE: $AUTH_CODE"

# 🟡 chuẩn bị thư mục data
mkdir -p "$PWD/$URNETWORK_DATA_FOLDER/data/.urnetwork"
sudo chmod -R 777 "$PWD/$URNETWORK_DATA_FOLDER/data/.urnetwork"

# 🟡 tạo jwt từ auth_code
log "${YELLOW}🔑 Tạo JWT file..."
sudo docker run --rm \
  -v "$PWD/$URNETWORK_DATA_FOLDER/data/.urnetwork:/root/.urnetwork" \
  --entrypoint /usr/local/sbin/bringyour-provider \
  bringyour/community-provider:latest auth "$AUTH_CODE"

if [ ! -f "$PWD/$URNETWORK_DATA_FOLDER/data/.urnetwork/jwt" ]; then
  log "${RED}❌ JWT file không được tạo. Kết thúc..."
  exit 1
fi
log "${GREEN}✅ JWT file đã được tạo."

# 🟢 chạy container provider
log "${YELLOW}🚀 Khởi động URnetwork container..."
sudo docker run -d \
  -v "$PWD/$URNETWORK_DATA_FOLDER/data/.urnetwork:/root/.urnetwork" \
  bringyour/community-provider:latest provide

log "${GREEN}✅ Worker đã chạy thành công."
