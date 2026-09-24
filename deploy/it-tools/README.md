# IT-Tools（tools.prb9.top）

轻量开发者工具箱：[CorentinTh/it-tools](https://github.com/CorentinTh/it-tools)。  
几乎是静态前端，2G 机器上很省。

## 当前部署（VPS）

- 目录：`/opt/it-tools/`（`Dockerfile` + `docker-compose.yml`）
- 镜像：基于 `corentinth/it-tools:latest` 构建为 `pixel-home/it-tools:zh`（**默认中文**）
- 监听：`127.0.0.1:8788`
- 公网：Cloudflare Tunnel `prb9` 远程 ingress  
  `tools.prb9.top` → `http://localhost:8788`

官方自带 `zh` 语言包；Dockerfile 把默认 `locale:"en"` 改成 `locale:"zh"`。  
页面右上角语言选择器仍可切回 English 等。

> 该隧道在 Zero Trust 里是**远程管理**的：改 `/etc/cloudflared/config.yml` 会被 dashboard 配置覆盖。  
> 增删 hostname 请在 Cloudflare One → Networks → Tunnels → `prb9` → Public Hostname，或用 API 更新 tunnel configuration。

### 启停 / 更新

```bash
cd /opt/it-tools
docker compose build --pull
docker compose up -d
docker compose ps
curl -sI http://127.0.0.1:8788/   # 应 200
```

### 本仓库一键启动（新机器）

```bash
cd deploy/it-tools
docker compose up -d --build
```

默认仍只绑本机 `127.0.0.1:8788`（不直接裸奔公网）。

## 反代备选（Nginx）

若不用 Tunnel，DNS：`tools.prb9.top` → 服务器后可用：

```nginx
server {
    listen 80;
    server_name tools.prb9.top;

    location / {
        proxy_pass http://127.0.0.1:8788;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

HTTPS 用 Cloudflare Full / Let's Encrypt 任一即可。

## 可选：Uptime Kuma

加一个 monitor 指到 `https://tools.prb9.top/`，和主机、股票分析并列。
