#Coding by: Caleb Sosa
#Created in 2026
#This is the main character movement script for the game. 
#It handles player movement, jumping, and power-up effects.

extends CharacterBody2D

# =========================================================
# MOVEMENT SETTINGS
# =========================================================

@export var move_speed: float = 300.0
@export var boosted_speed: float = 600.0
@export var debuffed_speed: float = 150.0

@export var gravity: float = 980.0
@export var jump_height: float = 200.0
@export var boosted_jump_height: float = 400.0
@export var debuff_jump_height: float = 50.0


# =========================================================
# SPEED EFFECTS
# =========================================================

var speed_boost_active: bool = false
var speed_boost_timer: float = 0.0

var speed_debuff_active: bool = false
var speed_debuff_timer: float = 0.0


# =========================================================
# JUMP EFFECTS
# =========================================================

var jump_boost_active: bool = false
var jump_boost_timer: float = 0.0

var jump_debuff_active: bool = false
var jump_debuff_timer: float = 0.0


# =========================================================
# DOUBLE JUMP POWER-UP
# =========================================================

var double_jump_available: bool = false
var double_jump_used: bool = false


# =========================================================
# SHRINK / GROW POWER-UP
# =========================================================

@export var shrink_scale: float = 0.5
@export var shrink_duration: float = 10.0

var shrink_grow_active: bool = false
var shrink_grow_timer: float = 0.0
var original_scale: Vector2


# =========================================================
# DASH ABILITY
# =========================================================

@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.2

var dash_active: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 1.0


# =========================================================
# GLIDE ABILITY
# =========================================================

@export var glide_duration: float = 1.0
@export var glide_gravity_multiplier: float = 0.25

var glide_available: bool = false
var glide_active: bool = false
var glide_timer: float = 0.0


# =========================================================
# DEATH AND CHECKPOINT
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead: bool = false
var checkpoint_position: Vector2


func _ready() -> void:
    checkpoint_position = global_position
    original_scale = scale


# =========================================================
# PHYSICS PROCESS
# =========================================================

func _physics_process(delta: float) -> void:

    # Do not move during the death animation.
    if is_dead:
        return

    # Update temporary power-up timers.
    update_effect_timers(delta)

    # -----------------------------------------------------
    # UPDATE DASH TIMER
    # -----------------------------------------------------

    if dash_active:
        dash_timer -= delta

        if dash_timer <= 0.0:
            dash_active = false
            dash_timer = 0.0

    # -----------------------------------------------------
    # GRAVITY AND GLIDE
    # -----------------------------------------------------

    if is_on_floor():
        velocity.y = 0.0
        double_jump_used = false
        glide_active = false
        glide_timer = 0.0

    else:
        if glide_active:
            glide_timer -= delta

            if glide_timer <= 0.0:
                glide_active = false
                glide_timer = 0.0

        if glide_active:
            velocity.y += gravity * glide_gravity_multiplier * delta
        else:
            velocity.y += gravity * delta

    # -----------------------------------------------------
    # HORIZONTAL MOVEMENT
    # -----------------------------------------------------

    var direction: float = Input.get_axis(
        "move_left",
        "move_right"
    )

    var current_speed: float = move_speed

    if speed_boost_active:
        current_speed = boosted_speed
    elif speed_debuff_active:
        current_speed = debuffed_speed

    if dash_active:
        velocity.x = dash_direction * dash_speed
    else:
        velocity.x = direction * current_speed

    # -----------------------------------------------------
    # DETERMINE JUMP HEIGHT
    # -----------------------------------------------------

    var current_jump_height: float = jump_height

    if jump_boost_active:
        current_jump_height = boosted_jump_height
    elif jump_debuff_active:
        current_jump_height = debuff_jump_height

    # -----------------------------------------------------
    # NORMAL JUMP AND DOUBLE JUMP
    # -----------------------------------------------------

    if Input.is_action_just_pressed("jump"):

        if is_on_floor():
            velocity.y = -sqrt(
                2.0 * gravity * current_jump_height
            )

        elif double_jump_available and not double_jump_used:
            velocity.y = -sqrt(
                2.0 * gravity * current_jump_height
            )

            double_jump_used = true
            double_jump_available = false

    # -----------------------------------------------------
    # GLIDE INPUT
    # -----------------------------------------------------

    if Input.is_action_just_pressed("glide"):
        if not is_on_floor() and glide_available:
            glide_active = true
            glide_timer = glide_duration
            glide_available = false

    # -----------------------------------------------------
    # MOVE PLAYER
    # -----------------------------------------------------

    move_and_slide()


