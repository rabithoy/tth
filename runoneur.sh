#!/bin/bash
set -e

EMAIL="minhkweitei@gmail.com"
PASSWORD="Koaibiet123@"
urnetwork_data_folder="urnetwork_data"
UNIQUE_ID=1
container_pulled=false

# 🧩 Lấy UR_AUTH_TOKEN 1 lần
TOKEN=$(curl -s -X POST https://api.bringyour.com/auth/login-with-password \
  -H "Content-Type: application/json" \
  -d "{\"user_auth\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.network.by_jwt')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo "❌ Login thất bại, không lấy được JWT token"
  exit 1
fi

UR_AUTH_TOKEN=$(curl -s -X POST https://api.bringyour.com/auth/code-create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"duration_minutes":15,"uses":30}' | jq -r '.auth_code')

if [ -z "$UR_AUTH_TOKEN" ] || [ "$UR_AUTH_TOKEN" == "null" ]; then
  echo "❌ Không tạo được auth_code"
  exit 1
fi

echo "✅ UR_AUTH_TOKEN: $UR_AUTH_TOKEN"

# 🧩 Chạy container URnetwork
if [[ $UR_AUTH_TOKEN ]]; then
  if [ "$container_pulled" = false ]; then
    sudo docker pull bringyour/community-provider:latest

    mkdir -p "$PWD/$urnetwork_data_folder/data/.urnetwork"
    sudo chmod -R 777 "$PWD/$urnetwork_data_folder/data/.urnetwork"

    # Chạy auth container tạo JWT nếu chưa có
    if [ ! -f "$PWD/$urnetwork_data_folder/data/.urnetwork/jwt" ]; then
      sudo docker run --rm \
        -v "$PWD/$urnetwork_data_folder/data/.urnetwork:/root/.urnetwork" \
        --entrypoint /usr/local/sbin/bringyour-provider \
        bringyour/community-provider:latest auth "$UR_AUTH_TOKEN"
      
      sleep 1
      if [ ! -f "$PWD/$urnetwork_data_folder/data/.urnetwork/jwt" ]; then
        echo "❌ JWT file could not be generated. Exiting..."
        exit 1
      fi
    fi

    container_pulled=true
  fi

  # Chạy URnetwork provide luôn
  docker_parameters=(
    -v "$PWD/$urnetwork_data_folder/data/.urnetwork:/root/.urnetwork"
    bringyour/community-provider:latest provide
  )

  sudo docker run -d "${docker_parameters[@]}"
  echo "✅ URnetwork container đang chạy"
fi
