# 点击区域组件
# 此脚本定义了一个可点击的区域组件，用于处理鼠标交互
# 当鼠标进入、离开或点击该区域时会触发相应的信号和鼠标样式变化
extends Area2D
class_name ClickAreaComponent  # 定义组件的类名，便于在代码中引用

# 鼠标右键点击信号
# 当用户在该区域内点击鼠标右键时发出此信号
# 其他脚本可以连接此信号来响应右键点击事件
signal mouse_right_click

# 节点就绪时调用
# 初始化鼠标事件监听器的连接
func _ready() -> void:
	# 连接鼠标进入信号到处理函数
	# 当鼠标光标进入该区域时会自动调用_on_mouse_entered函数
	mouse_entered.connect(_on_mouse_entered)

	# 连接鼠标离开信号到处理函数
	# 当鼠标光标离开该区域时会自动调用_on_mouse_exited函数
	mouse_exited.connect(_on_mouse_exited)

	# 连接输入事件信号到处理函数
	# 当区域内发生输入事件（键盘、鼠标等）时会调用_on_input_event函数
	input_event.connect(_on_input_event)

# 鼠标进入区域时的处理函数
# 改变鼠标光标样式为进入状态
func _on_mouse_entered() -> void:
	# 调用MouseCursor单例的设置鼠标进入状态的方法
	# 这会改变游戏中的鼠标光标外观，提示用户可以进行交互
	MouseCursor.set_mouse_entered_cursor()

# 鼠标离开区域时的处理函数
# 恢复默认鼠标光标样式
func _on_mouse_exited() -> void:
	# 调用MouseCursor单例的设置默认鼠标的方法
	# 恢复鼠标的默认外观
	MouseCursor.set_default_cursor()

# 输入事件处理函数
# 处理发生在该区域内的输入事件
# @param viewport: 发生事件的视口节点
# @param event: 输入事件对象，包含事件的具体信息
# @param shape_idx: 碰撞形状的索引（用于多形状碰撞体）
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# 检查是否是鼠标右键按下事件
	# event.is_action_pressed("mouse_right") 检查输入映射中定义的"mouse_right"动作
	if event.is_action_pressed("mouse_right"):
		# 发出右键点击信号，通知其他系统用户进行了右键点击
		# 连接此信号的脚本将收到通知并可以执行相应逻辑
		mouse_right_click.emit()
