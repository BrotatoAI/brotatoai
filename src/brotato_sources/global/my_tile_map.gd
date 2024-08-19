class_name MyTileMap
extends TileMap

onready var outline = $Outline


func init(zone:ZoneData)->void :
	outline.rect_size = Vector2(Utils.TILE_SIZE * (zone.width + 2), Utils.TILE_SIZE * (zone.height + 2))
	for i in zone.width:
		for j in zone.height:
			my_set_cell(i, j, zone.my_id)


func my_set_cell(x:int, y:int, my_id:int)->void :
	set_cell(x, y, my_id, false, false, false, get_subtile_with_priority(my_id))


func get_subtile_with_priority(my_id:int)->Vector2:
	var rect = tile_set.tile_get_region(my_id)
	var size_x = rect.size.x / tile_set.autotile_get_size(my_id).x
	var size_y = rect.size.y / tile_set.autotile_get_size(my_id).y
	var tile_array = []

	for x in size_x:
		for y in size_y:
			var priority = tile_set.autotile_get_subtile_priority(my_id, Vector2(x, y))
			for p in priority:
				tile_array.append(Vector2(x, y))

	return tile_array[randi() % tile_array.size()]
