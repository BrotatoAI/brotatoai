class_name EnemyProjectileRotating
extends EnemyProjectile

export (int) var min_target_distance = 100
export (int) var max_target_distance = 100
export (int) var speed = 100
export (bool) var destroy_on_hit = false
export (float) var damage = 1.0
export (float) var damage_increase_each_wave = 1.0

var actual_target_distance = 0

func _ready()->void :
	set_damage(damage + ((RunData.current_wave - 1) * damage_increase_each_wave) as int)
	actual_target_distance = rand_range(min_target_distance, max_target_distance)


func _physics_process(delta:float)->void :
	if position.x < actual_target_distance:
		position.x += speed * RunData.current_run_accessibility_settings.speed * delta


func _on_Hitbox_hit_something(_thing_hit:Node, _damage_dealt:int)->void :
	if destroy_on_hit:
		set_to_be_destroyed()
