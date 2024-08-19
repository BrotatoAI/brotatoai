class_name EliteContainer
extends Inventory

export (Resource) var elite_icon
export (Resource) var horde_icon

var elite_elements: = []


func _ready()->void :
	elite_elements = get_children()
	var next_wave = RunData.current_wave + 1

	if RunData.elites_spawn.size() > 0:
		for i in min(RunData.elites_spawn.size(), elite_elements.size()):

			if RunData.elites_spawn[i][0] < next_wave:
				continue

			if RunData.elites_spawn[i][0] == next_wave:
				elite_elements[i].update_background_color(Tier.DANGER_0)

			elite_elements[i].show()

			if RunData.elites_spawn[i][1] == EliteType.ELITE:
				elite_elements[i].set_icon(elite_icon)
			elif RunData.elites_spawn[i][1] == EliteType.HORDE:
				elite_elements[i].set_icon(horde_icon)

			elite_elements[i].set_number(RunData.elites_spawn[i][0])
