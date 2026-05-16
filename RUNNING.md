# 运行 flutter_interview 项目

## 环境要求

- Flutter 3.41+
- Dart 3.11+
- Xcode（iOS模拟器需要）
- Node.js（Melos需要）

## 安装依赖

```bash
# 安装Melos（如未安装）
dart pub global activate melos

# 安装所有包的依赖
cd flutter_interview
melos bootstrap
```

## 运行项目

### iOS 模拟器

```bash
# 1. 打开模拟器
open -a Simulator

# 2. 进入app目录运行
cd packages/apps/App
flutter run
```

### Android 模拟器

先启动 Android 模拟器，然后：

```bash
cd packages/apps/App
flutter run
```

### 指定设备运行

```bash
# 查看可用设备
flutter devices

# 指定设备
cd packages/apps/App
flutter run -d "iPhone 15"
```

## 常用 Melos 命令

| 命令 | 作用 |
|------|------|
| `melos bootstrap` | 安装所有包依赖 |
| `melos run analyze` | 分析所有包的代码 |
| `melos run test` | 运行所有包的测试 |
| `melos run clean` | 清理所有包的构建缓存 |
| `melos run generate` | 运行 build_runner 生成代码 |

## 项目结构

```
flutter_interview/
├── packages/
│   ├── apps/App/          # 主应用入口
│   ├── common/            # 公共包
│   │   ├── core/          #   核心工具
│   │   └── widgets/       #   公共组件
│   └── tech/              # 技术点示例
│       ├── animation/     #   动画
│       ├── custom_painter/#   自定义绘制
│       ├── di_guide/      #   依赖注入
│       ├── http_client/   #   网络请求
│       ├── local_storage/ #   本地存储
│       ├── precise_timer/ #   精确定时器
│       ├── router_guide/  #   路由导航
│       └── state_management/# 状态管理
└── melos.yaml             # Melos配置文件
```
