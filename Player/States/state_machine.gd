# 状态机管理器
# 负责管理玩家状态的切换和执行
# 采用有限状态机模式，确保玩家在任何时刻都处于且仅处于一个状态
extends Node
class_name StateMachine

## 初始状态
# 游戏开始时进入的默认状态
@export var initial_state: State

## 当前活跃状态
# 玩家当前所处的状态实例
var current_state: State

func _ready() -> void:
	# 遍历所有子节点，为状态节点连接转换信号
	for state in get_children():
		if state is State:
			# 连接状态转换信号到状态机的方法
			state.transition_to.connect(transition_state)

	# 初始化进入初始状态
	if initial_state:
		current_state = initial_state
		current_state._enter()

## 物理帧更新
# 每物理帧执行当前状态的物理更新逻辑
# @param delta: 物理帧间隔时间
func _physics_process(delta: float) -> void:
	# 执行当前状态的物理更新逻辑
	# 状态机确保一次只能执行一个状态的逻辑
	current_state._physics_update(delta)

## 状态转换函数
# 根据状态名称切换到新的状态
# @param next_state_name: 要切换到的状态节点名称
func transition_state(next_state_name:String):
	# 获取目标状态节点
	var next_state:State = get_node(next_state_name)

	# 调试输出状态名称
	print(next_state_name)

	# 安全检查
	if !next_state:
		return

	# 如果是同一状态，不执行转换
	if current_state == next_state:
		return

	# 退出当前状态
	current_state._exit()

	# 切换到新状态并进入
	current_state = next_state
	next_state._enter()
		
