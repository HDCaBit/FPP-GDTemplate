class_name BaseItem
extends RigidBody3D

@export var item_data: ItemData = null
@export var auto_collect_on_contact: bool = false
@export var collect_on_interact: bool = true

func _ready() -> void:
	add_to_group("world_item")
	if collect_on_interact:
		add_to_group("collectible")
	if auto_collect_on_contact:
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and auto_collect_on_contact:
		if item_data:
			EventBus.item_collected.emit(item_data, 1)
			queue_free()

func get_item_data() -> ItemData:
	return item_data

func get_quantity() -> int:
	return 1

func get_interaction_prompt() -> String:
	if item_data:
		return "Pick up %s" % item_data.item_name
	return "Pick up"
