extends Node

@onready var idle: Node = $IDLE
@onready var move: Node = $MOVE
@onready var jump: Node = $JUMP
@onready var fall: Node = $FALL
@onready var dash: Node = $DASH
@onready var climb: Node = $CLIMB
@onready var wall_slide: Node = $WALL_SLIDE
@onready var wall_jump: Node = $WALL_JUMP
@onready var dead: Node = $DEAD
@onready var transition: Node = $TRANSITION
@onready var gravity_transition: Node = $GRAVITY_TRANSITION
