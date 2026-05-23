class_name InventoryUIController
extends CanvasLayer

## Inventory UI screen — shows all inventory slots.
## Toggles visibility via EventBus action_requested.

@onready var grid_container: GridContainer = get_node_or_null("InventoryPanel/GridContainer")

var _is_open: bool = false

func _ready() -> void:
	visible = false
	EventBus.action_requested.connect(_on_action_requested)
	EventBus.inventory_updated.connect(_on_inventory_updated)

func _on_action_requested(action_name: String, _context: Dictionary) -> void:
	if action_name == "toggle_inventory":
		toggle()

func toggle() -> void:
	_is_open = !_is_open
	visible = _is_open
	InputManager.set_mouse_captured(!_is_open)

func _on_inventory_updated(inventory_data: Array) -> void:
	if not is_instance_valid(grid_container):
		return
	# Clear existing children
	for child in grid_container.get_children():
		child.queue_free()
	# Create slot buttons
	for slot in inventory_data:
		var btn := Button.new()
		if slot is ItemSlot and not slot.is_empty():
			btn.text = "%s x%d" % [slot.item_data.item_name, slot.quantity]
		else:
			btn.text = "[Empty]"
		btn.custom_minimum_size = Vector2(120, 40)
		grid_container.add_child(btn)

func close() -> void:
	_is_open = false
	visible = false
	InputManager.set_mouse_captured(true)
