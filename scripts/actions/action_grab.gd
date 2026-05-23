class_name ActionGrab
extends Node

func execute(context: Dictionary) -> void:
	var target: Node = context.get("target")
	var player: Node = context.get("player")
	if not is_instance_valid(target) or not is_instance_valid(player):
		EventBus.action_completed.emit("grab", false)
		return
	
	# Find hand rig in player subtree
	var hand_rig := _find_hand_rig(player)
	if not is_instance_valid(hand_rig):
		# Fallback: just parent to player camera
		hand_rig = player
	
	# Detach from world and attach to hand
	if target.get_parent():
		target.reparent(hand_rig)
	target.position = Vector3.ZERO
	if target is RigidBody3D:
		target.freeze = true
	
	EventBus.item_grabbed.emit(target)
	EventBus.action_completed.emit("grab", true)
	EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/pickup.ogg", player.global_position, 0.0)

func _find_hand_rig(player: Node) -> Node:
	for child in player.get_children():
		if child.is_in_group("hand_rig"):
			return child
		for gc in child.get_children():
			if gc.is_in_group("hand_rig"):
				return gc
	return null
