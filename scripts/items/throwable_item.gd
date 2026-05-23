class_name ThrowableItem
extends BaseItem

## Item that can be thrown after being grabbed.

@export var throw_force_override: float = 0.0  # 0 = use default from action_throw

func _ready() -> void:
	super._ready()
	add_to_group("grabbable")
	add_to_group("interactable")

func get_interaction_prompt() -> String:
	if item_data:
		return "Pick up %s [F]" % item_data.item_name
	return "Pick up [F]"

func get_throw_force() -> float:
	return throw_force_override
