# 碰撞组件
# 负责处理游戏对象的碰撞检测和伤害计算
# 通常用于玩家工具、武器等需要与环境或敌人互动的对象
extends Area2D
class_name HitComponent

## 碰撞形状引用
# 通过@onready获取碰撞形状组件的引用
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## 当前物品类型
# 标识当前装备的物品类型，用于确定碰撞行为
@export var current_item_type: Item.ItemType = Item.ItemType.None

## 伤害值
# 工具或武器的伤害数值
# 需要在更换工具时根据不同工具设置对应的伤害值
@export var damage:int = 1

func _ready() -> void:
	# 初始化时禁用碰撞形状，等待工具激活时再启用
	collision_shape_2d.disabled = true
