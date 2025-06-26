@tool
extends Node


const AUTOLOAD_NAME = "LootLockerSDK"

static var LootLockerSettings = preload("res://addons/LootLockerSDK/Game/Internals/LootLockerInternal_Settings.gd")

#
#func _enable_plugin():
	#add_autoload_singleton(AUTOLOAD_NAME, "res://addons/LootLockerSDK/LootLockerSDKAutoload.gd")
	#LootLockerSettings.GetInstance().loadSettings()
#
#func _disable_plugin():
	#remove_autoload_singleton(AUTOLOAD_NAME)

func _init() -> void:
	LootLockerSettings.GetInstance().loadSettings()
