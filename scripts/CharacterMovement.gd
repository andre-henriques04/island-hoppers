
extends CharacterBody2D

# Speeds are in pixels/second
@export var move_speed: float = 200.0
@export var boosted_speed: float = 400.0
@export var debuffed_speed: float = 100.0

@export var gravity: float = 980.0
@export var jump_height: float = 64.0
@export var boosted_jump_height: float = 160.0
@export var debuff_jump_height: float = 16.0

@export var sprite: AnimatedSprite2D

# Movement tuning
@export var max_floor_angle: float = 50.0
@export var snap_length: float = 8.0

# Jump responsiveness
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var speed_boost_timer: float = 0.0
var speed_debuff_timer: float = 0.0
var jump_boost_timer: float = 0.0
var jump_debuff_timer: float = 0.0
var obstacle_launch_timer: float = 0.0


func _ready() -> void:
	# Allow the character to follow walkable slopes.
	up_direction = Vector2.UP
	floor_max_angle = deg_to_rad(max_floor_angle)
	floor_snap_length = snap_length
	floor_constant_speed = true


func _physics_process(delta: float) -> void:
	# Tick effect timers
	speed_boost_timer = maxf(speed_boost_timer - delta, 0.0)
	speed_debuff_timer = maxf(speed_debuff_timer - delta, 0.0)
	jump_boost_timer = maxf(jump_boost_timer - delta, 0.0)
	jump_debuff_timer = maxf(jump_debuff_timer - delta, 0.0)

	# Horizontal input
	var horizontal := Input.get_axis("ui_left", "ui_right")

	# Speed: debuff takes priority over boost
	var current_speed := move_speed
	if speed_boost_timer > 0.0:
		current_speed = boosted_speed
	if speed_debuff_timer > 0.0:
		current_speed = debuffed_speed

	obstacle_launch_timer = maxf(obstacle_launch_timer - delta, 0.0)
	if obstacle_launch_timer <= 0.0:
		velocity.x = horizontal * current_speed

	# Remember whether we were on the floor before moving.
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	# Buffer jump input so slightly early presses still work.
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump height: debuff takes priority over boost
	var current_jump_height := jump_height
	if jump_boost_timer > 0.0:
		current_jump_height = boosted_jump_height
	if jump_debuff_timer > 0.0:
		current_jump_height = debuff_jump_height

	# Jump if grounded or within the coyote-time window.
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0 and obstacle_launch_timer <= 0.0:
		velocity.y = -sqrt(2.0 * gravity * current_jump_height)
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	move_and_slide()

	_update_animation(horizontal)


func apply_obstacle_launch(launch_velocity: Vector2, control_seconds: float = 0.28) -> void:
	velocity = launch_velocity
	obstacle_launch_timer = control_seconds
	coyote_timer = 0.0
	jump_buffer_timer = 0.0


func reset_after_respawn() -> void:
	velocity = Vector2.ZERO
	obstacle_launch_timer = 0.0
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	speed_boost_timer = 0.0
	speed_debuff_timer = 0.0
	jump_boost_timer = 0.0
	jump_debuff_timer = 0.0


func _update_animation(horizontal: float) -> void:
	if sprite == null:
		return

	if horizontal < 0.0:
		sprite.flip_h = true
	elif horizontal > 0.0:
		sprite.flip_h = false

	if horizontal != 0.0:
		if sprite.animation != "run" or not sprite.is_playing():
			sprite.play("run")
	else:
		sprite.stop()


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
