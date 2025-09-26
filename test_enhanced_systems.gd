extends Node2D

# 测试增强系统的场景脚本

func _ready() -> void:
	print("=== 星露谷物语增强系统测试场景 ===")
	print("新增功能：")
	print("1. 多种作物类型（番茄、草莓）")
	print("2. 季节系统（春、夏、秋、冬）")
	print("3. 动物系统（鸡、牛）")
	print("4. 水分管理和作物生长系统")
	print("5. 动物生产系统")
	print("=================================")

	# 连接时间系统信号用于调试
	TimeSystem.time_tick_day.connect(on_day_tick)
	TimeSystem.season_changed.connect(on_season_changed)

func on_day_tick(day: int) -> void:
	print("第", day, "天 - 季节:", get_current_season_name())

func on_season_changed(season: int, season_name: String) -> void:
	print("季节变化！现在是", season_name, "季")

func get_current_season_name() -> String:
	var season_index = TimeSystem.current_season
	var seasons = ["春", "夏", "秋", "冬"]
	return seasons[season_index] if season_index < seasons.size() else "未知"