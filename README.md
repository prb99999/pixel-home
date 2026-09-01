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

## 动态数据（Blotter / STOCK 摘要）

主页从 JSON 拉取数据，**不用每次改 `index.html`**：

| 文件 | 用途 |
|------|------|
| `data/trades.json` | 量化成交 Blotter |
| `data/stock-latest.json` | STOCK 最新分析标题 + 一行结论 |

`index.html` 里 `SITE_CONFIG.feeds` 会**优先**请求 `stock.prb9.top` 上的同名 JSON，失败再回退到 Pages 上的 `/data/*`。若要让 stock 站直接供数，在反代里加：

```nginx
location /data/ {
    add_header Access-Control-Allow-Origin https://prb9.top;
    alias /path/to/your/data/;
}
```

### 更新成交 / STOCK 摘要（不用命令行）

打开 **[数据编辑台](https://prb9.top/tools/edit-data.html)**：

1. 填表 → 点 **生成并复制 JSON**
2. 自动打开 GitHub 对应文件 → 粘贴 → **Commit changes**
3. 等 Pages 部署完，刷新主页

| 文件 | GitHub 一键编辑 |
|------|-----------------|
| `data/trades.json` | https://github.com/prb99999/pixel-home/edit/main/data/trades.json |
| `data/stock-latest.json` | https://github.com/prb99999/pixel-home/edit/main/data/stock-latest.json |

新成交写在数组**最前面**。买入：`{ "date":"...", "side":"buy", "symbol":"ZS", "price":153.87, "strat":"QNT" }`  
卖出：`{ "date":"...", "side":"sell", "symbol":"TMUS", "price":181.53, "pnlPct":"+0.46%" }`

STOCK 摘要：`{ "title":"...", "summary":"一行结论", "url":"https://stock.prb9.top/", "updatedAt":"2026-08-25" }`

## Cloudflare Web Analytics

**Pages 一键开启（推荐）**

1. Cloudflare → **Workers & Pages** → 你的 Pages 项目 → **Settings**
2. 找到 **Web Analytics** → **Enable**
3. 重新部署后，CF 会**自动注入** beacon，面板里就能看到真实访客

这种情况下 **不用填** `cfAnalyticsToken`，也**不要**再手动加 snippet（会重复统计）。

**手动模式（可选）**

仅在 Web Analytics 里选了「手动安装 JS Snippet」时，把 token 填入：

```js
cfAnalyticsToken: '你的token',
```

> CF 没有公开访客数 API。主页 `PULSE` 表示统计是否开启；详细数据在 CF 面板 → Web Analytics。已移除 Abacus 虚高计数。

## 部署到 Cloudflare Pages

1. 把本仓库推到 GitHub
2. Cloudflare Dashboard → **Workers & Pages** → Create → Connect Git
3. 构建设置：
   - **Build command**：留空，或填 `exit 0`
   - **Build output directory**：`/`
4. 部署完成后，在 Pages 项目里 **Custom domains** 绑你的域名

> 域名 DNS 已在 Cloudflare 时，自定义域名通常会自动配好 HTTPS。
