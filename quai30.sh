#!/bin/bash

# 在出错时退出脚本
set -e

# 记录脚本开始时间
start_time=$(date +"%T")
echo "Script started at $start_time"

# 更新和升级Ubuntu软件包
sudo apt update && sudo apt upgrade -y

# 安装必要的软件包
sudo apt install -y git cmake build-essential mesa-common-dev screen nano

# 检查git命令是否存在
if ! command -v git &> /dev/null; then
    echo "git is not installed. Exiting."
    exit 1
fi

# 克隆指定的git仓库并进入相应目录
REPO_DIR="quai-gpu-miner"
if [ ! -d "$REPO_DIR" ]; then
    git clone https://github.com/dominant-strategies/quai-gpu-miner.git
fi
cd $REPO_DIR

# 更新git子模块
git submodule update --init --recursive

FILE_PATH="./libethash-cuda/CMakeLists.txt"

# 使用sed命令替换内容
sed -i.bak '/list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_30,code=sm_30")/{
N;N;N;N;N;N;N;N;
s/list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_30,code=sm_30")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_35,code=sm_35")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_50,code=sm_50")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_52,code=sm_52")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_53,code=sm_53")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_60,code=sm_60")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_61,code=sm_61")\
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_62,code=sm_62")/\
    list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_89,code=sm_89")\
    list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_86,code=sm_86")\
    list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_80,code=sm_80")/}' $FILE_PATH

# 删除备份文件
rm $FILE_PATH.bak

echo "File has been modified successfully!"

echo "-------------------------"
echo -e "\e[31mCurrent Directory: $(pwd)\e[0m"
echo "-------------------------"

# 文件路径
FILE_PATH1="./ethcoreminer/main.cpp"

# 要注释的行的内容
TARGET_LINE_CONTENT="signal(SIGSEGV, MinerCLI::signalHandler);"

# 使用sed命令注释指定内容的行
sed -i "/${TARGET_LINE_CONTENT}/s/^/\/\// " $FILE_PATH1


echo "Line containing '$TARGET_LINE_CONTENT' has been commented in $FILE_PATH1"


# 定义文件路径
FILE_PATH2="./CMakeLists.txt"  # 请将 path_to_your_file 替换为实际的文件路径

# 使用sed命令进行替换
sed -i 's/option(ETHASHCUDA "Build with CUDA mining" OFF)/option(ETHASHCUDA "Build with CUDA mining" ON)/' $FILE_PATH2

echo "Content has been replaced successfully in $FILE_PATH2"



# 创建build目录并进入
BUILD_DIR="build"
if [ ! -d "$BUILD_DIR" ]; then
    mkdir $BUILD_DIR
fi
cd $BUILD_DIR

# 运行cmake命令
cmake .. && cmake --build .

echo "-------------------------"
echo -e "\e[31mCurrent Directory: $(pwd)\e[0m"
echo "-------------------------"

# 创建test.sh文件
TEST_SCRIPT="test.sh"
if [ ! -f "$TEST_SCRIPT" ]; then
    echo "#!/bin/bash
    while [ 1 ];
    do
        sleep 2
        ./ethcoreminer/ethcoreminer -P stratum://47.253.41.254:3333 -L 1 && break
    done" > $TEST_SCRIPT
fi

# 使test.sh可执行
chmod +x $TEST_SCRIPT

# 使用screen命令
if command -v screen &> /dev/null; then
    screen -R gpu
else
    echo "screen is not installed. Skipping."
fi

# 记录脚本结束时间
end_time=$(date +"%T")
echo "Script finished at $end_time"
