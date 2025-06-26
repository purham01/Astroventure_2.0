extends Node

@export var disappearing_tiles : PackedScene

@onready var world = get_node("..")
@onready var tilemap : TileMapLayer = get_node("../TileMap/DisappearingTiles")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	addObjects()

func addObjects():
	var usedCells = tilemap.get_used_cells()
	var place_at
	var placed_positions = []
	var placed_tiles = []
	for cell in usedCells:
		place_at = world.to_global(tilemap.map_to_local(cell))
		if place_at in placed_positions:
			continue
		
		var tile_instance = disappearing_tiles.instantiate()
		place_tile(tile_instance, place_at)
		placed_positions.append(place_at)
		placed_tiles.append(tile_instance)
		check_neighbouring_tiles(cell, usedCells, placed_positions, placed_tiles, tile_instance)
			
	tilemap.clear()

func place_tile(tile_instance, place_at):
	add_child(tile_instance)
	#place_at.x -=7
	#place_at.y +=8
	tile_instance.position = place_at
	
func check_neighbouring_tiles(cell, usedCells, placed_positions, placed_tiles, tile_instance):
	var place_at
	var tile_instance_right
	var tile_instance_left
	cell.x += 1
	if cell in usedCells:
		place_at = world.to_global(tilemap.map_to_local(cell))
		if place_at not in placed_positions:
			tile_instance_right = disappearing_tiles.instantiate()
			place_tile(tile_instance_right, place_at)
			placed_positions.append(place_at)
			placed_tiles.append(tile_instance_right)
			check_neighbouring_tiles(cell, usedCells, placed_positions, placed_tiles, tile_instance_right)
		else:
			tile_instance_right = placed_tiles[placed_positions.find(place_at)]
		tile_instance.tile_right = tile_instance_right
	cell.x -= 2
	if cell in usedCells:
		place_at = world.to_global(tilemap.map_to_local(cell))
		if place_at not in placed_positions:
			tile_instance_left = disappearing_tiles.instantiate()
			place_tile(tile_instance_left, place_at)
			placed_positions.append(place_at)
			placed_tiles.append(tile_instance_left)
			check_neighbouring_tiles(cell, usedCells, placed_positions, placed_tiles, tile_instance_left)
		else:
			tile_instance_left = placed_tiles[placed_positions.find(place_at)]
		tile_instance.tile_left = tile_instance_left
