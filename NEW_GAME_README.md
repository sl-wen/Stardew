# 新建存档功能实现说明

## 功能概述

新建存档功能已经完全实现，允许玩家创建全新的游戏进度，清除所有旧数据并初始化游戏状态。

## 实现功能

### 1. 存档文件管理
- **清除存档文件**：删除现有的 `user://abc.tres` 存档文件
- **安全操作**：包含错误检查和日志输出
- **目录权限检查**：确保用户目录可以访问

### 2. 游戏状态初始化
- **玩家状态重置**：
  - 清空玩家物品栏
  - 重置玩家位置到默认位置 (2505, 360)
  - 重置当前物品和物品类型
  - 恢复玩家移动能力

- **保存组件数据清理**：
  - 清除所有SaveComponent组件的子节点
  - 保持SaveComponent本身不变

### 3. 用户界面
- **开始菜单**：点击"创建"按钮启动新游戏
- **加载游戏**：点击"加载"按钮加载现有存档
- **多人游戏**：预留接口（当前显示提示信息）

## 文件结构

### 核心文件
- `UI/game_start_menu.gd` - 开始菜单UI逻辑
- `Global/save_manager.gd` - 存档管理器
- `SaveSystem/save_component.gd` - 保存组件
- `SaveSystem/save_data.gd` - 存档数据结构
- `Player/player.gd` - 玩家类定义
- `Bag/scene/item.gd` - 物品类定义
- `Bag/scene/inventory_system.gd` - 物品栏系统

## 使用方法

### 1. 创建新游戏
1. 运行游戏
2. 在开始菜单中点击**"创建"**按钮
3. 系统会自动：
   - 清除旧存档文件
   - 初始化新游戏状态
   - 加载主场景
   - 移除开始菜单
4. 玩家将出现在默认位置，物品栏为空

### 2. 加载游戏
1. 运行游戏
2. 在开始菜单中点击**"加载"**按钮
3. 系统会自动：
   - 加载主场景
   - 尝试从存档文件恢复数据
   - 如果没有存档文件，保持空状态
4. 游戏状态将恢复到上次保存的状态

## 技术实现

### SaveManager.new_game()
```gdscript
func new_game() -> void:
    # 清除现有存档
    clear_save_data()

    # 初始化默认游戏状态
    initialize_default_game_state()
```

### SaveManager.initialize_default_game_state()
```gdscript
func initialize_default_game_state() -> void:
    var player = get_tree().get_first_node_in_group("Player") as Player
    if player:
        # 清除玩家物品栏
        if player.bag_system:
            player.bag_system.items.clear()
            player.bag_system.items.resize(player.bag_system.items_size)

        # 重置玩家位置
        player.global_position = Vector2(2505, 360)

        # 重置玩家状态
        player.current_item = null
        player.current_item_type = Item.ItemType.None
        player.can_move = true

    # 清除保存组件数据
    var save_components = get_tree().get_nodes_in_group("SaveComponents")
    for save_component in save_components:
        for child in save_component.get_parent().get_children():
            if child.name != "SaveComponent":
                child.queue_free()
```

### 开始菜单创建按钮
```gdscript
func _on_create_pressed() -> void:
    print("开始新建游戏...")

    # 加载主场景
    SceneManager.load_main_scene()

    # 初始化新游戏状态
    SaveManager.new_game()

    # 移除开始菜单
    queue_free()

    print("新游戏创建完成")
```

## 存档文件位置

- **路径**：`user://abc.tres`
- **实际位置**：`~/.local/share/godot/app_userdata/Stardew/abc.tres`

## 错误处理

- **文件不存在**：安全处理，不会出现错误
- **权限问题**：日志输出错误信息
- **目录访问失败**：提供详细的错误日志
- **资源加载失败**：跳过并继续游戏
- **异步操作**：使用await正确处理异步加载，避免数据不一致

## 技术细节

### 异步实现
- **SaveComponent.set_save_data()**：异步函数，包含节点清理和恢复
- **SaveManager._load_async()**：异步加载函数，确保数据完整性
- **game_start_menu._on_load_pressed()**：使用await等待加载完成

### 性能优化
- **节点清理**：使用queue_free()和await process_frame确保完整清理
- **数据恢复**：逐个恢复节点，避免内存峰值
- **错误恢复**：即使部分组件失败，也会继续其他组件的恢复

## 测试

运行 `test_new_game_implementation.gd` 脚本可以验证所有功能是否正常工作。

## 扩展功能

- **多人游戏**：预留接口，可以在 `_on_coop_pressed()` 中实现
- **多存档**：可以扩展为支持多个存档文件
- **存档备份**：可以添加自动备份功能

## 注意事项

1. 确保 Player 节点在 "Player" 组中
2. 确保 SaveComponent 组件在 "SaveComponents" 组中
3. 确保所有资源路径正确
4. 建议在发布前进行完整的功能测试