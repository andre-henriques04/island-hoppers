extends Node2D

@onready var arena_trigger = $ArenaTrigger
@onready var left_gate = $LeftGate
@onready var right_gate = $RightGate

@export var gate_drop_distance: float = 150.0
@export var gate_drop_duration: float = 1.0

var arena_started = false


func _ready():
	arena_trigger.body_entered.connect(_on_body_entered)
	print("Boss arena loaded!")


func _on_body_entered(body):
	if body.name != "PlayerCharacter":
		return

	if arena_started:
		return

	print("Player entered boss arena!")

	start_boss_arena()


func start_boss_arena():
	arena_started = true

	print("Dropping gates!")

	arena_trigger.set_deferred("monitoring", false)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		left_gate,
		"position:y",
		left_gate.position.y + gate_drop_distance,
		gate_drop_duration
	)

	tween.tween_property(
		right_gate,
		"position:y",
		right_gate.position.y + gate_drop_distance,
		gate_drop_duration
	)

	tween.set_parallel(false)

	await tween.finished

	print("Gates dropped!")
