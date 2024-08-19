class_name HealingEffect
extends Effect


static func get_id() -> String:
	return "healing"


func apply() -> void:
	RunData.emit_signal("healing_effect", max(1, value + RunData.effects["consumable_heal"]), "")


func unapply() -> void:
	pass
