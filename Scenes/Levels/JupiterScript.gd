extends Node

@export var moving_spikes : PackedScene
@export var tilemap : TileMap
@onready var world = get_node("..")
@export var disappearing_tiles : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	addSpikes()
	addDissappearingTiles()
	tilemap.clear_layer(2)
	tilemap.clear_layer(3)

func addSpikes():
	var usedCells = tilemap.get_used_cells(2) + tilemap.get_used_cells(3)
	for cell in usedCells:
		var cellLayer = 2 if tilemap.get_cell_source_id(2, cell) != -1 else 3
		var cellSrcId = tilemap.get_cell_source_id(cellLayer, cell)
		var cellAlt = tilemap.get_cell_alternative_tile(cellLayer, cell)
		var place_at = world.to_global(tilemap.map_to_local(cell))
		if cellSrcId == 3:
			place_spike(place_at, cellLayer, cellAlt)
	

func place_spike(place_at, cellLayer, cellAlt):
	var spike_instance = moving_spikes.instantiate()
	if cellLayer == 3:
		spike_instance.retracted = true
	add_child(spike_instance)
	if cellAlt == 0:
		place_at.x -=34
		place_at.y +=8
	elif cellAlt == 2:
		spike_instance.rotation = PI
		place_at.x -= 16
		place_at.y -= 4
	elif cellAlt == 3:
		spike_instance.rotation = 1.5 * PI
		place_at.x -= 34
		place_at.y += 23
	elif cellAlt == 4:
		spike_instance.rotation = 0.5 * PI
		place_at.x -= 18
		place_at.y -= -10
	spike_instance.position = place_at

func addDissappearingTiles():
	var usedCells = tilemap.get_used_cells(2)
	var cellLayer = 2
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
			check_neighbouring_tiles(cell, usedCells, cellLayer, placed_positions, placed_tiles, tile_instance)

func place_tile(tile_instance, place_at, cellLayer):
	add_child(tile_instance)
	place_at.x -=(7+26)
	place_at.y +=(8+16)
	tile_instance.position = place_at
	
func check_neighbouring_tiles(cell, usedCells, cellLayer, placed_positions, placed_tiles, tile_instance):
	var place_at
	var tile_instance_right
	var tile_instance_left
	cell.x += 1
	if cell in usedCells:
		place_at = world.to_global(tilemap.map_to_local(cell))
		if place_at not in placed_positions:
			tile_instance_right = disappearing_tiles.instantiate()
			place_tile(tile_instance_right, place_at, cellLayer)
			placed_positions.append(place_at)
			placed_tiles.append(tile_instance_right)
			check_neighbouring_tiles(cell, usedCells, cellLayer, placed_positions, placed_tiles, tile_instance_right)
		else:
			tile_instance_right = placed_tiles[placed_positions.find(place_at)]
		tile_instance.tile_right = tile_instance_right
	cell.x -= 2
	if cell in usedCells:
		place_at = world.to_global(tilemap.map_to_local(cell))
		if place_at not in placed_positions:
			tile_instance_left = disappearing_tiles.instantiate()
			place_tile(tile_instance_left, place_at, cellLayer)
			placed_positions.append(place_at)
			placed_tiles.append(tile_instance_left)
			check_neighbouring_tiles(cell, usedCells, cellLayer, placed_positions, placed_tiles, tile_instance_left)
		else:
			tile_instance_left = placed_tiles[placed_positions.find(place_at)]
		tile_instance.tile_left = tile_instance_left
