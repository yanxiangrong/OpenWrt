#!/bin/bash
set -xve

REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"
CONFIG_FILE="configs/x86_64.config"
DIY_SCRIPT="diy-script.sh"
CLASH_KERNEL="amd64"
FIRMWARE_TAG="X86_64"
TZ="Asia/Shanghai"

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

sudo timedatectl set-timezone $TZ

sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 \
python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

git clone https://github.com/yanxiangrong/OpenWrt.git workspace
cd workspace
GITHUB_WORKSPACE=$(pwd)
chmod +x $GITHUB_WORKSPACE/scripts/*.sh
chmod +x $DIY_SCRIPT
df -hT $GITHUB_WORKSPACE

git clone $REPO_URL -b $REPO_BRANCH openwrt
cd openwrt
OPENWRT_PATH=$(pwd)

./scripts/feeds update -a
./scripts/feeds install -a

cp $GITHUB_WORKSPACE/$CONFIG_FILE $OPENWRT_PATH/.config

$GITHUB_WORKSPACE/$DIY_SCRIPT
$GITHUB_WORKSPACE/scripts/preset-clash-core.sh $CLASH_KERNEL
$GITHUB_WORKSPACE/scripts/preset-terminal-tools.sh
$GITHUB_WORKSPACE/scripts/preset-adguard-core.sh $CLASH_KERNEL
make defconfig
make download -j8

mkdir -p files/etc/uci-defaults
cp $GITHUB_WORKSPACE/scripts/init-settings.sh files/etc/uci-defaults/99-init-settings

make -j8
