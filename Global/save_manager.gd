# 存档管理器
# 此脚本作为Autoload单例运行，负责游戏的存档和读档功能
# 通过SaveComponent组件收集所有需要保存的数据，封装到SaveData资源中
extends Node

## 清除存档文件
# 删除现有的存档文件，为新建游戏做准备
func clear_save_data() -> void:
	# 检查存档文件是否存在
	if FileAccess.file_exists("user://abc.tres"):
		# 删除存档文件
		var dir = DirAccess.open("user://")
		if dir:
			var error = dir.remove("abc.tres")
			if error == OK:
				print("存档文件已清除")
			else:
				print("清除存档文件失败，错误码：", error)
		else:
			print("无法打开用户目录")
	else:
		print("没有找到存档文件，无需清除")

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
		var component_data = save_component.get_save_data()
		save_data.nodes.append_array(component_data)

	# 获取玩家节点并保存物品栏数据
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player:
		save_data.player_inventory = player.bag_system

	# 保存数据到硬盘（user://是Godot的用户数据目录）
	ResourceSaver.save(save_data,"user://abc.tres")

## 从硬盘加载游戏数据
# 从user://abc.tres文件中加载SaveData资源
# 将数据恢复到各个SaveComponent组件和玩家物品栏
func _load() -> void:
	# 检查存档文件是否存在
	if not FileAccess.file_exists("user://abc.tres"):
		print("存档文件不存在")
		return

	# 加载存档数据资源
	var save_data = ResourceLoader.load("user://abc.tres") as SaveData
	if not save_data:
		print("加载存档数据失败")
		return

	# 获取所有需要恢复数据的组件节点
	var save_components = get_tree().get_nodes_in_group("SaveComponents") as Array[SaveComponent]
	for save_component in save_components:
		# 打印调试信息
		print("正在恢复数据:", save_data.nodes.size(), "个节点")
		# 将保存的数据恢复到组件中
		save_component.set_save_data(save_data.nodes)

	# 获取玩家节点并恢复物品栏数据
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player and save_data.player_inventory:
		player.bag_system = save_data.player_inventory

## 新建游戏
# 清除存档文件并初始化新游戏状态
func new_game() -> void:
	# 清除现有存档
	clear_save_data()

	# 初始化默认游戏状态
	initialize_default_game_state()

## 初始化默认游戏状态
# 设置新游戏的初始状态
func initialize_default_game_state() -> void:
	# 获取玩家节点
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player:
		# 清除玩家物品栏
		if player.bag_system:
			player.bag_system.items.clear()
			player.bag_system.items.resize(player.bag_system.items_size)

		# 重置玩家位置到默认位置
		# 使用MainScene中Player的初始位置作为默认
		player.global_position = Vector2(2505, 360)

		# 重置玩家状态
		player.current_item = null
		player.current_item_type = Item.ItemType.None
		player.can_move = true

	# 清除所有保存组件的数据
	var save_components = get_tree().get_nodes_in_group("SaveComponents") as Array[SaveComponent]
	for save_component in save_components:
		# 清除所有子节点（除了SaveComponent本身）
		for child in save_component.get_parent().get_children():
			if child.name != "SaveComponent":
				child.queue_free()

	print("新游戏状态初始化完成")
