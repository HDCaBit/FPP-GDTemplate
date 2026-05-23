class_name InventorySystem
extends Node

@export var inventory_size: int = 20
@export var hotbar_size: int = 5

var slots: Array[ItemSlot] = []
var hotbar: Array[ItemSlot] = []

func _ready() -> void:
	add_to_group("player_inventory")
	_initialize_slots()
	EventBus.item_collected.connect(_on_item_collected)

func _initialize_slots() -> void:
	slots.clear()
	for i in range(inventory_size):
		slots.append(ItemSlot.new())
	hotbar.clear()
	for i in range(hotbar_size):
		hotbar.append(ItemSlot.new())

func add_item(item_data: ItemData, quantity: int = 1) -> bool:
	# Try stack first
	for slot in slots:
		if slot.can_stack(item_data):
			slot.quantity += quantity
			_broadcast_update()
			return true
	# Find empty slot
	for slot in slots:
		if slot.is_empty():
			slot.item_data = item_data
			slot.quantity = quantity
			_broadcast_update()
			return true
	EventBus.inventory_full.emit()
	return false

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for slot in slots:
		if not slot.is_empty() and slot.item_data.item_id == item_id:
			if slot.quantity >= quantity:
				slot.quantity -= quantity
				if slot.quantity <= 0:
					slot.clear()
				_broadcast_update()
				return true
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	var total := 0
	for slot in slots:
		if not slot.is_empty() and slot.item_data.item_id == item_id:
			total += slot.quantity
	return total >= quantity

func get_inventory_snapshot() -> Array:
	return slots.duplicate()

func _broadcast_update() -> void:
	EventBus.inventory_updated.emit(get_inventory_snapshot())

func _on_item_collected(item_data: ItemData, quantity: int) -> void:
	add_item(item_data, quantity)

func get_save_data() -> Array:
	var data := []
	for slot in slots:
		if slot.is_empty():
			data.append({"id": "", "qty": 0})
		else:
			data.append({"id": slot.item_data.item_id, "qty": slot.quantity})
	return data
