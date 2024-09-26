extends Node

@export var moving_spikes : PackedScene
@export var tilemap : TileMap
@onready var world = get_node("..")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	addObjects()

func addObjects():
	var usedCells = tilemap.get_used_cells(2) + tilemap.get_used_cells(3)
	for cell in usedCells:
		var cellLayer = 2 if tilemap.get_cell_source_id(2, cell) != -1 else 3
		var cellSrcId = tilemap.get_cell_source_id(cellLayer, cell)
		var cellAlt = tilemap.get_cell_alternative_tile(cellLayer, cell)
		var place_at = world.to_global(tilemap.map_to_local(cell))
		if cellSrcId == 3:
			place_spike(place_at, cellLayer, cellAlt)
	tilemap.clear_layer(2)
	tilemap.clear_layer(3)

func place_spike(place_at, cellLayer, cellAlt):
	var spike_instance = moving_spikes.instantiate()
	if cellLayer == 3:
		spike_instance.retracted = true
	add_child(spike_instance)
	if cellAlt == 0:
		place_at.x -=24
		place_at.y +=4
	elif cellAlt == 2:
		spike_instance.rotation = PI
		place_at.x -= 8
		place_at.y -= 12
	elif cellAlt == 3:
		spike_instance.rotation = 1.5 * PI
		place_at.x -= 8
		place_at.y += 4
	elif cellAlt == 4:
		spike_instance.rotation = 0.5 * PI
		place_at.x -= 24
		place_at.y -= 12
	spike_instance.position = place_at


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
