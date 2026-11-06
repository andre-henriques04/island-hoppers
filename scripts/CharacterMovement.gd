
extends CharacterBody2D

# =========================================================
# MOVEMENT SETTINGS
# =========================================================

@export var move_speed: float = 200.0
@export var boosted_speed: float = 400.0
@export var debuffed_speed: float = 100.0

@export var gravity: float = 980.0
@export var jump_height: float = 64.0
@export var boosted_jump_height: float = 160.0
@export var debuff_jump_height: float = 16.0

@export var sprite: AnimatedSprite2D

@export var max_floor_angle: float = 50.0
@export var snap_length: float = 8.0

# =========================================================
# JUMP RESPONSIVENESS
# =========================================================

@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# =========================================================
# POWER-UP TIMERS
# =========================================================

var speed_boost_timer: float = 0.0
var speed_debuff_timer: float = 0.0
var jump_boost_timer: float = 0.0
var jump_debuff_timer: float = 0.0

# =========================================================
# DASH ABILITY
# =========================================================

@export var dash_speed: float = 650.0
@export var dash_duration: float = 0.20

var dash_active: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 1.0

# =========================================================
# GLIDE ABILITY
# =========================================================

@export var glide_duration: float = 3.0
@export var glide_gravity_multiplier: float = 0.25
@export var glide_max_fall_speed: float = 100.0

var glide_available: bool = false
var glide_active: bool = false
var glide_timer: float = 0.0

# =========================================================
# OBSTACLE LAUNCH
# =========================================================

var obstacle_launch_timer: float = 0.0

# =========================================================
# CHECKPOINT / DEATH SYSTEM
# =========================================================

@export var death_animation_duration: float = 0.6

var spawn_position: Vector2
var is_dead: bool = false


func _ready() -> void:
	up_direction = Vector2.UP
	floor_max_angle = deg_to_rad(max_floor_angle)
	floor_snap_length = snap_length
	floor_constant_speed = true

	# Save the initial spawn position.
	spawn_position = global_position


func _physics_process(delta: float) -> void:

	if is_dead:
		return

	# -----------------------------------------------------
	# POWER-UP TIMERS
	# -----------------------------------------------------

	speed_boost_timer = maxf(speed_boost_timer - delta, 0.0)
	speed_debuff_timer = maxf(speed_debuff_timer - delta, 0.0)
	jump_boost_timer = maxf(jump_boost_timer - delta, 0.0)
	jump_debuff_timer = maxf(jump_debuff_timer - delta, 0.0)

	# -----------------------------------------------------
	# HORIZONTAL MOVEMENT
	# -----------------------------------------------------

	var horizontal := Input.get_axis("ui_left", "ui_right")

	var current_speed := move_speed

	if speed_boost_timer > 0.0:
		current_speed = boosted_speed

	if speed_debuff_timer > 0.0:
		current_speed = debuffed_speed

	# Dash takes priority over normal horizontal movement.
	dash_timer = maxf(dash_timer - delta, 0.0)
	dash_active = dash_timer > 0.0

	obstacle_launch_timer = maxf(obstacle_launch_timer - delta, 0.0)

	if dash_active:
		velocity.x = dash_direction * dash_speed

	elif obstacle_launch_timer <= 0.0:
		velocity.x = horizontal * current_speed

	# -----------------------------------------------------
	# COYOTE TIME
	# -----------------------------------------------------

	if is_on_floor():
		coyote_timer = coyote_time
		glide_active = false
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	# -----------------------------------------------------
	# JUMP BUFFERING
	# -----------------------------------------------------

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	# -----------------------------------------------------
	# GLIDE MECHANIC
	# -----------------------------------------------------

	if not is_on_floor() and glide_available:
		if Input.is_action_pressed("ui_accept") and velocity.y > 0.0:
			if not glide_active:
				glide_active = true
				glide_timer = glide_duration

	if glide_active:
		glide_timer = maxf(glide_timer - delta, 0.0)

		if glide_timer <= 0.0:
			glide_active = false
			glide_available = false

	# -----------------------------------------------------
	# GRAVITY
	# -----------------------------------------------------

	if not is_on_floor():

		if glide_active:
			velocity.y += gravity * glide_gravity_multiplier * delta
			velocity.y = minf(velocity.y, glide_max_fall_speed)

		else:
			velocity.y += gravity * delta

	# -----------------------------------------------------
	# JUMP HEIGHT
	# -----------------------------------------------------

	var current_jump_height := jump_height

	if jump_boost_timer > 0.0:
		current_jump_height = boosted_jump_height

	if jump_debuff_timer > 0.0:
		current_jump_height = debuff_jump_height

	# -----------------------------------------------------
	# JUMP EXECUTION
	# -----------------------------------------------------

	if jump_buffer_timer > 0.0 \
	and coyote_timer > 0.0 \
	and obstacle_launch_timer <= 0.0 \
	and not dash_active:

		velocity.y = -sqrt(2.0 * gravity * current_jump_height)

		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	move_and_slide()

	_update_animation(horizontal)


