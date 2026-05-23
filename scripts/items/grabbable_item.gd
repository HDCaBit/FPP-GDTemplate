class_name GrabbableItem
extends BaseItem

func _ready() -> void:
	super._ready()
	add_to_group("grabbable")
	add_to_group("interactable")

func get_interaction_prompt() -> String:
	if item_data:
		return "Grab %s [F]" % item_data.item_name
	return "Grab [F]"

func get_weapon_data() -> ItemData:
	return item_data
