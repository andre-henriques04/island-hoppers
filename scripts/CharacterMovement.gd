extends CharacterBody2D

# Speeds are in pixels/second
@export var move_speed: float = 300.0
@export var boosted_speed: float = 600.0
@export var debuffed_speed: float = 100.0

@export var gravity: float = 980.0
@export var jump_height: float = 170.0
@export var boosted_jump_height: float = 160.0
@export var debuff_jump_height: float = 16.0

@export var sprite: AnimatedSprite2D

# Movement tuning
@export var max_floor_angle: float = 50.0
@export var snap_length: float = 8.0

# Jump responsiveness
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10

# Animation tuning
@export var idle_delay: float = 2.5
@export var walk_duration: float = 1.5

var walk_timer: float = 0.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var idle_timer: float = 0.0

var speed_boost_timer: float = 0.0
var speed_debuff_timer: float = 0.0
var jump_boost_timer: float = 0.0
var jump_debuff_timer: float = 0.0
var obstacle_launch_timer: float = 0.0

# True only when a player-initiated jump is being animated.
var jump_animation_active: bool = false


func _ready() -> void:
	up_direction = Vector2.UP
	floor_max_angle = deg_to_rad(max_floor_angle)
	floor_snap_length = snap_length
	floor_constant_speed = true


func _physics_process(delta: float) -> void:
	# Tick powerup and obstacle timers.
	speed_boost_timer = maxf(speed_boost_timer - delta, 0.0)
	speed_debuff_timer = maxf(speed_debuff_timer - delta, 0.0)
	jump_boost_timer = maxf(jump_boost_timer - delta, 0.0)
	jump_debuff_timer = maxf(jump_debuff_timer - delta, 0.0)
	obstacle_launch_timer = maxf(obstacle_launch_timer - delta, 0.0)

	# Horizontal input.
	var horizontal := Input.get_axis("ui_left", "ui_right")

	# Speed priority: debuff > boost > normal.
	var current_speed := move_speed

	if speed_boost_timer > 0.0:
		current_speed = boosted_speed

	if speed_debuff_timer > 0.0:
		current_speed = debuffed_speed

	# Preserve launch velocity while obstacle control is locked.
	if obstacle_launch_timer <= 0.0:
		velocity.x = horizontal * current_speed

	# Coyote time.
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	# Jump input buffering.
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	# Gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump height priority: debuff > boost > normal.
	var current_jump_height := jump_height

	if jump_boost_timer > 0.0:
		current_jump_height = boosted_jump_height

	if jump_debuff_timer > 0.0:
		current_jump_height = debuff_jump_height

	# Perform a player-initiated jump.
	if (
		jump_buffer_timer > 0.0
		and coyote_timer > 0.0
		and obstacle_launch_timer <= 0.0
	):
		velocity.y = -sqrt(2.0 * gravity * current_jump_height)

		jump_buffer_timer = 0.0
		coyote_timer = 0.0

		jump_animation_active = true
		idle_timer = 0.0

	move_and_slide()

	_update_animation(delta, horizontal)






func _update_animation(delta: float, horizontal: float) -> void:
	if sprite == null:
		return

	# Face the direction of movement.
	if horizontal < 0.0:
		sprite.flip_h = true
	elif horizontal > 0.0:
		sprite.flip_h = false

	# Player-initiated jump animation.
	if jump_animation_active:
		if sprite.animation != "jump" or not sprite.is_playing():
			sprite.play("jump")

		if not is_on_floor():
			idle_timer = 0.0
			walk_timer = 0.0
			return

		jump_animation_active = false
		idle_timer = 0.0
		walk_timer = 0.0

	# Don't animate or count timers while airborne.
	if not is_on_floor():
		idle_timer = 0.0
		walk_timer = 0.0
		return

	# Walk first, then run, regardless of direction changes.
	if absf(horizontal) > 0.01:
		idle_timer = 0.0

		if walk_timer < walk_duration:
			walk_timer = minf(walk_timer + delta, walk_duration)
			_play_animation("walk")
		else:
			_play_animation("run")

		return

	# Reset the walking timer only when movement stops.
	walk_timer = 0.0

	# Accumulate idle time.
	idle_timer += delta

	# Play idle only after the delay.
	if idle_timer >= idle_delay:
		_play_animation("idle")


func _play_animation(animation_name: String) -> void:
	if sprite.animation != animation_name or not sprite.is_playing():
		sprite.play(animation_name)


func apply_obstacle_launch(
	launch_velocity: Vector2,
	control_seconds: float = 0.28
) -> void:
	velocity = launch_velocity
	obstacle_launch_timer = control_seconds

	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	idle_timer = 0.0

	# Obstacle launches do not count as player-initiated jumps.
	jump_animation_active = false


func reset_after_respawn() -> void:
	velocity = Vector2.ZERO

	obstacle_launch_timer = 0.0
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	idle_timer = 0.0
	walk_timer = 0.0

	speed_boost_timer = 0.0
	speed_debuff_timer = 0.0
	jump_boost_timer = 0.0
	jump_debuff_timer = 0.0

	jump_animation_active = false

	if sprite != null:
		sprite.flip_h = false
		sprite.play("idle")


# --- Speed effects ---

func activate_speed_boost() -> void:
	speed_boost_timer = 5.0


func activate_speed_debuff() -> void:
	speed_debuff_timer = 5.0


# --- Jump effects ---

func activate_jump_boost() -> void:
	jump_boost_timer = 5.0


func activate_jump_debuff() -> void:
	jump_debuff_timer = 15.0
