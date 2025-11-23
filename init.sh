#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${2}${1}${NC}"
}

print_success() {
    print_message "$1" "$GREEN"
}

print_error() {
    print_message "$1" "$RED"
}

print_warning() {
    print_message "$1" "$YELLOW"
}

print_info() {
    print_message "$1" "$BLUE"
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖 / Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "[X] Docker 未安装，请先安装 Docker / Docker not installed, please install Docker first"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "[X] Docker Compose 未安装，请先安装 Docker Compose / Docker Compose not installed, please install Docker Compose first"
        exit 1
    fi
    
    print_success "[OK] 依赖检查通过 / Dependencies check passed"
}

# 收集用户信息
collect_user_info() {
    print_info "\n[*] 请填写以下信息 / Please fill in the following information:\n"
    
    read -p "用户名 / Username: " USERNAME
    while [ -z "$USERNAME" ]; do
        print_warning "[!] 用户名不能为空 / Username cannot be empty"
        read -p "用户名 / Username: " USERNAME
    done
    
    read -p "邮箱 / Email: " EMAIL
    while [ -z "$EMAIL" ]; do
        print_warning "[!] 邮箱不能为空 / Email cannot be empty"
        read -p "邮箱 / Email: " EMAIL
    done
    
    read -p "个人简介 / Bio [可选，直接回车使用默认值 'Code for fun' / Optional, press Enter for default 'Code for fun']: " BIO
    BIO=${BIO:-"Code for fun"}
    
    echo ""
    print_info "[*] 博客基础 URL 说明 / Blog Base URL Explanation:"
    echo "  本地开发: http://localhost:8080"
    echo "  生产环境: https://your-domain.com 或 https://api.your-domain.com"
    echo "  用于生成头像等资源的绝对 URL"
    echo "  For local development: http://localhost:8080"
    echo "  For production: https://your-domain.com or https://api.your-domain.com"
    echo "  Used to generate absolute URLs for resources like avatars"
    echo ""
    read -p "博客基础 URL / Blog Base URL [直接回车使用默认值 http://localhost:8080 / Press Enter for default http://localhost:8080]: " BASE_URL
    BASE_URL=${BASE_URL:-http://localhost:8080}
    
    echo ""
    read -p "你希望前端运行在本机哪个端口？/ Which port do you want the frontend to run on? [直接回车使用默认值 3000 / Press Enter for default 3000]: " FRONTEND_PORT
    FRONTEND_PORT=${FRONTEND_PORT:-3000}
    
    read -p "你希望后端运行在本机哪个端口？/ Which port do you want the backend to run on? [直接回车使用默认值 8080 / Press Enter for default 8080]: " BACKEND_PORT
    BACKEND_PORT=${BACKEND_PORT:-8080}
}

# 生成 .env 文件
generate_env_file() {
    print_info "生成 .env 文件 / Generating .env file..."
    
    cat > .env << EOF
# Blog Configuration
BLOG_BASE_URL=${BASE_URL}

# Port Configuration
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
EOF
    
    print_success "[OK] .env 文件已生成 / .env file generated"
}

# 生成 profile.json
generate_profile_json() {
    print_info "生成 profile.json / Generating profile.json..."
    
    mkdir -p data
    
    # 生成用户 ID（小写用户名）
    USER_ID=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    cat > data/profile.json << EOF
{
  "id": "${USER_ID}",
  "username": "${USERNAME}",
  "avatar": "",
  "bio": "${BIO}",
  "email": "${EMAIL}"
}
EOF
    
    print_success "[OK] profile.json 已生成 / profile.json generated"
}

# 创建目录结构
create_directory_structure() {
    print_info "创建目录结构 / Creating directory structure..."
    
    mkdir -p data/articles
    mkdir -p data/assets
    
    print_success "[OK] 目录结构已创建 / Directory structure created"
}

# 创建示例文章
create_sample_article() {
    if [ ! -f "data/articles/welcome.md" ]; then
        print_info "创建示例文章 / Creating sample article..."
        
        cat > data/articles/welcome.md << 'EOF'
---
id: welcome
title: Welcome to MyBlog
publishDate: 2024-11-23
---
# Welcome to MyBlog

欢迎使用 leonBlog！

这是你的第一篇文章。你可以编辑 `data/articles/welcome.md` 来修改这篇文章，或者创建新的文章。

## 如何添加新文章

1. 在 `data/articles/` 目录下创建新的 `.md` 文件
2. 在文件开头添加 Front Matter（可选）：
   ```markdown
   ---
   id: article-id
   title: 文章标题
   publishDate: 2024-11-23
   ---
   ```
3. 然后写你的文章内容

## Front Matter 说明

- `id`: 文章 ID（如果不提供，将使用文件名）
- `title`: 文章标题（如果不提供，将使用第一个标题或文件名）
- `publishDate`: 发布日期（如果不提供，将使用文件修改日期）

祝你使用愉快！
EOF
        
        print_success "[OK] 示例文章已创建 / Sample article created"
    fi
}

# 初始化 Git 仓库
init_git_repo() {
    if [ ! -d "data/.git" ]; then
        print_info "初始化 Git 仓库 / Initializing Git repository..."
        
        cd data
        git init -b main
        git config user.name "${USERNAME}" || git config user.name "Blog User"
        git config user.email "${EMAIL}" || git config user.email "blog@example.com"
        
        # 创建 .gitignore
        cat > .gitignore << 'EOF'
.DS_Store
*.log
EOF
        
        git add .
        git commit -m "Initial commit: blog data"
        cd ..
        
        print_success "[OK] Git 仓库已初始化 / Git repository initialized"
        print_warning "[!] 提示 / Tip: 你可以将 data 目录推送到远程 Git 仓库进行备份 / You can push the data directory to a remote Git repository for backup"
    fi
}

# 验证配置
validate_config() {
    print_info "验证配置 / Validating configuration..."
    
    if [ ! -f ".env" ]; then
        print_error "[X] .env 文件不存在 / .env file does not exist"
        return 1
    fi
    
    if [ ! -f "data/profile.json" ]; then
        print_error "[X] profile.json 不存在 / profile.json does not exist"
        return 1
    fi
    
    if [ ! -d "data/articles" ]; then
        print_error "[X] articles 目录不存在 / articles directory does not exist"
        return 1
    fi
    
    print_success "[OK] 配置验证通过 / Configuration validation passed"
}

# 主函数
main() {
    clear
    print_info "=========================================="
    print_info "   leonBlog Deployment Initialization"
    print_info "   leonBlog 部署初始化工具"
    print_info "=========================================="
    echo
    
    # 检查是否已初始化
    if [ -f ".env" ]; then
        print_warning "[!] 检测到已有配置文件 / Configuration file already exists"
        read -p "是否重新初始化？/ Reinitialize? (y/N): " REINIT
        if [ "$REINIT" != "y" ] && [ "$REINIT" != "Y" ]; then
            print_info "跳过初始化 / Skipping initialization..."
            exit 0
        fi
    fi
    
    check_dependencies
    collect_user_info
    
    echo
    print_info "开始初始化 / Starting initialization..."
    echo
    
    generate_env_file
    create_directory_structure
    generate_profile_json
    create_sample_article
    init_git_repo
    
    echo
    if validate_config; then
        print_success "=========================================="
        print_success "   [OK] 初始化完成！/ Initialization Complete!"
        print_success "=========================================="
        echo
        print_info "下一步 / Next Steps:"
        echo "  1. 运行 'docker-compose up -d' 启动服务 / Run 'docker-compose up -d' to start services"
        echo "  2. 访问 http://localhost:${FRONTEND_PORT} 查看博客 / Visit http://localhost:${FRONTEND_PORT} to view your blog"
        echo ""
        print_warning "[!] 重要提示 / Important Notes:"
        echo "  - 上传头像: 将头像图片放到 data/assets/ 目录，然后编辑 data/profile.json 中的 'avatar' 字段"
        echo "    Upload avatar: Place your avatar image in data/assets/, then edit the 'avatar' field in data/profile.json"
        echo "  - 修改个人资料: 编辑 data/profile.json 文件"
        echo "    Edit profile: Edit the data/profile.json file"
        echo "  - 添加文章: 在 data/articles/ 目录下创建 .md 文件"
        echo "    Add articles: Create .md files in the data/articles/ directory"
        echo ""
    else
        print_error "[X] 初始化失败，请检查错误信息 / Initialization failed, please check error messages"
        exit 1
    fi
}

# 运行主函数
main

