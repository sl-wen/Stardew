# 存档管理器
# 此脚本作为Autoload单例运行，负责游戏的存档和读档功能
# 通过SaveComponent组件收集所有需要保存的数据，封装到SaveData资源中
extends Node

## 保存游戏数据到硬盘
# 收集所有SaveComponent组件的数据和玩家物品栏数据
# 将数据封装到SaveData资源并保存到user://abc.tres文件中
func _save() -> void:
	# 创建新的存档数据容器
	var save_data = SaveData.new()

	# 获取所有需要保存的组件节点
	# 这些组件都在"SaveComponents"组中
	var save_components = get_tree().get_nodes_in_group("SaveComponents") as Array[SaveComponent]
	for save_component in save_components:
		# 从每个组件获取保存数据
		# 注意：到myhouse场景时save_component可能会被释放
		save_data.nodes = save_component.get_save_data()

	# 获取玩家节点并保存物品栏数据
	var player = get_tree().get_first_node_in_group("Player") as Player
	save_data.player_inventory = player.bag_system

	# 保存数据到硬盘（user://是Godot的用户数据目录）
	ResourceSaver.save(save_data,"user://abc.tres")

## 从硬盘加载游戏数据
# 从user://abc.tres文件中加载SaveData资源
# 将数据恢复到各个SaveComponent组件和玩家物品栏
func _load() -> void:
	# 加载存档数据资源
	var save_data = ResourceLoader.load("user://abc.tres") as SaveData

	# 获取所有需要恢复数据的组件节点
	var save_components = get_tree().get_nodes_in_group("SaveComponents") as Array[SaveComponent]
	for save_component in save_components:
		# 打印调试信息
		print(save_data.nodes)
		# 将保存的数据恢复到组件中
		save_component.set_save_data(save_data.nodes)

	# 获取玩家节点并恢复物品栏数据
	var player = get_tree().get_first_node_in_group("Player") as Player
	player.bag_system = save_data.player_inventory
