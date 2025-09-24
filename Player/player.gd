# 玩家角色主控制器
# 负责玩家移动、物品使用、工具操作等核心功能
# 采用状态机模式管理不同的玩家状态（移动、攻击、使用工具等）
# 作为整个游戏的核心控制器，管理玩家与游戏世界的交互
extends CharacterBody2D  # 继承自CharacterBody2D，具有2D物理和移动能力
class_name Player  # 定义玩家类的类名，便于在代码中引用

## 玩家组件引用
# 通过@onready获取场景中的各个组件节点
# 这些组件在节点树中必须存在，负责不同的玩家功能
@onready var hit_component: HitComponent = $HitComponent  # 碰撞检测组件，用于工具和武器的碰撞检测
@onready var weapon: Sprite2D = $Weapon/Weapon           # 武器精灵，显示玩家当前装备的武器纹理
@onready var jian_qi: JianQi = $Weapon/JianQi             # 剑气效果，特殊武器的视觉效果组件
@onready var effects: AnimatedSprite2D = $Effects        # 特效动画精灵，用于显示浇水、攻击等特效
@onready var place_component: PlaceComponent = $PlaceComponent  # 放置组件，负责玩家放置物品的功能
@onready var state_machine: StateMachine = $StateMachine  # 状态机，管理玩家当前的行为状态

## 导出的玩家属性
# 这些属性可以在Godot编辑器中进行配置
# 允许设计师在不修改代码的情况下调整玩家参数
@export var bag_system:InventorySystem  # 背包系统，管理玩家物品栏和物品存储
@export var current_item_type: Item.ItemType:
	# 当设置物品类型时，根据当前物品自动更新
	# 这个setter确保物品类型与当前物品保持同步
	set(val):
		if current_item != null:
			# 如果有当前物品，使用物品的实际类型
			current_item_type = current_item.type
		else:
			# 如果没有物品，设为None类型
			current_item_type = Item.ItemType.None
@export var current_item:Item :
	# 当设置当前物品时，处理物品选择逻辑
	# 这个setter在物品改变时自动调用相关处理函数
	set(val):
		handle_selected_item(val)
		current_item = val
@export var swing_sfx:AudioStream  # 挥舞音效资源，用于武器挥舞时的声音效果

## 玩家信号
# 用于与其他系统通信，解耦玩家与其他游戏系统
signal watering  # 浇水信号，当玩家使用浇水工具时发出
signal get_item # 拾取物品信号，当玩家拾取物品时发出

## 玩家状态变量
var items = null  # 物品数组引用，指向背包系统中的物品数组
var item_index:int = 0:  # 当前物品在物品栏中的索引
	# 当物品索引改变时，自动更新当前物品
	set(val):
		item_index = val
		# 如果指定索引的物品不存在，清空当前物品
		if items[item_index] == null:
			current_item = null
static var direction:Vector2 = Vector2.ZERO  # 移动方向（静态变量，供其他地方访问）
var player_direction:Vector2  # 玩家朝向方向（用于记住移动后的方向）
# static var tool_direction:Vector2  # 工具使用方向（根据鼠标位置计算）
var can_move:bool  # 是否可以移动，用于控制玩家移动的启用/禁用

## 地图交互变量
var ground:TileMapLayer     # 地面图块层引用，用于地图交互计算
var mouse_position:Vector2  # 鼠标在地面上的位置，用于精确的鼠标交互
var cell_position:Vector2i  # 鼠标所在单元格的地图坐标，用于单元格级别的操作
var cell_source_id:int      # 单元格的图块源ID（-1表示没有图块）
var local_cell_position:Vector2  # 单元格的中心位置，用于特效和交互定位
var distance:float          # 玩家到单元格中心的距离，用于距离判断


func _ready() -> void:
	# 初始化背包系统
	# 调整物品数组大小以匹配背包容量
	bag_system.items.resize(bag_system.items_size)
	# 获取物品数组引用，便于后续访问和修改
	items = bag_system.items

	# 初始化武器显示
	weapon.hide()  # 初始时隐藏武器，等待玩家选择武器后显示
	weapon.offset = Vector2(12,-12)  # 设置武器相对位置偏移
	weapon.flip_h = false           # 不翻转武器纹理
	weapon.position = Vector2(0,-12) # 设置武器在玩家身上的位置

	# 初始化其他组件
	jian_qi.hide()      # 隐藏剑气效果，等待特殊武器触发
	can_move = true     # 允许移动，玩家可以自由移动
	effects.hide()      # 隐藏特效动画，等待需要时显示

	# 设置初始朝向（向下）
	# 玩家默认面向下方，这会影响Idle状态的动画方向
	player_direction = Vector2.DOWN

	# 连接场景切换信号，确保场景切换后重新初始化
	# 当玩家在不同场景间切换时，需要重新获取地面引用等
	SceneManager.level_changed.connect(initial)

	# 执行初始化
	# 获取地面图块层引用等初始化操作
	initial()

