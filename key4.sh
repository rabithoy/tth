#!/bin/bash

GROUP_ID="key4"

while true; do
  echo "Đang ping server để lấy appToken..."

  # Gọi API để lấy appToken
  APP_TOKEN_JSON=$(curl -s "http://142.171.114.6:6000/worker-ping?groupId=$GROUP_ID")
  APP_TOKEN=$(echo "$APP_TOKEN_JSON" | sed -n "s/.*\"appToken\":\"\([^\"]*\)\".*/\1/p")

  if [ -z "$APP_TOKEN" ]; then
    echo "Không có appToken được trả về, chờ 2 phút..."
    sleep 120
    continue
  fi

  echo "Nhận được appToken: $APP_TOKEN"

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

  # So sánh token cũ và mới
  CURRENT_TOKEN=$(sed -n 's/^TRAFFMONETIZER_TOKEN=//p' properties.conf | tr -d '\r')
  echo "CURRENT_TOKEN: [$CURRENT_TOKEN]"
  echo "NEW_APP_TOKEN: [$APP_TOKEN]"

  TOKEN_CHANGED=false
  if [ "$CURRENT_TOKEN" != "$APP_TOKEN" ]; then
    TOKEN_CHANGED=true
    echo "Token thay đổi → cập nhật"
    sed -i "s|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=$APP_TOKEN|" properties.conf
  else
    echo "Token giống nhau"
  fi

  sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf

  # Kiểm tra container
  CONTAINER_RUNNING=$(sudo docker ps -q)

  if [ -n "$CONTAINER_RUNNING" ]; then
    echo "Container đang chạy"

    if [ "$TOKEN_CHANGED" = true ] || [ "$HAS_PROXY_UPDATE" = true ]; then
      echo "Có thay đổi token/proxy → restart"
      sudo docker ps -q | sudo xargs -n1 docker update --restart=no
      sudo bash internetIncome.sh --delete
      sleep 10
      sudo rm -rf traffmonetizerdata resolv.conf
      sleep 2
      sudo bash internetIncome.sh --start
      sleep 60
    else
      echo "Không có thay đổi → giữ nguyên"
    fi
  else
    echo "Không có container đang chạy → start mới"
    sudo rm -rf traffmonetizerdata resolv.conf
    sleep 2
    sudo bash internetIncome.sh --start
    sleep 20
  fi

  echo "⏳ Chờ 2 phút trước vòng ping tiếp theo..."
  sleep 120
  cd
done

