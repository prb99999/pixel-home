# IT-Tools（tools.prb9.top）

轻量开发者工具箱：[CorentinTh/it-tools](https://github.com/CorentinTh/it-tools)。  
几乎是静态前端，2G 机器上很省。

## 一键启动

```bash
cd deploy/it-tools
docker compose up -d
```

默认监听本机 `127.0.0.1:8788`（不直接裸奔公网）。

## 反代（Nginx 示例）

DNS：`tools.prb9.top` → 你的服务器（Cloudflare 代理也可）。

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
