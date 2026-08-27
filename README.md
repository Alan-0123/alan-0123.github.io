# Alan 个人作品集网站

一个部署在 GitHub Pages 上的个人作品集静态网站，包含个人简介、精选项目、技能专长与联系方式四大板块，采用响应式设计，适配桌面与移动端。

**线上地址**：<https://alan-0123.github.io/>

## 目录结构

```
.
├── index.html                    # 页面主文件（所有文字内容在这里修改）
├── assets/
│   ├── css/style.css             # 样式表（颜色、字体、布局）
│   ├── js/main.js                # 交互脚本（菜单、动效，一般无需改动）
│   └── images/                   # 项目预览图
│       ├── project-analytics.jpg
│       ├── project-ai-chat.jpg
│       ├── project-membership.jpg
│       └── project-workflow.jpg
├── .github/workflows/deploy.yml  # GitHub Pages 自动部署工作流
├── .nojekyll                     # 禁用 Jekyll 处理（勿删）
└── README.md
```

## 如何修改内容

所有文案都集中在 `index.html` 中，各板块均有 `<!-- 编辑提示 -->` 注释标记：

| 想改什么 | 去哪里改 |
|---|---|
| 姓名、职位、一句话介绍 | `首屏 · 个人简介` 区块 |
| 项目标题 / 描述 / 标签 / 链接 | `精选项目` 区块，每个 `<article>` 是一个项目 |
| 技能分组与工具 | `技能专长` 区块 |
| 个人经历与关键数字 | `关于我` 区块 |
| 邮箱、GitHub、微信等 | `联系方式` 区块 |

**替换项目预览图**：将新图片（建议 16:9、宽 1600px 左右、JPG）覆盖 `assets/images/` 下同名文件即可；新增图片则需同步修改 `index.html` 中对应 `<img>` 的 `src` 与 `alt`。

> 注意：页面中的项目数据、指标（如「留存提升 18%」）与联系方式均为示例占位内容，上线前请务必替换为你的真实信息。

## 本地预览

```bash
# 在项目根目录执行，然后浏览器打开 http://localhost:8000
python -m http.server 8000
```

## 部署方式

推送到 `main` 分支即自动触发 GitHub Actions 部署（见 `.github/workflows/deploy.yml`），约 1 分钟后生效。

**首次使用需要在 GitHub 上做一次性设置**：

1. 打开仓库 **Settings → Pages**
2. 将 **Build and deployment → Source** 设置为 **GitHub Actions**

设置完成后，每次 `git push` 都会自动发布最新版本，无需手动操作。

## 更换主题色

网站使用暖纸底 + 朱砂红的配色，定义于 `assets/css/style.css` 顶部的 CSS 变量（OKLCH 色彩空间）：

```css
--accent:        oklch(47% 0.16 30);   /* 主色：朱砂 */
--accent-strong: oklch(51% 0.18 29);   /* 大字号装饰用 */
```

替换为任意 OKLCH / 十六进制颜色即可整站换色。

## 关于仓库命名

仓库已命名为 `alan-0123.github.io`，符合 GitHub Pages 用户站命名规则（`<用户名>.github.io`），因此站点直接托管在根路径 `https://alan-0123.github.io/` 下。请勿将仓库改回其他名称，否则站点地址会变为带子路径的形式。

## 技术说明

- 纯静态 HTML/CSS/JS，无构建依赖，零框架
- 字体：[Fraunces](https://fonts.google.com/specimen/Fraunces)（拉丁文标题）+ 系统中文字体
- 动效遵循 `prefers-reduced-motion` 无障碍偏好
- 图片均已压缩优化，并使用懒加载
