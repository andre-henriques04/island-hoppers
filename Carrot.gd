#Coding by: Caleb Sosa
#Created in 2026
#This is the food item script for the game. 
#The food item is a carrot item that the player can collect to gain points or health.
#Here, we define the behavior of the carrot when the player collides with it.
#Penalties/ buffs are on the character movement script, 
#so when the player collides with the carrot, 
#it will call a function on the character movement script to apply the penalty or buff.
extends Area2D

var activated: bool = false

@onready var spawn_point: Marker2D = $SpawnPoint


func _ready() -> void:
    body_entered.connect(_on_body_entered)

extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        body.activate_speed_boost()
        queue_free()
