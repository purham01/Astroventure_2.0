extends Node

static var LootLockerSettings = preload("res://addons/LootLockerSDK/Game/Internals/LootLockerInternal_Settings.gd")

func _init() -> void:
	LootLockerSettings.GetInstance().loadSettings()
