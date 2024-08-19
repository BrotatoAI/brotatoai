class_name MyTileMapLimits
extends StaticBody2D








var collider_depth = 4 * Utils.TILE_SIZE


func init(zone:ZoneData)->void :
	var width = zone.width * Utils.TILE_SIZE
	var height = zone.height * Utils.TILE_SIZE
	
	create_wall(
		Vector2( - collider_depth / 2, height / 2), Vector2(collider_depth, height + collider_depth)
	)
	
	create_wall(
		Vector2(width + collider_depth / 2, height / 2), 
		Vector2(collider_depth, height + collider_depth)
	)
	
	create_wall(
		Vector2(width / 2, - collider_depth / 2), Vector2(width + collider_depth, collider_depth)
	)
	
	create_wall(
		Vector2(width / 2, height + collider_depth / 2), 
		Vector2(width + collider_depth, collider_depth)
	)


func create_wall(center:Vector2, size:Vector2)->void :
	var wall_shape = CollisionShape2D.new()
	wall_shape.shape = RectangleShape2D.new()
	wall_shape.shape.extents = size / 2
	self.add_child(wall_shape)
	wall_shape.global_position = center
