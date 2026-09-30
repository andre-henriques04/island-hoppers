extends CharacterBody3D

@export var move_speed: float = 5.0
@export var boosted_speed: float = 10.0
@export var debuffed_speed: float = 2.5

@export var gravity: float = -9.81
@export var jump_height: float = 2.0

@export var boosted_jump_height: float = 15.0
@export var debuff_jump_height: float = 0.5


var speed_boost_active: bool = false
var speed_boost_timer: float = 0.0

var speed_debuff_active: bool = false
var speed_debuff_timer: float = 0.0

var jump_boost_active: bool = false
var jump_boost_timer: float = 0.0

var jump_debuff_active: bool = false
var jump_debuff_timer: float = 0.0


func _physics_process(delta: float) -> void:

    # -------------------------
    # Speed boost timer
    # -------------------------
    if speed_boost_active:
        speed_boost_timer -= delta

        if speed_boost_timer <= 0.0:
            speed_boost_active = false


    # -------------------------
    # Speed debuff timer
    # -------------------------
    if speed_debuff_active:
        speed_debuff_timer -= delta

        if speed_debuff_timer <= 0.0:
            speed_debuff_active = false


    # -------------------------
    # Jump boost timer
    # -------------------------
    if jump_boost_active:
        jump_boost_timer -= delta

        if jump_boost_timer <= 0.0:
            jump_boost_active = false


    # -------------------------
    # Jump debuff timer
    # -------------------------
if jump_boost_active:
    jump_boost_timer -= delta

    if jump_boost_timer <= 0.0:
        jump_boost_active = false


if jump_debuff_active:
    jump_debuff_timer -= delta

    if jump_debuff_timer <= 0.0:
        jump_debuff_active = false


    # -------------------------
    # Get keyboard input
    # -------------------------
    var horizontal := Input.get_axis("move_left", "move_right")
    var vertical := Input.get_axis("move_forward", "move_backward")


    # -------------------------
    # Create movement direction
    # -------------------------
    var move := transform.basis.x * horizontal + transform.basis.z * vertical

    if move.length() > 0:
        move = move.normalized()


    # -------------------------
    # Determine movement speed
    # -------------------------
    var current_speed := move_speed

    if speed_boost_active:
        current_speed = boosted_speed

    if speed_debuff_active:
        current_speed = debuffed_speed


    # -------------------------
    # Move the player
    # -------------------------
    velocity.x = move.x * current_speed
    velocity.z = move.z * current_speed


    # -------------------------
    # Apply gravity
    # -------------------------
    if not is_on_floor():
        velocity.y += gravity * delta
    elif velocity.y < 0:
        velocity.y = -2.0


    # -------------------------
    # Determine jump height
    # -------------------------
    var current_jump_height := jump_height

    if jump_boost_active:
        current_jump_height = boosted_jump_height

    if jump_debuff_active:
        current_jump_height = debuff_jump_height


    # -------------------------
    # Jump
    # -------------------------
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = sqrt(current_jump_height * -2.0 * gravity)


    # -------------------------
    # Move the player
    # -------------------------
    move_and_slide()


# =========================================================
# SPEED EFFECTS
# =========================================================

func activate_speed_boost() -> void:
    speed_boost_active = true
    speed_boost_timer = 20.0


func activate_speed_debuff() -> void:
    speed_debuff_active = true
    speed_debuff_timer = 10.0


# =========================================================
# JUMP EFFECTS
# =========================================================

func activate_jump_boost() -> void:
    jump_boost_active = true
    jump_boost_timer = 20.0


func activate_jump_debuff() -> void:
    jump_debuff_active = true
    jump_debuff_timer = 15.0