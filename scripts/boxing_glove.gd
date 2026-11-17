extends "res://scripts/timing_obstacle.gd"
## Uses the prototype's timing cycle; local UP is the punch direction.

@export var launch_speed := 1350.0
@export var upward_assist := 260.0

var _hit_bodies: Dictionary = {}
@onready var glove_sprite: AnimatedSprite2D = $Pusher/Visual


func _ready() -> void:
	obstacle_touched.connect(_launch_body)
	super._ready()
	# Extension is drawn into the spritesheet, not a second position tween.
	pusher.position = Vector2.ZERO


func _set_phase(next_phase: Phase, _tint: Color) -> void:
	_phase = next_phase
	visual.modulate = Color(1.0, 0.75, 0.35) if next_phase == Phase.WARNING else Color.WHITE
	warning_light.visible = next_phase == Phase.WARNING
	warning_light.color = WARNING_COLOR
	if next_phase == Phase.RESTING or next_phase == Phase.WARNING:
		glove_sprite.frame = 0
	if next_phase == Phase.EXTENDED:
		_hit_bodies.clear()


func _move_pusher(target_y: float, duration: float) -> void:
	var extending := target_y == EXTENDED_Y
	var tween := create_tween()
	# Frames 0–2 extend to the peak. Frames 3–35 settle back to rest.
	tween.tween_method(_show_frame, 0.0 if extending else 3.0, 2.0 if extending else 35.0, duration)
	await tween.finished


func _show_frame(value: float) -> void:
	glove_sprite.frame = roundi(value)


func _launch_body(body: Node2D) -> void:
	if not body.has_method("apply_obstacle_launch") or _hit_bodies.has(body.get_instance_id()):
		return
	_hit_bodies[body.get_instance_id()] = true
	var direction := Vector2.UP.rotated(global_rotation)
	var impulse := direction * launch_speed
	# A sideways punch also lifts the bunny slightly off the platform.
	if absf(direction.x) > 0.5:
		impulse.y -= upward_assist
	body.apply_obstacle_launch(impulse)
