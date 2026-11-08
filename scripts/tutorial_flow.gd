extends Node
## Tutorial-only retry and goal handoff. Shared checkpoint objects can call
## set_checkpoint(); until integrated, retry returns to the tutorial entrance.

signal tutorial_completed

const Progress = preload("res://scripts/session_progress.gd")
const MENU := "res://scenes/main_menu.tscn"

@export var fall_y := 512.0
@export var completion_seconds := 1.4

@onready var level: Node2D = get_parent()
@onready var player: CharacterBody2D = level.get_node("PlayerCharacter")
@onready var goal: Area2D = level.get_node("SiblingGoal")
@onready var message: Label = $HUD/Message
@onready var fade: ColorRect = $HUD/Fade

var respawn_position := Vector2.ZERO
var completing := false


func _ready() -> void:
	process_physics_priority = 110
	respawn_position = player.global_position
	goal.body_entered.connect(_on_goal_entered)


func _physics_process(_delta: float) -> void:
	if not completing and (player.global_position.y > fall_y or player.global_position.x < -256.0
			or player.global_position.x > 6656.0):
		retry()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or completing:
		return
	if event.keycode == KEY_R:
		retry()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(MENU)


func set_checkpoint(world_position: Vector2) -> void:
	if not completing:
		respawn_position = world_position


func retry() -> void:
	if completing:
		return
	player.global_position = respawn_position
	player.reset_after_respawn()
	player.reset_physics_interpolation()
	level.sync_camera_to_player()


func _on_goal_entered(body: Node2D) -> void:
	if body != player or completing:
		return
	completing = true
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	Progress.complete_island(&"tutorial")
	tutorial_completed.emit()
	message.text = "Sibling rescued!\nReturning to the home screen…"
	message.show()
	fade.show()
	create_tween().tween_property(fade, "color:a", 0.8, minf(0.3, completion_seconds))
	await get_tree().create_timer(completion_seconds).timeout
	get_tree().change_scene_to_file(MENU)
