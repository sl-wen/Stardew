# 状态基类
# 所有玩家状态的基类，定义了状态的基本生命周期方法
# 使用模板方法模式，子类通过重写虚方法实现具体状态逻辑
extends Node
class_name State

## 状态转换信号
# 当需要切换状态时发出此信号
# @param state_name: 要切换到的状态名称
@warning_ignore("unused_signal")
signal transition_to(state_name:String)

## 进入状态（虚方法）
# 当玩家进入此状态时调用
# 通常用于初始化状态、播放进入动画等一次性操作
# 循环播放的动画应该在_physics_update中处理
func _enter():
	pass

## 退出状态（虚方法）
# 当玩家离开此状态时调用
# 通常用于清理状态、停止动画、移除效果等
func _exit():
	pass

## 物理帧更新（虚方法）
# 每物理帧调用，用于状态的核心逻辑
# 包括：移动计算、状态转换条件判断、持续动画播放等
# @param delta: 物理帧间隔时间
func _physics_update(delta):
	pass

## 帧更新（虚方法）
# 每帧调用，通常用于粒子特效、UI更新等不需要物理计算的操作
# @param delta: 帧间隔时间
func _update(delta):
	pass

## 更新动画（虚方法）
# 执行对应状态的动画逻辑
# 通常在_physics_update中调用以确保动画与物理更新同步
func _update_animation():
	pass
