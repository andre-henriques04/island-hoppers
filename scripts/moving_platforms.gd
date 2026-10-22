
extends AnimatableBody2D

enum MoveDirection {
	RIGHT,
	LEFT,
	DOWN,
	UP
}

@export_group("Movement")
@export var direction: MoveDirection = MoveDirection.RIGHT

@export_range(0.0, 2000.0, 1.0, "or_greater")
var travel_distance: float = 192.0

@export_range(1.0, 1000.0, 1.0, "or_greater")
var speed: float = 64.0

@export_range(0.0, 10.0, 0.1)
var endpoint_pause: float = 0.5


var _start_position: Vector2
var _end_position: Vector2
var _moving_to_end := true
var _pause_remaining := 0.0


func _ready() -> void:
	_start_position = position

	var direction_vector := Vector2.ZERO

	match direction:
		MoveDirection.RIGHT:
			direction_vector = Vector2.RIGHT
		MoveDirection.LEFT:
			direction_vector = Vector2.LEFT
		MoveDirection.DOWN:
			direction_vector = Vector2.DOWN
		MoveDirection.UP:
			direction_vector = Vector2.UP

	_end_position = (
		_start_position + direction_vector * travel_distance
	)


func _physics_process(delta: float) -> void:
	if _pause_remaining > 0.0:
		_pause_remaining = maxf(0.0, _pause_remaining - delta)
		return

	var target := _end_position if _moving_to_end \
		else _start_position

	position = position.move_toward(
		target,
		speed * delta
	)

	if position.distance_to(target) < 0.01:
		position = target
		_moving_to_end = not _moving_to_end
		_pause_remaining = endpoint_pause
