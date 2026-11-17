extends SceneTree
var failed := false
func check(value: bool, label: String) -> void:
	print(("PASS: " if value else "FAIL: ") + label)
	if not value: failed = true
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var level = load("res://scenes/boss_island.tscn").instantiate()
	root.add_child(level)
	await physics_frame
	var manager = level.get_node("ArenaManager")
	var encounter = manager.get_node("FoxEncounter")
	var player = level.get_node("PlayerCharacter")
	var fox = encounter.fox
	check(not encounter.active and not fox.visible, "Fight remains dormant during platforming")
	var left_y: float = manager.left_gate.position.y
	player.position = Vector2(7350, -400)
	for frame in range(100): await physics_frame
	check(manager.arena_started and encounter.active, "Physical entry closes gates and starts encounter")
	check(is_equal_approx(manager.left_gate.position.y, left_y + 270), "Gate drops exactly once")
	check(player.dash_unlocked and player.glide_unlocked, "Encounter uses real dash/glide abilities")
	check(fox.global_position.x > 6400 and fox.global_position.x < 8300, "Boss placed inside actual arena")
	check(fox.get_node("Artwork").sprite_frames.get_frame_count("walk") == 8, "Walk sheet has eight frames")
	check(fox.get_node("Artwork").sprite_frames.get_frame_count("pound") == 24, "Ground pound sheet has 24 frames")
	check(fox.get_node("BiteEffect").sprite_frames.get_frame_count("bite") == 12, "Separate bite overlay has twelve frames")
	# Wait for real ground pounds and let gravity land the bunny on the head.
	var aimed := false
	for frame in range(3200):
		if encounter.ended: break
		if fox.state == "stunned" and not aimed:
			player.position = fox.position + Vector2(0, -240)
			player.velocity = Vector2.ZERO
			encounter.previous_feet = player.position.y + 72
			aimed = true
		elif fox.state != "stunned": aimed = false
		await physics_frame
	check(encounter.victory_layer.visible, "Victory dialogue opens after final stomp")
	check(encounter.ended and fox.health == 0, "Real physics fight reaches three-stomp victory")
	check(encounter.hazards.is_empty() and not player.is_physics_processing(), "Victory freezes combat and clears hazards")
	check(encounter.victory_layer.visible and not encounter.get_node("Instructions").visible, "Victory uses speech box without combat heading")
	var retry := InputEventKey.new()
	retry.keycode = KEY_R
	retry.pressed = true
	encounter._unhandled_key_input(retry)
	check(not encounter.victory_layer.visible, "Retry hides victory dialogue")
	check(encounter.health == 5 and fox.health == 3 and not encounter.ended, "Retry restores encounter health")
	encounter.invulnerable = 0
	encounter.health = 1
	encounter.hurt()
	check(encounter.ended and not fox.is_physics_processing(), "Lethal boss damage stops fight")
	encounter.restart_encounter()
	player.die()
	for frame in range(80): await physics_frame
	check(not player.is_dead and encounter.health == 5 and fox.health == 3, "Controller death and respawn restart the encounter")
	check(encounter.hazards.is_empty(), "Respawn removes stale hazards")
	check(is_equal_approx(manager.left_gate.position.y, left_y + 270), "Retry does not drop gates again")
	for hit in range(3):
		fox.enter("stunned", 1)
		fox.take_stomp()
	current_scene = level
	var confirm := InputEventKey.new()
	confirm.keycode = KEY_ENTER
	confirm.pressed = true
	encounter._unhandled_key_input(confirm)
	for frame in range(5): await process_frame
	check(current_scene != null and current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Victory confirmation returns to actual main menu")
	current_scene.queue_free()
	await process_frame
	quit(1 if failed else 0)
