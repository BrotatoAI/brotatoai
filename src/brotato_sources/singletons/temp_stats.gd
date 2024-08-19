extends Node



signal temp_stats_updated

var stats = null
var player = null
var _are_stats_dirty = false

func reset()->void :
	stats = init_stats()


func get_signal_name()->String:
	return "temp_stats_updated"


func set_stat(stat_name:String, value:int)->void :
	stats[stat_name] = value
	emit_signal(get_signal_name())


func add_stat(stat_name:String, value:int)->void :
	stats[stat_name] += value
	_are_stats_dirty = true


func remove_stat(stat_name:String, value:int)->void :
	stats[stat_name] -= value
	_are_stats_dirty = true


func emit_updated()->void :
	if not _are_stats_dirty:
		return 
	_are_stats_dirty = false
	emit_signal(get_signal_name())


func get_stat(stat_name:String)->int:
	if stat_name in stats:
		return stats[stat_name] * RunData.get_stat_gain(stat_name)
	else :
		return 0


func init_stats()->Dictionary:
	return RunData.init_stats(true)
