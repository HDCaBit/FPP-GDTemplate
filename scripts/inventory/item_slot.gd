class_name ItemSlot
extends Resource

@export var item_data: ItemData = null
@export var quantity: int = 0

func is_empty() -> bool:
	return item_data == null or quantity <= 0

func clear() -> void:
	item_data = null
	quantity = 0

func can_stack(other_data: ItemData) -> bool:
	if item_data == null or other_data == null:
		return false
	return item_data.item_id == other_data.item_id and quantity < item_data.max_stack_size
