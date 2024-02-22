#!/bin/bash

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to restart Mongoser
restart_mongoser() {
    echo -e "${YELLOW}Restarting Mongoser...${NC}"
    free -h
    /usr/safetrax/startup/mongoser restart
}

# Function to restart Mongod and Raptor
restart_mongod_raptor() {
    echo -e "${YELLOW}Restarting Mongod, Mongoser, and Raptor...${NC}"
    pkill mongod
    local ram_size=$(free -g | awk '/^Mem:/{print $2}')
    local cache_size=0

    if [[ $ram_size -lt 13 ]]; then
        cache_size=$(awk "BEGIN {printf \"%.2f\", $ram_size * 0.25}")
    elif [[ $ram_size -ge 40 ]]; then
        cache_size=$(awk "BEGIN {printf \"%.2f\", $ram_size * 0.15}")
    else
        cache_size=$(awk "BEGIN {printf \"%.2f\", $ram_size * 0.20}")
    fi

    echo "Calculated cache size for $ram_size GB RAM: $cache_size GB"
    
    nohup mongod --master --dbpath /usr/safetrax/var/lib/mongo/ --wiredTigerCacheSizeGB "$cache_size" >> /usr/safetrax/var/log/mongodb/mongod.log 2>&1 &
    nohup mongod --master --dbpath /var/lib/mongo/ --wiredTigerCacheSizeGB "$cache_size" >> /var/log/mongodb/mongod.log 2>&1 &
    restart_mongoser
    /usr/safetrax/startup/raptor restart
}

# Function to print number of cores
print_core_count() {
    echo -e "${YELLOW}Number of cores: ${NC}$(grep -c ^processor /proc/cpuinfo)"
}

# Function to display top 5 CPU processes
top_cpu_processes() {
    echo -e "${YELLOW}Top 5 CPU Processes:${NC}"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
}

# Function to display top 5 memory-consuming processes
top_memory_processes() {
    echo -e "${YELLOW}Top 5 Memory-consuming Processes:${NC}"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -6
}

# Main menu
while :
do
    echo -e "${GREEN}Menu:${NC}"
    echo "1. Mongoser restart"
    echo "2. Mongod, Mongoser, Raptor restart"
    echo "3. Print number of cores"
    echo "4. Top 5 CPU processes"
    echo "5. Top 5 memory-taking processes"
    echo "6. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) restart_mongoser;;
        2) restart_mongod_raptor;;
        3) print_core_count;;
        4) top_cpu_processes;;
        5) top_memory_processes;;
        6) exit;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}";;
    esac
    echo ""
done
