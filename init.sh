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
    print_info "检查依赖..."
    
    if ! command -v docker &> /dev/null; then
        print_error "❌ Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "❌ Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    print_success "✅ 依赖检查通过"
}

# 收集用户信息
collect_user_info() {
    print_info "\n📝 请填写以下信息：\n"
    
    read -p "用户名 (Username): " USERNAME
    while [ -z "$USERNAME" ]; do
        print_warning "用户名不能为空"
        read -p "用户名 (Username): " USERNAME
    done
    
    read -p "邮箱 (Email): " EMAIL
    while [ -z "$EMAIL" ]; do
        print_warning "邮箱不能为空"
        read -p "邮箱 (Email): " EMAIL
    done
    
    read -p "个人简介 (Bio) [可选]: " BIO
    BIO=${BIO:-"Code for fun"}
    
    read -p "博客基础 URL [http://localhost:8080]: " BASE_URL
    BASE_URL=${BASE_URL:-http://localhost:8080}
    
    read -p "后端端口 [8080]: " BACKEND_PORT
    BACKEND_PORT=${BACKEND_PORT:-8080}
    
    read -p "前端端口 [3000]: " FRONTEND_PORT
    FRONTEND_PORT=${FRONTEND_PORT:-3000}
}

# 生成 .env 文件
generate_env_file() {
    print_info "生成 .env 文件..."
    
    cat > .env << EOF
# Blog Configuration
BLOG_BASE_URL=${BASE_URL}

# Port Configuration
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
EOF
    
    print_success "✅ .env 文件已生成"
}

# 生成 profile.json
generate_profile_json() {
    print_info "生成 profile.json..."
    
    mkdir -p data
    
    # 生成用户 ID（小写用户名）
    USER_ID=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    cat > data/profile.json << EOF
{
  "id": "${USER_ID}",
  "username": "${USERNAME}",
  "avatar": "assets/avatar.jpg",
  "bio": "${BIO}",
  "email": "${EMAIL}"
}
EOF
    
    print_success "✅ profile.json 已生成"
}

# 创建目录结构
create_directory_structure() {
    print_info "创建目录结构..."
    
    mkdir -p data/articles
    mkdir -p data/assets
    
    print_success "✅ 目录结构已创建"
}

# 创建示例文章
create_sample_article() {
    if [ ! -f "data/articles/welcome.md" ]; then
        print_info "创建示例文章..."
        
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
        
        print_success "✅ 示例文章已创建"
    fi
}

# 初始化 Git 仓库
init_git_repo() {
    if [ ! -d "data/.git" ]; then
        print_info "初始化 Git 仓库..."
        
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
        
        print_success "✅ Git 仓库已初始化"
        print_warning "💡 提示：你可以将 data 目录推送到远程 Git 仓库进行备份"
    fi
}

# 验证配置
validate_config() {
    print_info "验证配置..."
    
    if [ ! -f ".env" ]; then
        print_error "❌ .env 文件不存在"
        return 1
    fi
    
    if [ ! -f "data/profile.json" ]; then
        print_error "❌ profile.json 不存在"
        return 1
    fi
    
    if [ ! -d "data/articles" ]; then
        print_error "❌ articles 目录不存在"
        return 1
    fi
    
    print_success "✅ 配置验证通过"
}

# 主函数
main() {
    clear
    print_info "╔════════════════════════════════════════╗"
    print_info "║      🤖 leonBlog 部署初始化工具       ║"
    print_info "╚════════════════════════════════════════╝"
    echo
    
    # 检查是否已初始化
    if [ -f ".env" ]; then
        print_warning "⚠️  检测到已有配置文件"
        read -p "是否重新初始化？(y/N): " REINIT
        if [ "$REINIT" != "y" ] && [ "$REINIT" != "Y" ]; then
            print_info "跳过初始化..."
            exit 0
        fi
    fi
    
    check_dependencies
    collect_user_info
    
    echo
    print_info "开始初始化..."
    echo
    
    generate_env_file
    create_directory_structure
    generate_profile_json
    create_sample_article
    init_git_repo
    
    echo
    if validate_config; then
        print_success "╔════════════════════════════════════════╗"
        print_success "║         ✅ 初始化完成！                ║"
        print_success "╚════════════════════════════════════════╝"
        echo
        print_info "下一步："
        echo "  1. 运行 'docker-compose up -d' 启动服务"
        echo "  2. 访问 http://localhost:${FRONTEND_PORT} 查看博客"
        echo "  3. 编辑 data/ 目录下的文件来管理内容"
        echo
    else
        print_error "❌ 初始化失败，请检查错误信息"
        exit 1
    fi
}

# 运行主函数
main

