# 代码注释规范指南

本文档定义了Stardew Godot项目中代码注释的标准和要求，确保所有代码都有详细的中文注释，提高代码的可读性和可维护性。

## 📋 总体要求

1. **全覆盖**：所有代码文件必须有详细的中文注释
2. **行级别**：重要代码行都应有相应的解释注释
3. **及时更新**：代码修改时同步更新相关注释
4. **一致性**：所有注释遵循统一的格式和风格

## 📝 注释格式规范

### 1. 文件头部注释
每个代码文件都必须在开头包含详细的功能说明：

```gdscript
# 文件名 控制器/组件/系统
# 负责[主要功能]，包含[具体功能点]
# 采用[设计模式]实现[核心机制]
# [其他重要说明]
extends BaseClass  # 继承说明
```

### 2. 导出属性注释
所有@export属性必须有详细注释：

```gdscript
## 属性分组标题
# 详细说明属性的作用、影响范围和使用场景

# 简洁的行内注释：属性单位和示例值
@export var player_speed: int = 100  # 玩家移动速度，像素/秒
@export var max_health: float = 100.0  # 最大生命值
@export var weapon_damage: int = 10  # 武器伤害值
```

### 3. 变量注释
类变量和局部变量都需要适当注释：

```gdscript
# 公开变量使用var，私有变量使用var（无下划线前缀）
var player_position: Vector2  # 玩家当前位置
var _internal_timer: float    # 内部计时器（私有变量）

# 常量使用const，命名采用SCREAMING_SNAKE_CASE
const MAX_SPEED: int = 200    # 最大移动速度常量
const GRAVITY: float = 9.8   # 重力加速度常量
```

### 4. 函数注释
所有函数都必须有完整的函数注释：

```gdscript
## 函数功能概述
# 详细描述函数的主要功能和执行逻辑
# 说明函数在整个系统中的作用和调用时机
# @param param_name: 参数类型 - 参数详细说明
# @return: 返回值类型 - 返回值详细说明
func function_name(param1: Type, param2: Type) -> ReturnType:
    # 函数内部的行级别注释
    var result = param1 + param2  # 计算两个参数的和
    return result  # 返回计算结果
```

### 5. 行级别注释
重要代码行都需要有注释说明：

```gdscript
func update_player(delta: float) -> void:
    # 获取输入方向向量
    var direction = Input.get_vector("left", "right", "up", "down")

    # 检查是否可以移动
    if can_move:
        # 计算新的位置
        var new_position = position + direction * speed * delta

        # 边界检查：防止超出屏幕范围
        new_position.x = clamp(new_position.x, 0, screen_width)
        new_position.y = clamp(new_position.y, 0, screen_height)

        # 更新位置
        position = new_position
```

## 🎯 具体示例

### 状态机注释示例

```gdscript
# 玩家移动状态
# 负责处理玩家的移动逻辑，包括方向控制、动画播放和状态转换
# 当玩家按下移动键时进入此状态，按键松开时切换回Idle状态
extends State  # 继承自状态基类

# 导出的属性，可以在Godot编辑器中进行配置
@export var player: Player      # 玩家主脚本引用，用于访问玩家属性和方法
@export var anim: AnimationPlayer  # 动画播放器引用，用于控制移动动画
@export var speed: int = 100    # 移动速度，像素/秒，影响玩家的移动快慢

func _enter():
    # 进入移动状态时的处理
    # 当玩家从其他状态切换到移动状态时调用
    print("Move")  # 调试输出，标识当前状态
    pass  # 进入状态时的初始化逻辑

func _physics_update(delta):
    # 物理帧更新处理
    # 每物理帧执行一次，处理移动的核心逻辑
    direction = player.direction  # 获取当前玩家的移动方向
    update_animation()  # 更新动画播放

    # 检查是否应该切换回Idle状态
    if player.direction == Vector2.ZERO:
        transition_to.emit("Idle")  # 发出状态转换信号

    # 执行移动
    player.velocity = direction * speed  # 设置速度向量
    player.move_and_slide()  # 执行移动并处理碰撞
```

### 组件注释示例

```gdscript
# 点击区域组件
# 此脚本定义了一个可点击的区域组件，用于处理鼠标交互
# 当鼠标进入、离开或点击该区域时会触发相应的信号和鼠标样式变化
extends Area2D  # 继承自Area2D节点，具有2D碰撞检测能力
class_name ClickAreaComponent  # 定义组件的类名，便于在代码中引用

# 鼠标右键点击信号
# 当用户在该区域内点击鼠标右键时发出此信号
# 其他脚本可以连接此信号来响应右键点击事件
signal mouse_right_click

func _ready() -> void:
    # 连接鼠标进入信号到处理函数
    mouse_entered.connect(_on_mouse_entered)
    # 连接鼠标离开信号到处理函数
    mouse_exited.connect(_on_mouse_exited)
    # 连接输入事件信号到处理函数
    input_event.connect(_on_input_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    # 检查是否是鼠标右键按下事件
    if event.is_action_pressed("mouse_right"):
        # 发出右键点击信号，通知其他系统用户进行了右键点击
        mouse_right_click.emit()
```

## 📏 注释质量标准

### 1. 准确性
- 注释内容必须准确反映代码的实际功能
- 避免模糊或错误的描述

### 2. 完整性
- 重要逻辑都有相应注释
- 复杂算法有步骤说明
- 边界条件和异常情况有说明

### 3. 清晰性
- 使用简洁明了的语言
- 避免过于技术化的术语
- 保持一致的注释风格

### 4. 维护性
- 注释与代码同步更新
- 删除无用注释
- 定期检查注释质量

## 🔧 检查工具

### 手动检查清单
- [ ] 文件头部有功能说明吗？
- [ ] 所有@export属性有注释吗？
- [ ] 复杂函数有详细注释吗？
- [ ] 重要代码行有解释注释吗？
- [ ] 注释与代码内容一致吗？

### 自动化检查
项目包含注释检查脚本，可以自动验证注释的完整性：

```bash
# 运行注释检查脚本
python scripts/check_comments.py
```

## 📚 最佳实践

1. **及时注释**：编写代码时同步添加注释
2. **定期审查**：代码审查时检查注释质量
3. **持续改进**：根据反馈不断完善注释
4. **团队协作**：保持注释风格的一致性

## 🎉 总结

良好的代码注释是项目成功的关键因素之一。通过遵循本指南，我们可以确保：

- 新开发者能够快速理解代码结构
- 代码维护和调试更加高效
- 项目知识得到有效传承
- 代码质量得到持续提升

请所有开发者严格遵守本注释规范，共同维护项目的代码质量！