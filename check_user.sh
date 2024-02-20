#!/bin/bash
mkdir -p /root/admin-script/
touch /root/admin-script/user_suspend.txt
touch /root/admin-script/user_active.txt
# Di chuyển đến thư mục chứa dữ liệu người dùng DirectAdmin
cd /usr/local/directadmin/data/users
echo > /root/admin-script/user_suspend.txt
echo > /root/admin-script/user_active.txt

# Tìm kiếm các tài khoản bị suspend và lưu vào file user_suspend.txt (chỉ lấy phần tên người dùng)
grep -r "suspended=yes" */user.conf | sed 's/\/user.conf:suspended=yes//' > /root/admin-script/user_suspend.txt
grep -r "suspended=no" */user.conf | sed 's/\/user.conf:suspended=no//' > /root/admin-script/user_active.txt

# Đếm số lượng người dùng đang suspend và in ra
suspend_count=$(cat /root/admin-script/user_suspend.txt | wc -l)
echo "Số lượng user đang Suspend là: $suspend_count"

# Đếm số lượng người dùng đang active và in ra
active_count=$(cat /root/admin-script/user_active.txt | wc -l)
echo "Số lượng user đang Active là: $active_count"

# Đọc danh sách người dùng từ tệp user_suspend.txt vào mảng users
mapfile -t users < /root/admin-script/user_suspend.txt

# Tính tổng dung lượng
total_size=0

for user_info in "${users[@]}"; do
    # Lấy tên người dùng từ thông tin dòng
    user=$(echo "$user_info" | awk -F '/' '{print $1}')

    user_dir="/home/$user/"  # Thay đổi đường dẫn tùy theo cấu trúc thư mục của bạn
    user_size=$(du -sh "$user_dir" | awk '{print $1}')
    echo "Dung lượng của $user: $user_size"
    total_size=$((total_size + $(du -sb "$user_dir" | awk '{print $1}')))
done

# Chuyển đổi tổng dung lượng thành GB
total_size_gb=$(awk "BEGIN {printf \"%.2f\", $total_size / (1024*1024*1024)}")

# Sử dụng df -h để kiểm tra dung lượng và in ra
disk_info=$(df -h /home)
total=$(echo "$disk_info" | awk 'NR==2 {print $2}')
used=$(echo "$disk_info" | awk 'NR==2 {print $3}')
available=$(echo "$disk_info" | awk 'NR==2 {print $4}')

# Tạo danh sách các user suspend
suspend_users_list=$(printf "#%s, " "${users[@]}")

# Lấy tên hostname của máy
hostname=$(hostname)

# Kiểm tra giá trị của hostname
echo "Hostname: $hostname"

# Tạo thông điệp cần gửi
message="👨‍💻 SERVER $hostname"$'\n\n'
message+="✅ Số lượng user đang Suspend là: $suspend_count"$'\n'
message+="✅ Danh sách user đang suspend: ${suspend_users_list%,}"$'\n'  # Remove the trailing comma
message+="✅ Tổng dung lượng của các user Suspend là: ${total_size_gb}GB"$'\n'
message+="✅ Số lượng user đang Active là: $active_count"$'\n'
message+="✅ Tổng: $total"$'\n'
message+="✅ Đã dùng: $used"$'\n'
message+="✅ Còn trống: $available"$'\n'

# Telegram Bot token và chat_id
TELEGRAM_BOT_TOKEN="Nhập vào token"
TELEGRAM_CHAT_ID="Nhập vào ID Chat"

# Gửi thông điệp đến Telegram
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$message"

# Kết thúc script
exit 0
