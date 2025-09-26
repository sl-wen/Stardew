extends Node

# 季节系统测试脚本

func _ready() -> void:
	print("=== 季节系统测试 ===")
	print("测试一年365天的季节分布:")
	print("春季：1-91天")
	print("夏季：92-182天")
	print("秋季：183-273天")
	print("冬季：274-365天")
	print("====================")

	# 测试一些关键日期
	test_season_calculation(1, "新年第一天")
	test_season_calculation(91, "春季最后一天")
	test_season_calculation(92, "夏季第一天")
	test_season_calculation(182, "夏季最后一天")
	test_season_calculation(183, "秋季第一天")
	test_season_calculation(273, "秋季最后一天")
	test_season_calculation(274, "冬季第一天")
	test_season_calculation(365, "冬季最后一天")
	test_season_calculation(366, "下一年第一天（春季）")

func test_season_calculation(day: int, description: String) -> void:
	var season_info = get_season_info(day)
	print("第%3d天 (%s): %s季 (一年中的第%d天)" % [day, description, season_info["season_name"], season_info["day_in_year"]])

func get_season_info(day: int) -> Dictionary:
	var day_in_year = ((day - 1) % 365) + 1

	var season_index: int
	var season_name: String

	if day_in_year <= 91:
		season_index = 0
		season_name = "春"
	elif day_in_year <= 182:
		season_index = 1
		season_name = "夏"
	elif day_in_year <= 273:
		season_index = 2
		season_name = "秋"
	else:
		season_index = 3
		season_name = "冬"

	return {
		"season_index": season_index,
		"season_name": season_name,
		"day_in_year": day_in_year
	}