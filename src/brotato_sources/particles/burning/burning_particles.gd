class_name BurningParticles
extends Particles2D

export (Resource) var red_mat
export (Resource) var blue_mat

onready var _collision = $SpreadArea / CollisionShape2D

var burning_data:BurningData
var bodies = []
var emit_remaining: = 0.0


func _ready()->void :
	if RunData.effects["burning_spread"] <= 0:
		deactivate_spread()


func _physics_process(delta:float)->void :
	
	
	
	if visible and not emitting:
		if emit_remaining == 0.0:
			emit_remaining = lifetime * 1.2
		else :
			emit_remaining -= delta
			if emit_remaining < 0.0:
				emit_remaining = 0.0
				visible = false
	else :
		emit_remaining = 0.0

	if _collision.disabled:return 

	if burning_data != null and burning_data.spread > 0 and bodies.size() > 0:
		for body in bodies:
			if is_instance_valid(body) and not body.dead and body._burning == null:
				burning_data.spread = max(0, burning_data.spread - 1) as int
				body.apply_burning(burning_data)
				burning_data.spread = 0
				break


func start_emitting()->void :
	emitting = true
	visible = true
	update_color()


func update_color()->void :
	if burning_data != null:
		if burning_data.type == BurningType.ELEMENTAL:
			process_material = red_mat
		elif burning_data.type == BurningType.ENGINEERING:
			process_material = blue_mat


func activate_spread()->void :
	_collision.set_deferred("disabled", false)


func deactivate_spread()->void :
	_collision.set_deferred("disabled", true)


func _on_SpreadArea_body_entered(body:Node)->void :
	if is_instance_valid(body) and not body.dead:
		bodies.push_back(body)


func _on_SpreadArea_body_exited(body:Node)->void :
	bodies.erase(body)
