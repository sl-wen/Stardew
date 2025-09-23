# 玩家角色主控制器
# 负责玩家移动、物品使用、工具操作等核心功能
# 采用状态机模式管理不同的玩家状态（移动、攻击、使用工具等）
extends CharacterBody2D
class_name Player

## 玩家组件引用
# 通过@onready获取场景中的各个组件节点
@onready var hit_component: HitComponent = $HitComponent  # 碰撞检测组件
@onready var weapon: Sprite2D = $Weapon/Weapon           # 武器精灵
@onready var jian_qi: JianQi = $Weapon/JianQi             # 剑气效果
@onready var effects: AnimatedSprite2D = $Effects        # 特效动画精灵
@onready var place_component: PlaceComponent = $PlaceComponent  # 放置组件
@onready var state_machine: StateMachine = $StateMachine  # 状态机

## 导出的玩家属性
# 这些属性可以在Godot编辑器中进行配置
@export var bag_system:InventorySystem  # 背包系统，管理玩家物品栏
@export var current_item_type: Item.ItemType:
	# 当设置物品类型时，根据当前物品自动更新
	set(val):
		if current_item != null:
			current_item_type = current_item.type
		else:
			current_item_type = Item.ItemType.None
@export var current_item:Item :
	# 当设置当前物品时，处理物品选择逻辑
	set(val):
		handle_selected_item(val)
		current_item = val
@export var swing_sfx:AudioStream  # 挥舞音效资源

## 玩家信号
# 用于与其他系统通信
signal watering  # 浇水信号
signal get_item # 拾取物品信号

## 玩家状态变量
var items = null  # 物品数组引用
var item_index:int = 0:  # 当前物品在物品栏中的索引
	set(val):
		item_index = val
		if items[item_index] == null:
			current_item = null
static var direction:Vector2 = Vector2.ZERO  # 移动方向（静态变量，供其他地方访问）
var player_direction:Vector2  # 玩家朝向方向（用于记住移动后的方向）
# static var tool_direction:Vector2  # 工具使用方向（根据鼠标位置计算）
var can_move:bool  # 是否可以移动

## 地图交互变量
var ground:TileMapLayer     # 地面图块层引用
var mouse_position:Vector2  # 鼠标在地面上的位置
var cell_position:Vector2i  # 鼠标所在单元格的地图坐标
var cell_source_id:int      # 单元格的图块源ID（-1表示没有图块）
var local_cell_position:Vector2  # 单元格的中心位置
var distance:float          # 玩家到单元格中心的距离


func _ready() -> void:
	# 初始化背包系统
	bag_system.items.resize(bag_system.items_size)
	items = bag_system.items

	# 初始化武器显示
	weapon.hide()
	weapon.offset = Vector2(12,-12)  # 设置武器偏移位置
	weapon.flip_h = false           # 不翻转武器
	weapon.position = Vector2(0,-12) # 设置武器位置

	# 初始化其他组件
	jian_qi.hide()      # 隐藏剑气效果
	can_move = true     # 允许移动
	effects.hide()      # 隐藏特效

	# 设置初始朝向（向下）
	player_direction = Vector2.DOWN

	# 连接场景切换信号，确保场景切换后重新初始化
	SceneManager.level_changed.connect(initial)

	# 执行初始化
	initial()

## 初始化玩家相关引用
# 在游戏开始和场景切换时调用，获取地面图块层引用
func initial() -> void:
	ground = get_tree().get_first_node_in_group("TileMap")

## 每帧处理
# 主要处理特效动画的隐藏逻辑
# @param delta: 帧间隔时间
func _process(delta: float) -> void:
	# 如果特效动画播放完毕，隐藏特效精灵
	if !effects.is_playing():
		effects.hide()

## 物理帧处理
# 处理玩家移动输入
# @param _delta: 帧间隔时间（未使用）
func _physics_process(_delta: float) -> void:
	if can_move:
		# 获取WASD输入方向向量
		direction = Input.get_vector("move_left","move_right","move_up","move_down")
		# 计算工具使用方向（根据鼠标位置）
		# tool_direction = global_position.direction_to(get_global_mouse_position())

