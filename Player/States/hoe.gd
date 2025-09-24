# 锄头状态
# 负责处理玩家使用锄头工具的逻辑，包括动画播放
# 锄头主要用于耕种土地，创建可种植作物的农田
extends State  # 继承自状态基类

# 导出的属性，可以在Godot编辑器中进行配置
@export var player: Player  # 玩家主脚本引用，用于访问玩家属性
@export var anim: AnimationPlayer  # 动画播放器引用，用于播放锄头动画
@export var tool_collistion: CollisionShape2D  # 工具碰撞形状，用于检测锄头操作范围

## 进入锄头状态
# 当玩家切换到锄头状态时调用
# 立即播放对应的锄头动画
func _enter():
	# 更新动画，根据玩家朝向播放对应的锄头动画
	# 立即开始动画播放，锄头操作不需要复杂的时序控制
	_update_animation()

## 退出锄头状态
# 当玩家从锄头状态切换到其他状态时调用
# 停止动画播放
func _exit():
	# 停止当前播放的动画
	# 锄头动画通常比较短促，及时停止可以避免动画残留
	anim.stop()

## 物理帧更新
# 每物理帧执行一次，处理锄头状态的核心逻辑
# @param delta: 物理帧间隔时间
func _physics_update(delta):
	# 检查动画是否播放完毕
	# 如果动画播放结束，说明锄头操作完成，切换回Idle状态
	if !anim.is_playing():
		# 发出状态转换信号，切换到Idle状态
		# 玩家可以继续进行其他操作
		transition_to.emit("Idle")

## 更新动画播放
# 根据玩家朝向播放对应的锄头动画
# 不同方向的锄头挥舞需要不同的动画表现
func _update_animation():
	# 根据玩家朝向播放对应的锄头动画
	# 锄头操作的动画相对简单，主要展示挥舞动作
	if player.player_direction == Vector2.UP:
		# 向上挥锄动画
		anim.play("hoe_up")
	elif player.player_direction == Vector2.DOWN:
		# 向下挥锄动画
		anim.play("hoe_down")
	elif player.player_direction == Vector2.LEFT:
		# 向左挥锄动画
		anim.play("hoe_left")
	elif player.player_direction == Vector2.RIGHT:
		# 向右挥锄动画
		anim.play("hoe_right")
