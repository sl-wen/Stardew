# 斧头状态
# 负责处理玩家使用斧头工具的逻辑，包括动画播放和碰撞检测
# 斧头主要用于砍伐树木或其他可破坏的物体
extends State  # 继承自状态基类

# 导出的属性，可以在Godot编辑器中进行配置
@export var player: Player  # 玩家主脚本引用，用于访问玩家属性
@export var anim: AnimationPlayer  # 动画播放器引用，用于播放斧头动画
@export var tool_collistion: CollisionShape2D  # 工具碰撞形状，用于检测斧头攻击范围

# 内部状态变量
var i: int  # 帧计数器，用于控制碰撞检测的时机

## 进入斧头状态
# 当玩家切换到斧头状态时调用
# 初始化状态变量并设置碰撞检测
func _enter():
	# 重置帧计数器
	i = 0

	# 立即禁用碰撞检测，等待动画开始后在合适时机启用
	# 这样可以避免动画开始时就触发碰撞
	tool_collistion.disabled = false

	# 更新动画，根据玩家朝向播放对应的斧头动画
	_update_animation()

## 退出斧头状态
# 当玩家从斧头状态切换到其他状态时调用
# 清理状态，停止动画和碰撞检测
func _exit():
	# 停止当前播放的动画
	anim.stop()

	# 禁用碰撞检测，避免状态切换后仍产生碰撞
	tool_collistion.disabled = true

## 物理帧更新
# 每物理帧执行一次，处理斧头状态的核心逻辑
# @param delta: 物理帧间隔时间
func _physics_update(delta):
	# 递增帧计数器
	i += 1

	# 在第20帧启用碰撞检测
	# 为什么等待20帧？因为需要等待斧头挥舞动画播放到合适位置
	# 过早启用碰撞会导致攻击范围不准确
	if i == 20:  # 让碰撞在20帧后执行
		tool_collistion.disabled = false

	# 检查动画是否播放完毕
	# 如果动画播放结束，说明斧头挥舞动作完成，切换回Idle状态
	if !anim.is_playing():
		transition_to.emit("Idle")  # 发出状态转换信号，切换到Idle状态

## 更新动画播放
# 根据玩家朝向播放对应的斧头动画并设置碰撞位置
# 不同方向的斧头挥舞需要不同的动画和碰撞位置
func _update_animation():
	# 根据玩家朝向播放对应的斧头动画
	if player.player_direction == Vector2.UP:
		# 向上挥斧动画
		anim.play("axe_up")
		# 设置碰撞形状位置，向上挥斧时碰撞范围在头顶上方
		tool_collistion.position = Vector2(0, -18)
	elif player.player_direction == Vector2.DOWN:
		# 向下挥斧动画
		anim.play("axe_down")
		# 向下挥斧时碰撞范围在脚下
		tool_collistion.position = Vector2(0, 2)
	elif player.player_direction == Vector2.LEFT:
		# 向左挥斧动画
		anim.play("axe_left")
		# 向左挥斧时碰撞范围在左侧
		tool_collistion.position = Vector2(-10, -12)
	elif player.player_direction == Vector2.RIGHT:
		# 向右挥斧动画
		anim.play("axe_right")
		# 向右挥斧时碰撞范围在右侧
		tool_collistion.position = Vector2(10, -12)
