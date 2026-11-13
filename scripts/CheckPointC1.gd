#Coding by: Caleb Sosa
#Created in 2026
#This is the checkpoint script for the game, unique to the cloud level.
#It allows the player to set a checkpoint position when they collide with the checkpoint area.


# =========================================================
# CHECKPOINT
# =========================================================


extends Area2D

var activated: bool = false

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


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
		animation.play()

		print("Checkpoint activated!")
