# 全局常量和工具类
# 此脚本作为Autoload单例运行，用于存储游戏中常用的常量、预加载场景和全局工具函数
extends Node

## 工具提示预制体路径
# 用于在游戏中显示各种提示信息，如物品描述、操作说明等
const TOOL_TIP = preload("res://UI/tool_tip.tscn")

## 掉落物组件预制体路径
# 当玩家破坏物体或击杀敌人时，会生成掉落物组件来显示掉落的物品
const FALL_OBJECT_COMPONENT = preload("res://FallObjects/fall_object_component.tscn")

## 根场景路径字典
# 存储游戏中各个重要场景节点的路径，方便在代码中快速访问
# main_scene: 主场景根节点
# main_canvas_layer: 主画布层，用于管理UI元素
# pop_up: 弹窗容器，用于显示各种弹窗界面
# levels: 关卡容器，包含游戏的主要内容层
# drops: 掉落物容器，专门用于管理掉落物品
# ui_manager: UI管理器，负责协调各种UI组件
var root_scene:Dictionary = {
	"main_scene": "/root/MainScene",
	"main_canvas_layer":"/root/MainScene/MainCanvasLayer",
	"pop_up":"/root/MainScene/MainCanvasLayer/PopUp",
	"levels":"/root/MainScene/Levels",
	"drops":"/root/MainScene/Levels/Drops",
	"ui_manager":"/root/MainScene/MainCanvasLayer/UIManager",
}
