extends CharacterBody2D
class_name Player
## 只用于选择Item和此Item对应的动画和状态，其他的功能通过额外组件来实现

@onready var hit_component: HitComponent = $HitComponent
@onready var weapon: Sprite2D = $Weapon/Weapon
@onready var jian_qi: JianQi = $Weapon/JianQi
@onready var effects: AnimatedSprite2D = $Effects
@onready var place_component: PlaceComponent = $PlaceComponent
@onready var state_machine: StateMachine = $StateMachine

@export var bag_system:InventorySystem
@export var current_item_type: Item.ItemType:
	set(val):
		if current_item != null:
			current_item_type = current_item.type
		else:
			current_item_type = Item.ItemType.None
@export var current_item:Item :
	set(val):
		handle_selected_item(val)
		current_item = val
@export var swing_sfx:AudioStream
		
signal watering
signal get_item ##拾取物品发送的信号


var items = null
var item_index:int = 0: ##current_item对应的下标
	set(val):
		item_index = val
		if items[item_index] == null:
			current_item = null
static var direction:Vector2 = Vector2.ZERO#在其他地方调用direction会使用同一个内存空间的direction变量
var player_direction:Vector2 #这个变量用于记住移动之后留下来的方向，上面这个是移动操作的变量
#static var tool_direction:Vector2 #使用工具的方向，根据鼠标来判断
var can_move:bool

var ground:TileMapLayer
var mouse_position:Vector2 #鼠标位置
var cell_position:Vector2i #tile单元格坐标
var cell_source_id:int #用于判断单元格下方是否有tile，-1则是没有
var local_cell_position:Vector2 #单元格中心位置
var distance:float


func _ready() -> void:
	bag_system.items.resize(bag_system.items_size)
	items = bag_system.items
	weapon.hide()
	weapon.offset = Vector2(12,-12)
	weapon.flip_h = false
	weapon.position = Vector2(0,-12)
	jian_qi.hide()
	can_move = true
	effects.hide()
	#只有部分代码需要在场景转换时重新赋值
	initial()
	SceneManager.level_changed.connect(initial)

func initial() -> void:
	ground = get_tree().get_first_node_in_group("TileMap")
	
	
func _process(delta: float) -> void:
	if !effects.is_playing():
		effects.hide()
	
func _physics_process(_delta: float) -> void:
	if can_move:
		direction = Input.get_vector("move_left","move_right","move_up","move_down")
	#tool_direction = global_position.direction_to(get_global_mouse_position())

func handle_selected_item(item:Item) -> void:
	if item == null : return
	current_item_type = item.type
	#设置碰撞箱大小
	if item.collision_size != Vector2.ZERO:
		var coll = hit_component.get_child(0) as CollisionShape2D
		coll.shape.extents = item.collision_size
	elif item.collision_size == Vector2.ZERO:
		var coll = hit_component.get_child(0) as CollisionShape2D
		coll.shape.extents = Vector2(8,8)
	#选中物品时做出的相应效果
	match item.type:
		Item.ItemType.Weapon:
			weapon.texture = item.texture
		Item.ItemType.Placeables:
			place_component.item_to_place = item
		Item.ItemType.Consume:
			pass
		Item.ItemType.Water:
			show_water_effects()
	 

func show_water_effects() -> void:
	get_cell_under_mouse()
	if Input.is_action_just_pressed("mouse_left") and !effects.visible and distance<=40:
		effects.global_position = local_cell_position
		watering.emit(local_cell_position)
		effects.show()
		effects.play("water")
	
func get_cell_under_mouse() -> void:
	if ground == null : return
	mouse_position = ground.get_local_mouse_position() #返回该 CanvasItem 中鼠标的位置
	cell_position = ground.local_to_map(mouse_position) #返回包含给定 mouse_position 的单元格地图坐标
	cell_source_id = ground.get_cell_source_id(cell_position) #返回位于坐标的单元格的图块源 ID。如果单元格不存在则返回 -1。
	local_cell_position = ground.map_to_local(cell_position) #返回位于坐标 coords 的单元格的图块源 ID。如果单元格不存在则返回 -1。
	distance = self.global_position.distance_to(local_cell_position) #玩家到单元格中心的距离
func _unhandled_input(event: InputEvent) -> void: #这个函数可以忽略UI的事件操作
	#可以使用信号转换，也可以使用函数转换
	if current_item == null : return
	if event.is_action_pressed("mouse_left"):
		match self.current_item_type:
			Item.ItemType.Axe:
				state_machine.transition_state("Axe")
			Item.ItemType.Draft:
				state_machine.transition_state("Draft")
			Item.ItemType.Hoe:
				state_machine.transition_state("Hoe")
			Item.ItemType.Water:
				state_machine.transition_state("Water")
			Item.ItemType.Weapon:
				state_machine.transition_state("Swing")
				AudioManager.play_sfx(swing_sfx)
				if current_item.name == "喵刀":
					var rain_bow_cat = load("res://Bag/projectiles/rainbow_cat.tscn").instantiate() as Node2D
					get_tree().root.add_child(rain_bow_cat)
					rain_bow_cat.global_position = global_position
				if current_item.name == "暗影焰刀":
					var rain_bow_cat = load("res://Bag/projectiles/暗影焰刀.tscn").instantiate() as Node2D
					get_tree().root.add_child(rain_bow_cat)
					rain_bow_cat.global_position = global_position
			Item.ItemType.None:
				print("没有物品")
			_:
				print("没有对应类型")
