# Emily NPC 控制器
# 控制Emily角色的移动、动画和对话交互
# Emily在指定范围内自动巡逻，玩家可以通过右键点击与其对话
extends CharacterBody2D  # 继承自CharacterBody2D，具有2D物理和移动能力

# 对话UI预制体
# 预加载对话界面场景，提高运行时性能
const DIALOGUE_UI = preload("res://NPC/dialogue/dialogue_ui.tscn")

# NPC组件引用
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D  # 动画精灵，用于播放NPC动画

# 导出的NPC属性，可以在编辑器中配置
@export var click_area:ClickAreaComponent  # 点击区域组件，处理鼠标交互
@export var dialogue:Dialogue  # 对话数据，包含NPC的对白内容

# NPC状态变量
var speed:int = 30  # 移动速度，像素/秒
var direction:Vector2  # 当前移动方向
var initial_pos  # 初始位置，用于计算巡逻路径
var is_dialogue:bool  # 是否正在对话中

func _ready() -> void:
	# 初始化设置
	# 连接右键点击信号到对话处理函数
	click_area.mouse_right_click.connect(on_mouse_right_click)

	# 记录初始位置，用于巡逻路径计算
	initial_pos = global_position

	# 初始状态为非对话状态
	is_dialogue = false

func _physics_process(delta: float) -> void:
	# 物理帧更新，处理NPC的主要逻辑
	# 每物理帧执行一次，确保物理计算的准确性

	if !is_dialogue:
		# 非对话状态：执行自动巡逻逻辑
		# 在指定矩形区域内来回移动
		if global_position.distance_to(initial_pos) < 2.0:
			# 如果接近初始位置，向右移动
			direction = Vector2.RIGHT
		elif global_position.distance_to(initial_pos + Vector2(50,0)) <2.0:
			# 如果接近右上角，向下移动
			direction = Vector2.DOWN
		elif global_position.distance_to(initial_pos + Vector2(50,50)) <2.0:
			# 如果接近右下角，向左移动
			direction = Vector2.LEFT
		elif global_position.distance_to(initial_pos + Vector2(0,50)) <2.0:
			# 如果接近左下角，向上移动
			direction = Vector2.UP
	else:
		# 对话状态：停止移动并播放跳舞动画
		direction = Vector2.ZERO  # 停止移动
		animated_sprite_2d.play("dance1")  # 播放跳舞动画

		# 预留的返回初始位置逻辑（已注释）
		#if global_position.distance_to(initial_pos) > 10:
			#direction = global_position.direction_to(initial_pos)

	# 检查对话是否结束
	# 获取弹窗容器中的对话UI
	var pop_up = get_node(Global.root_scene["pop_up"])
	var dialogue_ui = pop_up.find_child("DialogueUi")
	if !dialogue_ui:
		# 如果对话UI不存在，说明对话已结束
		is_dialogue = false

	# 执行移动
	velocity = speed * direction  # 设置速度向量
	move_and_slide()  # 执行移动并处理碰撞

	# 更新动画
	update_anim()
	
## 更新动画播放
# 根据移动方向更新NPC的动画播放和精灵翻转
# 确保NPC在移动时显示正确的动画和朝向
func update_anim():
	# 处理精灵翻转
	# 向左移动时翻转精灵，向其他方向时保持正常
	if direction == Vector2.LEFT:
		animated_sprite_2d.flip_h = true  # 水平翻转精灵
	else:
		animated_sprite_2d.flip_h = false  # 恢复正常方向

	# 根据移动方向播放对应的动画
	if direction == Vector2.ZERO:
		# 静止时播放空闲动画
		animated_sprite_2d.play("idle")
	if direction == Vector2.DOWN:
		# 向下移动时播放向下移动动画
		animated_sprite_2d.play("move_down")
	if direction == Vector2.UP:
		# 向上移动时播放向上移动动画
		animated_sprite_2d.play("move_up")
	if direction == Vector2.LEFT:
		# 向左移动时播放向右移动动画（配合翻转实现向左移动效果）
		animated_sprite_2d.play("move_right")
	if direction == Vector2.RIGHT:
		# 向右移动时播放向右移动动画
		animated_sprite_2d.play("move_right")

## 鼠标右键点击处理
# 当玩家右键点击NPC时，检查距离并开启对话
# 只有在玩家足够接近时才允许对话
func on_mouse_right_click() ->void:
	# 获取玩家节点
	# 使用Player组来查找玩家，避免直接引用可能出现的空指针
	var player := get_tree().get_first_node_in_group("Player")

	# 检查玩家是否在对话距离内（20像素）
	if global_position.distance_to(player.global_position) < 20:
		# 玩家在对话距离内，开启对话模式
		is_dialogue = true

		# 实例化对话UI
		# 创建对话界面实例并设置对话数据
		var dialogue_ui = DIALOGUE_UI.instantiate()
		dialogue_ui.dialogue = dialogue

		# 获取弹窗容器并添加对话UI
		# 对话UI会被添加到弹窗容器中，确保显示在最上层
		var pop_up = get_node(Global.root_scene["pop_up"])
		pop_up.add_child(dialogue_ui)
