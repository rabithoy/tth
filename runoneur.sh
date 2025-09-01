#!/bin/bash
set -e

EMAIL="minhkweitei@gmail.com"
PASSWORD="Koaibiet123@"
urnetwork_data_folder="urnetwork_data"
UNIQUE_ID=1
container_pulled=false

# 🎨 Màu cho log
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

log() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "${YELLOW}🟡 Bắt đầu lấy UR_AUTH_TOKEN..."

TOKEN=$(curl -s -X POST https://api.bringyour.com/auth/login-with-password \
  -H "Content-Type: application/json" \
  -d "{\"user_auth\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.network.by_jwt')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  log "${RED}❌ Login thất bại, không lấy được JWT token"
  exit 1
fi

log "${GREEN}✅ Lấy JWT token thành công."

UR_AUTH_TOKEN=$(curl -s -X POST https://api.bringyour.com/auth/code-create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"duration_minutes":2,"uses":2}' | jq -r '.auth_code')

if [ -z "$UR_AUTH_TOKEN" ] || [ "$UR_AUTH_TOKEN" == "null" ]; then
  log "${RED}❌ Không tạo được auth_code"
  exit 1
fi

log "${GREEN}✅ UR_AUTH_TOKEN: $UR_AUTH_TOKEN"

# 🟢 Chạy container URnetwork
if [[ $UR_AUTH_TOKEN ]]; then
  if [ "$container_pulled" = false ]; then
    log "${YELLOW}🟡 Pull Docker image bringyour/community-provider:latest..."
    sudo docker pull bringyour/community-provider:latest

    mkdir -p "$PWD/$urnetwork_data_folder/data/.urnetwork"
    sudo chmod -R 777 "$PWD/$urnetwork_data_folder/data/.urnetwork"
    log "${GREEN}✅ Thư mục .urnetwork đã sẵn sàng."

    # Chạy auth container tạo JWT nếu chưa có
    if [ ! -f "$PWD/$urnetwork_data_folder/data/.urnetwork/jwt" ]; then
      log "${YELLOW}🟡 Tạo JWT file..."
      sudo docker run --rm \
        -v "$PWD/$urnetwork_data_folder/data/.urnetwork:/root/.urnetwork" \
        --entrypoint /usr/local/sbin/bringyour-provider \
        bringyour/community-provider:latest auth "$UR_AUTH_TOKEN"
      
      sleep 1
      if [ ! -f "$PWD/$urnetwork_data_folder/data/.urnetwork/jwt" ]; then
        log "${RED}❌ JWT file không được tạo. Kết thúc..."
        exit 1
      fi
      log "${GREEN}✅ JWT file đã được tạo."
    fi

    container_pulled=true
  fi

  # Chạy URnetwork provide luôn
  log "${YELLOW}🟡 Khởi động URnetwork container..."
  docker_parameters=(
    -v "$PWD/$urnetwork_data_folder/data/.urnetwork:/root/.urnetwork"
    bringyour/community-provider:latest provide
  )

  sudo docker run -d "${docker_parameters[@]}"
  log "${GREEN}✅ URnetwork container đang chạy."
fi
