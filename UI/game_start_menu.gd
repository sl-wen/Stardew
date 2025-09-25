extends CanvasLayer

@onready var title: TextureRect = %Title
@onready var buttons: MarginContainer = %Buttons
@onready var create: TextureButton = %Create
@onready var load: TextureButton = %Load
@onready var coop: TextureButton = %Coop
@onready var exit: TextureButton = %Exit

@export var bg_music1:AudioStream

func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(title,"global_position",Vector2(342,90),0.5)
	tween.set_parallel()
	tween.tween_property(buttons,"global_position",Vector2(408,440),0.5)
	create.pressed.connect(_on_create_pressed)
	load.pressed.connect(_on_load_pressed)
	coop.pressed.connect(_on_coop_pressed)
	exit.pressed.connect(_on_exit_pressed)
	AudioManager.play_music(bg_music1)

func _on_create_pressed() -> void:
	print("开始新建游戏...")

	# 加载主场景
	SceneManager.load_main_scene()

	# 初始化新游戏状态
	SaveManager.new_game()

	# 移除开始菜单
	queue_free()

	print("新游戏创建完成")


func _on_load_pressed() -> void:
	print("开始加载游戏...")

	# 加载主场景
	SceneManager.load_main_scene()

	# 尝试加载存档数据
	SaveManager._load()

	# 移除开始菜单
	queue_free()

	print("游戏加载完成")

func _on_coop_pressed() -> void:
	print("多人游戏功能暂未实现")
	# TODO: 实现多人游戏功能
	# 可以在这里添加多人游戏的初始化逻辑


func _on_exit_pressed() -> void:
	get_tree().quit()
