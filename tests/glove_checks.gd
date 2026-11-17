extends SceneTree
## Run: godot --headless --path . --fixed-fps 60 --script tests/glove_checks.gd

class Probe:
	extends CharacterBody2D
	var launches: Array[Vector2] = []
	func apply_obstacle_launch(impulse: Vector2) -> void:
		launches.append(impulse)

var failures := 0

func _initialize() -> void:
	call_deferred("run_checks")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func run_checks() -> void:
	await check_contact_cycle(0.0)
	await check_contact_cycle(PI * 1.5)
	await check_route_launch()
	await check_practice()
	await check_prototype()
	print("Glove checks: ", "PASS" if failures == 0 else str(failures) + " failures")
	quit(0 if failures == 0 else 1)

func check_contact_cycle(angle: float) -> void:
	var stage := Node2D.new()
	root.add_child(stage)
	var glove = load("res://scenes/boxing_glove.tscn").instantiate()
	glove.rotation = angle
	glove.rest_min_seconds = 0.3
	glove.rest_max_seconds = 0.3
	glove.warning_seconds = 0.3
	glove.extend_seconds = 0.1
	glove.active_seconds = 0.4
	glove.retract_seconds = 0.3
	var probe := Probe.new()
	probe.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60,144)
	collision.shape = shape
	probe.add_child(collision)
	stage.add_child(glove)
	stage.add_child(probe)
	var contact := Vector2.UP.rotated(angle) * 92.0
	probe.position = contact
	await frames(24)
	check(probe.launches.is_empty(), "Rest/warning contact must be safe")
	check(glove.warning_light.visible, "Warning cue must be visible")
	check(not glove.hitbox.monitoring, "Warning hitbox must be inactive")
	await frames(24)
	check(probe.launches.size() == 1, "Overlapping bunny must receive one punch")
	if not probe.launches.is_empty():
		var expected: Vector2 = Vector2.UP.rotated(angle) * glove.launch_speed
		if angle != 0.0: expected.y -= glove.upward_assist
		check(probe.launches[0].is_equal_approx(expected), "Punch direction/strength must follow rotation")
	check(glove.glove_sprite.frame == 2, "Active hitbox must match extended art")
	probe.position = Vector2(1000,1000)
	await frames(3)
	probe.position = contact
	await frames(3)
	check(probe.launches.size() == 1, "Leaving/re-entering cannot repeat the same punch")
	await frames(18)
	check(not glove.hitbox.monitoring, "Recovery hitbox must be inactive")
	check(probe.launches.size() == 1, "Recovery contact must be safe")
	await frames(78)
	check(probe.launches.size() == 2, "A later punch must be able to launch again")
	stage.free()
	await frames(2)

func check_route_launch() -> void:
	var level = load("res://scenes/main.tscn").instantiate()
	var glove = level.get_node("BoxingGlove2")
	glove.rest_min_seconds = 0.5
	glove.rest_max_seconds = 0.5
	root.add_child(level)
	var player = level.player
	# Start on Griffin's new approach platform, below-left of the raised glove.
	player.position = Vector2(3900,-296)
	var jumped := false
	var launched := false
	for i in range(180):
		await physics_frame
		if glove._phase == 1 and player.is_on_floor() and not jumped:
			Input.action_press("ui_accept")
			jumped = true
		else:
			Input.action_release("ui_accept")
		if player.velocity.y < -1200.0: launched = true
		if jumped and not launched and player.position.x < 4025.0:
			Input.action_press("ui_right")
		else:
			Input.action_release("ui_right")
		if launched and player.position.y < -680.0 and player.position.x > 3900.0:
			Input.action_press("ui_left")
		elif player.position.x <= 3900.0:
			Input.action_release("ui_left")
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	Input.action_release("ui_accept")
	check(launched, "Actual tutorial glove must launch the shared bunny")
	check(player.is_on_floor() and player.position.y < -650.0 and player.position.x < 3920.0,
		"Timed jump and left steering must land on the intended tutorial ledge")
	# Existing effects must still work after launch control expires.
	player.activate_speed_boost()
	check(player.speed_boost_timer > 0.0, "Speed effects must remain available")
	check(player.obstacle_launch_timer == 0.0, "Launch control must expire")
	level.free()
	await frames(2)

func check_practice() -> void:
	var stage = load("res://scenes/glove_practice.tscn").instantiate()
	root.add_child(stage)
	await frames(360)
	var player = stage.get_node("CharacterBody2D")
	check(player.is_on_floor() and player.position.y < -300.0,
		"Practice glove must carry the actual bunny onto the high platform")
	stage.free()
	await frames(2)

func check_prototype() -> void:
	var preview = load("res://scenes/timing_obstacle_demo.tscn").instantiate()
	root.add_child(preview)
	await frames(300)
	check(is_instance_valid(preview.get_node("TimingObstacle/Pusher/Visual")),
		"Original prototype preview must still run")
	preview.free()
	await frames(2)
