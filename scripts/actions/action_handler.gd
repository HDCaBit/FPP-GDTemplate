class_name ActionHandler
extends Node

# References to action sub-nodes (all nullable)
var _action_attack: Node = null
var _action_shoot: Node = null
var _action_throw: Node = null
var _action_drop: Node = null
var _action_grab: Node = null
var _action_collect: Node = null
var _interaction: Node = null

# Currently held item
var held_item: Node = null
var equipped_slot: int = -1

func _ready() -> void:
	add_to_group("player_action_handler")
	_find_action_nodes()
	EventBus.item_grabbed.connect(_on_item_grabbed)
	EventBus.item_dropped.connect(_on_item_dropped)

func _find_action_nodes() -> void:
	_action_attack  = get_node_or_null("ActionAttack")
	_action_shoot   = get_node_or_null("ActionShoot")
	_action_throw   = get_node_or_null("ActionThrow")
	_action_drop    = get_node_or_null("ActionDrop")
	_action_grab    = get_node_or_null("ActionGrab")
	_action_collect = get_node_or_null("ActionCollect")
	# Find interaction in parent's children
	if is_instance_valid(owner):
		for child in owner.get_children():
			if child.is_in_group("player_interaction"):
				_interaction = child
				break

func request_attack() -> void:
	EventBus.action_requested.emit("attack", {"held_item": held_item})
	if is_instance_valid(_action_attack) and _action_attack.has_method("execute"):
		_action_attack.execute({"held_item": held_item, "player": owner})

func request_shoot() -> void:
	EventBus.action_requested.emit("shoot", {"held_item": held_item})
	if is_instance_valid(_action_shoot) and _action_shoot.has_method("execute"):
		_action_shoot.execute({"held_item": held_item, "player": owner})

func request_throw() -> void:
	if not is_instance_valid(held_item):
		return
	EventBus.action_requested.emit("throw", {"held_item": held_item})
	if is_instance_valid(_action_throw) and _action_throw.has_method("execute"):
		_action_throw.execute({"held_item": held_item, "player": owner})

func request_drop() -> void:
	if not is_instance_valid(held_item):
		return
	EventBus.action_requested.emit("drop", {"held_item": held_item})
	if is_instance_valid(_action_drop) and _action_drop.has_method("execute"):
		_action_drop.execute({"held_item": held_item, "player": owner})

func request_grab() -> void:
	if not is_instance_valid(_interaction):
		return
	var target: Node = _interaction.get_current_target() if _interaction.has_method("get_current_target") else null
	if not is_instance_valid(target):
		return
	if not target.is_in_group("grabbable"):
		return
	EventBus.action_requested.emit("grab", {"target": target})
	if is_instance_valid(_action_grab) and _action_grab.has_method("execute"):
		_action_grab.execute({"target": target, "player": owner})

func request_collect() -> void:
	if not is_instance_valid(_interaction):
		return
	var target: Node = _interaction.get_current_target() if _interaction.has_method("get_current_target") else null
	if not is_instance_valid(target):
		return
	if not target.is_in_group("collectible"):
		return
	EventBus.action_requested.emit("collect", {"target": target})
	if is_instance_valid(_action_collect) and _action_collect.has_method("execute"):
		_action_collect.execute({"target": target, "player": owner})

func request_interact() -> void:
	if is_instance_valid(_interaction) and _interaction.has_method("try_interact"):
		_interaction.try_interact()

func request_reload() -> void:
	if is_instance_valid(held_item) and held_item.has_method("reload"):
		held_item.reload()

func request_equip_slot(slot_index: int) -> void:
	equipped_slot = slot_index
	EventBus.action_requested.emit("equip_slot", {"slot": slot_index})

func _on_item_grabbed(item_node: Node) -> void:
	held_item = item_node

func _on_item_dropped(_item_data, _pos) -> void:
	held_item = null
