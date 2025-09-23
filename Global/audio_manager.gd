# 音频管理器
# 此脚本作为Autoload单例运行，负责管理游戏中的所有音频播放
# 包括背景音乐的平滑切换和音效的同时播放
extends Node

## 音频总线类型枚举
# 定义游戏中使用的音频总线类型，便于统一管理音量控制
enum Bus{
	MASTER,  # 主音量总线，控制所有音频的整体音量
	MUSIC,   # 音乐总线，专门用于背景音乐播放
	SFX,     # 音效总线，专门用于游戏音效播放
}

## 音频总线名称常量
# 对应Godot音频总线系统中的总线名称
const MUSIC_BUS = "Music"  # 音乐总线名称
const SFX_BUS = "SFX"      # 音效总线名称

## 音乐播放器数量
# 使用双播放器系统实现背景音乐的平滑渐变切换
# 第一个播放器播放当前音乐，第二个播放器预加载下一首音乐
var music_player_count:int = 2

## 当前活跃的音乐播放器索引
# 用于跟踪当前正在播放音乐的播放器，0或1
var current_music_player_index:int = 0

## 音乐播放器数组
# 存储所有音乐播放器的引用，实现音乐的循环切换
var music_players:Array[AudioStreamPlayer]

## 音乐渐变时长（秒）
# 控制音乐切换时的渐入渐出效果持续时间
var music_fade_duration:float = 1.0

## 音效播放器数量
# 同时最多可以播放6个音效，避免音效播放冲突
var sfx_player_count:int = 6

## 音效播放器数组
# 存储所有音效播放器的引用，实现多音效同时播放
var sfx_players:Array[AudioStreamPlayer]


func _ready() -> void:
	# 节点就绪时初始化所有音频播放器
	initial_music_player()
	initial_sfx_player()

## 初始化音乐播放器
# 创建指定数量的音乐播放器，设置到音乐总线
# 这些播放器将用于实现背景音乐的平滑切换
func initial_music_player() -> void:
	for i in music_player_count:
		# 创建新的音频播放器
		var audio_player := AudioStreamPlayer.new()
		# 设置为始终处理模式，确保在游戏暂停时也能播放音频
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		# 设置到音乐总线
		audio_player.bus = MUSIC_BUS
		# 添加为子节点
		add_child(audio_player)
		# 存入数组管理
		music_players.append(audio_player)

## 初始化音效播放器
# 创建指定数量的音效播放器，设置到音效总线
# 这些播放器将用于同时播放多个游戏音效
func initial_sfx_player() -> void:
	for i in sfx_player_count:
		# 创建新的音效播放器
		var sfx_player := AudioStreamPlayer.new()
		# 设置到音效总线
		sfx_player.bus = SFX_BUS
		# 添加为子节点
		add_child(sfx_player)
		# 存入数组管理
		sfx_players.append(sfx_player)

## 播放背景音乐
# 使用双播放器系统实现平滑的音乐切换
# 如果传入的音乐与当前播放的音乐相同，则不执行任何操作
# @param audio: 要播放的音频流资源
func play_music(audio:AudioStream) -> void:
	# 获取当前播放器
	var current_audio_player := music_players[current_music_player_index]
	# 如果是同一首音乐，直接返回避免重复播放
	if current_audio_player.stream == audio:
		return # 避免相同的音乐重复播放

	# 计算空闲播放器的索引（另一个播放器）
	var empty_audio_player_index = 0 if current_music_player_index == 1 else 1
	var empty_audio_player = music_players[empty_audio_player_index]

	# 设置新的音乐流并开始渐入效果
	empty_audio_player.stream = audio
	play_fade_in(empty_audio_player)
	# 当前播放器开始渐出效果
	play_fade_out(current_audio_player)
	# 更新当前播放器索引
	current_music_player_index = empty_audio_player_index

## 音乐渐入效果
# 使用Tween实现音量从静音到正常的平滑过渡
# @param audio_player: 要进行渐入的音频播放器
func play_fade_in(audio_player:AudioStreamPlayer) -> void:
	# 开始播放
	audio_player.play()
	# 创建渐变动画，从当前音量(-40dB)渐变到0dB（正常音量）
	var tween = create_tween()
	tween.tween_property(audio_player,"volume_db",0,music_fade_duration)

## 音乐渐出效果
# 使用Tween实现音量从正常到静音的平滑过渡，完成后停止播放
# @param audio_player: 要进行渐出的音频播放器
func play_fade_out(audio_player:AudioStreamPlayer) -> void:
	# 创建渐变动画，从当前音量渐变到-40dB（静音）
	var tween = create_tween()
	tween.tween_property(audio_player,"volume_db",-40,music_fade_duration)
	# 等待渐变完成
	await tween.finished
	# 停止播放并清除音频流
	audio_player.stop()
	audio_player.stream = null

## 播放游戏音效
# 在空闲的音效播放器中播放指定音效
# 支持同时播放多个音效，直到所有播放器都被占用
# @param audio: 要播放的音效音频流资源
func play_sfx(audio:AudioStream) -> void:
	# 遍历所有音效播放器，找到第一个空闲的播放器
	for i in sfx_player_count:
		var sfx_player = sfx_players[i]
		if not sfx_player.playing:
			# 设置音效流并开始播放
			sfx_player.stream = audio
			sfx_player.play()
			break # 找到第一个空闲播放器后立即停止搜索

## 设置音频总线音量
# 将线性音量值转换为分贝值并应用到指定音频总线
# @param bus_index: 音频总线类型枚举 (Bus.MASTER, Bus.MUSIC, Bus.SFX)
# @param v: 线性音量值 (0.0-1.0)
func set_volume(bus_index:Bus, v:float) -> void:
	# 将线性音量转换为分贝值
	var db = linear_to_db(v)
	# 应用到指定的音频总线
	AudioServer.set_bus_volume_db(bus_index, db)
