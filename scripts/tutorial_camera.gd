extends Node2D
## Fixed tutorial views. Screen changes preserve the player's movement state.

@export var player: CharacterBody2D
@export_range(0.0, 64.0, 1.0) var boundary_margin := 24.0

@onready var cameras: Array[Camera2D] = [
	$"Camera (Screen 1)", $"Camera (Screen 2)", $"Camera (Screen 3)",
	$"Camera (Screen 4)", $"Camera (Screen 5)",
]

var active_screen := -1
var _previous_position := Vector2.ZERO


func _ready() -> void:
	# Run after the player so crossing a boundary is reflected in the same frame.
	process_physics_priority = 100
	sync_camera_to_player()


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	# A checkpoint teleport must select its destination immediately.
	if player.global_position.distance_to(_previous_position) > 512.0:
		sync_camera_to_player()
	else:
		_select_screen(_screen_at(player.global_position, true))
	_previous_position = player.global_position


## Call after placing the player at a checkpoint, including near a boundary.
func sync_camera_to_player() -> void:
	if not is_instance_valid(player):
		return
	_select_screen(_screen_at(player.global_position, false))
	_previous_position = player.global_position


func _screen_at(point: Vector2, use_margin: bool) -> int:
	var column := 0 if active_screen <= 0 else (1 if active_screen <= 2 else 2)
	var margin := boundary_margin if use_margin and active_screen >= 0 else 0.0
	# Columns follow the existing camera offsets, rather than window dimensions.
	if point.x < cameras[1].offset.x - (margin if column >= 1 else 0.0):
		return 0
	if column == 0 and point.x < cameras[1].offset.x + margin:
		return 0
	var in_right_column := point.x >= cameras[3].offset.x + (margin if column < 2 else -margin)
	var upper := 3 if in_right_column else 1
	var lower := upper + 1
	var split_y := cameras[lower].offset.y
	if active_screen == upper and point.y < split_y + margin:
		return upper
	if active_screen == lower and point.y > split_y - margin:
		return lower
	return upper if point.y < split_y else lower


func _select_screen(index: int) -> void:
	if index == active_screen:
		return
	for i in range(cameras.size()):
		cameras[i].enabled = i == index
	cameras[index].make_current()
	cameras[index].reset_smoothing()
	active_screen = index
