# leonBlog-deploy

leonBlog 一键部署工具，提供交互式初始化脚本和 Docker Compose 配置。

## 功能特性

- 🤖 交互式初始化脚本（类似 oh-my-zsh）
- 🐳 Docker Compose 一键部署
- 📦 自动拉取最新镜像（多平台支持）
- 📝 自动创建数据目录和 Git 仓库
- ⚙️ 自动生成配置文件

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/makitara/leonBlog-deploy.git
cd leonBlog-deploy
```

### 2. 运行初始化脚本

```bash
./init.sh
```

脚本会引导你填写：
- 用户名
- 邮箱
- 个人简介
- 博客 URL
- 端口配置

### 3. 启动服务

```bash
docker-compose up -d
```

### 4. 访问博客

- 前端：http://localhost:3000
- 后端 API：http://localhost:8080/api

## 项目结构

```
leonBlog-deploy/
├── docker-compose.yml    # Docker Compose 配置
├── init.sh               # 交互式初始化脚本
├── .env.example          # 环境变量模板
├── .env                  # 环境变量（init.sh 生成）
└── data/                 # 数据目录（Git 仓库）
    ├── profile.json      # 个人资料
    ├── articles/         # 文章目录
    └── assets/           # 静态资源
```

## 管理内容

### 添加文章

在 `data/articles/` 目录下创建 `.md` 文件：

```markdown
---
id: my-article
title: 我的文章
publishDate: 2024-11-23
---
# 我的文章

文章内容...
```

### 更新个人资料

编辑 `data/profile.json`：

```json
{
  "id": "user-id",
  "username": "用户名",
  "avatar": "assets/avatar.jpg",
  "bio": "个人简介",
  "email": "email@example.com"
}
```

### 同步数据

数据目录是一个 Git 仓库，你可以：

```bash
cd data
git add .
git commit -m "Update content"
git push origin main
```

## 常用命令

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps
```

## 配置说明

### 环境变量

编辑 `.env` 文件来修改配置：

```bash
# 博客基础 URL
BLOG_BASE_URL=http://localhost:8080

# 端口配置
BACKEND_PORT=8080
FRONTEND_PORT=3000
```

### 镜像地址

默认使用以下镜像：
- 后端：`ghcr.io/makitara/leonblog-be:latest`
- 前端：`ghcr.io/makitara/leonblog-fe:latest`

如需使用其他镜像，修改 `docker-compose.yml` 中的 `image` 字段。

## 故障排查

### 服务无法启动

1. 检查 Docker 是否运行：`docker ps`
2. 查看日志：`docker-compose logs`
3. 检查端口是否被占用

### 无法访问前端

1. 检查前端容器是否运行：`docker-compose ps`
2. 检查端口映射是否正确
3. 查看前端日志：`docker-compose logs frontend`

### API 请求失败

1. 检查后端容器是否运行：`docker-compose ps`
2. 检查数据目录是否正确挂载
3. 查看后端日志：`docker-compose logs backend`

## 更新服务

当项目发布新版本时，你需要手动拉取最新镜像并重启服务：

```bash
# 拉取最新镜像
docker-compose pull

# 重启服务（使用新镜像）
docker-compose up -d
```

或者使用一条命令：

```bash
docker-compose pull && docker-compose up -d
```

**注意**：`docker-compose up -d` 不会自动拉取最新镜像，它只会使用本地已有的镜像。因此更新时必须先执行 `docker-compose pull`。

## 备份数据

数据目录 `data/` 是一个 Git 仓库，建议：

1. 在 GitHub 创建私有仓库
2. 添加远程仓库：
   ```bash
   cd data
   git remote add origin https://github.com/yourusername/blog-data.git
   git push -u origin main
   ```
3. 定期提交和推送更改

## 许可证

MIT

