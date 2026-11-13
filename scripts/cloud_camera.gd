
extends Node2D
## Fixed tutorial views. Screen changes preserve the player's movement state.

@export var player: CharacterBody2D
@export_range(0.0, 64.0, 1.0) var boundary_margin := 24.0

@onready var cameras: Array[Camera2D] = [
	$"Camera (Screen 1)",
	$"Camera (Screen 2)",
	$"Camera (Screen 3)",
	$"Camera (Screen 4)",
	$"Camera (Screen 5)"
]

var active_screen := -1
var _previous_position := Vector2.ZERO


func _ready() -> void:
	process_physics_priority = 100

	for camera in cameras:
		camera.enabled = false

	sync_camera_to_player()


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	if player.global_position.distance_to(_previous_position) > 512.0:
		sync_camera_to_player()
	else:
		_select_screen(_screen_at(player.global_position))

	_previous_position = player.global_position


## Call after placing the player at a checkpoint.
func sync_camera_to_player() -> void:
	if not is_instance_valid(player):
		return

	_select_screen(_screen_at(player.global_position))
	_previous_position = player.global_position


## Returns the camera whose visible rectangle contains the point.
func _screen_at(point: Vector2) -> int:
	if cameras.is_empty():
		return -1

	# First, keep the active camera if the player remains
	# inside its screen boundaries (with hysteresis).
	if active_screen >= 0 and active_screen < cameras.size():
		if _point_inside_camera(point, cameras[active_screen], boundary_margin):
			return active_screen

	# Otherwise, find a camera whose visible rectangle contains the player.
	for i in range(cameras.size()):
		if i == active_screen:
			continue

		if _point_inside_camera(point, cameras[i], 0.0):
			return i

	# No camera contains the player. Keep the current camera.
	return active_screen if active_screen >= 0 else 0


## Checks whether a world position is inside a camera's visible rectangle.
func _point_inside_camera(
	point: Vector2,
	camera: Camera2D,
	margin: float
) -> bool:
	if not is_instance_valid(camera):
		return false

	var viewport_size := get_viewport_rect().size

	var half_size := viewport_size / (2.0 * camera.zoom)

	var camera_position := camera.global_position

	var left := camera_position.x - half_size.x - margin
	var right := camera_position.x + half_size.x + margin
	var top := camera_position.y - half_size.y - margin
	var bottom := camera_position.y + half_size.y + margin

	return (
		point.x >= left
		and point.x <= right
		and point.y >= top
		and point.y <= bottom
	)


func _select_screen(index: int) -> void:
	if index < 0 or index >= cameras.size():
		return

	if index == active_screen:
		return

	for i in range(cameras.size()):
		cameras[i].enabled = i == index

	cameras[index].make_current()
	cameras[index].reset_smoothing()

	active_screen = index
