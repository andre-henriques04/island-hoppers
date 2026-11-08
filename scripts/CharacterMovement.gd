
extends CharacterBody2D


# =========================================================
# MOVEMENT SETTINGS
# =========================================================

# Speeds are in pixels/second.
@export var move_speed: float = 300.0
@export var boosted_speed: float = 600.0
@export var debuffed_speed: float = 100.0

@export var gravity: float = 980.0
@export var jump_height: float = 170.0
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


# =========================================================
# ANIMATION SETTINGS
# =========================================================

@export var idle_delay: float = 2.5
@export var walk_duration: float = 1.5

var walk_timer: float = 0.0
var idle_timer: float = 0.0

var jump_animation_active: bool = false


# =========================================================
# JUMP STATE
# =========================================================

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
@export var ground_dash_cooldown: float = 0.15

# Permanent ownership.
var dash_unlocked: bool = false

# Dash state.
var dash_active: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 1.0

# Usage restrictions.
var air_dash_used: bool = false
var ground_dash_cooldown_timer: float = 0.0


# =========================================================
# GLIDE ABILITY
# =========================================================

@export var glide_duration: float = 3.0
@export var glide_gravity_multiplier: float = 0.25
@export var glide_max_fall_speed: float = 100.0

# Permanent ownership.
var glide_unlocked: bool = false

# Glide state.
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


# =========================================================
# INITIALIZATION
# =========================================================

func _ready() -> void:

	up_direction = Vector2.UP
	floor_max_angle = deg_to_rad(max_floor_angle)
	floor_snap_length = snap_length
	floor_constant_speed = true

	spawn_position = global_position


# =========================================================
# MAIN PHYSICS
# =========================================================

func _physics_process(delta: float) -> void:

	if is_dead:
		return

	# -----------------------------------------------------
	# DASH INPUT
	# -----------------------------------------------------

	if Input.is_action_just_pressed("dash"):
		activate_dash()

	# -----------------------------------------------------
	# POWER-UP TIMERS
	# -----------------------------------------------------

	speed_boost_timer = maxf(speed_boost_timer - delta, 0.0)
	speed_debuff_timer = maxf(speed_debuff_timer - delta, 0.0)

	jump_boost_timer = maxf(jump_boost_timer - delta, 0.0)
	jump_debuff_timer = maxf(jump_debuff_timer - delta, 0.0)

	obstacle_launch_timer = maxf(obstacle_launch_timer - delta, 0.0)

	# -----------------------------------------------------
	# HORIZONTAL MOVEMENT
	# -----------------------------------------------------

	var horizontal := Input.get_axis("ui_left", "ui_right")

	# Speed priority: debuff > boost > normal.
	var current_speed := move_speed

	if speed_boost_timer > 0.0:
		current_speed = boosted_speed

	if speed_debuff_timer > 0.0:
		current_speed = debuffed_speed

	# -----------------------------------------------------
	# DASH TIMERS
	# -----------------------------------------------------

	dash_timer = maxf(dash_timer - delta, 0.0)

	ground_dash_cooldown_timer = maxf(
		ground_dash_cooldown_timer - delta,
		0.0
	)

	dash_active = dash_timer > 0.0

	# Apply horizontal movement.
	if dash_active:

		velocity.x = dash_direction * dash_speed

	elif obstacle_launch_timer <= 0.0:

		velocity.x = horizontal * current_speed

	# -----------------------------------------------------
	# COYOTE TIME / LANDING RESET
	# -----------------------------------------------------

	if is_on_floor():

		coyote_timer = coyote_time

		# Restore air dash.
		air_dash_used = false

		# Restore glide.
		glide_available = glide_unlocked
		glide_active = false
		glide_timer = 0.0

	else:

		coyote_timer = maxf(
			coyote_timer - delta,
			0.0
		)

	# -----------------------------------------------------
	# JUMP BUFFERING
	# -----------------------------------------------------

	if Input.is_action_just_pressed("ui_accept"):

		jump_buffer_timer = jump_buffer_time

	else:

		jump_buffer_timer = maxf(
			jump_buffer_timer - delta,
			0.0
		)

	# -----------------------------------------------------
	# GLIDE MECHANIC
	# -----------------------------------------------------

	if not is_on_floor() and glide_unlocked and glide_available:

		# Start or resume gliding while falling.
		if Input.is_action_pressed("ui_accept") and velocity.y > 0.0:

			if not glide_active:

				# Only initialize the timer for a new glide.
				if glide_timer <= 0.0:
					glide_timer = glide_duration

				glide_active = true

		# Stop gliding when jump is released.
		else:

			glide_active = false

	# Only consume time while actively gliding.
	if glide_active:

		glide_timer = maxf(glide_timer - delta, 0.0)

		# Glide duration exhausted.
		if glide_timer <= 0.0:

			glide_active = false
			glide_available = false

	# -----------------------------------------------------
	# GRAVITY
	# -----------------------------------------------------

	if not is_on_floor():

		if glide_active:

			velocity.y += gravity * glide_gravity_multiplier * delta

			velocity.y = minf(
				velocity.y,
				glide_max_fall_speed
			)

		else:

			velocity.y += gravity * delta

	# -----------------------------------------------------
	# JUMP HEIGHT
	# -----------------------------------------------------

	# Jump height priority: debuff > boost > normal.
	var current_jump_height := jump_height

	if jump_boost_timer > 0.0:
		current_jump_height = boosted_jump_height

	if jump_debuff_timer > 0.0:
		current_jump_height = debuff_jump_height

	# -----------------------------------------------------
	# JUMP EXECUTION
	# -----------------------------------------------------

	if (
		jump_buffer_timer > 0.0
		and coyote_timer > 0.0
		and obstacle_launch_timer <= 0.0
		and not dash_active
	):

		velocity.y = -sqrt(
			2.0 * gravity * current_jump_height
		)

		jump_buffer_timer = 0.0
		coyote_timer = 0.0

		jump_animation_active = true
		idle_timer = 0.0

	# -----------------------------------------------------
	# MOVEMENT
	# -----------------------------------------------------

	move_and_slide()

	# -----------------------------------------------------
	# ANIMATION
	# -----------------------------------------------------

	_update_animation(delta, horizontal)


