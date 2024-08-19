class_name Stats
extends Resource

enum Tier{COMMON, UNCOMMON, RARE, LEGENDARY}

export (int) var health = 1
export (float) var health_increase_each_wave = 1.0
export (int) var speed = 300
export (int) var speed_randomization = 0
export (int) var damage = 1
export (float) var damage_increase_each_wave = 1.0
export (float) var attack_cd = 30.0
export (int) var value = 1
export (float, 0.0, 1.0, 0.1) var knockback_resistance = 0.0
export (int) var gold_spread = 0
export (bool) var can_drop_consumables = true
export (bool) var always_drop_consumables = false
export (float, 0.0, 1.0, 0.01) var base_drop_chance = 0.01
export (float, 0.0, 1.0, 0.01) var item_drop_chance = 0.01
export (Tier) var min_consumable_tier = Tier.COMMON
export (Tier) var max_consumable_tier = Tier.COMMON
export (int) var armor = 0
export (float) var armor_increase_each_wave = 0.0