# =========================================================
# UPDATE POWER-UP TIMERS
# =========================================================

func update_effect_timers(delta: float) -> void:

    if speed_boost_active:
        speed_boost_timer -= delta

        if speed_boost_timer <= 0.0:
            speed_boost_active = false
            speed_boost_timer = 0.0

    if speed_debuff_active:
        speed_debuff_timer -= delta

        if speed_debuff_timer <= 0.0:
            speed_debuff_active = false
            speed_debuff_timer = 0.0

    if jump_boost_active:
        jump_boost_timer -= delta

        if jump_boost_timer <= 0.0:
            jump_boost_active = false
            jump_boost_timer = 0.0

    if jump_debuff_active:
        jump_debuff_timer -= delta

        if jump_debuff_timer <= 0.0:
            jump_debuff_active = false
            jump_debuff_timer = 0.0

    if shrink_grow_active:
        shrink_grow_timer -= delta

        if shrink_grow_timer <= 0.0:
            shrink_grow_active = false
            shrink_grow_timer = 0.0
            scale = original_scale


# =========================================================
# SPEED POWER-UPS
# =========================================================

func activate_speed_boost() -> void:
    speed_boost_active = true
    speed_boost_timer = 20.0


func activate_speed_debuff() -> void:
    speed_debuff_active = true
    speed_debuff_timer = 10.0


# =========================================================
# JUMP POWER-UPS
# =========================================================

func activate_jump_boost() -> void:
    jump_boost_active = true
    jump_boost_timer = 20.0


func activate_jump_debuff() -> void:
    jump_debuff_active = true
    jump_debuff_timer = 15.0


# =========================================================
# DOUBLE JUMP POWER-UP
# =========================================================

func activate_double_jump() -> void:
    double_jump_available = true
    double_jump_used = false


# =========================================================
# SHRINK / GROW POWER-UP
# =========================================================

func activate_shrink_grow() -> void:
    shrink_grow_active = true
    shrink_grow_timer = shrink_duration
    scale = original_scale * shrink_scale


# =========================================================
# DASH ABILITY
# =========================================================

func activate_dash() -> void:
    if dash_active:
        return

    dash_active = true
    dash_timer = dash_duration

    var direction: float = Input.get_axis(
        "move_left",
        "move_right"
    )

    if direction != 0.0:
        dash_direction = sign(direction)
    else:
        dash_direction = 1.0


# =========================================================
# GLIDE ABILITY
# =========================================================

func activate_glide() -> void:
    glide_available = true
    glide_active = false
    glide_timer = 0.0


# =========================================================
# CHECKPOINT SYSTEM
# =========================================================

func set_checkpoint(new_position: Vector2) -> void:
    checkpoint_position = new_position


# =========================================================
# DEATH AND RESPAWN
# =========================================================

func die() -> void:

    if is_dead:
        return

    is_dead = true
    velocity = Vector2.ZERO

    animated_sprite.play("death")

    # Wait for the death animation to finish.
    await animated_sprite.animation_finished

    # Respawn at the most recently activated checkpoint.
    global_position = checkpoint_position
    velocity = Vector2.ZERO

    # Reset speed effects.
    speed_boost_active = false
    speed_boost_timer = 0.0

    speed_debuff_active = false
    speed_debuff_timer = 0.0

    # Reset jump effects.
    jump_boost_active = false
    jump_boost_timer = 0.0

    jump_debuff_active = false
    jump_debuff_timer = 0.0

    # Reset double jump.
    double_jump_available = false
    double_jump_used = false

    # Reset shrink / grow.
    shrink_grow_active = false
    shrink_grow_timer = 0.0
    scale = original_scale

    # Reset dash.
    dash_active = false
    dash_timer = 0.0
    dash_direction = 1.0

    # Reset glide.
    glide_available = false
    glide_active = false
    glide_timer = 0.0

    # Resume gameplay.
    is_dead = false
    animated_sprite.play("idle")
