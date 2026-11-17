
@tool
extends Control

# --- BUTTON CONFIGURATION ---

@export var polygon_points: PackedVector2Array = PackedVector2Array([
	Vector2(50, 0),
	Vector2(200, 0),
	Vector2(250, 75),
	Vector2(200, 150),
	Vector2(50, 150),
	Vector2(0, 75)
]) :
	set(value):
		polygon_points = value
		queue_redraw()

@export var target_scene: String = ""
@export var island_id: StringName = &""

# Leave empty if this island has no unlock requirement.
@export var requires_completion: StringName = &""

@export var outline_color: Color = Color.WHITE
@export var outline_width: float = 3.0

const SessionProgress = preload("res://scripts/session_progress.gd")

var hovered := false
var is_locked := false
var _starting := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if Engine.is_editor_hint():
		queue_redraw()
		return

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Check whether this island is unlocked.
	is_locked = (
		requires_completion != &"" and
		not SessionProgress.is_complete(requires_completion)
	)

	queue_redraw()


# --- POLYGON DRAWING ---

func _draw() -> void:
	if polygon_points.size() < 3:
		return

	# Draw the outline only when hovered and unlocked.
	if hovered and not is_locked:
		var outline_points = polygon_points.duplicate()
		outline_points.append(polygon_points[0])

		draw_polyline(
			outline_points,
			outline_color,
			outline_width,
			true
		)

	# Show vertex markers in the editor.
	if Engine.is_editor_hint():
		for point in polygon_points:
			draw_circle(point, 8.0, Color.WHITE)
			draw_circle(point, 5.0, Color.RED)


# --- MOUSE DETECTION ---

func _has_point(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(
		point,
		polygon_points
	)


func _on_mouse_entered() -> void:
	if is_locked:
		return

	hovered = true
	queue_redraw()


func _on_mouse_exited() -> void:
	hovered = false
	queue_redraw()


# --- BUTTON PRESS ---

func _gui_input(event: InputEvent) -> void:
	if is_locked or _starting:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_play_button_pressed()
			accept_event()


func _on_play_button_pressed() -> void:
	if _starting or is_locked:
		return

	if target_scene.is_empty():
		push_warning("No target scene assigned!")
		return

	_starting = true
	get_tree().change_scene_to_file(target_scene)
