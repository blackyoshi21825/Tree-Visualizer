#!/bin/bash

# Fire Tree Visualizer - Cross-platform directory tree with fire theme
# Works on Mac, Linux, and Windows (Git Bash/WSL)

# Options
SHOW_SIZE=false
SHOW_COUNT=false
SHOW_TOTAL=false
SORT_BY="name"
TOTAL_SIZE=0

# Fire colors using ANSI escape codes
RED='\033[91m'
ORANGE='\033[93m'
YELLOW='\033[93m'
RESET='\033[0m'

# Fire emojis and symbols
FIRE="🔥"
FOLDER="📁"

# Tree drawing characters
BRANCH="├── "
LAST_BRANCH="└── "
VERTICAL="│   "
SPACE="    "

print_fire_header() {
    echo -e "${RED}${ORANGE}FOLDER TREE VISUALIZER ${RESET}"
    echo ""
}

format_size() {
    local size=$1
    if [[ $size -lt 1024 ]]; then
        echo "${size}B"
    elif [[ $size -lt 1048576 ]]; then
        echo "$((size/1024))K"
    else
        echo "$((size/1048576))M"
    fi
}

get_file_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$1" 2>/dev/null || echo 0
    else
        stat -c%s "$1" 2>/dev/null || echo 0
    fi
}

count_items() {
    local dir="$1"
    local files=0
    local dirs=0
    
    while IFS= read -r -d '' item; do
        local basename=$(basename "$item")
        if [[ -d "$item" && ("$basename" == ".git" || "$basename" == "node_modules" || "$basename" == "__pycache__" || "$basename" == "build" || "$basename" == "dist" || "$basename" == ".vscode" ) ]]; then
            continue
        fi
        if [[ -d "$item" ]]; then
            ((dirs++))
        else
            ((files++))
        fi
    done < <(find "$dir" -maxdepth 1 -not -path "$dir" -print0 2>/dev/null)
    
    echo "$files $dirs"
}

calculate_total_size() {
    local dir="$1"
    find "$dir" -type f \(! "$basename" == ".git" ! -path "*/node_modules/*" ! -path "*/__pycache__/*" ! -path "*/build/*" ! -path "*/dist/*" ! -path "*/.vscode/*" \) -exec stat -c%s {} + 2>/dev/null | awk '{sum+=$1} END {print sum+0}'
}

