#Coding by: Caleb Sosa
#Created in 2026
#This is the deathbarrier script for the game.
#It allows the player to enter the death barrier area and die, 
#resetting to the last checkpoint position.
extends Area2D


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        body.die()