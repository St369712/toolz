#!/bin/bash

print_help () {
  echo "Usage: toolz [-f] [-s] [-p] [-u] [-h]"
  echo " -f : Find Helper"
  echo " -s : System Information"
  echo " -p : Process Mangement"
  echo " -u : User Mangement"
  echo " -h : Help"
  exit 1
}

find_helper() {
  echo "Find Helper"
  read -p "Enter directory path (default: projectone): " dir
  dir=${dir:-projectone}
  if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    return 1
  fi
  read -p "Enter filename pattern (e.g., *.txt or *.sh): " pattern
  while true; do
    read -p "Enter file type (f = regular file, d = directory, leave blank to skip): " type
    if [[ -z "$type" || "$type" == "f" || "$type" == "d" ]]; then
      break
    else
      echo "Invalid input. Please enter 'f', 'd', or leave blank."
    fi
  done
  cmd="find \"$dir\""
  if [ -n "$pattern" ]; then
    cmd+=" -name \"$pattern\""
  fi
  if [ -n "$type" ]; then
    cmd+=" -type $type"
  fi
  echo "Running: $cmd"
  echo
  eval $cmd
}

system_info() {
  echo "System Information"
  echo "Memory"
  free -h | awk '/^Mem:/ {print "Used: "$3", Free: "$4", Total: "$2}'
  echo "--- Running Processes ---"
  ps -e --no-headers | wc -l
  echo "--- Disk Usage ---"
  df -h | grep "^/dev/" | awk '{print $1 " - Used: "$3 ", Available: "$4 ", Mounted on: "$6}'
  echo "=========================="
}

process_management() {
  echo "Process Management"
  echo "1. Show top CPU processes"
  echo "2. Show top memory processes"
  echo "3. Show longest-running processes"
  read -p "Choose an option (1-3): " choice
  case $choice in
    1) ps aux --sort=-%cpu | head -n 10 ;;
    2) ps aux --sort=-%mem | head -n 10 ;;
    3) ps -eo pid,etime,cmd --sort=etime | head -n 10 ;;
    *) echo "Invalid choice" ;;
  esac
  read -p "Enter PID to kill (or leave blank): " pid
  if [[ -n "$pid" ]]; then
    kill "$pid" && echo "Process $pid killed" || echo "Failed to kill process"
  fi
}

user_management() {
  echo "User Management"
  echo "1. Show currently logged-in users"
  echo "2. Show user account information"
  echo "3. Show login history"
  read -p "Choose an option (1-3): " opt
  case $opt in
    1) who ;;
    2)
      read -p "Enter username: " uname
      id "$uname" && getent passwd "$uname"
      ;;
    3) last -a | head -n 10 ;;
    *) echo "Invalid option" ;;
  esac
}

# ניתוח הדגלים
while getopts "fspuh" opt; do
  case $opt in
    f) find_helper ;;
    s) system_info ;;
    p) process_management ;;
    u) user_management ;;
    h) print_help ;;
    *) print_help ;;
  esac
done

# אם לא סופק אף דגל
if [ $OPTIND -eq 1 ]; then
  usage
fi



