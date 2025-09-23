# 场景管理器
# 此脚本作为Autoload单例运行，负责游戏场景的加载、切换和管理
# 实现场景的无缝切换和玩家位置的正确重置
extends Node

## 场景切换信号
# 当场景发生变化时发出此信号
# 用于通知其他系统（如箱子交互系统）需要重新连接信号
# 因为在场景切换后，原有的信号连接会断开，需要重新建立
signal level_changed

## 主场景资源路径
# 游戏主场景（MainScene.tscn）的资源文件路径
var main_scene_path :String = "res://Main/MainScene.tscn"

## 主场景根节点路径
# 主场景在场景树中的绝对路径，用于快速访问
var main_scene_level_root:String = "/root/MainScene"

## 关卡场景字典
# 存储所有可切换关卡场景的名称和路径映射
# 键为关卡名称，值为对应的场景资源路径
var level_scenes:Dictionary = {
	"Farm" : "res://Map/Farm/farm.tscn",        # 农场场景
	"MyHouse" : "res://Map/MyHouse/my_house.tscn", # 房屋场景
	"Town" : "res://Map/Town/town.tscn",        # 城镇场景
	"Store" : "res://Map/Store/store.tscn",     # 商店场景
}

## 玩家引用
# 全局玩家节点的引用，用于场景切换时的位置管理
var player : Player

func _ready() -> void:
	# 节点就绪时连接信号和获取玩家引用
	level_changed.connect(on_level_changed)
	player = get_tree().get_first_node_in_group("Player")

## 场景切换信号处理函数
# 当场景发生变化时，重新获取玩家引用
# 因为场景切换后玩家节点可能会重新创建
func on_level_changed() -> void:
	player = get_tree().get_first_node_in_group("Player")

## 加载主场景
# 如果主场景已经存在则直接返回
# 否则实例化并添加到场景树根节点，然后发出场景切换信号
func load_main_scene() -> void:
	# 检查主场景是否已存在，避免重复加载
	if get_tree().root.has_node(main_scene_level_root):
		return

	# 加载并实例化主场景
	var main_scene :Node2D= load(main_scene_path).instantiate()
	if main_scene != null:
		get_tree().root.add_child(main_scene)
		level_changed.emit()

## 切换关卡场景
# 卸载当前关卡，加载新的关卡场景，并设置玩家出生位置
# @param target_level: 目标关卡名称（如"Farm", "MyHouse"等）
# @param spawn_pos_name: 玩家出生位置节点的名称
func change_level(target_level:String, spawn_pos_name:String) -> void:
	# 获取目标场景路径
	var scene_path = level_scenes.get(target_level)
	if scene_path == null:
		return # 如果场景路径不存在，直接返回

	# 实例化目标场景
	var target_scene = load(scene_path).instantiate()

	# 获取主场景根节点
	var main_scene = get_tree().root.get_node(main_scene_level_root)
	if main_scene == null:
		return

	# 获取关卡容器节点（Levels）
	var levels = main_scene.find_child("Levels")
	if levels != null:
		# 释放当前关卡的所有子节点
		var nodes = levels.get_children()
		if nodes != null:
			for node in nodes:
				node.queue_free()

		# 等待一帧确保释放完成
		await get_tree().process_frame

		# 添加新的关卡场景
		levels.add_child(target_scene)

	# 发出场景切换信号，通知其他系统更新
	level_changed.emit()

	# 设置玩家出生位置
	set_spawn_position(spawn_pos_name)

## 设置玩家出生位置
# 根据出生位置名称或默认位置设置玩家位置
# @param spawn_pos_name: 出生位置节点的名称
func set_spawn_position(spawn_pos_name:String) -> void:
	# 获取所有出生位置节点
	var spawn_poss = get_tree().get_nodes_in_group("SpawnPosition")

	if spawn_poss == null:
		return

	# 如果只有一个出生位置，直接使用
	if spawn_poss.size() == 1:
		player.global_position = spawn_poss[0].global_position
	else:
		# 如果有多个出生位置，根据名称匹配
		for spawn_pos in spawn_poss:
			if spawn_pos.name == spawn_pos_name:
				player.global_position = spawn_pos.global_position

## 获取当前关卡根节点
# 返回当前活跃关卡场景的根节点
# @return: 当前关卡的根节点，如果不存在则返回null
func get_current_level() -> Node2D:
	# 获取主场景根节点
	var main_scene = get_tree().root.get_node(main_scene_level_root)
	if main_scene == null:
		return null

	# 获取关卡容器
	var levels = main_scene.find_child("Levels")
	if levels == null:
		return null

	# 获取第一个子节点（当前关卡）
	var node : Node = levels.get_child(0)
	if node == null:
		return null

	return node
