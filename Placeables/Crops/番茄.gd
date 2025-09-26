extends Node2D
class_name TomatoCrop

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var area_2d: Area2D = $Area2D

@export var fall_objects:Array[Item]

var player:Player = null
var can_hurt:bool
var plant_day:int = 0  # 种植天数
var current_growth_stage:int = 0  # 当前生长阶段
var is_watered:bool = false  # 是否浇水
var is_dead:bool = false  # 是否枯死
var harvest_count:int = 0  # 已收获次数

# 生长阶段对应的纹理区域
var growth_stages = [
	Rect2(192, 160, 16, 16),  # 种子
	Rect2(208, 160, 16, 16),  # 发芽
	Rect2(224, 160, 16, 16),  # 生长
	Rect2(240, 160, 16, 16),  # 开花
	Rect2(192, 160, 16, 16),  # 结果（成熟）
	Rect2(192, 176, 16, 16),  # 枯萎
]

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	hurt_component.body_droped.connect(on_body_droped)
	player = get_tree().get_first_node_in_group("Player")
	TimeSystem.time_tick_day.connect(on_time_tick_day)
	TimeSystem.time_tick.connect(on_time_tick)
	plant_day = TimeSystem.current_day
	can_hurt = false
	update_growth_stage()

func _on_body_entered(body: Node2D) -> void:
	if body is Player and can_hurt:
		var direction := global_position.direction_to(body.global_position)
		var skew := -direction.x * 5  # 判断玩家方向并乘上震动强度
		var tween = create_tween()
		tween.tween_property(sprite_2d.material, "shader_parameter/skew", skew, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite_2d.material, "shader_parameter/skew", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func on_body_droped() -> void:
	call_deferred("add_fall_objects", 1, fall_objects[0])
	if harvest_count >= 3:  # 最多收获3次
		queue_free()

func add_fall_objects(num: int, item: Item) -> void:
	if is_dead:
		return
	for i in range(num):
		var fall_ins = Global.FALL_OBJECT_COMPONENT.instantiate()
		var drops = get_tree().root.get_node_or_null("Drops") as Node2D
		if !drops:
			drops = get_parent()
		fall_ins.is_bezier = true
		fall_ins.position = global_position
		drops.add_child(fall_ins)
		fall_ins.generate(item)

func on_time_tick_day(day: int) -> void:
	var days_grown = day - plant_day
	update_growth_stage()

func on_time_tick(day: int, hour: int, minute: int, week) -> void:
	# 检查是否需要枯萎（超过一天没浇水）
	if is_watered:
		is_watered = false  # 每天都需要浇水
	elif current_growth_stage > 0:
		# 如果已经生长但没浇水，有概率枯萎
		if randf() < 0.1:  # 10%概率枯萎
			wither()

func update_growth_stage() -> void:
	var days_grown = TimeSystem.current_day - plant_day
	var max_growth_days = 11  # 番茄生长11天

	if days_grown >= max_growth_days:
		current_growth_stage = 4  # 成熟
		can_hurt = true
	elif days_grown >= 8:
		current_growth_stage = 3  # 开花
	elif days_grown >= 5:
		current_growth_stage = 2  # 生长
	elif days_grown >= 2:
		current_growth_stage = 1  # 发芽
	else:
		current_growth_stage = 0  # 种子

	# 更新纹理
	if growth_stages.size() > current_growth_stage:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = preload("res://Art/maps/springobjects.es-ES.png")
		atlas_texture.region = growth_stages[current_growth_stage]
		sprite_2d.texture = atlas_texture

func wither() -> void:
	# 枯萎逻辑
	is_dead = true
	current_growth_stage = 5
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = preload("res://Art/maps/springobjects.es-ES.png")
	atlas_texture.region = growth_stages[5]
	sprite_2d.texture = atlas_texture
	can_hurt = true

func water_crop() -> void:
	# 浇水逻辑
	if not is_dead:
		is_watered = true
		# 可以添加浇水特效