# =========================================================
# DASH ABILITY
# =========================================================

func activate_dash() -> void:

	if dash_active or is_dead:
		return

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0.0:
		dash_direction = signf(direction)
	else:
		dash_direction = 1.0

	dash_active = true
	dash_timer = dash_duration

	velocity.x = dash_direction * dash_speed


# =========================================================
# GLIDE POWER-UP ACTIVATION
# =========================================================

func activate_glide() -> void:

	glide_available = true
	glide_active = false
	glide_timer = 0.0


# =========================================================
# OBSTACLE LAUNCH
# =========================================================

func apply_obstacle_launch(
	launch_velocity: Vector2,
	control_seconds: float = 0.28
) -> void:

	velocity = launch_velocity
	obstacle_launch_timer = control_seconds
	coyote_timer = 0.0
	jump_buffer_timer = 0.0


# =========================================================
# CHECKPOINT SYSTEM
# =========================================================

func set_checkpoint(new_position: Vector2) -> void:

	spawn_position = new_position

	print("Checkpoint updated: ", spawn_position)


# =========================================================
# DEATH / RESPAWN SYSTEM
# =========================================================

func die() -> void:

	if is_dead:
		return

	is_dead = true

	velocity = Vector2.ZERO
	set_physics_process(false)

	# Play the death animation if one exists.
	if sprite != null and sprite.sprite_frames != null:
		if sprite.sprite_frames.has_animation("death"):
			sprite.play("death")

	# Allow time for the death animation.
	await get_tree().create_timer(death_animation_duration).timeout

	# Return to the most recently saved checkpoint.
	global_position = spawn_position

	reset_after_respawn()

	is_dead = false
	set_physics_process(true)


func reset_after_respawn() -> void:

	velocity = Vector2.ZERO

	obstacle_launch_timer = 0.0

	coyote_timer = 0.0
	jump_buffer_timer = 0.0

	speed_boost_timer = 0.0
	speed_debuff_timer = 0.0

	jump_boost_timer = 0.0
	jump_debuff_timer = 0.0

	dash_active = false
	dash_timer = 0.0

	glide_available = false
	glide_active = false
	glide_timer = 0.0

	if sprite != null:
		if sprite.sprite_frames != null \
		and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			sprite.stop()


# =========================================================
# ANIMATION
# =========================================================

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
		if sprite.sprite_frames != null \
		and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			sprite.stop()


# =========================================================
# SPEED POWER-UPS
# =========================================================

func activate_speed_boost() -> void:
	speed_boost_timer = 20.0


func activate_speed_debuff() -> void:
	speed_debuff_timer = 10.0


# =========================================================
# JUMP POWER-UPS
# =========================================================

func activate_jump_boost() -> void:
	jump_boost_timer = 20.0


func activate_jump_debuff() -> void:
	jump_debuff_timer = 15.0
