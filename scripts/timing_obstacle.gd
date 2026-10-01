extends Node2D
## A reusable, non-lethal pop-out obstacle for the tutorial island.
## Connect `obstacle_touched` to a player or game manager when those systems exist.

signal obstacle_touched(body: Node2D)

enum Phase { RESTING, WARNING, EXTENDED, RETRACTING }

@export_range(0.1, 10.0, 0.1) var rest_min_seconds := 1.4
@export_range(0.1, 10.0, 0.1) var rest_max_seconds := 2.6
@export_range(0.1, 5.0, 0.1) var warning_seconds := 0.6
@export_range(0.1, 5.0, 0.1) var active_seconds := 0.7
@export_range(0.05, 2.0, 0.05) var extend_seconds := 0.18
@export_range(0.05, 2.0, 0.05) var retract_seconds := 0.22

const HIDDEN_Y := 72.0
const EXTENDED_Y := 0.0
const REST_COLOR := Color("6dbd75")
const WARNING_COLOR := Color("f2c14e")
const ACTIVE_COLOR := Color("e85d4a")

@onready var pusher: Node2D = $Pusher
@onready var visual: Polygon2D = $Pusher/Visual
@onready var hitbox: Area2D = $Pusher/Hitbox
@onready var warning_light: Polygon2D = $WarningLight

var _random := RandomNumberGenerator.new()
var _phase := Phase.RESTING


func _ready() -> void:
	_random.randomize()
	pusher.position.y = HIDDEN_Y
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_run_cycle()


func _run_cycle() -> void:
	while is_inside_tree():
		_set_phase(Phase.RESTING, REST_COLOR)
		await get_tree().create_timer(_random.randf_range(rest_min_seconds, rest_max_seconds)).timeout
		if not is_inside_tree():
			return

		_set_phase(Phase.WARNING, WARNING_COLOR)
		await get_tree().create_timer(warning_seconds).timeout
		if not is_inside_tree():
			return

		_set_phase(Phase.EXTENDED, ACTIVE_COLOR)
		await _move_pusher(EXTENDED_Y, extend_seconds)
		if not is_inside_tree():
			return
		hitbox.monitoring = true
		await get_tree().create_timer(active_seconds).timeout
		if not is_inside_tree():
			return

		hitbox.monitoring = false
		_set_phase(Phase.RETRACTING, REST_COLOR)
		await _move_pusher(HIDDEN_Y, retract_seconds)


func _set_phase(next_phase: Phase, tint: Color) -> void:
	_phase = next_phase
	visual.color = tint
	warning_light.visible = next_phase == Phase.WARNING or next_phase == Phase.EXTENDED
	warning_light.color = WARNING_COLOR if next_phase == Phase.WARNING else ACTIVE_COLOR


func _move_pusher(target_y: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(pusher, "position:y", target_y, duration)
	await tween.finished


func _on_hitbox_body_entered(body: Node2D) -> void:
	if _phase == Phase.EXTENDED:
		obstacle_touched.emit(body)
