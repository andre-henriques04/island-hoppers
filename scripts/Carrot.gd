
extends Area2D

@export var bob_height: float = 10.0
@export var bob_speed: float = 1.0
@export var respawn_time: float = 10.0

var start_y: float
var is_collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# Store the starting position
	start_y = position.y

	# Create a looping bobbing animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", start_y - bob_height, bob_speed)
	tween.tween_property(self, "position:y", start_y + bob_height, bob_speed)

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if body.has_method("activate_speed_boost"):
		body.activate_speed_boost()
		is_collected = true

		# Hide the carrot and disable collisions
		hide()
		$CollisionShape2D.set_deferred("disabled", true)

		# Wait before respawning
		await get_tree().create_timer(respawn_time).timeout

		# Respawn the carrot
		position.y = start_y
		show()
		$CollisionShape2D.set_deferred("disabled", false)
		is_collected = false
