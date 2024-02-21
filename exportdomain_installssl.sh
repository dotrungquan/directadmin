#!/bin/bash
#Author: DOTRUNGQUAN.INFO
# Đường dẫn đến thư mục chứa file domain.conf
domain_conf_dir="/usr/local/directadmin/data/users"

# Đường dẫn đến file domain.txt
output_file="/root/domain.txt"

# Lặp qua tất cả các file domain.conf
for conf_file in $domain_conf_dir/*/domains/*.conf; do
    # Kiểm tra xem file tồn tại
    if [ -f "$conf_file" ]; then
        # Lấy tên domain từ tên file và ghi vào domain.txt
        domain=$(basename "$conf_file" .conf)
        echo "$domain" >> "$output_file"
    fi
done

echo "Quá trình hoàn thành. Các domain đã được ghi vào $output_file"

# Đường dẫn đến script cài SSL
letsencrypt_script="/usr/local/directadmin/scripts/letsencrypt.sh"

# Lặp qua danh sách tên miền và gọi lệnh cài SSL
while IFS= read -r domain; do
    echo "Cài SSL cho domain: $domain"
    "$letsencrypt_script" request "$domain"
done < "$output_file"

echo "Quá trình cài SSL đã hoàn thành."
