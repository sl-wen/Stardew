# 状态机管理器
# 负责管理玩家状态的切换和执行
# 采用有限状态机模式，确保玩家在任何时刻都处于且仅处于一个状态
# 状态机控制状态的生命周期：进入 -> 更新 -> 退出 -> 切换
extends Node  # 继承自Node，可以作为场景树的节点使用
class_name StateMachine  # 定义状态机管理器的类名

## 初始状态
# 游戏开始时进入的默认状态
# 通常设置为Idle状态，让玩家在游戏开始时处于空闲状态
@export var initial_state: State

## 当前活跃状态
# 玩家当前所处的状态实例
# 只有这一个状态会被执行，其他状态处于休眠状态
var current_state: State

# 节点就绪时调用
# 初始化状态机，连接所有状态的转换信号并进入初始状态
func _ready() -> void:
	# 遍历所有子节点，为状态节点连接转换信号
	# 这样当状态需要切换时，可以通知状态机进行处理
	for state in get_children():
		# 检查节点是否为状态类型
		if state is State:
			# 连接状态转换信号到状态机的方法
			# 当状态发出transition_to信号时，会调用状态机的transition_state方法
			state.transition_to.connect(transition_state)

	# 初始化进入初始状态
	if initial_state:
		# 设置当前状态为初始状态
		current_state = initial_state
		# 调用进入方法，执行状态的进入逻辑
		current_state._enter()

## 物理帧更新
# 每物理帧执行当前状态的物理更新逻辑
# 状态机确保一次只能执行一个状态的逻辑，避免状态冲突
# @param delta: 物理帧间隔时间，单位为秒
func _physics_process(delta: float) -> void:
	# 执行当前状态的物理更新逻辑
	# 这包括：移动计算、碰撞检测、状态转换条件判断等
	# 状态机作为统一入口，保证状态更新的时序和一致性
	current_state._physics_update(delta)

## 状态转换函数
# 根据状态名称切换到新的状态
# 这个方法是状态机控制状态切换的核心逻辑
# @param next_state_name: 要切换到的状态节点名称，例如"Idle"、"Move"、"Attack"
func transition_state(next_state_name:String):
	# 获取目标状态节点
	# 使用get_node根据名称查找状态节点
	var next_state:State = get_node(next_state_name)

	# 调试输出状态名称
	# 在开发阶段用于跟踪状态切换，生产版本应该移除
	print(next_state_name)

	# 安全检查：确保目标状态存在
	if !next_state:
		# 如果目标状态不存在，输出警告并返回
		print("警告：状态", next_state_name, "不存在")
		return

	# 如果是同一状态，不执行转换
	# 避免不必要的状态切换开销
	if current_state == next_state:
		print("已经是", next_state_name, "状态，无需切换")
		return

	# 退出当前状态
	# 在切换前调用当前状态的退出方法，执行清理工作
	current_state._exit()

	# 切换到新状态并进入
	# 更新当前状态引用为新状态
	current_state = next_state
	# 调用新状态的进入方法，执行初始化工作
	next_state._enter()

