#!/bin/bash

GROUP_ID="all"

while true; do

  # Đảm bảo thư mục tồn tại trước khi làm việc
  if [ ! -d "InternetIncome-main" ]; then
    echo "❌ Không tìm thấy thư mục InternetIncome-main sau giải nén. Thoát..."
    exit 1
  fi

  cd InternetIncome-main

  # Cập nhật proxy nếu có file
  PROXY_UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
  HAS_PROXY_UPDATE=false

  if [ -f "$PROXY_UPDATE_FILE" ]; then
    echo "Tìm thấy file update proxy: $PROXY_UPDATE_FILE"
    cp "$PROXY_UPDATE_FILE" proxies.txt
    echo "Đã cập nhật proxies.txt từ $PROXY_UPDATE_FILE"
    rm -f "$PROXY_UPDATE_FILE"
    HAS_PROXY_UPDATE=true
  fi

  # Kiểm tra proxy có đủ dòng không
  LINE_COUNT=$(wc -l < proxies.txt)
  if [ "$LINE_COUNT" -lt 5 ]; then
    echo "proxies.txt có ít hơn 5 dòng ($LINE_COUNT dòng), chờ 2 phút..."
    cd ..
    sleep 120
    continue
  fi

  sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
  sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskLEggSnhicxN|" properties.conf
  sudo sed -i 's|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=OeWo3xtxe5TusWwkTdsjfpoulyY3l9CqOMez01eZK/s=|' properties.conf

  # Kiểm tra container
  # Lấy danh sách container đang chạy
  CONTAINER_RUNNING=$(sudo docker ps -q)
  CONTAINER_COUNT=$(echo "$CONTAINER_RUNNING" | wc -l)

  if [ "$CONTAINER_COUNT" -ge 4 ]; then
    echo "Có $CONTAINER_COUNT container đang chạy"

    if [ "$HAS_PROXY_UPDATE" = true ]; then
      echo "Có thay đổi token/proxy → restart"
      sudo bash internetIncome.sh --delete
      sleep 10
      sudo bash internetIncome.sh --start
      sleep 60
    else
      echo "Không có thay đổi → giữ nguyên"
    fi
  else
  fi


  echo "⏳ Chờ 5 phút trước vòng ping tiếp theo..."
  sleep 300
  cd
done

