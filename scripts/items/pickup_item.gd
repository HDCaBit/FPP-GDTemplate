class_name PickupItem
extends BaseItem

## Pickup item — auto-collects on contact or on interact.
## Set auto_collect_on_contact = true for automatic pickup.

func _ready() -> void:
	super._ready()
	add_to_group("collectible")
	add_to_group("interactable")

func get_interaction_prompt() -> String:
	if item_data:
		return "Pick up %s [E]" % item_data.item_name
	return "Pick up [E]"
