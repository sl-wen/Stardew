extends Node2D
class_name Chicken

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D

var animal_item: Item  # 关联的动物物品
var happiness: int = 70  # 幸福度 (0-100)
var last_production_day: int = 0  # 上次生产日期
var has_produced_today: bool = false  # 今天是否已生产

# 鸡的动画帧
var idle_frames = [
	Rect2(432, 144, 16, 16),
	Rect2(448, 144, 16, 16)
]

var animation_timer: float = 0.0
var current_frame: int = 0

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	TimeSystem.time_tick_day.connect(on_time_tick_day)
	TimeSystem.time_tick.connect(on_time_tick)

func set_animal_item(item: Item) -> void:
	animal_item = item
	happiness = item.happiness

func _process(delta: float) -> void:
	# 简单的动画循环
	animation_timer += delta
	if animation_timer >= 0.5:  # 每0.5秒切换一次帧
		animation_timer = 0.0
		current_frame = (current_frame + 1) % idle_frames.size()

		# 更新纹理
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = preload("res://Art/maps/springobjects.es-ES.png")
		atlas_texture.region = idle_frames[current_frame]
		sprite_2d.texture = atlas_texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# 玩家接近时增加幸福度
		if happiness < 100:
			happiness += 1

func on_time_tick_day(day: int) -> void:
	# 重置每日生产状态
	has_produced_today = false
	last_production_day = day

	# 随机增加或减少幸福度（模拟喂食、环境等因素）
	var happiness_change = randi_range(-5, 3)
	happiness = clamp(happiness + happiness_change, 0, 100)

func on_time_tick(day: int, hour: int, minute: int, week) -> void:
	# 鸡在早上6-8点产蛋
	if not has_produced_today and hour >= 6 and hour <= 8:
		if happiness >= 50:  # 幸福度足够时才产蛋
			produce_egg()
			has_produced_today = true

func produce_egg() -> void:
	# 生产鸡蛋
	if animal_item and animal_item.produces.size() > 0:
		var egg_item = load("res://Bag/items/animal/鸡蛋.tres") as Item
		if egg_item:
			# 创建掉落物
			var fall_ins = Global.FALL_OBJECT_COMPONENT.instantiate()
			var drops = get_tree().root.get_node_or_null("Drops") as Node2D
			if !drops:
				drops = get_parent()
			fall_ins.is_bezier = true
			fall_ins.position = global_position + Vector2(randf_range(-10, 10), -10)
			drops.add_child(fall_ins)
			fall_ins.generate(egg_item)

func interact_with_player() -> void:
	# 玩家与鸡互动
	var happiness_increase = randi_range(5, 15)
	happiness = clamp(happiness + happiness_increase, 0, 100)

	# 可以添加音效或特效
	print("鸡的幸福度增加了！当前幸福度：", happiness)