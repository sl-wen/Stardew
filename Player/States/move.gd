# 玩家移动状态
# 负责处理玩家的移动逻辑，包括方向控制、动画播放和状态转换
# 当玩家按下移动键时进入此状态，按键松开时切换回Idle状态
extends State  # 继承自状态基类

# 导出的属性，可以在Godot编辑器中进行配置
@export var player:Player      # 玩家主脚本引用，用于访问玩家属性和方法
@export var anim:AnimationPlayer  # 动画播放器引用，用于控制移动动画
@export var speed:int = 100    # 移动速度，像素/秒，影响玩家的移动快慢

# 移动方向向量
# 存储当前的移动方向，用于动画播放和方向记录
var direction:Vector2

# 进入移动状态时的处理
# 当玩家从其他状态切换到移动状态时调用
func _enter():
	# 调试输出，标识当前状态（在最终版本中应该移除）
	print("Move")

	# 进入状态时的初始化逻辑
	# 这里暂时为空，子类可以根据需要添加初始化代码
	# 例如：播放进入动画、重置移动计数器等
	pass  # 进入这个状态时要做什么（比如播放动画）

# 退出移动状态时的处理
# 当玩家从移动状态切换到其他状态时调用
func _exit():
	# 停止当前播放的动画
	# 防止动画在状态切换后继续播放，造成视觉混乱
	anim.stop()

	# 退出状态时的清理逻辑
	# 这里暂时为空，子类可以根据需要添加清理代码
	# 例如：重置移动相关的临时变量、停止音效等
	pass  # 离开这个状态时要做什么

# 物理帧更新处理
# 每物理帧执行一次，处理移动的核心逻辑
# @param delta: 物理帧间隔时间（秒）
func _physics_update(delta):
	# 获取当前玩家的移动方向
	# player.direction由输入系统更新，包含WASD键的输入向量
	direction = player.direction

	# 更新动画播放
	# 根据当前移动方向播放对应的动画
	_update_animation()

	# 如果当前有移动输入，记录移动方向到玩家对象
	# 这个方向会被Idle状态使用，确保Idle动画方向正确
	if direction != Vector2.ZERO:  # 记录Move->Idle的方向
		player.player_direction = direction

	# 检查是否应该切换回Idle状态
	# 如果玩家没有输入任何移动方向，切换到Idle状态
	if player.direction == Vector2.ZERO:
		# 发出状态转换信号，切换到Idle状态
		transition_to.emit("Idle")

	# 执行移动
	# 设置玩家的速度向量并执行移动和碰撞检测
	player.velocity = player.direction * speed  # 计算速度向量
	player.move_and_slide()  # 执行移动并处理碰撞

# 更新动画播放
# 根据移动方向选择并播放对应的动画
func _update_animation():
	# 停下来的时候direction为0,所以Idle下面条件永远不会执行
	# 为了避免这种情况，Move状态需要一个单独的direction
	# 注释：当玩家停止移动时，direction会变为零向量
	# 但Idle状态的动画方向判断需要用到最后移动的方向
	# 因此Move状态维护自己的direction变量来记录最后的移动方向

	# 根据方向向量播放对应的移动动画
	if direction == Vector2.UP:      # 向上移动
		anim.play("move_up")
	elif direction == Vector2.DOWN:  # 向下移动
		anim.play("move_down")
	elif direction == Vector2.LEFT:   # 向左移动
		anim.play("move_left")
	elif direction == Vector2.RIGHT:  # 向右移动
		anim.play("move_right")

	# 预留的动画混合代码
	# 如果使用AnimationTree，可以通过混合位置来实现平滑的方向过渡
	#anim["parameters/Move/blend_position"] = player.player_direction
