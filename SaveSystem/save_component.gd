extends Node
class_name SaveComponent
## 作为需要存档的节点的子节点，对属性的获取和赋值都是通过这个组件

func _ready() -> void:
	await get_parent().ready
	add_to_group("SaveComponents")
	

func get_save_data() -> Array[PackedScene]:
	var nodes_to_save: Array[PackedScene] = []
	var parent = get_parent()
	for child in parent.get_children():
		var pack_scene = PackedScene.new()
		pack_scene.pack(child)
		if child.name != "SaveComponent":
			nodes_to_save.append(pack_scene)
	return nodes_to_save
	
func set_save_data(nodes:Array[PackedScene]) -> void:
	var parent = get_parent()

	# 先清理现有的子节点（除了SaveComponent本身）
	for child in parent.get_children():
		if child.name != "SaveComponent":
			child.queue_free()

	# 等待一帧确保节点被完全清理
	await get_tree().process_frame

	# 恢复保存的节点
	for node_scene in nodes:
		var node_instance = node_scene.instantiate()
		parent.add_child(node_instance)

	print("组件数据恢复完成:", nodes.size(), "个节点")
