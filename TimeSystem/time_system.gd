# 时间系统管理器
# 此脚本作为Autoload单例运行，负责游戏内的时间流逝和时间管理
# 实现游戏时间的加速、星期循环、天数计算等功能
extends Node

## 时间转换常量
# 游戏时间与现实时间的转换关系：
# 现实中1秒 = 游戏中1分钟
# 现实中1分钟 = 游戏中1小时 (分钟×60)
# 现实中24分钟 = 游戏中1天 (小时×24)
# 支持星期、天数、小时、分钟的完整时间系统

## 每天的分钟数
# 24小时 × 60分钟 = 1440分钟
const MINUTES_PER_DAY : int  = 24 * 60

## 每小时的分钟数
const MINUTES_PER_HOUR : int = 60

## 游戏中一分钟对应的弧度值
# TAU是2π，确保时间循环，游戏中一分钟对应现实的时间
# 这个常量在滤镜系统中有重要作用
const GAME_MINUTE_DURATION: float = TAU / MINUTES_PER_DAY

## 游戏时间流速倍率
# 控制游戏时间的快慢，1.0为正常速度
var game_speed:float = 1.0

## 星期数组
# 定义游戏中的星期循环，从星期一到星期天
var weeks:Array = ["星期一","星期二","星期三","星期四","星期五","星期六","星期天"]

## 季节数组
# 定义游戏中的季节循环
var seasons:Array = ["春","夏","秋","冬"]

## 初始天数
# 游戏开始时的天数
var initial_day:int = 1

## 初始小时
# 游戏开始时的小时数
var initial_hour:int = 6

## 初始分钟
# 游戏开始时的分钟数
var initial_minute:int = 30

## 初始星期
# 游戏开始时的星期
var inital_week = weeks[0]

## 累计游戏时间
# 跟踪当前累计的游戏时间（弧度值）
var time:float = 0.0

## 当前分钟缓存
# 用于检测分钟变化，避免重复发出信号
var current_minute:int = -1

## 当前天数缓存
# 用于检测天数变化，避免重复发出信号
var current_day:int = 0

## 当前季节
# 基于天数计算季节（每28天一个季节）
var current_season:int = 0  # 0=春, 1=夏, 2=秋, 3=冬

## 季节变化信号
# 季节变化时触发，传递当前季节
signal season_changed(season:int, season_name:String)

## 游戏时间信号
# 每帧发出，传递当前累计时间
signal game_time(time:float)

## 时间刻度信号
# 每分钟变化时触发，传递当前的天数、小时、分钟、星期
signal time_tick(day:int,hour:int,minute:int,week)

## 天数变化信号
# 每天变化时触发，传递当前天数
# 主要用于作物生长、任务刷新等需要按天计算的功能
signal time_tick_day(day:int)

func _ready() -> void:
	# 节点就绪时设置初始时间
	set_initial_time()

## 每帧更新游戏时间
# 根据游戏速度和时间常量更新累计时间
# 发出时间信号供其他系统使用
# @param delta: 帧间隔时间（秒）
func _process(delta: float) -> void:
	# 更新累计游戏时间
	# 使用delta * game_speed * GAME_MINUTE_DURATION计算
	# 这样可以实现游戏时间的加速和时间循环
	time += delta * game_speed * GAME_MINUTE_DURATION

	# 发出游戏时间信号，传递当前累计时间
	game_time.emit(time)

	# 重新计算具体时间值（天、小时、分钟等）
	recalculate_time()

## 设置初始时间
# 根据配置的初始天数、小时、分钟计算初始累计时间
func set_initial_time() -> void:
	# 计算初始的总分钟数
	var initial_total_minutes = initial_day * MINUTES_PER_DAY + (initial_hour * MINUTES_PER_HOUR) + initial_minute

	# 转换为累计时间（弧度值）
	time = initial_total_minutes * GAME_MINUTE_DURATION

## 重新计算当前游戏时间
# 从累计时间值计算出具体的游戏时间（天、小时、分钟、星期）
func recalculate_time() -> void:
	# 将累计时间转换为游戏中的虚拟分钟数
	var total_minutes:int = int(time / GAME_MINUTE_DURATION)

	# 计算当天已经过去的分钟数
	var current_day_minutes:int = int(total_minutes % MINUTES_PER_DAY)

	# 计算具体时间值
	var day: int = int(total_minutes / MINUTES_PER_DAY) # 总天数
	var hour: int = int(current_day_minutes / MINUTES_PER_HOUR) # 当前小时
	var minute:int = int(current_day_minutes % MINUTES_PER_HOUR) # 当前分钟

	# 计算当前星期（7天循环）
	var week = weeks[day%7 - 1]

	# 只有在分钟或天数发生变化时才发出信号，避免重复调用
	if current_minute != minute:
		current_minute = minute
		# 发出时间刻度信号，传递当前时间信息
		time_tick.emit(day,hour,minute,week)

	if current_day != day:
		current_day = day
		# 发出天数变化信号，主要用于作物生长等需要按天计算的功能
		time_tick_day.emit(day)

	# 检查季节变化（每28天一个季节）
	var new_season = int(day / 28) % 4
	if current_season != new_season:
		current_season = new_season
		# 发出季节变化信号
		season_changed.emit(current_season, seasons[current_season])
