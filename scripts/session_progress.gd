extends RefCounted
## Shared session state for menu/level handoffs. No permanent save is implied.

static var completed_islands: Dictionary = {}


static func complete_island(island: StringName) -> void:
	completed_islands[island] = true


static func is_complete(island: StringName) -> bool:
	return completed_islands.get(island, false)
