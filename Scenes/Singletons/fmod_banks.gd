extends Node

@onready var dash: FmodEventEmitter2D = $Player/Dash
@onready var walk: FmodEventEmitter2D = $Player/Walk
@onready var die: FmodEventEmitter2D = $Player/Die
@onready var respawn: FmodEventEmitter2D = $Player/Respawn
@onready var respawn_2: FmodEventEmitter2D = $Player/Respawn2

@onready var collect: FmodEventEmitter2D = $Star/Collect

@onready var portal_enter: FmodEventEmitter2D = $Portal/PortalEnter
@onready var portal_exit: FmodEventEmitter2D = $Portal/PortalExit

@onready var destroy_wall: FmodEventEmitter2D = $DestructbleWall/DestroyWall

@onready var select: FmodEventEmitter2D = $UI/Select
@onready var cancel: FmodEventEmitter2D = $UI/Cancel
@onready var pause: FmodEventEmitter2D = $UI/Pause
@onready var unpause: FmodEventEmitter2D = $UI/Unpause
@onready var popup_open: FmodEventEmitter2D = $UI/PopupOpen
@onready var popup_close: FmodEventEmitter2D = $UI/PopupClose
@onready var error: FmodEventEmitter2D = $UI/Error

@onready var start: FmodEventEmitter2D = $MovingPlatform/Start
@onready var end: FmodEventEmitter2D = $MovingPlatform/End

@onready var eye_sfx: FmodEventEmitter2D = $Eye/EyeSfx
@onready var continue_game: FmodEventEmitter2D = $UI/ContinueGame
@onready var end_game: FmodEventEmitter2D = $UI/EndGame
