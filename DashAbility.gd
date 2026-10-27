#Coding by: Caleb Sosa
#Created in 2026
#This is the dash ability.
#The item is a movement modifer. It directly will affect the character movement.

extends Area2D

var activated: bool = false

func activate_dash() -> void:
    if dash_active:
        return

    dash_active = true
    dash_timer = dash_duration

    # Dash in the direction of movement.
    var direction: float = Input.get_axis(
        "move_left",
        "move_right"
    )

    if direction != 0.0:
        dash_direction = sign(direction)
    else:
        # If standing still, dash to the right.
        dash_direction = 1.0