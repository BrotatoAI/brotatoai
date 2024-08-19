class_name WaveGroupData
extends Resource

export (float) var spawn_chance = 1.0
export (int) var spawn_timing = 1
export (int) var repeating = 999
export (int) var repeating_interval = 3
export (int) var reduce_repeating_interval = 0
export (int) var min_repeating_interval = 1
export (int) var area = - 1
export (int) var spawn_dist_away_from_edges = 0
export (bool) var spawn_edge_of_map = false
export (Array, Resource) var wave_units_data = []
export (bool) var is_neutral = false
export (bool) var is_boss = false
export (bool) var is_horde = false
export (int) var min_difficulty = 0


export (int) var min_wave = 0
export (int) var max_wave = 9999
