extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("activate_jump_boost"):
		body.activate_jump_boost()
		queue_free()
