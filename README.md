# Pure v1.0

用 SwiftUI 动画把《纯粹理性批判》的模型可视化的 iOS App。

按“人物 → 书籍 → 章节”浏览。每章一页：核心观点、数学化公式、一段动画和要点。动画中的圆和方框都使用 iOS 26 原生 Liquid Glass，背景可在“外观”里自定义（内置样式、相册照片、暗度）。

| 人物 | 书籍 | 章节 |
| --- | --- | --- |
| 康德 | 《纯粹理性批判》 | 24 |
| 黑格尔 | 《精神现象学》 | 6 |
| 黑格尔 | 《逻辑学》 | 5 |
| 罗素 | 《论指称》 | 2 |
| 罗素 | 《数学原理》 | 3 |
| 罗素 | 《哲学问题》 | 3 |

## 构建

App 代码有改动并推送到 `main` 时，GitHub Actions 自动编译并在 Releases 发布 `Pure-vX.Y-unsigned.ipa`。版本号每次发布自动加 0.1（从 v1.1 开始）；要跳大版本，把 `VERSION` 文件改成例如 `2.0`。需要自行签名后安装（TrollStore、AltStore、Sideloadly 等）。

最低 iOS 26。界面全部使用 Liquid Glass（`glassEffect`、`GlassEffectContainer`、`.glass` 按钮），动画也用玻璃质感绘制；图标为纯白玻璃设计。
