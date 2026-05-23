class_name ActionCollect
extends Node

func execute(context: Dictionary) -> void:
	var target: Node = context.get("target")
	var player: Node = context.get("player")
	if not is_instance_valid(target):
		EventBus.action_completed.emit("collect", false)
		return
	
	var item_data: Resource = null
	var quantity: int = 1
	
	if target.has_method("get_item_data"):
		item_data = target.get_item_data()
	if target.has_method("get_quantity"):
		quantity = target.get_quantity()
	
	if item_data == null:
		EventBus.action_completed.emit("collect", false)
		return
	
	EventBus.item_collected.emit(item_data, quantity)
	EventBus.action_completed.emit("collect", true)
	EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/pickup.ogg",
		target.global_position if target is Node3D else Vector3.ZERO, 0.0)
	target.queue_free()
