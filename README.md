# Pixel Home

基于 [bearlike/Pixel-Portfolio-Webite](https://github.com/bearlike/Pixel-Portfolio-Webite) 的像素风个人静态主页，适合部署到 **Cloudflare Pages**。

## 本地预览

```bash
# 任意静态服务器均可，例如：
python3 -m http.server 8080
# 浏览器打开 http://localhost:8080
```

## 需要你改的地方

在 `index.html` 里搜索并替换：

| 占位 | 说明 |
|------|------|
| `https://YOUR-STOCK-SITE.example.com` | 股票分析站完整 URL（两处） |
| `Panpan` | 显示名 |
| `you@example.com` / `@you` | 联系方式 / GitHub |

## 部署到 Cloudflare Pages

1. 把本仓库推到 GitHub
2. Cloudflare Dashboard → **Workers & Pages** → Create → Connect Git
3. 构建设置：
   - **Build command**：留空，或填 `exit 0`
   - **Build output directory**：`/`
4. 部署完成后，在 Pages 项目里 **Custom domains** 绑你的域名

> 域名 DNS 已在 Cloudflare 时，自定义域名通常会自动配好 HTTPS。
