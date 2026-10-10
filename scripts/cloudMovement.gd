extends Node2D

@export var cloud_speed: float = 30.0
@export var cloud_texture: Texture2D
@export var cloud_scale: Vector2 = Vector2(1.0, 1.0)
@export var cloud_y: float = 150.0
@export var cloud_count: int = 3

var clouds: Array[Sprite2D] = []


func _ready() -> void:
	if cloud_texture == null:
		push_warning("Assign a cloud PNG to cloud_texture.")
		return

	var screen_width: float = get_viewport_rect().size.x
	var cloud_width: float = cloud_texture.get_width() * cloud_scale.x

	if cloud_width <= 0.0:
		return

	for i in range(cloud_count):
		var cloud := Sprite2D.new()
		cloud.texture = cloud_texture
		cloud.scale = cloud_scale
		cloud.position = Vector2(
			i * screen_width / float(cloud_count),
			cloud_y
		)
		add_child(cloud)
		clouds.append(cloud)


func _process(delta: float) -> void:
	if clouds.is_empty():
		return

	var screen_width: float = get_viewport_rect().size.x
	var cloud_width: float = cloud_texture.get_width() * cloud_scale.x

	for cloud in clouds:
		cloud.position.x -= cloud_speed * delta

		if cloud.position.x < -cloud_width:
			cloud.position.x += screen_width + cloud_width
