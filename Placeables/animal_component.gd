extends Node
class_name AnimalComponent

@onready var block: Sprite2D = $Block
@onready var area_2d: Area2D = $Block/Area2D

@export var ground: TileMapLayer
@export var terrain_set: int = 0  # 地形集合
@export var terrain: int = 5  # 动物放置地形下标

var mouse_position: Vector2  # 鼠标位置
var cell_position: Vector2i  # tile单元格坐标
var cell_source_id: int
var local_cell_position: Vector2  # 单元格中心位置
var distance: float

var player: Player
var can_place: bool = true  # 是否可以放置
var in_grass: bool = false  # 是否在草地上
var layer_masks: Array = [2, 8]  # 与动物碰撞的层

func _ready() -> void:
	await get_parent().ready
	initial()
	SceneManager.level_changed.connect(initial)
	block.hide()
	area_2d.area_entered.connect(on_area_entered)
	area_2d.area_exited.connect(on_area_exited)
	can_place = true
	in_grass = false

func initial():
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	if player.current_item_type == Item.ItemType.Animal:
		get_cell_under_mouse()
		block.show()
		block.global_position = local_cell_position

		# 获取那个位置的瓦片数据
		var tile_data: TileData = ground.get_cell_tile_data(cell_position)
		if tile_data:
			var data = tile_data.get_custom_data("IsGrass")
			if data:
				in_grass = true
		else:
			in_grass = false

		# 检查是否可以放置
		if distance <= 32 and can_place and in_grass:
			block.modulate = Color("0bff2569")  # 绿色 - 可以放置
		else:
			block.modulate = Color("ff192569")  # 红色 - 不可以放置
	else:
		block.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		if player.current_item_type == Item.ItemType.Animal and can_place and in_grass:
			get_cell_under_mouse()
			add_animal()

func on_area_entered(area: Area2D) -> void:
	var layer_mask = area.collision_layer
	if layer_mask in layer_masks:
		can_place = false

func on_area_exited(area: Area2D) -> void:
	can_place = true

func get_cell_under_mouse() -> void:
	mouse_position = ground.get_local_mouse_position()
	cell_position = ground.local_to_map(mouse_position)
	cell_source_id = ground.get_cell_source_id(cell_position)
	local_cell_position = ground.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)

func add_animal() -> void:
	if player.current_item == null:
		return
	if distance <= 32:
		if player.current_item_type == Item.ItemType.Animal:
			var animal_scene = load(player.current_item.placeable_scene_path)
			var animal_ins = animal_scene.instantiate() as Node2D
			animal_ins.global_position = local_cell_position

			# 将动物信息传递给实例
			if animal_ins.has_method("set_animal_item"):
				animal_ins.set_animal_item(player.current_item)

			get_parent().find_child("Animals").add_child(animal_ins)
			player.bag_system.remove_num_item(player.item_index, 1)