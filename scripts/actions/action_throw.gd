class_name ActionThrow
extends Node

@export var throw_force: float = 15.0

func execute(context: Dictionary) -> void:
	var held: Node = context.get("held_item")
	var player: Node = context.get("player")
	if not is_instance_valid(held) or not is_instance_valid(player):
		EventBus.action_completed.emit("throw", false)
		return
	
	var camera := _get_camera(player)
	var direction := Vector3.FORWARD
	if is_instance_valid(camera):
		direction = -camera.global_transform.basis.z
	
	# Detach from hand and apply physics impulse
	if held.get_parent():
		held.reparent(get_tree().current_scene)
	held.global_position = player.global_position + direction * 1.0 + Vector3.UP * 0.5
	if held is RigidBody3D:
		held.freeze = false
		held.apply_central_impulse(direction * throw_force)
	
	EventBus.item_thrown.emit(held, direction * throw_force)
	EventBus.action_completed.emit("throw", true)
	EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/throw.ogg", player.global_position, 0.0)

func _get_camera(player: Node) -> Camera3D:
	if not is_instance_valid(player): return null
	for child in player.get_children():
		if child is Camera3D: return child
		for gc in child.get_children():
			if gc is Camera3D: return gc
	return null