# =========================================================
# ANIMATION SYSTEM
# =========================================================

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

	# Walk first, then run.
	if absf(horizontal) > 0.01:

		idle_timer = 0.0

		if walk_timer < walk_duration:

			walk_timer = minf(
				walk_timer + delta,
				walk_duration
			)

			_play_animation("walk")

		else:

			_play_animation("run")

		return

	# Reset walking timer when movement stops.
	walk_timer = 0.0

	# Accumulate idle time.
	idle_timer += delta

	# Play idle only after the delay.
	if idle_timer >= idle_delay:

		_play_animation("idle")


func _play_animation(animation_name: String) -> void:

	if sprite.animation != animation_name or not sprite.is_playing():

		sprite.play(animation_name)


# =========================================================
# DASH ABILITY
# =========================================================

func activate_dash() -> void:

	if not dash_unlocked:
		return

	if dash_active or is_dead:
		return

	if obstacle_launch_timer > 0.0:
		return

	var on_ground := is_on_floor()

	# Ground cooldown.
	if on_ground and ground_dash_cooldown_timer > 0.0:
		return

	# One dash per airborne period.
	if not on_ground and air_dash_used:
		return

	# Determine direction.
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0.0:

		dash_direction = signf(direction)

	else:

		if sprite != null and sprite.flip_h:

			dash_direction = -1.0

		else:

			dash_direction = 1.0

	# Start dash.
	dash_active = true
	dash_timer = dash_duration

	velocity.x = dash_direction * dash_speed

	# Apply restrictions.
	if on_ground:

		ground_dash_cooldown_timer = ground_dash_cooldown

	else:

		air_dash_used = true


# =========================================================
# DASH UNLOCK
# =========================================================

func unlock_dash() -> void:

	if dash_unlocked:
		return

	dash_unlocked = true

	print("Dash ability permanently unlocked!")


# =========================================================
# GLIDE UNLOCK
# =========================================================

func unlock_glide() -> void:

	if glide_unlocked:
		return

	glide_unlocked = true

	glide_available = true
	glide_active = false
	glide_timer = 0.0

	print("Glide ability permanently unlocked!")


# =========================================================
# GLIDE PICKUP ACTIVATION
# =========================================================

func activate_glide() -> void:

	unlock_glide()


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
	idle_timer = 0.0

	# Obstacle launches do not count as player-initiated jumps.
	jump_animation_active = false


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

	# Death animation.
	if sprite != null and sprite.sprite_frames != null:

		if sprite.sprite_frames.has_animation("death"):

			sprite.play("death")

	# Wait for animation.
	await get_tree().create_timer(
		death_animation_duration
	).timeout

	# Respawn at checkpoint.
	global_position = spawn_position

	reset_after_respawn()

	is_dead = false

	set_physics_process(true)


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

	# Reset dash state, NOT ownership.
	dash_active = false
	dash_timer = 0.0
	air_dash_used = false
	ground_dash_cooldown_timer = 0.0

	# Reset glide state, NOT ownership.
	glide_available = glide_unlocked
	glide_active = false
	glide_timer = 0.0

	# Reset jump animation.
	jump_animation_active = false

	# Reset animation.
	if sprite != null:

		sprite.flip_h = false

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
