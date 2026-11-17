extends Control
## Screen-space dialogue whose tail follows the speaking character in world space.
var speaker: Node2D
var words: Label
var box := Rect2()
var tip := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	words = Label.new()
	words.text = "All this way... for your family?\nI underestimated you, little hopper.\nYou win. Take your sibling home."
	words.add_theme_color_override("font_color", Color.BLACK)
	words.add_theme_font_size_override("font_size", 20)
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(words)

func _process(_delta: float) -> void:
	if not is_instance_valid(speaker): return
	tip = speaker.get_global_transform_with_canvas() * Vector2(25, -65)
	var viewport := get_viewport_rect().size
	var width := minf(520, viewport.x - 32)
	box = Rect2(Vector2(clampf(tip.x - width * 0.65, 16, viewport.x - width - 16), maxf(110, tip.y - 260)), Vector2(width, 170))
	words.position = box.position + Vector2(22, 20)
	words.size = box.size - Vector2(44, 40)
	queue_redraw()

func _draw() -> void:
	if box.size == Vector2.ZERO: return
	var base := Vector2(clampf(tip.x - 60, box.position.x + 35, box.end.x - 35), box.end.y)
	var triangle := PackedVector2Array([base - Vector2(18, 1), base + Vector2(18, -1), tip])
	draw_colored_polygon(triangle, Color.WHITE)
	draw_polyline(PackedVector2Array([triangle[0], tip, triangle[1]]), Color(0.1, 0.1, 0.1), 2, true)
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color(0.1, 0.1, 0.1)
	style.set_border_width_all(2)
	draw_style_box(style, box)
	draw_line(base - Vector2(17, 0), base + Vector2(17, 0), Color.WHITE, 3)
