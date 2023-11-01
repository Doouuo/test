#!/bin/bash

while true; do
    echo "请选择要执行的脚本："
    echo "1. 下载更新依赖"
    echo "2. 下载项目"
    echo "3. 开启所有端口"
    echo "4. 请返回主目录，下载官方快照"
    echo "5. 编译运行"
    echo "6. 安装代理"
    echo "7. 退出"

    # 获取用户输入
    read -p "请输入选项(1/2/3/4): " choice

    case $choice in
        1)
            echo "执行脚本1..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install screen nano
            sudo apt install snapd
            sudo snap install go --classic
            sudo apt install git make
            echo -e "\e[31m执行完成\e[0m"
            ;;
        2)
            echo "执行脚本2..."
            git clone https://github.com/dominant-strategies/go-quai.git
            cd go-quai
            git checkout v0.19.4
             echo -e "\e[31m执行完成\e[0m"
            ;;
        3)
            echo "执行脚本3..."
            iptables -P INPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -F
            iptables-save
            apt-get install iptables-persistent
            netfilter-persistent save
            netfilter-persistent reload
            echo -e "\e[31m执行完成\e[0m"
            ;;
        4)  
            echo "执行脚本4..."
            wget https://archive.quai.network/quai_colosseum_backup.tar.gz
            tar -zxvf quai_colosseum_backup.tar.gz
            cp -r quai_colosseum_backup ~/.quai
            echo -e "\e[31m执行完成\e[0m"
            ;;
        5)  
            echo "执行脚本5..."
            cd go-quai
            make go-quai
            make run 
            echo -e "\e[31m执行完成\e[0m"
            ;;

        6)  
            echo "执行脚本6..."
            git clone https://github.com/dominant-strategies/go-quai-stratum.git
            cd go-quai-stratum
            git checkout v0.9.0-rc.0
            cp config/config.example.json config/config.json
            make quai-stratum
            ;;
        7)
            echo "退出..."
            exit 0
            ;;
        *)
            echo "无效的选项!"
            ;;
    esac

    echo "脚本执行完毕"
    echo "---------------------------------------"
done
