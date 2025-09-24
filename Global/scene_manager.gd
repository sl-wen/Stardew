# 场景管理器
# 此脚本作为Autoload单例运行，负责游戏场景的加载、切换和管理
# 实现场景的无缝切换和玩家位置的正确重置
# 确保玩家在不同场景间切换时位置和状态的连续性
extends Node  # 继承自Node，作为场景管理器节点

## 场景切换信号
# 当场景发生变化时发出此信号
# 用于通知其他系统（如箱子交互系统）需要重新连接信号
# 因为在场景切换后，原有的信号连接会断开，需要重新建立
signal level_changed

## 主场景资源路径
# 游戏主场景（MainScene.tscn）的资源文件路径
# 这个场景作为游戏的基础容器，包含所有UI和关卡内容
var main_scene_path :String = "res://Main/MainScene.tscn"

## 主场景根节点路径
# 主场景在场景树中的绝对路径，用于快速访问
# 使用绝对路径确保在任何情况下都能正确定位到主场景
var main_scene_level_root:String = "/root/MainScene"

## 关卡场景字典
# 存储所有可切换关卡场景的名称和路径映射
# 键为关卡名称，值为对应的场景资源路径
# 便于通过名称快速获取和切换到指定场景
var level_scenes:Dictionary = {
	# 农场场景，包含农田、作物、动物等农业相关内容
	"Farm" : "res://Map/Farm/farm.tscn",

	# 房屋场景，玩家的居住场所
	"MyHouse" : "res://Map/MyHouse/my_house.tscn",

	# 城镇场景，包含NPC、商店、公共设施等
	"Town" : "res://Map/Town/town.tscn",

	# 商店场景，玩家可以买卖物品的地方
	"Store" : "res://Map/Store/store.tscn",
}

## 玩家引用
# 全局玩家节点的引用，用于场景切换时的位置管理
# 通过Player组获取玩家节点，确保场景切换时能正确定位玩家
var player : Player

func _ready() -> void:
	# 节点就绪时连接信号和获取玩家引用
	# 确保场景管理器在游戏开始时就正确初始化
	level_changed.connect(on_level_changed)
	# 获取Player组中的第一个节点作为玩家引用
	# 使用组来查找玩家，避免直接引用可能出现的空指针问题
	player = get_tree().get_first_node_in_group("Player")

## 场景切换信号处理函数
# 当场景发生变化时，重新获取玩家引用
# 因为场景切换后玩家节点可能会重新创建或重新实例化
# 需要更新引用以确保后续操作能正确访问到玩家节点
func on_level_changed() -> void:
	# 重新获取玩家引用
	# 这个函数会在每次场景切换后被调用，确保玩家引用始终有效
	player = get_tree().get_first_node_in_group("Player")

## 加载主场景
# 如果主场景已经存在则直接返回
# 否则实例化并添加到场景树根节点，然后发出场景切换信号
# 这个函数确保游戏始终有且只有一个主场景实例
func load_main_scene() -> void:
	# 检查主场景是否已存在，避免重复加载
	# 如果主场景已经存在，说明游戏已经正常运行，直接返回
	if get_tree().root.has_node(main_scene_level_root):
		return

	# 加载并实例化主场景
	# 使用load()加载场景资源，然后使用instantiate()创建实例
	var main_scene :Node2D= load(main_scene_path).instantiate()
	if main_scene != null:
		# 将主场景添加到场景树根节点
		# 这样主场景就成为游戏的顶级容器
		get_tree().root.add_child(main_scene)
		# 发出场景切换信号，通知其他系统场景已加载完成
		level_changed.emit()

