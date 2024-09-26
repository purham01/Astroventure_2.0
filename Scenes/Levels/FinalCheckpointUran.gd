extends Node

@onready var tilemap = $"../LevelTileMap"
@onready var world = $".."
@export var disappearing_tiles : PackedScene
@onready var hidey_spikes = $"../Spikey bois/HideySpikes"
@onready var hidey_spikes_2 = $"../Spikey bois/HideySpikes2"



func _on_heart_15_pick_up():

	addObjects()
	
func addObjects():
	tilemap.set_layer_enabled(4,true)
	var usedCells = tilemap.get_used_cells(4)
	var cellLayer = 4
	var cellSrcId
	var place_at
	var placed_positions = []
	var placed_tiles = []
	for cell in usedCells:
		place_at = world.to_global(tilemap.map_to_local(cell))
		if place_at in placed_positions:
			continue
		cellSrcId = tilemap.get_cell_source_id(cellLayer, cell)
		if cellSrcId == 4:
			var tile_instance = disappearing_tiles.instantiate()
			
			
			place_tile(tile_instance, place_at, cellLayer)
			
			
			placed_positions.append(place_at)
			placed_tiles.append(tile_instance)
	hidey_spikes.animation_player.play("hide")
	hidey_spikes_2.animation_player.play("hide")
	tilemap.clear_layer(4)
	
	

func place_tile(tile_instance, place_at, cellLayer):
	add_child(tile_instance)
	tile_instance.animation_player.play_backwards("disappear_2")
	place_at.x -=7
	place_at.y +=8
	tile_instance.position = place_at
