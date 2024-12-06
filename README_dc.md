# 爱盘docker部署
1. 创建.env, 配置环境变量
```bash
cp .env.example .env
```
2. docker-compose.yml
```dockerfile
services:
  aipan:
    image: ghcr.io/longfengpili/aipan:latest
    container_name: aipan-app
    restart: always # 确保容器在停止后自动重启
    ports:
      - "3000:3000" # 映射容器的 3000 端口到宿主机的 3000 端口
    env_file:
      - .env
    depends_on:
      postgres:
        condition: service_healthy 

  postgres:
    image: postgres:latest
    container_name: aipan-db
    restart: always
    expose:
      - 5432
    # ports:
    #   - 5432:5432
    volumes:
       - ./data:/var/lib/postgresql/data
    env_file:
       - .env
    healthcheck:
       test: ['CMD-SHELL', 'pg_isready -d ${POSTGRES_DB} -U ${POSTGRES_USER}']
       interval: 10s
       timeout: 5s
       retries: 5

```
3. 创建数据库本地路径
```bash
mkdir data
```
4. 启动容器
```bash
docker-compose up -d
```
5. 访问页面
+ 首页： http://host:3000
+ admin: http://host:3000/login