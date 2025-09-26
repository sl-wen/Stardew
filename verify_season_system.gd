extends Node

# 验证季节系统是否正确

func _ready() -> void:
	print("=== 季节系统验证 ===")
	print("验证一年365天的季节分布是否正确...")
	print("")

	# 验证边界日期
	var test_cases = [
		{"day": 1, "expected_season": "春", "description": "新年第一天"},
		{"day": 91, "expected_season": "春", "description": "春季最后一天"},
		{"day": 92, "expected_season": "夏", "description": "夏季第一天"},
		{"day": 182, "expected_season": "夏", "description": "夏季最后一天"},
		{"day": 183, "expected_season": "秋", "description": "秋季第一天"},
		{"day": 273, "expected_season": "秋", "description": "秋季最后一天"},
		{"day": 274, "expected_season": "冬", "description": "冬季第一天"},
		{"day": 365, "expected_season": "冬", "description": "冬季最后一天"},
		{"day": 366, "expected_season": "春", "description": "下一年第一天"},
	]

	var all_correct = true

	for test_case in test_cases:
		var actual_season = get_season_by_day(test_case["day"])
		var expected_season = get_season_index(test_case["expected_season"])

		if actual_season == expected_season:
			print("✅ 第%d天 (%s): %s季 - 正确" % [test_case["day"], test_case["description"], test_case["expected_season"]])
		else:
			print("❌ 第%d天 (%s): 期望%s季，实际%s季 - 错误" % [test_case["day"], test_case["description"], test_case["expected_season"], ["春", "夏", "秋", "冬"][actual_season]])
			all_correct = false

	print("")
	if all_correct:
		print("🎉 季节系统验证通过！365天季节分布正确。")
	else:
		print("⚠️ 季节系统存在错误，需要检查。")

func get_season_by_day(day: int) -> int:
	var day_in_year = ((day - 1) % 365) + 1

	if day_in_year <= 91:
		return 0  # Spring
	elif day_in_year <= 182:
		return 1  # Summer
	elif day_in_year <= 273:
		return 2  # Autumn
	else:
		return 3  # Winter

func get_season_index(season_name: String) -> int:
	match season_name:
		"春":
			return 0
		"夏":
			return 1
		"秋":
			return 2
		"冬":
			return 3
		_:
			return -1