class_name ActionDrop
extends Node

@export var drop_offset: Vector3 = Vector3(0, 0.5, -1.0)

func execute(context: Dictionary) -> void:
	var held: Node = context.get("held_item")
	var player: Node = context.get("player")
	if not is_instance_valid(held) or not is_instance_valid(player):
		EventBus.action_completed.emit("drop", false)
		return
	
	var drop_pos: Vector3 = player.global_position + player.global_transform.basis * drop_offset
	
	if held.get_parent():
		held.reparent(get_tree().current_scene)
	held.global_position = drop_pos
	
	if held is RigidBody3D:
		held.freeze = false
	
	var item_data: Resource = null
	if held.has_method("get_item_data"):
		item_data = held.get_item_data()
	
	EventBus.item_dropped.emit(item_data, drop_pos)
	EventBus.action_completed.emit("drop", true)
	EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/drop.ogg", drop_pos, 0.0)