draw_tree() {
    local dir="$1"
    local prefix="$2"
    local is_last="$3"
    
    # Get all items in directory
    local items=()
    while IFS= read -r -d '' item; do
        local basename=$(basename "$item")
        # Skip excluded folders
        if [[ -d "$item" && ("$basename" == ".git" || "$basename" == "node_modules" || "$basename" == "__pycache__" || "$basename" == "build" || "$basename" == "dist" || "$basename" == ".vscode" ) ]]; then
            continue
        fi
        items+=("$item")
    done < <(find "$dir" -maxdepth 1 -not -path "$dir" -print0 2>/dev/null | 
        if [[ "$SORT_BY" == "size" ]]; then
            while IFS= read -r -d '' item; do
                if [[ -f "$item" ]]; then
                    size=$(get_file_size "$item")
                    printf "%010d\0%s\0" "$size" "$item"
                else
                    printf "%010d\0%s\0" "0" "$item"
                fi
            done | sort -z -n | cut -d$'\0' -f2-
        else
            sort -z
        fi)
    
    local count=${#items[@]}
    local i=0
    
    for item in "${items[@]}"; do
        i=$((i + 1))
        local basename=$(basename "$item")
        local is_last_item=$([[ $i -eq $count ]] && echo true || echo false)
        
        if [[ -d "$item" ]]; then
            # Directory
            local dir_info=""
            if $SHOW_COUNT; then
                local counts=($(count_items "$item"))
                dir_info=" (${counts[0]}f, ${counts[1]}d)"
            fi
            
            if $is_last_item; then
                echo -e "${prefix}${LAST_BRANCH}${YELLOW}${FOLDER} ${basename}/${dir_info}${RESET}"
                draw_tree "$item" "${prefix}${SPACE}" true
            else
                echo -e "${prefix}${BRANCH}${YELLOW}${FOLDER} ${basename}/${dir_info}${RESET}"
                draw_tree "$item" "${prefix}${VERTICAL}" false
            fi
        else
            # File
            local file_color="${ORANGE}"
            local file_emoji="📄"
            case "${basename##*.}" in
                sh|bash|zsh) file_color="${RED}"; file_emoji="🔥" ;;
                py) file_color="${YELLOW}"; file_emoji="🐍" ;;
                js|ts) file_color="${YELLOW}"; file_emoji="⚡" ;;
                c|h) file_color="${YELLOW}"; file_emoji="🔧" ;;
                cpp|cc|cxx) file_color="${YELLOW}"; file_emoji="🔧" ;;
                java) file_color="${YELLOW}"; file_emoji="☕" ;;
                php) file_color="${YELLOW}"; file_emoji="🐘" ;;
                rb) file_color="${YELLOW}"; file_emoji="💎" ;;
                go) file_color="${YELLOW}"; file_emoji="🐹" ;;
                rs) file_color="${YELLOW}"; file_emoji="🦀" ;;
                swift) file_color="${YELLOW}"; file_emoji="🦉" ;;
                kt) file_color="${YELLOW}"; file_emoji="🎯" ;;
                html|htm) file_emoji="🌐" ;;
                css) file_emoji="🎨" ;;
                json) file_emoji="📋" ;;
                xml) file_emoji="📰" ;;
                md) file_color="${ORANGE}"; file_emoji="📝" ;;
                txt) file_color="${ORANGE}"; file_emoji="📄" ;;
                pdf) file_emoji="📕" ;;
                doc|docx) file_emoji="📘" ;;
                xls|xlsx) file_emoji="📗" ;;
                ppt|pptx) file_emoji="📙" ;;
                zip|tar|gz|rar) file_emoji="📦" ;;
                jpg|jpeg|png|gif|bmp) file_emoji="🖼️" ;;
                mp3|wav|flac) file_emoji="🎵" ;;
                mp4|avi|mkv) file_emoji="🎬" ;;
                exe|app) file_emoji="⚙️" ;;
                log) file_emoji="📊" ;;
            esac
            
            local file_info=""
            if $SHOW_SIZE; then
                local size=$(get_file_size "$item")
                file_info=" ($(format_size $size))"
                if $SHOW_TOTAL; then
                    TOTAL_SIZE=$((TOTAL_SIZE + size))
                fi
            elif $SHOW_TOTAL; then
                local size=$(get_file_size "$item")
                TOTAL_SIZE=$((TOTAL_SIZE + size))
            fi
            
            if $is_last_item; then
                echo -e "${prefix}${LAST_BRANCH}${file_color}${file_emoji} ${basename}${file_info}${RESET}"
            else
                echo -e "${prefix}${BRANCH}${file_color}${file_emoji} ${basename}${file_info}${RESET}"
            fi
        fi
    done
}

# Parse arguments
start_dir="."
while [[ $# -gt 0 ]]; do
    case $1 in
        --size) SHOW_SIZE=true; shift ;;
        --count) SHOW_COUNT=true; shift ;;
        --total) SHOW_TOTAL=true; shift ;;
        --sort) SORT_BY="$2"; shift 2 ;;
        -*) echo "Unknown option: $1"; exit 1 ;;
        *) start_dir="$1"; shift ;;
    esac
done

# Main execution
print_fire_header
if [[ ! -d "$start_dir" ]]; then
    echo -e "${RED}Error: Directory '$start_dir' not found!${RESET}"
    exit 1
fi

echo -e "${RED}${FIRE}${RESET} $(basename "$(realpath "$start_dir")")/"
draw_tree "$start_dir" "" true

if $SHOW_TOTAL; then
    echo -e "\n${ORANGE}📊 Total size: $(format_size $TOTAL_SIZE)${RESET}"
fi

echo ""