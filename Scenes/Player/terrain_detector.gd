extends Area2D

signal terrain_entered(terrain_type)

const bitmask : int = 255

enum TerrainType {
	
	NORMAL = 1,
	ICE = 2
}

var current_tilemap : TileMap
var current_terrain: int = -1
var previous_terrain: int = -1


func _exit_tree():
	current_tilemap = null
	current_terrain = -1




func _process_tilemap_collision(body: Node2D, body_rid: RID):
	current_tilemap = body as TileMap
	#print("Yo, i am processoing yo collision")
	var collided_tile_cords = current_tilemap.get_coords_for_body_rid(body_rid)
	
	for index in current_tilemap.get_layers_count():
		var tile_data = current_tilemap.get_cell_tile_data(index,collided_tile_cords)
		if !tile_data is TileData:
			continue
		var terrain_mask = tile_data.get_custom_data_by_layer_id(0)
		_update_terrain(terrain_mask)
		break

#static func get_custom_data_at(position: Vector2, custom_data_name: String) -> Variant:
#	var data = get_tile_data_at(position)
#	return data.get_custom_data(custom_data_name)


func _update_terrain(terrain_mask: int):
	
	if terrain_mask != current_terrain:
		previous_terrain = current_terrain
		current_terrain = terrain_mask
		emit_signal("terrain_entered", current_terrain)



func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		_process_tilemap_collision(body, body_rid)


func _on_body_exited(body):
	if body is TileMap:
		#print("No terrain detected")
		current_terrain = -1
		previous_terrain = -1
		emit_signal("terrain_entered", current_terrain)
