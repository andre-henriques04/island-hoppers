#Coding by: Caleb Sosa
#Created in 2026
#This section of code is for the Glide Power Up in the game.
#It allows the player to glide through the air for a limited time, 
#providing a unique gameplay mechanic.

extends Area2D

var activated : bool = false

func activate_glide() -> void:
    glide_available = true
    glide_active = false
    glide_timer = 0.0