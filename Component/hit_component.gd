# 碰撞组件
# 负责处理游戏对象的碰撞检测和伤害计算
# 通常用于玩家工具、武器等需要与环境或敌人互动的对象
# 当这些对象接触到可破坏的物体时，会触发碰撞事件并造成伤害
extends Area2D  # 继承自Area2D节点，具有2D碰撞检测能力
class_name HitComponent  # 定义组件的类名，便于在代码中引用

## 碰撞形状引用
# 通过@onready获取碰撞形状组件的引用
# 碰撞形状定义了碰撞检测的范围和形状
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## 当前物品类型
# 标识当前装备的物品类型，用于确定碰撞行为
# 不同的物品类型可能有不同的碰撞处理逻辑
@export var current_item_type: Item.ItemType = Item.ItemType.None

## 伤害值
# 工具或武器的伤害数值
# 需要在更换工具时根据不同工具设置对应的伤害值
# 例如斧头可能有更高的伤害值来砍伐树木
@export var damage:int = 1

# 节点就绪时调用
# 进行碰撞组件的初始化设置
func _ready() -> void:
	# 初始化时禁用碰撞形状，等待工具激活时再启用
	# 这样可以避免在游戏开始时就触发意外的碰撞事件
	# 只有当玩家真正使用工具时才会启用碰撞检测
	collision_shape_2d.disabled = true
