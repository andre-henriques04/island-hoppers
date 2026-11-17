extends CharacterBody2D
## Arena-independent encounter state; presentation and hazards are supplied by the arena.
signal attack_fired(kind: String, direction: float)
signal state_changed
signal defeated

@export var chase_speed := 95.0
@export var max_health := 3
@export var warning_duration := 1.15
@export var stun_duration := 3.4
@export var arena_left := 80.0
@export var arena_right := 1070.0
var target: CharacterBody2D
var health := 3
var state := "chase"
var remaining := 2.0
var attack_index := 0
var facing := -1.0
var bite_connected := false
@onready var visual: Polygon2D = $Visual

func _ready() -> void:
	health = max_health
	build_animations()
	$Visual.visible = false

func enter(next: String, duration: float) -> void:
	state = next
	remaining = duration
	bite_connected = false
	state_changed.emit()

func _physics_process(delta: float) -> void:
	velocity.y += 980.0 * delta
	velocity.x = 0.0
	remaining -= delta
	if not is_instance_valid(target) or state == "defeated":
		move_and_slide()
		return
	if state == "chase":
		var distance := target.position.x - position.x
		if absf(distance) > 160.0:
			velocity.x = signf(distance) * chase_speed
		if remaining <= 0.0:
			facing = -1.0 if distance < 0 else 1.0
			enter(["bite_warning", "throw_warning", "pound_warning"][attack_index % 3], warning_duration)
			attack_index += 1
	elif state.ends_with("warning") and remaining <= 0.0:
		if state == "bite_warning":
			enter("bite", 0.22)
		elif state == "throw_warning":
			attack_fired.emit("projectile", facing)
			enter("recovery", 1.2)
		else:
			velocity.y = -360.0
			enter("pound_air", 3.0)
	elif state == "bite" and remaining <= 0.0:
		enter("recovery", 1.2)
	elif state == "pound_air" and is_on_floor() and velocity.y >= 0.0:
		attack_fired.emit("wave", -1.0)
		attack_fired.emit("wave", 1.0)
		enter("stunned", stun_duration)
	elif state in ["recovery", "stunned"] and remaining <= 0.0:
		enter("chase", 1.8)
	visual.color = Color.CORAL
	if state.ends_with("warning"):
		visual.color = Color.GOLD
	elif state == "stunned":
		visual.color = Color.MEDIUM_SEA_GREEN
	elif state == "recovery":
		visual.color = Color.SLATE_GRAY
	$Status.text = state.replace("_", " ").to_upper()
	$Artwork.modulate = visual.color.lightened(0.55)
	update_animation()
	move_and_slide()
	position.x = clampf(position.x, arena_left, arena_right)

func take_stomp() -> bool:
	if state != "stunned":
		return false
	health -= 1
	if health <= 0:
		enter("defeated", 0.0)
		visual.color = Color.DIM_GRAY
		$Artwork.modulate = Color.DIM_GRAY
		$Status.text = "DEFEATED"
		$BiteEffect.hide()
		defeated.emit()
	else:
		enter("recovery", 1.4)
	return true

func build_animations() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	add_sheet(frames, "walk", "res://assets/art/Fox Boss/fox_walk.png", Vector2i(512, 512), 8, 10.0, true)
	add_sheet(frames, "pound", "res://assets/art/Fox Boss/spritesheet.png", Vector2i(512, 512), 24, 24.0, false)
	add_sheet(frames, "idle", "res://assets/art/Fox Boss/fox_walk.png", Vector2i(512, 512), 1, 1.0, true)
	$Artwork.sprite_frames = frames
	$Artwork.play("idle")
	var teeth := SpriteFrames.new()
	teeth.remove_animation("default")
	var texture = load("res://assets/art/Fox Boss/fox_bite_attack.png")
	add_sheet(teeth, "bite", "res://assets/art/Fox Boss/fox_bite_attack.png", Vector2i(texture.get_width() / 4, texture.get_height() / 3), 12, 40.0, false)
	$BiteEffect.sprite_frames = teeth

func add_sheet(frames: SpriteFrames, animation: String, path: String, cell: Vector2i, count: int, fps: float, loops: bool) -> void:
	var texture = load(path)
	frames.add_animation(animation)
	frames.set_animation_speed(animation, fps)
	frames.set_animation_loop(animation, loops)
	var columns: int = texture.get_width() / cell.x
	for i in range(count):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(Vector2((i % columns) * cell.x, (i / columns) * cell.y), Vector2(cell))
		frames.add_frame(animation, atlas)

func update_animation() -> void:
	var animation := "idle"
	if state == "chase" and absf(velocity.x) > 0:
		animation = "walk"
	elif state == "pound_air":
		animation = "pound"
	if $Artwork.animation != animation:
		$Artwork.play(animation)
	# Use the latter half of the sheet for descent; physics controls landing.
	if state == "pound_air" and velocity.y >= 0 and $Artwork.frame < 12:
		$Artwork.frame = 12
	$BiteEffect.visible = state == "bite"
	$BiteEffect.position = Vector2(facing * 90, -60)
	if state == "bite" and not $BiteEffect.is_playing():
		$BiteEffect.play("bite")
	elif state != "bite":
		$BiteEffect.stop()
		$BiteEffect.frame = 0
