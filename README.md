# Pixel Home

基于 [bearlike/Pixel-Portfolio-Webite](https://github.com/bearlike/Pixel-Portfolio-Webite) 的像素风个人静态主页，适合部署到 **Cloudflare Pages**。

内含同风格静态博客：`/blog/`（无需服务器常驻进程）。

## 本地预览

```bash
# 任意静态服务器均可，例如：
python3 -m http.server 8080
# 浏览器打开 http://localhost:8080
# 博客：http://localhost:8080/blog/
```

## 需要你改的地方

在 `index.html` 里搜索并替换：

| 占位 | 说明 |
|------|------|
| `https://YOUR-STOCK-SITE.example.com` | 股票分析站完整 URL（两处） |
| `Panpan` | 显示名 |
| `you@example.com` / `@you` | 联系方式 / GitHub |

## 博客：怎么写新文章

纯静态，**不用在 VPS 上部署**，跟着 Pages 一起发布。

1. 复制 `blog/posts/hello-pixel.html` 为 `blog/posts/你的-slug.html`
2. 改标题、日期、正文；导航链接按需调整
3. 在 `blog/posts.json` 追加一条：

```json
{
  "slug": "你的-slug",
  "title": "标题",
  "date": "2026-07-22",
  "tags": ["标签"],
  "excerpt": "列表页摘要"
}
```

4. 提交推送即可。列表页会读 `posts.json`（无 JS 时也有静态回退）。

样式在 `assets/css/pixel-blog.css`，与首页同一套色板 / Fusion Pixel / NES 面板。

## 部署到 Cloudflare Pages

1. 把本仓库推到 GitHub
2. Cloudflare Dashboard → **Workers & Pages** → Create → Connect Git
3. 构建设置：
   - **Build command**：留空，或填 `exit 0`
   - **Build output directory**：`/`
4. 部署完成后，在 Pages 项目里 **Custom domains** 绑你的域名

> 域名 DNS 已在 Cloudflare 时，自定义域名通常会自动配好 HTTPS。
