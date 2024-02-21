echo "警告⚠"
echo "分配的服务器性能有限，若选择的插件过多，务必注意CPU性能！"
echo -e "已知CPU型号(降序): 7763，8370C，8272CL，8171M，E5-2673\n"
echo "--------------------------CPU信息--------------------------"
echo "CPU物理数量: $(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)"
echo "CPU核心数量: $(nproc)"
echo -e "CPU型号信息:$(cat /proc/cpuinfo | grep -m1 name | awk -F: '{print $2}')\n"
echo "--------------------------内存信息--------------------------"
echo "已安装内存详细信息:"
echo -e "$(sudo lshw -short -C memory | grep GiB)\n"
echo "--------------------------硬盘信息--------------------------"
echo "硬盘数量: $(ls /dev/sd* | grep -v [1-9] | wc -l)" && df -hT

sudo apt update -y
sudo apt upgrade -y

sudo timedatectl set-timezone Asia/Shanghai

sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 \
python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

mkdir workspace
cd workspace
df -hT .

git clone https://github.com/yanxiangrong/OpenWrt.git
git clone https://github.com/coolsnowwolf/lede

chmod +x OpenWrt/scripts/*.sh
chmod +x OpenWrt/diy-script.sh
cp OpenWrt/configs/x86_64.config lede/.config

cd lede
make defconfig

./scripts/feeds update -a
./scripts/feeds install -a

../OpenWrt/diy-script.sh
../OpenWrt/scripts/preset-clash-core.sh amd64
../OpenWrt/scripts/preset-terminal-tools.sh
../OpenWrt/scripts/preset-adguard-core.sh amd64

mkdir -p files/etc/uci-defaults
cp ../OpenWrt/scripts/init-settings.sh files/etc/uci-defaults/99-init-settings

make download -j32
make -j16