## 切换关卡场景
# 卸载当前关卡，加载新的关卡场景，并设置玩家出生位置
# 这是场景切换的核心函数，确保玩家在不同关卡间平滑过渡
# @param target_level: 目标关卡名称（如"Farm", "MyHouse"等）
# @param spawn_pos_name: 玩家出生位置节点的名称
func change_level(target_level:String, spawn_pos_name:String) -> void:
	# 获取目标场景路径
	# 从level_scenes字典中根据关卡名称获取对应的场景文件路径
	var scene_path = level_scenes.get(target_level)
	if scene_path == null:
		# 如果场景路径不存在，输出警告并直接返回
		print("警告：关卡", target_level, "不存在")
		return

	# 实例化目标场景
	# 加载场景资源并创建实例，准备添加到场景树
	var target_scene = load(scene_path).instantiate()

	# 获取主场景根节点
	# 通过预定义的路径获取主场景节点
	var main_scene = get_tree().root.get_node(main_scene_level_root)
	if main_scene == null:
		# 如果主场景不存在，说明游戏状态异常，直接返回
		print("错误：主场景不存在")
		return

	# 获取关卡容器节点（Levels）
	# 关卡容器是主场景的子节点，专门用于容纳各个关卡场景
	var levels = main_scene.find_child("Levels")
	if levels != null:
		# 释放当前关卡的所有子节点
		# 获取所有当前关卡的子节点
		var nodes = levels.get_children()
		if nodes != null:
			# 遍历并释放所有子节点
			# queue_free()是安全的释放方法，会在当前帧结束后释放
			for node in nodes:
				node.queue_free()

		# 等待一帧确保释放完成
		# 确保上一关卡的所有节点都被正确释放后，再添加新关卡
		await get_tree().process_frame

		# 添加新的关卡场景
		# 将新实例化的关卡场景添加到关卡容器中
		levels.add_child(target_scene)

	# 发出场景切换信号，通知其他系统更新
	# 其他系统（如UI、音效等）需要知道场景已切换完成
	level_changed.emit()

	# 设置玩家出生位置
	# 根据指定的出生点名称设置玩家在关卡中的位置
	set_spawn_position(spawn_pos_name)

## 设置玩家出生位置
# 根据出生位置名称或默认位置设置玩家位置
# 确保玩家在进入新场景时出现在正确的位置
# @param spawn_pos_name: 出生位置节点的名称
func set_spawn_position(spawn_pos_name:String) -> void:
	# 获取所有出生位置节点
	# SpawnPosition是一个节点组，包含场景中的所有出生点
	var spawn_poss = get_tree().get_nodes_in_group("SpawnPosition")

	# 安全检查：如果没有找到出生位置节点，直接返回
	if spawn_poss == null:
		print("警告：未找到SpawnPosition组中的节点")
		return

	# 如果只有一个出生位置，直接使用
	# 适用于只有一个出生点的场景
	if spawn_poss.size() == 1:
		# 将玩家位置设置为第一个（也是唯一一个）出生位置
		player.global_position = spawn_poss[0].global_position
	else:
		# 如果有多个出生位置，根据名称匹配
		# 遍历所有出生位置，找到名称匹配的节点
		for spawn_pos in spawn_poss:
			# 检查出生位置节点的名称是否与指定名称匹配
			if spawn_pos.name == spawn_pos_name:
				# 找到匹配的出生位置，设置玩家位置
				player.global_position = spawn_pos.global_position
				# 设置完成后可以直接返回，不需要继续遍历
				return

		# 如果没有找到指定名称的出生位置，使用第一个出生位置作为默认
		if spawn_poss.size() > 0:
			print("警告：未找到名为", spawn_pos_name, "的出生位置，使用默认位置")
			player.global_position = spawn_poss[0].global_position

## 获取当前关卡根节点
# 返回当前活跃关卡场景的根节点
# 用于访问当前关卡中的对象和数据
# @return: 当前关卡的根节点，如果不存在则返回null
func get_current_level() -> Node2D:
	# 获取主场景根节点
	# 通过预定义的路径获取主场景
	var main_scene = get_tree().root.get_node(main_scene_level_root)
	if main_scene == null:
		# 如果主场景不存在，返回null
		return null

	# 获取关卡容器
	# 关卡容器包含当前活跃的关卡场景
	var levels = main_scene.find_child("Levels")
	if levels == null:
		# 如果关卡容器不存在，返回null
		return null

	# 获取第一个子节点（当前关卡）
	# 关卡容器中的第一个子节点就是当前活跃的关卡
	var node : Node = levels.get_child(0)
	if node == null:
		# 如果没有关卡节点，返回null
		return null

	# 返回当前关卡节点
	return node
