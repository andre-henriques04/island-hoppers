extends CharacterBody2D

# Speeds are in pixels/second
@export var move_speed: float = 200.0
@export var boosted_speed: float = 400.0
@export var debuffed_speed: float = 100.0

@export var gravity: float = 980.0   # positive = down in 2D
@export var jump_height: float = 64.0  # pixels
@export var boosted_jump_height: float = 160.0
@export var debuff_jump_height: float = 16.0

@export var sprite: AnimatedSprite2D

var speed_boost_timer: float = 0.0
var speed_debuff_timer: float = 0.0
var jump_boost_timer: float = 0.0
var jump_debuff_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Tick effect timers
	speed_boost_timer = max(speed_boost_timer - delta, 0.0)
	speed_debuff_timer = max(speed_debuff_timer - delta, 0.0)
	jump_boost_timer = max(jump_boost_timer - delta, 0.0)
	jump_debuff_timer = max(jump_debuff_timer - delta, 0.0)

	# Horizontal input
	var horizontal := Input.get_axis("ui_left", "ui_right")

	# Speed (debuff takes priority over boost)
	var current_speed := move_speed
	if speed_boost_timer > 0.0:
		current_speed = boosted_speed
	if speed_debuff_timer > 0.0:
		current_speed = debuffed_speed

	velocity.x = horizontal * current_speed

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump height (debuff takes priority over boost)
	var current_jump_height := jump_height
	if jump_boost_timer > 0.0:
		current_jump_height = boosted_jump_height
	if jump_debuff_timer > 0.0:
		current_jump_height = debuff_jump_height

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -sqrt(2.0 * gravity * current_jump_height)

	move_and_slide()
	_update_animation(horizontal)


func _update_animation(horizontal: float) -> void:
	if sprite == null:
		return
	if horizontal != 0.0:
		sprite.flip_h = horizontal < 0.0

	# Only plays animations that exist, so rename these to match yours
	var anim := "idle"
	if not is_on_floor():
		anim = "jump"
	elif horizontal != 0.0:
		anim = "run"
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim:
			sprite.play(anim)


# --- Speed effects ---
func activate_speed_boost() -> void:
	speed_boost_timer = 20.0

func activate_speed_debuff() -> void:
	speed_debuff_timer = 10.0

# --- Jump effects ---
func activate_jump_boost() -> void:
	jump_boost_timer = 20.0

func activate_jump_debuff() -> void:
	jump_debuff_timer = 15.0
