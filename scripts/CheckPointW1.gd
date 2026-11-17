#Coding by: Caleb Sosa
#Created in 2026
#This is the checkpoint script for the game, unique to the witch level.
#It allows the player to set a checkpoint position when they collide with the checkpoint area.


extends Area2D

var activated: bool = false

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation.animation_finished.connect(_on_animation_finished)

	# Set the checkpoint's initial appearance.
	animation.play("default")
	animation.stop()


func _on_body_entered(body: Node2D) -> void:

	# Ignore already activated checkpoints.
	if activated:
		return

	# Check whether the object supports checkpoints.
	if body.has_method("set_checkpoint"):

		# Save the checkpoint position.
		body.set_checkpoint(spawn_point.global_position)

		activated = true

		# Play the default animation once.
		animation.play("default")

		print("Checkpoint activated!")


func _on_animation_finished() -> void:

	# Switch to the looping animation after the default animation finishes.
	if animation.animation == "default":
		animation.play("loop")
