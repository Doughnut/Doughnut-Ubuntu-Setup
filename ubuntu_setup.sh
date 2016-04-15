#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo ""
  echo "Please Run As Root"
  echo ""
  exit
fi

echo "Please enter your username: "; read USER1
apt-get install iptables-persistent -y

mkdir /tmp/setup/
cd /tmp/setup

# Disable ipv6 and set swappiness to reasonable level
cat << EOF >> /etc/sysctl.conf

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

vm.swappiness = 10

EOF

sysctl -p

IPT="/sbin/iptables"
$IPT --flush
$IPT --delete-chain
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s 0.0.0.0/0 -j DROP
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

add-apt-repository ppa:graphics-drivers/ppa -y

apt-get install libxss1 libappindicator1 libindicator7 -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome*.deb
apt-get install -f -y

apt-get install curl gnome-tweak-tool thunderbird pidgin pidgin-sipe guake python-pip vlc pithos openssh-server zsh python-pandas python-beautifulsoup haveged unrar wget git vim sendmail xclip -y

cat << EOF >> /etc/ssh/sshd_config

# Disabling bad MACs, CYPHERS, and Key Exchanges for sshd
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256

AllowUsers $USER1
EOF

add-apt-repository ppa:pi-rho/security -y > /dev/null && apt-get update > /dev/null && apt-get install nmap -y

# Install Sublime Text 3
SUBL=$(curl https://www.sublimetext.com/3 | grep -i "amd64.deb" | cut -d "\"" -f 4)
wget $SUBL
dpkg -i sublime-text*.deb

#Install Dropbox
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
add-apt-repository "deb http://linux.dropbox.com/ubuntu $(lsb_release -sc) main"
apt-get update > /dev/null && apt-get install dropbox python-gpgme -y; pkill nautilus # you're welcome, dropbox

pip install thefuck
pip install livestreamer

apt-get update -y > /dev/null && apt-get upgrade -y



##Oh-My-ZSH Install (because it's amazing)
#git clone git://github.com/robbyrussell/oh-my-zsh.git /home/$USER1/.oh-my-zsh
#cp /home/$USER1/.zshrc /home/$USER1/.zshrc.orig
#cp /home/$USER1/.oh-my-zsh/templates/zshrc.zsh-template /home/$USER1/.zshrc
#sed -i 's/ZSH_THEME=.*$/ZSH_THEME="junkfood"/g' /home/$USER1/.zshrc
#sed -i 's/# COMPLETION_WAITING_DOTS="true"$/COMPLETION_WAITING_DOTS="true"/g' /home/jeffreyf/.zshrc
#sed -i 's/# HIST_STAMPS="mm/dd/yyyy"$/HIST_STAMPS="mm/dd/yyyy"/g' /home/jeffreyf/.zshrc
#chsh $USER1 -s /bin/zsh




