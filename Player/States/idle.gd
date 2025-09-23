# 闲置状态
# 玩家静止不动时的状态，显示闲置动画
# 当玩家开始移动时自动切换到移动状态
extends State

## 玩家引用
# 通过@export在Godot编辑器中连接到Player节点
@export var player:Player

## 动画播放器引用
# 用于播放玩家动画
@export var anim:AnimationPlayer

## 进入闲置状态
# 当玩家停止移动进入此状态时调用
# 播放默认的向下闲置动画
func _enter():
	print("Idle")
	# 播放向下闲置动画
	anim.play("idle_down")

## 退出闲置状态
# 当玩家离开闲置状态时调用
# 目前暂无特殊处理逻辑
func _exit():
	pass

## 物理帧更新
# 每物理帧检查是否需要状态转换
# @param delta: 物理帧间隔时间
func _physics_update(delta):
	# 更新动画显示
	_update_animation()

	# 如果玩家开始移动，切换到移动状态
	if player.direction != Vector2.ZERO:
		transition_to.emit("Move")

## 更新动画显示
# 根据玩家朝向播放对应的闲置动画
# 确保动画方向与玩家朝向保持一致
func _update_animation():
	# 根据玩家朝向播放对应的闲置动画
	if player.player_direction == Vector2.UP:
		anim.play("idle_up")
	elif player.player_direction == Vector2.DOWN:
		anim.play("idle_down")
	elif player.player_direction == Vector2.LEFT:
		anim.play("idle_left")
	elif player.player_direction == Vector2.RIGHT:
		anim.play("idle_right")

# 注释：以下是未使用的输入处理函数
# 如果需要处理鼠标输入，可以取消注释
# func _unhandled_input(event: InputEvent) -> void:
# 	# 处理鼠标左键点击，根据物品类型切换到相应状态
# 	if event.is_action_pressed("mouse_left"):
# 		match player.current_item_type:
# 			Item.ItemType.Axe:
# 				transition_to.emit("Axe")
# 			Item.ItemType.Draft:
# 				transition_to.emit("Draft")
# 			Item.ItemType.Hoe:
# 				transition_to.emit("Hoe")
# 			Item.ItemType.Water:
# 				transition_to.emit("Water")
# 			Item.ItemType.Weapon:
# 				transition_to.emit("Swing")
# 			_:
# 				print("没有对应类型")
