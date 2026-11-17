extends Node2D
## Self-contained demo: no changes to the shared player controller or island progression.
var player: CharacterBody2D
var health := 5
var invulnerable := 0.0
var hazards: Array[Dictionary] = []
var previous_feet := 0.0
var ended := false
@export var player_path: NodePath
@export var automatic_start := true
@export var left_bound := 40.0
@export var right_bound := 1110.0
@export var floor_height := 600.0
@export var boss_spawn := Vector2(900, 540)
@export var player_spawn := Vector2(300, 450)
var active := false
var waiting_for_respawn := false
var music: AudioStreamPlayer
var paused_background := false
var victory_layer: CanvasLayer
var victory_box: PanelContainer
@onready var fox = $Fox

func _ready() -> void:
	if player_path.is_empty():
		var tutorial := preload("res://scenes/main.tscn").instantiate()
		player = tutorial.get_node("PlayerCharacter") as CharacterBody2D
		tutorial.remove_child(player)
		tutorial.free()
		player.position = player_spawn
		add_child(player)
	else:
		player = get_node(player_path) as CharacterBody2D
	build_victory_dialogue()
	fox.add_collision_exception_with(player)
	fox.target = player
	fox.attack_fired.connect(spawn_hazard)
	fox.defeated.connect(finish_victory)
	music = AudioStreamPlayer.new()
	music.stream = preload("res://assets/audio/Bossbattle.ogg")
	music.volume_db = -18.0
	add_child(music)
	fox.set_physics_process(false)
	fox.hide()
	$Instructions.hide()
	if automatic_start:
		start_encounter()
	update_hud()

func start_encounter() -> void:
	if active: return
	active = true
	restart_encounter()

func restart_encounter() -> void:
	ended = false
	victory_layer.hide()
	health = 5
	invulnerable = 1.6
	waiting_for_respawn = false
	clear_hazards()
	player.position = player_spawn
	player.reset_after_respawn()
	player.is_dead = false
	player.modulate = Color.WHITE
	player.set_physics_process(true)
	# Final encounter uses the real controller abilities, independent of menu unlock work.
	player.unlock_dash()
	player.unlock_glide()
	fox.position = boss_spawn
	fox.velocity = Vector2.ZERO
	fox.health = fox.max_health
	fox.attack_index = 0
	fox.arena_left = left_bound + 50
	fox.arena_right = right_bound - 50
	fox.enter("chase", 2.0)
	fox.show()
	fox.get_node("Status").show()
	fox.set_physics_process(true)
	previous_feet = player.position.y + 72
	$Instructions.show()
	var background = get_node_or_null("/root/MusicManager")
	if background != null and background.music_player != null and background.music_player.playing and not background.music_player.stream_paused:
		background.music_player.stream_paused = true
		paused_background = true
	music.play()
	update_hud()

func player_rect() -> Rect2:
	var half := Vector2(30, 72) * player.scale
	return Rect2(player.position - half, half * 2)

func bite_rect() -> Rect2:
	# Fixed facing during warning; retreat, jump, or shrink to avoid the high bite.
	var left: float = fox.position.x + 25 if fox.facing > 0 else fox.position.x - 155
	return Rect2(left, fox.position.y - 75, 130, 30)

func spawn_hazard(kind: String, direction: float) -> void:
	var wave := kind == "wave"
	hazards.append({"position": Vector2(fox.position.x + direction * 65, fox.position.y + (45 if wave else -25)), "velocity": Vector2(direction * (230 if wave else 260), 0), "size": Vector2(44, 26) if wave else Vector2(28, 28), "kind": kind})

func finish_victory() -> void:
	ended = true
	victory_layer.show()
	$Instructions.hide()
	fox.get_node("Status").hide()
	fox.get_node("Artwork").modulate = Color.WHITE
	preload("res://scripts/session_progress.gd").complete_island(&"boss")
	music.stop()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	fox.set_physics_process(false)
	clear_hazards()

func clear_hazards() -> void:
	hazards.clear()
	queue_redraw()