## 处理物品选择
# 当玩家选择物品时，更新碰撞箱大小并设置相应的物品效果
# @param item: 被选择的物品
func handle_selected_item(item:Item) -> void:
	if item == null:
		return

	current_item_type = item.type

	# 根据物品类型设置碰撞箱大小
	if item.collision_size != Vector2.ZERO:
		# 使用物品指定的碰撞箱大小
		var coll = hit_component.get_child(0) as CollisionShape2D
		coll.shape.extents = item.collision_size
	elif item.collision_size == Vector2.ZERO:
		# 使用默认碰撞箱大小
		var coll = hit_component.get_child(0) as CollisionShape2D
		coll.shape.extents = Vector2(8,8)

	# 根据物品类型设置相应的视觉效果
	match item.type:
		Item.ItemType.Weapon:
			# 设置武器纹理
			weapon.texture = item.texture
		Item.ItemType.Placeables:
			# 设置要放置的物品
			place_component.item_to_place = item
		Item.ItemType.Consume:
			# 消耗物品暂无特殊效果
			pass
		Item.ItemType.Water:
			# 水壶需要显示浇水效果
			show_water_effects()

## 显示浇水效果
# 当使用水壶时，在鼠标位置显示浇水动画
func show_water_effects() -> void:
	# 获取鼠标下的单元格信息
	get_cell_under_mouse()

	# 当玩家左键点击且特效不可见且距离足够近时
	if Input.is_action_just_pressed("mouse_left") and !effects.visible and distance <= 40:
		# 设置特效位置
		effects.global_position = local_cell_position
		# 发出浇水信号
		watering.emit(local_cell_position)
		# 显示并播放浇水动画
		effects.show()
		effects.play("water")

## 获取鼠标下的单元格信息
# 计算鼠标位置对应的地图单元格信息，用于工具操作
func get_cell_under_mouse() -> void:
	if ground == null:
		return

	# 获取鼠标在地面图块层中的本地位置
	mouse_position = ground.get_local_mouse_position()

	# 转换为地图坐标
	cell_position = ground.local_to_map(mouse_position)

	# 获取单元格的图块源ID
	cell_source_id = ground.get_cell_source_id(cell_position)

	# 获取单元格的世界位置
	local_cell_position = ground.map_to_local(cell_position)

	# 计算玩家到单元格中心的距离
	distance = self.global_position.distance_to(local_cell_position)

## 处理未处理的用户输入
# 响应鼠标左键点击，根据当前物品类型切换到相应的状态
# 这个函数可以忽略UI事件，确保游戏逻辑的响应优先级
# @param event: 输入事件
func _unhandled_input(event: InputEvent) -> void:
	# 如果当前没有选中物品，直接返回
	if current_item == null:
		return

	# 处理左键点击事件
	if event.is_action_pressed("mouse_left"):
		match self.current_item_type:
			Item.ItemType.Axe:
				# 切换到斧头状态（用于砍树）
				state_machine.transition_state("Axe")
			Item.ItemType.Draft:
				# 切换到草图状态（用于绘制）
				state_machine.transition_state("Draft")
			Item.ItemType.Hoe:
				# 切换到锄头状态（用于耕地）
				state_machine.transition_state("Hoe")
			Item.ItemType.Water:
				# 切换到浇水状态
				state_machine.transition_state("Water")
			Item.ItemType.Weapon:
				# 切换到挥舞状态
				state_machine.transition_state("Swing")
				# 播放挥舞音效
				AudioManager.play_sfx(swing_sfx)

				# 特殊武器效果处理
				if current_item.name == "喵刀":
					# 生成真彩虹猫效果
					var rain_bow_cat = load("res://Bag/projectiles/rainbow_cat.tscn").instantiate() as Node2D
					get_tree().root.add_child(rain_bow_cat)
					rain_bow_cat.global_position = global_position
				if current_item.name == "暗影焰刀":
					# 生成暗影焰刀效果
					var rain_bow_cat = load("res://Bag/projectiles/暗影焰刀.tscn").instantiate() as Node2D
					get_tree().root.add_child(rain_bow_cat)
					rain_bow_cat.global_position = global_position
			Item.ItemType.None:
				print("没有物品")
			_:
				print("没有对应类型")
