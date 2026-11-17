extends SceneTree
var arena
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, label: String) -> void:
	if not value:
		push_error(label)
		quit(1)
		assert(value, label)
	print("PASS: ", label)
func run() -> void:
	arena = load("res://scenes/fox_boss_practice.tscn").instantiate()
	root.add_child(arena)
	await physics_frame
	arena.set_physics_process(false)
	arena.player.set_physics_process(false)
	arena.fox.set_physics_process(false)
	arena.fox.position = Vector2(700, 560)
	arena.fox.facing = -1
	arena.player.position = Vector2(600, 528)
	check(arena.bite_rect().intersects(arena.player_rect()), "Standing bunny is inside bite")
	arena.player.position.y = 350
	check(not arena.bite_rect().intersects(arena.player_rect()), "Jump clears bite")
	arena.player.scale = Vector2.ONE
	arena.player.position = Vector2(950, 528)
	check(not arena.bite_rect().intersects(arena.player_rect()), "Retreat clears bite")
	arena.invulnerable = 0
	arena.hurt()
	arena.hurt()
	check(arena.health == 4, "Invulnerability prevents repeated contact damage")
	arena.spawn_hazard("wave", 1.0)
	check(arena.hazards.size() == 1, "Ground wave spawns")
	arena.spawn_hazard("projectile", -1.0)
	check(arena.hazards.size() == 2, "Ranged attack spawns")
	arena.clear_hazards()
	arena.invulnerable = 0
	arena.hazards.append({"position": Vector2(800, 528), "velocity": Vector2(1500, 0), "size": Vector2(28,28), "kind": "projectile"})
	arena._physics_process(0.2)
	check(arena.health == 3, "Swept fast projectile cannot tunnel through player")
	arena.fox.enter("recovery", 1)
	check(not arena.fox.take_stomp(), "Boss cannot take damage outside stun")
	for hit in range(3):
		arena.fox.enter("stunned", 3.4)
		arena.player.position = Vector2(700, 450)
		arena.player.velocity = Vector2(0, 200)
		arena.previous_feet = 490
		arena._physics_process(0.016)
	check(arena.fox.health == 0 and arena.ended, "Actual descending stomp detection reaches victory")
	check(arena.hazards.is_empty(), "Victory clears hazards")
	arena.queue_free()
	await process_frame
	arena = load("res://scenes/fox_boss_practice.tscn").instantiate()
	root.add_child(arena)
	await physics_frame
	check(arena.health == 5 and arena.fox.health == 3 and not arena.ended, "Fresh arena resets health and encounter")
	arena.set_physics_process(false)
	arena.player.set_physics_process(false)
	var saw := {}
	arena.fox.attack_fired.connect(func(kind, _direction): saw[kind] = true)
	arena.fox.warning_duration = 0.05
	arena.fox.stun_duration = 0.1
	arena.fox.remaining = 0.01
	for frame in range(650):
		await physics_frame
		saw[arena.fox.state] = true
	check(saw.has("bite") and saw.has("projectile") and saw.has("wave") and saw.has("stunned"), "Live physics completes bite, throw, landing waves and stun")
	arena.set_physics_process(false)
	arena.fox.set_physics_process(false)
	arena.hazards.clear()
	arena.health = 1
	arena.invulnerable = 0
	arena.hurt()
	check(arena.ended and not arena.player.is_physics_processing() and not arena.fox.is_physics_processing(), "Loss stops combat and player")
	arena.queue_free()
	quit()
