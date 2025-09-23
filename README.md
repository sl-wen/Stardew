# Stardew - Godot星露谷物语复刻项目

[![Godot](https://img.shields.io/badge/Godot-4.4%2B-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一个使用Godot引擎开发的星露谷物语风格农场模拟游戏，致力于还原原作的核心玩法和体验。

## 🎮 游戏特色

- **农场模拟**：种植作物、养殖动物、经营农场
- **探索冒险**：探索地图、发现宝藏、与NPC互动
- **战斗系统**：使用各种武器与怪物战斗
- **物品系统**：收集、制作、交易各种物品
- **时间系统**：完整的昼夜和季节循环
- **存档系统**：自动保存游戏进度

## 📸 游戏截图

### 游戏特色展示
![封面展示](./img/Snipaste_2025-05-26_18-06-43.png)
*游戏封面展示*

![真彩虹猫之刃](./img/Snipaste_2025-05-26_18-07-11.png)
*真彩虹猫之刃武器效果*

![暗影焰刀](./img/Snipaste_2025-05-26_18-07-27.png)
*暗影焰刀武器特效*

### 场景展示
![鹈鹕镇广场](./img/Snipaste_2025-05-26_18-07-46.png)
*鹈鹕镇广场场景*

![被抢劫的皮埃尔商店](./img/Snipaste_2025-05-26_18-08-03.png)
*皮埃尔商店场景*

![贝塞尔曲线石头](./img/Snipaste_2025-05-26_18-10-14.png)
*贝塞尔曲线绘制的石头地形*

### 游戏机制展示
![成熟的甜瓜和镰刀光效](./img/Snipaste_2025-05-26_18-10-32.png)
*作物种植和收获系统*

![和艾米丽的对话](./img/Snipaste_2025-05-26_18-14-02.png)
*NPC对话系统*

![箱子交互和工具提示](./img/Snipaste_2025-05-26_18-19-12.png)
*交互系统和UI提示*

## 🚀 快速开始

### 系统要求

- **操作系统**：Windows 10+, macOS 10.15+, Linux
- **引擎**：Godot 4.4 或更高版本
- **内存**：至少 4GB RAM
- **存储空间**：至少 500MB 可用空间

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/stardew-godot.git
   cd stardew-godot
   ```

2. **导入Godot项目**
   - 打开Godot编辑器
   - 点击"导入"按钮
   - 选择项目根目录下的 `project.godot` 文件

3. **运行游戏**
   - 在Godot编辑器中按 `F5` 键运行项目
   - 或者在项目管理器中双击项目并点击"播放"按钮

### 开发环境配置

#### 推荐Godot版本
- **稳定版本**：Godot 4.4 LTS
- **开发版本**：Godot 4.4+ (最新稳定版)

#### 开发环境设置
1. 启用GDScript LSP支持（提升代码提示和错误检查）
2. 配置项目设置：
   - 窗口分辨率：1280x720
   - 渲染方法：Forward+
   - 音频输出：立体声

## 🎯 游戏操作说明

### 基础移动
- **WASD**：移动角色
- **鼠标**：控制视角和交互

### 物品栏操作
- **E键**：打开/关闭物品栏
- **鼠标滚轮**：切换物品栏中的物品
- **Q键**：丢弃物品
- **左键点击**：使用物品/工具

### 游戏机制
- **耕地**：使用锄头在泥土上点击创建农田
- **种植**：选择种子在农田上点击进行种植
- **浇水**：使用洒水壶在作物上点击浇水
- **收获**：成熟的作物会变为金色，点击即可收获
- **战斗**：使用武器攻击怪物获得经验和掉落物

## 🏗️ 项目架构

### 核心系统架构

```
Global/                    # 全局管理器
├── global.gd             # 全局常量和工具函数
├── audio_manager.gd      # 音频管理系统
├── save_manager.gd       # 存档管理系统
├── scene_manager.gd      # 场景管理系统
└── mouse_cursor.gd       # 鼠标光标系统

Player/                   # 玩家系统
├── player.gd             # 玩家主控制器
├── player_camera.gd      # 玩家相机系统
└── States/               # 玩家状态机
    ├── state.gd          # 状态基类
    ├── state_machine.gd  # 状态机管理器
    ├── idle.gd           # 闲置状态
    ├── move.gd           # 移动状态
    ├── axe.gd            # 斧头状态
    ├── hoe.gd            # 锄头状态
    └── water.gd          # 浇水状态

Bag/                      # 物品栏系统
├── items/                # 物品定义
├── projectiles/          # 投掷物系统
└── scene/                # 物品栏UI

Component/                # 组件系统
├── hit_component.gd      # 碰撞组件
├── hurt_component.gd     # 受伤组件
└── tilemap_component.gd  # 地图组件

TimeSystem/               # 时间系统
└── time_system.gd        # 时间管理器

UI/                       # 用户界面
├── tool_tip.tscn         # 工具提示
└── inventory_ui.tscn     # 物品栏界面
```

### 设计模式

#### 状态机模式 (State Pattern)
玩家行为通过有限状态机管理，确保逻辑清晰和可维护性：

```gdscript
# 状态基类定义了标准的生命周期方法
class State:
    func _enter(): pass      # 进入状态
    func _exit(): pass       # 退出状态
    func _physics_update(delta): pass  # 物理更新
    func _update_animation(): pass     # 动画更新
```

#### 组件模式 (Component Pattern)
游戏对象功能通过组件系统实现，提高代码复用性：

```gdscript
# 碰撞组件
class HitComponent extends Area2D:
    func _init():
        collision_layer = 2
        collision_mask = 1
```

#### 单例模式 (Singleton Pattern)
核心管理器作为Autoload单例运行：

```gdscript
# project.godot 中的Autoload设置
Global="*res://Global/global.gd"
AudioManager="*res://Global/audio_manager.gd"
SceneManager="*res://Global/scene_manager.gd"
```

### 核心机制详解

#### 时间系统
- **游戏时间流速**：1秒现实时间 = 1分钟游戏时间
- **昼夜循环**：24小时制，6:00开始新的一天
- **季节系统**：4个季节循环，影响作物生长
- **事件触发**：基于时间的事件系统

#### 存档系统
- **自动保存**：游戏进行中自动保存关键数据
- **手动存档**：玩家可随时保存当前进度
- **数据结构**：使用Godot的Resource系统进行序列化

#### 音频系统
- **双播放器**：实现背景音乐的无缝切换
- **音效管理**：同时播放多个音效
- **音量控制**：独立的主音量、音乐、音效控制

## 🎨 艺术资源

### 像素艺术风格
- **分辨率**：16x16像素基础单位
- **调色板**：自定义16色调色板
- **动画帧**：4-8帧循环动画

### 音频资源
- **背景音乐**：不同场景的氛围音乐
- **音效**：工具使用、战斗、UI交互音效
- **环境音**：风声、水声、鸟鸣等环境音效

## 🔧 技术实现

### 性能优化
- **对象池**：复用掉落物和粒子效果
- **视锥剔除**：只渲染可见区域
- **纹理压缩**：优化资源占用

### 内存管理
- **引用计数**：避免循环引用导致的内存泄漏
- **资源卸载**：场景切换时正确释放资源
- **纹理管理**：按需加载纹理资源

### 调试功能
- **状态调试**：显示当前玩家状态信息
- **性能监控**：显示FPS和内存使用情况
- **碰撞调试**：可视化碰撞箱

## 🤝 贡献指南

### 开发流程
1. Fork 项目到你的GitHub账户
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add amazing feature'`
4. 推送分支：`git push origin feature/amazing-feature`
5. 创建Pull Request

### 代码规范
- 使用GDScript 2.0语法
- 遵循Godot最佳实践
- 添加详细的中文注释
- 使用有意义的变量和函数名

### 提交规范
```
feat: 添加新功能
fix: 修复bug
docs: 更新文档
style: 代码格式调整
refactor: 重构代码
test: 添加测试
```

## 📄 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- **原作**：Stardew Valley by ConcernedApe
- **引擎**：Godot Engine
- **社区**：Godot中文社区
- **开发者**：独立游戏开发者们

## 📞 联系方式

- **项目维护者**：你的名字
- **邮箱**：your-email@example.com
- **GitHub**：https://github.com/your-username
- **项目主页**：https://your-project-homepage.com

---

**注意**：这是一个学习和教育项目，旨在展示Godot引擎的强大功能。如有任何版权问题，请联系项目维护者。