## 初始化玩家相关引用
# 在游戏开始和场景切换时调用，获取地面图块层引用
# 确保玩家与地图系统正确交互
func initial() -> void:
	# 获取TileMap组中的第一个节点作为地面图块层
	# 这个组包含游戏中的所有TileMap节点
	ground = get_tree().get_first_node_in_group("TileMap")

## 每帧处理
# 主要处理特效动画的隐藏逻辑
# 每渲染帧执行一次，用于处理不需要物理计算的更新
# @param delta: 帧间隔时间，单位为秒
func _process(delta: float) -> void:
	# 如果特效动画播放完毕，隐藏特效精灵
	# 避免播放完毕的特效继续显示在屏幕上
	if !effects.is_playing():
		effects.hide()

## 物理帧处理
# 处理玩家移动输入
# 每物理帧执行一次，用于处理物理相关计算和移动
# @param _delta: 帧间隔时间（未使用）
func _physics_process(_delta: float) -> void:
	# 检查是否允许移动
	if can_move:
		# 获取WASD输入方向向量
		# Input.get_vector将四个方向键的输入转换为标准化向量
		# move_left/move_right/move_up/move_down在project.godot中定义
		direction = Input.get_vector("move_left","move_right","move_up","move_down")

		# 计算工具使用方向（根据鼠标位置）
		# 这行代码被注释掉了，但预留了功能
		# tool_direction = global_position.direction_to(get_global_mouse_position())

## 处理物品选择
# 当玩家选择物品时，更新碰撞箱大小并设置相应的物品效果
# 这个函数在物品改变时自动调用，确保玩家状态与物品同步
# @param item: 被选择的物品，如果为null则直接返回
func handle_selected_item(item:Item) -> void:
	# 安全检查：如果物品为空，不执行任何操作
	if item == null:
		return

	# 更新当前物品类型
	current_item_type = item.type

	# 根据物品类型设置碰撞箱大小
	# 碰撞箱决定工具/武器的攻击范围
	if item.collision_size != Vector2.ZERO:
		# 使用物品指定的碰撞箱大小
		# 不同物品可能有不同大小的碰撞范围
		var coll = hit_component.get_child(0) as CollisionShape2D
		coll.shape.extents = item.collision_size
	elif item.collision_size == Vector2.ZERO:
		# 使用默认碰撞箱大小
		# 当物品没有指定碰撞大小时，使用8x8的默认尺寸
		var coll = hit_component.get_child(0) as CollisionShape2D
		coll.shape.extents = Vector2(8,8)

	# 根据物品类型设置相应的视觉效果
	# 不同类型的物品需要不同的视觉表现
	match item.type:
		Item.ItemType.Weapon:
			# 设置武器纹理
			# 将武器的纹理应用到武器精灵上
			weapon.texture = item.texture
		Item.ItemType.Placeables:
			# 设置要放置的物品
			# 告诉放置组件当前要放置的物品
			place_component.item_to_place = item
		Item.ItemType.Consume:
			# 消耗物品暂无特殊效果
			# 消耗类物品（如食物、药水）暂时没有特殊的视觉效果
			pass
		Item.ItemType.Water:
			# 水壶需要显示浇水效果
			# 水壶类物品需要特殊的浇水效果处理
			show_water_effects()

## 显示浇水效果
# 当使用水壶时，在鼠标位置显示浇水动画
# 这个函数处理水壶类物品的使用逻辑和视觉效果
func show_water_effects() -> void:
	# 获取鼠标下的单元格信息
	# 计算鼠标位置对应的地图单元格，用于确定浇水目标
	get_cell_under_mouse()

	# 当玩家左键点击且特效不可见且距离足够近时
	# 确保玩家在有效距离内点击才触发浇水效果
	if Input.is_action_just_pressed("mouse_left") and !effects.visible and distance <= 40:
		# 设置特效位置到目标单元格中心
		effects.global_position = local_cell_position

		# 发出浇水信号，通知其他系统（如农田系统）进行浇水处理
		# 传递浇水位置，让农田系统知道哪个位置被浇水了
		watering.emit(local_cell_position)

		# 显示并播放浇水动画
		effects.show()
		effects.play("water")

