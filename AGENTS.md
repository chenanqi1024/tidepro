你是一名 iOS / SwiftUI 工程师。我正在开发一款潮汐类 App（SwiftUI，iOS 17+）。请按以下规格实现功能，并确保项目可编译运行。

开发约束
- 代码尽量简单易读
- 不使用任何第三方库
- 如使用 ObservableObject，请 import Combine

交付要求
- 完成实现后，请输出「本次改动日志」（新增/修改了哪些内容、涉及哪些页面/文件）

信息架构
- 底部 Tab 必须包含 4 个页面：
  1) 睡眠（Sleep）
  2) 专注（Focus）
  3) 呼吸（Breathe）
  4) 冥想（Meditate）

数据源
- API：https://zzz-pet.oss-cn-hangzhou.aliyuncs.com/api/sounds.json
- 返回格式：
{
  "alarm": {
    "id": "morning_joy",
    "name": "Morning Joy",
    "url": "https://xxxx.mp3",
    "cover": ""
  },
  "sounds": [
    {
      "id": "cat_purr_1",
      "name": "猫呼噜声",
      "url": "https://xxx.m4a",
      "cover": "https://xxx.jpg"
    }
  ]
}
- 数据使用规则：
  - 「睡眠」与「专注」共用同一份 sounds
  - 「睡眠」闹钟音乐使用 alarm

全局通用体验要求
- 整体UI风格偏梦幻，并且使用UI-Ux-Pro-Max Skill
- 网络加载必须包含：加载中 / 失败提示 + 失败重试
- 图片严格与显示区域一致；所有封面图都“填充裁剪”为 1:1
- 音频在切换页面时不要莫名停止（除非用户主动停止）
- 音频需要支持后台播放，在后台播放时用户可以通过通知栏暂停
