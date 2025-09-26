extends Resource
class_name Item

enum ItemType{
	None,
	Tool,##工具
	Hoe,##锄头
	Axe,##斧头
	Draft,##稿子
	Water,##水壶
	Weapon,##近战武器
	Consume,##消耗品
	Placeables,##可放置的物品
	Crops,##植物，作物等可以生长的物品
	Materials,##可合成的材料类物品
	Accessories,##饰品
	Floors,##地板类
	Seeds,##种子类
	Animal,##动物类
	AnimalProduct,##动物产品
}
enum UseType{
	None,
	Swing, ##挥舞
	Hold, ##手持
}
enum DamageType{
	None,
	Melee,##近战
	Magic,##魔法
	Summon,##召唤
	Shoot,##远程
}

enum Season{
	Spring,##春季
	Summer,##夏季
	Autumn,##秋季
	Winter,##冬季
}

@export var name:String ## 物品的名字
@export var type:ItemType ## 物品类型
@export_multiline var description:String
@export var quantity:int = 1
@export var max_quantity:int = 999
@export var countable:bool
@export var texture:Texture
@export var price:int = 1 ##物品价格
#下面是武器类的专属属性
@export_category("武器属性")
@export var collision_size:Vector2 ## 碰撞箱宽度高度
@export var use_time:int
@export var use_animation:int ##可以调整动画节点的speed_scale值
@export var auto_use:bool
@export var damage:int
@export var crit:float ## 暴击
@export var knockback:float ##击退
@export var open_trail:bool ##是否开启贴图攻击尾迹
@export var open_texture:bool ##是否开启贴图
@export var use_type:UseType
@export var damage_type:DamageType
@export var projectile:String
#放置类物品的属性
@export_category("放置类物品属性")
@export var placeable_scene_path:String

#作物相关属性
@export_category("作物属性")
@export var seasons:Array[Season] ## 可种植季节
@export var growth_days:int = 7 ## 生长天数
@export var regrowth_days:int = 0 ## 再生长天数（0表示不可再生）
@export var water_needed:bool = true ## 是否需要浇水
@export var harvest_count:int = 1 ## 收获数量
@export var seed_price:int = 0 ## 种子价格
@export var sell_price:int = 0 ## 售卖价格

#动物相关属性
@export_category("动物属性")
@export var animal_type:String ## 动物类型
@export var happiness:int = 50 ## 幸福度 (0-100)
@export var produces:Array[String] ## 生产的产品
@export var production_days:int = 1 ## 生产周期天数

func is_max_quantity() -> bool:
	return quantity>=max_quantity

func set_weapon(damage:int,crit:float,knockback:float) -> void:
	self.damage = damage
	self.crit = crit
	self.knockback = knockback
