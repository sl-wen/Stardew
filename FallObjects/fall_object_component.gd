# 掉落物组件
# 负责管理游戏中的掉落物品，包括贝塞尔曲线运动轨迹和玩家拾取逻辑
# 当玩家破坏物体或击败敌人时，会生成掉落物供玩家拾取
extends Node2D
class_name FallObjectComponent

## 组件引用
# 通过@onready获取场景中的各个组件节点
@onready var sprite_2d: Sprite2D = $Sprite2D                    # 物品精灵
@onready var area_2d: Area2D = $Area2D                          # 检测区域
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D  # 碰撞形状

## 掉落物属性
# 可在Godot编辑器中进行配置
@export var item:Item                              # 掉落的物品
@export var speed:float = 1.5                      # 掉落运动速度
@export var deviation_distance:float = 50          # 贝塞尔曲线偏航距离（p0到p1距离）
@export var deviation_angle:float = 90             # 贝塞尔曲线偏航角度

## 掉落物状态变量
var is_bezier:bool = true                          # 是否启用贝塞尔曲线运动
var player:Player                                  # 玩家引用
var body_in_area:bool = false                      # 是否有物体进入检测区域
var p0:Vector2                                      # 贝塞尔曲线起点
var p1:Vector2                                      # 贝塞尔曲线控制点
var p2:Vector2                                      # 贝塞尔曲线终点
var t:float = 0.0                                  # 曲线进度（0代表初始位置，1代表终点）


## 节点就绪处理
# 初始化掉落物组件，设置玩家引用和信号连接
func _ready() -> void:
	# 获取玩家引用
	player = get_tree().get_first_node_in_group("Player")

	# 连接区域进入信号
	area_2d.body_entered.connect(on_body_entered)

	# 初始化时禁用物理处理和碰撞检测
	set_physics_process(false)
	collision_shape_2d.disabled = true

	# 如果启用贝塞尔曲线，设置目标位置
	if is_bezier:
		set_destination()

	# 延迟0.5秒后启用碰撞检测
	await get_tree().create_timer(0.5).timeout
	collision_shape_2d.set_deferred("disabled", false)


## 物理帧更新
# 处理掉落物的贝塞尔曲线运动
# @param delta: 物理帧间隔时间
func _physics_process(delta: float) -> void:
	# 如果曲线进度未完成，继续移动
	if t < 1.0:
		t += delta * speed
		# 使用Godot内置的贝塞尔曲线插值函数
		position = position.bezier_interpolate(p0, p1, p2, t)
	
## 每帧更新
# 处理玩家拾取掉落物的逻辑
# @param delta: 帧间隔时间
func _process(delta: float) -> void:
	# 如果有物体进入检测区域，执行拾取逻辑
	if body_in_area:
		# 创建缓动动画，掉落物向玩家移动
		var tween = create_tween()
		tween.tween_property(self, "global_position", player.global_position, 0.5)

		# 当距离足够近时，完成拾取
		if player.global_position.distance_to(global_position) <= 15.0:
			# 再次移动到玩家位置确保拾取
			tween.tween_property(self, "global_position", player.global_position, 0.5)
			# 销毁掉落物
			queue_free()
			# 将物品添加到玩家背包
			player.bag_system.add_item(item)
			# 发出物品拾取信号
			player.get_item.emit(item)
	
## 物体进入检测区域处理
# 当有物体进入掉落物的检测区域时调用
# @param body: 进入区域的物体
func on_body_entered(body:Node2D) -> void:
	# 只有玩家进入时才执行拾取逻辑
	if body is Player:
		body_in_area = true

## 生成掉落物
# 根据传入的物品创建掉落物实例
# @param item: 要掉落的物品
func generate(item: Item):
	# 复制物品数据
	self.item = item.duplicate()
	# 设置精灵纹理
	sprite_2d.texture = item.texture

## 设置贝塞尔曲线目标位置
# 计算贝塞尔曲线的起点、控制点和终点
# 创建从当前位置到玩家附近的弧形轨迹
func set_destination() -> void:
	# 计算到玩家的方向
	var direction = global_position.direction_to(player.global_position)

	# 根据玩家相对位置设置终点
	if direction.x >= 0:
		# 玩家在右边，终点设在当前位置右侧
		p2 = global_position + Vector2(20, 0)
		# 偏航角度取负值
		deviation_angle = -deviation_angle
	else:
		# 玩家在左边，终点设在当前位置左侧
		p2 = global_position + Vector2(-20, 0)

	# 设置起点
	p0 = global_position

	# 计算控制点，创建弧形轨迹
	var tilted_unit_vector = (p2 - p0).normalized().rotated(deg_to_rad(deviation_angle))
	p1 = p0 + deviation_distance * tilted_unit_vector

	# 延迟启用物理处理
	call_deferred("set_physics_process", true)
	
## 二次贝塞尔曲线计算
# 自定义的二次贝塞尔曲线插值函数
# @param p0: 起点
# @param p1: 控制点
# @param p2: 终点
# @param t: 插值参数 (0-1)
# @return: 插值结果点
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	# 官方文档的二次贝塞尔曲线函数实现
	var q0 = p0.lerp(p1, t)  # 第一个线性插值
	var q1 = p1.lerp(p2, t)  # 第二个线性插值
	return q0.lerp(q1, t)    # 最终的二次贝塞尔插值
