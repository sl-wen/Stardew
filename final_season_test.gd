extends Node

func _ready() -> void:
	print("=== 最终季节系统测试 ===")
	print("验证365天季节分布是否正确实现...")
	print("")

	# 测试边界日期
	var test_dates = [
		{"day": 1, "expected": "春"},
		{"day": 91, "expected": "春"},
		{"day": 92, "expected": "夏"},
		{"day": 182, "expected": "夏"},
		{"day": 183, "expected": "秋"},
		{"day": 273, "expected": "秋"},
		{"day": 274, "expected": "冬"},
		{"day": 365, "expected": "冬"},
		{"day": 366, "expected": "春"},
	]

	var all_passed = true

	for test in test_dates:
		var actual_season = get_season_name(TimeSystem.get_season_by_day_static(test["day"]))
		var expected_season = test["expected"]

		if actual_season == expected_season:
			print("✅ 第%d天: 期望%s季，实际%s季 - 通过" % [test["day"], expected_season, actual_season])
		else:
			print("❌ 第%d天: 期望%s季，实际%s季 - 失败" % [test["day"], expected_season, actual_season])
			all_passed = false

	print("")
	if all_passed:
		print("🎉 季节系统测试全部通过！")
		print("农作物现在将按照正确的季节生长。")
		print("")
		print("季节分布总结：")
		print("- 春季：1-91天 (91天)")
		print("- 夏季：92-182天 (91天)")
		print("- 秋季：183-273天 (91天)")
		print("- 冬季：274-365天 (92天)")
	else:
		print("⚠️ 季节系统测试失败，需要检查实现。")

func get_season_name(season_index: int) -> String:
	var seasons = ["春", "夏", "秋", "冬"]
	return seasons[season_index] if season_index >= 0 and season_index < seasons.size() else "未知"