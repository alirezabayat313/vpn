# Open ports
echo -e "\033[1;32mSalam Rafiq"
read -p "${DK}پورت برای اتصال وی پی ان: " vpnport
ufw allow 80
ufw allow 443
ufw allow $vpnport
echo -e "\033[1;32mپورت های 80 و 443 و $vpnport باز شد!"

# sudo wget https://raw.githubusercontent.com/alirezabayat313/vpn/main/setup.sh -O setup.sh && sudo chmod +x setup.sh && sudo bash setup.sh
# Create 1GB swap memory
mkdir -p /var/swapmemory
cd /var/swapmemory
dd if=/dev/zero of=swapfile bs=1M count=1000
mkswap swapfile
swapon swapfile
chmod 600 swapfile
free -m
echo -e "\033[1;32mتعویض حافظه ایجاد شد."



# Boost network performance
sysctl -w net.core.rmem_max=26214400
sysctl -w net.core.rmem_default=26214400
echo -e "\033[1;32mعملکرد نتورک سرور شما افزایش یافت !"

# Install python, pip, and screen
apt update
apt install python3 python3-pip screen
echo -e "\033[1;32mپایتون و pip و screen نصب شد !"

# Install caddy
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install caddy
echo -e "\033[1;32mCaddy نصب شد !"

# Configure reverse proxy with caddy
read -p "دامنه پنل ادمین: " admindomain
cat << EOF > /etc/caddy/Caddyfile
$admindomain {
    reverse_proxy localhost:5000
}
EOF
caddy reload --config /etc/caddy/Caddyfile
echo -e "\033[1;32mکانفیگ پروکسی انجام شد !"

# Setup the web admin panel
cd
git clone https://github.com/dashroshan/openvpn-wireguard-admin vpn
cd vpn
python3 -m pip install -r requirements.txt
echo -e "\033[1;32mپنل ادمین کانفیگ شد !"

# Create the configWireguard.py
read -p "'wireguard' روی مخوای یا 'openvpn' ?"  vpntype
# "Enter 'wireguard' or 'openvpn' as needed: "
if [ "$vpntype" == "wireguard" ]; then
read -p "Enter 'True' or 'False' for AdBlock: "  adblock
cat << EOF > configWireguard.py
wireGuardBlockAds = $adblock
EOF
echo -e "\033[1;32mconfigureWireguard.py ساخته شد!"
fi

# Create the config.py
read -p "نام کاربری پنل ادمین: " adminuser
read -p "رمز عبور پنل ادمین: " adminpass

passwordhash=$(echo -n $adminpass | sha256sum | cut -d" " -f1)

cat << EOF > config.py
import $vpntype as vpn
creds = {
    "username": "$adminuser",
    "password": "$passwordhash",
}
EOF
echo -e "\033[1;32mفایل پایتون به اسم کانفیگ برای پنل ادمین ساخته شد!"

# Download vpn setup script
cd
if [ "$vpntype" == "wireguard" ]; then
wget https://raw.githubusercontent.com/Nyr/wireguard-install/master/wireguard-install.sh -O vpn-install.sh
else
wget https://raw.githubusercontent.com/Nyr/openvpn-install/master/openvpn-install.sh -O vpn-install.sh
fi
echo -e "\033[1;32mاسکریپت وی پی ان دانلود شد !"

# Setup vpn
chmod +x vpn-install.sh
bash vpn-install.sh
echo -e "\033[1;32mوی پی ان آماده شد شیطون"

# Run web admin portal
cd vpn
screen -dmS vpn bash -c 'python3 main.py; bash'
echo -e "\033[1;32mپنل ادمین روی پورت $admindomain اجرا شد!"
echo -e "\033[1;32mوی پی ان اوکی شد برو عشق کن"