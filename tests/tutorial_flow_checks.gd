extends SceneTree
## Run with --headless --fixed-fps 60 --script tests/tutorial_flow_checks.gd.
const Progress = preload("res://scripts/session_progress.gd")
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
	Progress.completed_islands.clear()
	change_scene_to_file("res://scenes/main_menu.tscn")
	await frames(3)
	check(not current_scene.get_node("MenuUI/CompletionStatus").visible, "Fresh session must not claim completion")
	var play = current_scene.get_node("MenuUI/PlayButton")
	play.pressed.emit()
	play.pressed.emit()
	await frames(3)
	check(current_scene.scene_file_path == "res://scenes/main.tscn", "Play must enter the tutorial")
	var level = current_scene
	var flow = level.get_node("TutorialFlow")
	var player = level.player
	player.set_physics_process(false)
	var entrance: Vector2 = flow.respawn_position
	player.position = Vector2(4500,-1500)
	level.sync_camera_to_player()
	player.apply_obstacle_launch(Vector2(400,-600))
	player.activate_speed_boost()
	player.activate_speed_debuff()
	player.activate_jump_boost()
	player.activate_jump_debuff()
	player.coyote_timer = 0.1
	player.jump_buffer_timer = 0.1
	var retry_key := InputEventKey.new()
	retry_key.keycode = KEY_R
	retry_key.pressed = true
	flow._unhandled_key_input(retry_key)
	check(player.position == entrance and level.active_screen == 0, "R must restore entrance and first camera")
	check(player.velocity == Vector2.ZERO and player.obstacle_launch_timer == 0.0, "Retry must clear launch velocity/control")
	check(player.speed_boost_timer == 0.0 and player.speed_debuff_timer == 0.0
		and player.jump_boost_timer == 0.0 and player.jump_debuff_timer == 0.0
		and player.coyote_timer == 0.0 and player.jump_buffer_timer == 0.0, "Retry must clear all temporary movement state")
	player.position = Vector2(4500,600)
	await frames(3)
	check(player.position == entrance and level.active_screen == 0, "Falling must recover automatically")
	flow.set_checkpoint(Vector2(2500,-1500))
	player.position = Vector2(4500,600)
	await frames(3)
	check(player.position == Vector2(2500,-1500) and level.active_screen == 1, "Checkpoint handoff must restore the matching camera")
	var home_key := InputEventKey.new()
	home_key.keycode = KEY_ESCAPE
	home_key.pressed = true
	flow._unhandled_key_input(home_key)
	await frames(3)
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Esc must return home")
	check(not Progress.is_complete(&"tutorial"), "Leaving early must not complete the island")
	for attempt in range(2):
		current_scene.get_node("MenuUI/PlayButton").pressed.emit()
		await frames(3)
		level = current_scene
		flow = level.get_node("TutorialFlow")
		player = level.player
		check(not flow.completing and flow.respawn_position == entrance, "Replay must reset completion and checkpoint state")
		check(player.is_physics_processing() and player.obstacle_launch_timer == 0.0, "Replay must restore movement")
		flow.completion_seconds = 0.2
		var signals := [0]
		flow.tutorial_completed.connect(func(): signals[0] += 1)
		var other_body := StaticBody2D.new()
		flow._on_goal_entered(other_body)
		other_body.free()
		check(not flow.completing, "Only the player may complete the goal")
		player.set_physics_process(false)
		player.position = Vector2(6070,-1193)
		await frames(4)
		check(flow.completing and signals[0] == 1, "Physical sibling contact must complete once")
		flow._on_goal_entered(player)
		check(signals[0] == 1, "Repeated contact must not emit duplicate completion")
		check(Progress.is_complete(&"tutorial"), "Completion must reach shared session progress")
		check(flow.message.visible and flow.fade.visible, "Completion feedback must be shown")
		await frames(20)
		check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Completion must return home")
		check(current_scene.get_node("MenuUI/CompletionStatus").visible, "Home must acknowledge completion")
	print("Tutorial flow checks: ", "PASS" if failures == 0 else str(failures) + " failures")
	quit(0 if failures == 0 else 1)
