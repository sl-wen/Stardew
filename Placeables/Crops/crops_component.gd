extends Node
class_name CropsComponent

@onready var block: Sprite2D = $Block
@onready var area_2d: Area2D = $Block/Area2D

@export var tilled_soil: TileMapLayer
@export var ground:TileMapLayer
@export var water_soil:TileMapLayer
@export var terrain_set: int = 0 #泥土瓦片tilemaplayer中的地形集合
@export var terrain:int = 4 #浇水泥土瓦片地形下标

var mouse_position:Vector2 #鼠标位置
var cell_position:Vector2i #tile单元格坐标
var cell_source_id:int
var local_cell_position:Vector2 #单元格中心位置
var distance:float

var player:Player
var can_crop:bool ##是否可以种植，检测是否有其他障碍物
var in_soil:bool ##是否在泥土
var layer_masks:Array = [2,8] #与种植作物碰撞的层
#这个是位掩码转换的值和2的次方有关，每一层具体的值，可以通过将光标放在那一层上可以看到

func _ready() -> void:
	await get_parent().ready#
	initial()
	SceneManager.level_changed.connect(initial)
	block.hide()
	area_2d.area_entered.connect(on_area_entered)
	area_2d.area_exited.connect(on_area_exited)
	can_crop = true
	in_soil = false
	player.watering.connect(on_watering)

func initial():
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	if player.current_item_type == Item.ItemType.Seeds or player.current_item_type == Item.ItemType.Water:
		get_cell_under_mouse()
		block.show()
		block.global_position = local_cell_position
		#获取那个位置的瓦片数据
		var tile_data:TileData = tilled_soil.get_cell_tile_data(cell_position)
		#获取自定义数据
		if tile_data:
			var data = tile_data.get_custom_data("IsSoil")
			#print(data)
			if data:
				in_soil = true
		else:
			in_soil = false
		#上面这一段都是在判断是否是泥土

		# 季节检测
		var current_season = get_current_season()
		var can_plant_in_season = can_plant_in_current_season(player.current_item, current_season)

		if distance <= 32 and can_crop and in_soil and can_plant_in_season:
			block.modulate = Color("0bff2569")  # 绿色 - 可以种植
		else:
			block.modulate = Color("ff192569")  # 红色 - 不可以种植
	else:
		block.hide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		if player.current_item_type == Item.ItemType.Seeds and can_crop and in_soil:
			var current_season = get_current_season()
			var can_plant_in_season = can_plant_in_current_season(player.current_item, current_season)
			if can_plant_in_season:
				get_cell_under_mouse()
				add_crop()

#能否种植的区域碰撞检测
func on_area_entered(area:Area2D) -> void:
	var layer_mask = area.collision_layer #能够检测到作物
	if layer_mask in layer_masks: 
		can_crop = false
		

func on_area_exited(area:Area2D) -> void:
	can_crop = true
	#小bug，area_exited始终会比进入另一个区域的area_entered优先执行
	
func get_cell_under_mouse() -> void:
	mouse_position = ground.get_local_mouse_position() #返回该 CanvasItem 中鼠标的位置
	cell_position = ground.local_to_map(mouse_position) #返回包含给定 mouse_position 的单元格地图坐标
	cell_source_id = ground.get_cell_source_id(cell_position) #返回位于坐标的单元格的图块源 ID。如果单元格不存在则返回 -1。
	local_cell_position = ground.map_to_local(cell_position) #返回位于坐标 coords 的单元格的图块源 ID。如果单元格不存在则返回 -1。
	distance = player.global_position.distance_to(local_cell_position) #玩家到单元格中心的距离

func add_crop() -> void:
	if player.current_item == null: return
	if distance <= 32:
		if player.current_item_type == Item.ItemType.Seeds:
			var crop_scene = load(player.current_item.placeable_scene_path)
			var crop_ins = crop_scene.instantiate() as Node2D
			crop_ins.global_position = local_cell_position

			# 将种子信息传递给作物实例
			if crop_ins.has_method("set_seed_item"):
				crop_ins.set_seed_item(player.current_item)

			get_parent().find_child("Crops").add_child(crop_ins)
			player.bag_system.remove_num_item(player.item_index, 1)
				
	
func remove_crop() -> void:
	if distance <= 32:
		var crop_nodes = get_parent().find_child("Crops").get_children()
		for i:Node2D in crop_nodes:
			if i.global_position == local_cell_position:
				queue_free()

func on_watering(local_cell_position) -> void:
	get_cell_under_mouse()
	if cell_source_id != -1 and in_soil:
		water_soil.set_cells_terrain_connect([cell_position],terrain_set,terrain,true)

		# 浇水已种植的作物
		var crop_nodes = get_parent().find_child("Crops").get_children()
		for crop_node in crop_nodes:
			if crop_node.global_position == local_cell_position:
				if crop_node.has_method("water_crop"):
					crop_node.water_crop()
				break

func get_current_season() -> Item.Season:
	# 获取当前季节，从TimeSystem获取正确计算
	return TimeSystem.current_season

func can_plant_in_current_season(seed_item: Item, current_season: Item.Season) -> bool:
	if not seed_item or seed_item.seasons.size() == 0:
		return true  # 如果没有季节限制，任何时候都可以种植
	return current_season in seed_item.seasons