func _physics_process(delta: float) -> void:
	invulnerable = maxf(0, invulnerable - delta)
	if not active: return
	if player.is_dead:
		waiting_for_respawn = true
		fox.set_physics_process(false)
		clear_hazards()
		return
	if waiting_for_respawn:
		restart_encounter()
		return
	if not ended:
		player.position.x = clampf(player.position.x, left_bound, right_bound)
		if player.position.y > floor_height + 300:
			health = 1
			hurt()
		var feet := player.position.y + 72.0 * player.scale.y
		var head: float = fox.position.y - 60.0
		if fox.state == "stunned" and player.velocity.y > 0 and previous_feet <= head + 12 and feet >= head and absf(player.position.x - fox.position.x) < 65:
			if fox.take_stomp():
				player.apply_obstacle_launch(Vector2(0, -430), 0.12)
		if fox.state == "bite" and not fox.bite_connected and bite_rect().intersects(player_rect()):
			fox.bite_connected = true
			hurt()
		previous_feet = feet
		if ended:
			update_hud()
			queue_redraw()
			return
		for i in range(hazards.size() - 1, -1, -1):
			var hazard := hazards[i]
			var old_position: Vector2 = hazard.position
			hazard.position += hazard.velocity * delta
			var swept := Rect2(old_position - hazard.size / 2, hazard.size).merge(Rect2(hazard.position - hazard.size / 2, hazard.size))
			if swept.intersects(player_rect()):
				hazards.remove_at(i)
				hurt()
				if ended: break
			elif hazard.position.x < left_bound - 100 or hazard.position.x > right_bound + 100:
				hazards.remove_at(i)
	player.modulate = Color(1, 0.55, 0.55, 0.6) if invulnerable > 0 else Color.WHITE
	update_hud()
	queue_redraw()

func hurt() -> void:
	if invulnerable > 0 or ended:
		return
	health -= 1
	invulnerable = 1.6
	if health <= 0:
		ended = true
		fox.set_physics_process(false)
		player.set_physics_process(false)
		clear_hazards()
		music.stop()

func update_hud() -> void:
	var hint := "Keep moving. Gold = warning; attacks lock their facing."
	match fox.state:
		"bite_warning", "bite": hint = "BITE: jump or back away from the marked attack zone."
		"throw_warning": hint = "THROW: jump over the incoming projectile."
		"pound_warning", "pound_air": hint = "GROUND POUND: wait for landing, then jump over the low waves."
		"stunned": hint = "STUNNED: jump onto the GREEN fox's head to damage it!"
		"recovery": hint = "Recovery: reposition for the next attack."
	if ended:
		hint = "Sibling rescued!" if fox.health <= 0 else "Try again! R restarts with full health."
	$Instructions/Label.text = "FOX BOSS | Bunny: %d/5   Fox: %d/3\nArrows: move | Space: jump / hold to glide | Shift: dash | R: retry\n%s" % [health, fox.health, hint]

func _draw() -> void:
	if not is_instance_valid(fox): return
	if fox.state in ["bite_warning", "bite"]:
		draw_rect(bite_rect(), Color(1, 0.7, 0.15, 0.3 if fox.state == "bite_warning" else 0.85))
	for hazard in hazards:
		draw_rect(Rect2(hazard.position - hazard.size / 2, hazard.size), Color.SKY_BLUE if hazard.kind == "wave" else Color.PLUM)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_R and active and not player.is_dead:
		restart_encounter()
	elif event.keycode == KEY_ENTER and ended and fox.health <= 0:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _exit_tree() -> void:
	if is_instance_valid(music):
		music.stop()
	if paused_background:
		var background = get_node_or_null("/root/MusicManager")
		if background != null and is_instance_valid(background.music_player):
			background.music_player.stream_paused = false

func build_victory_dialogue() -> void:
	victory_layer = CanvasLayer.new()
	victory_layer.layer = 40
	add_child(victory_layer)
	var speech := Control.new()
	speech.set_script(preload("res://scripts/fox_speech_bubble.gd"))
	speech.speaker = fox
	victory_layer.add_child(speech)
	var hint := Label.new()
	hint.text = "Enter: return home    R: play again"
	hint.position = Vector2(24, 110)
	victory_layer.add_child(hint)
	victory_layer.hide()
