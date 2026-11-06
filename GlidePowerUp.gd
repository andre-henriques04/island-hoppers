#Coding by: Caleb Sosa
#Created in 2026
#This section of code is for the Glide Power Up in the game.
#It allows the player to glide through the air for a limited time, 
#providing a unique gameplay mechanic.


extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:

	if body.has_method("activate_glide"):
		body.activate_glide()
		queue_free()