## 获取鼠标下的单元格信息
# 计算鼠标位置对应的地图单元格信息，用于工具操作
# 这个函数是玩家与地图交互的核心，提供精确的鼠标定位信息
func get_cell_under_mouse() -> void:
	# 安全检查：确保地面图块层存在
	if ground == null:
		return

	# 获取鼠标在地面图块层中的本地位置
	# get_local_mouse_position()返回鼠标相对于图块层的本地坐标
	mouse_position = ground.get_local_mouse_position()

	# 转换为地图坐标
	# local_to_map()将本地坐标转换为TileMap的单元格坐标
	cell_position = ground.local_to_map(mouse_position)

	# 获取单元格的图块源ID
	# 源ID用于标识单元格中放置的是什么类型的图块
	# -1表示该单元格为空
	cell_source_id = ground.get_cell_source_id(cell_position)

	# 获取单元格的世界位置
	# map_to_local()将地图坐标转换为世界坐标
	# 这个位置用于特效显示和交互计算
	local_cell_position = ground.map_to_local(cell_position)

	# 计算玩家到单元格中心的距离
	# 用于判断玩家是否在有效操作距离内
	distance = self.global_position.distance_to(local_cell_position)

## 处理未处理的用户输入
# 响应鼠标左键点击，根据当前物品类型切换到相应的状态
# 这个函数可以忽略UI事件，确保游戏逻辑的响应优先级
# _unhandled_input是Godot的特殊函数，用于处理未被UI或其他节点处理的事件
# @param event: 输入事件，包含鼠标、键盘等输入信息
func _unhandled_input(event: InputEvent) -> void:
	# 如果当前没有选中物品，直接返回
	# 避免在没有物品的情况下执行不必要的处理
	if current_item == null:
		return

	# 处理左键点击事件
	# 只有在有选中物品的情况下才响应左键点击
	if event.is_action_pressed("mouse_left"):
		# 根据当前物品类型切换到相应的状态
		# 每种物品类型都有对应的使用状态
		match self.current_item_type:
			Item.ItemType.Axe:
				# 切换到斧头状态（用于砍树）
				# Axe状态处理斧头的挥舞和砍伐逻辑
				state_machine.transition_state("Axe")
			Item.ItemType.Draft:
				# 切换到草图状态（用于绘制）
				# Draft状态处理绘图工具的使用
				state_machine.transition_state("Draft")
			Item.ItemType.Hoe:
				# 切换到锄头状态（用于耕地）
				# Hoe状态处理锄头的耕地逻辑
				state_machine.transition_state("Hoe")
			Item.ItemType.Water:
				# 切换到浇水状态
				# Water状态处理水壶的浇水逻辑
				state_machine.transition_state("Water")
			Item.ItemType.Weapon:
				# 切换到挥舞状态
				# Swing状态处理武器的攻击逻辑
				state_machine.transition_state("Swing")

				# 播放挥舞音效
				# 武器挥舞时播放音效增强游戏体验
				AudioManager.play_sfx(swing_sfx)

				# 特殊武器效果处理
				# 根据武器名称执行特殊的视觉效果
				if current_item.name == "喵刀":
					# 生成真彩虹猫效果
					# 加载彩虹猫弹丸场景并实例化
					var rain_bow_cat = load("res://Bag/projectiles/rainbow_cat.tscn").instantiate() as Node2D
					# 添加到场景根节点
					get_tree().root.add_child(rain_bow_cat)
					# 设置在玩家当前位置
					rain_bow_cat.global_position = global_position
				if current_item.name == "暗影焰刀":
					# 生成暗影焰刀效果
					# 加载暗影焰刀弹丸场景并实例化
					var rain_bow_cat = load("res://Bag/projectiles/暗影焰刀.tscn").instantiate() as Node2D
					# 添加到场景根节点
					get_tree().root.add_child(rain_bow_cat)
					# 设置在玩家当前位置
					rain_bow_cat.global_position = global_position
			Item.ItemType.None:
				# 调试输出：没有物品时的状态
				print("没有物品")
			_:
				# 调试输出：未知物品类型
				print("没有对应类型")
