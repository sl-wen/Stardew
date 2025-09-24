# 全局常量和工具类
# 此脚本作为Autoload单例运行，用于存储游戏中常用的常量、预加载场景和全局工具函数
# 作为单例运行意味着这个脚本在整个游戏生命周期中只存在一个实例
# 其他脚本可以通过Global.xxx的方式访问这里的常量和函数
extends Node  # 继承自Node，作为Godot场景树的节点

## 工具提示预制体路径
# 用于在游戏中显示各种提示信息，如物品描述、操作说明等
# preload在脚本加载时就预加载资源，提高运行时性能
const TOOL_TIP = preload("res://UI/tool_tip.tscn")

## 掉落物组件预制体路径
# 当玩家破坏物体或击杀敌人时，会生成掉落物组件来显示掉落的物品
# 这个预制体包含掉落物品的动画和交互逻辑
const FALL_OBJECT_COMPONENT = preload("res://FallObjects/fall_object_component.tscn")

## 根场景路径字典
# 存储游戏中各个重要场景节点的路径，方便在代码中快速访问
# 使用字典存储路径字符串，便于集中管理和维护
# 这些路径在游戏运行时动态构建，不同场景可能有不同的节点结构
var root_scene:Dictionary = {
	# 主场景根节点
	# 游戏的主要场景容器，所有其他场景都作为其子节点
	"main_scene": "/root/MainScene",

	# 主画布层，用于管理UI元素
	# CanvasLayer节点用于UI渲染，确保UI在场景变化时保持可见
	"main_canvas_layer":"/root/MainScene/MainCanvasLayer",

	# 弹窗容器，用于显示各种弹窗界面
	# 放置在CanvasLayer下，确保弹窗显示在最上层
	"pop_up":"/root/MainScene/MainCanvasLayer/PopUp",

	# 关卡容器，包含游戏的主要内容层
	# 游戏的各个关卡场景都放在这个容器中
	"levels":"/root/MainScene/Levels",

	# 掉落物容器，专门用于管理掉落物品
	# 掉落物品需要独立管理，避免与关卡场景混合
	"drops":"/root/MainScene/Levels/Drops",

	# UI管理器，负责协调各种UI组件
	# 统一管理所有UI元素的状态和交互
	"ui_manager":"/root/MainScene/MainCanvasLayer/UIManager",
}
