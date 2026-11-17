extends Node2D
## Loads the actual island and enters its arena, bypassing only the platforming route.
func _ready() -> void:
	var island := preload("res://scenes/boss_island.tscn").instantiate()
	add_child(island)
	island.get_node("PlayerCharacter").position = Vector2(7350, -400)
	island.sync_camera_to_player()
