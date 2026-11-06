#Coding by: Caleb Sosa
#Created in 2026
#This is the checkpoint script for the game, unique to the cloud level.
#It allows the player to set a checkpoint position when they collide with the checkpoint area.
extends Area2D

var activated: bool = false

@onready var spawn_point: Marker2D = $SpawnPoint


func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        body.set_checkpoint(spawn_point.global_position)
        activated = true
