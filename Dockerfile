# 第一阶段：构建阶段
FROM node:20.18.0-alpine AS builder
LABEL authors="Lei"

# 设置工作目录
WORKDIR /app

ENV ADMIN_USER=admin
ENV ADMIN_PASSWORD=password
ENV ADMIN_EMAIL=admin@qq.com
ENV JWT_SECRET=password
ENV POSTGRES_USER=aipan
ENV POSTGRES_PASSWORD=aipan
ENV POSTGRES_DB=aipan
ENV DATABASE_URL=postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@aipan-db:5432/$POSTGRES_DB
ENV SHADOW_DATABASE_URL=postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@aipan-db:5432/${POSTGRES_DB}_shadow

# 安装 pnpm
RUN npm install -g pnpm

# 复制 package.json 和 pnpm-lock.yaml（或 package-lock.json，如果有）
COPY package*.json ./

# 安装构建依赖
RUN pnpm install

# 复制所有项目文件
COPY . .

# 生成 Prisma 客户端（不执行数据库迁移）
RUN npx prisma generate

# 构建 Nuxt.js 项目
RUN npm run build

# 第二阶段：运行阶段
FROM node:20.18.0-alpine
LABEL authors="Lei"

# 设置工作目录
WORKDIR /app

# 复制构建后的项目文件
COPY --from=builder /app/.output .output
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/package.json package.json

# 复制 prisma schema 文件
COPY --from=builder /app/prisma /app/prisma

# 复制启动脚本
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 设置公共的环境变量
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

# 暴露端口
EXPOSE 3000

# 使用启动脚本作为启动命令
CMD ["/app/start.sh"]