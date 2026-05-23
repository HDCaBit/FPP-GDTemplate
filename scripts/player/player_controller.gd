class_name PlayerController
extends CharacterBody3D

# Component references — all nullable
var movement: Node = null
var camera_rig: Node = null
var health: Node = null
var stamina: Node = null
var interaction: Node = null
var action_handler: Node = null
var inventory: Node = null

# Cached node paths — components should be in these groups
const GROUP_MOVEMENT    := "player_movement"
const GROUP_CAMERA      := "player_camera"
const GROUP_HEALTH      := "player_health"
const GROUP_STAMINA     := "player_stamina"
const GROUP_INTERACTION := "player_interaction"
const GROUP_ACTIONS     := "player_action_handler"
const GROUP_INVENTORY   := "player_inventory"

func _ready() -> void:
	add_to_group("player")
	_find_components()
	_connect_input_signals()
	EventBus.player_spawned.emit(self)

func _find_components() -> void:
	# Find components by group within this player's subtree
	movement     = _find_in_children(GROUP_MOVEMENT)
	camera_rig   = _find_in_children(GROUP_CAMERA)
	health       = _find_in_children(GROUP_HEALTH)
	stamina      = _find_in_children(GROUP_STAMINA)
	interaction  = _find_in_children(GROUP_INTERACTION)
	action_handler = _find_in_children(GROUP_ACTIONS)
	inventory    = _find_in_children(GROUP_INVENTORY)

func _find_in_children(group: String) -> Node:
	for child in get_children():
		if child.is_in_group(group):
			return child
		# Also search one level deeper
		for grandchild in child.get_children():
			if grandchild.is_in_group(group):
				return grandchild
	return null

func _connect_input_signals() -> void:
	# Connect input signals to components (each connection is null-checked)
	InputManager.interact_pressed.connect(_on_interact_pressed)
	InputManager.pause_pressed.connect(_on_pause_pressed)
	InputManager.inventory_toggled.connect(_on_inventory_toggled)
	InputManager.grab_pressed.connect(_on_grab_pressed)
	InputManager.collect_pressed.connect(_on_collect_pressed)
	InputManager.throw_pressed.connect(_on_throw_pressed)
	InputManager.drop_pressed.connect(_on_drop_pressed)
	InputManager.attack_pressed.connect(_on_attack_pressed)
	InputManager.shoot_pressed.connect(_on_shoot_pressed)
	InputManager.reload_pressed.connect(_on_reload_pressed)
	InputManager.hotbar_pressed.connect(_on_hotbar_pressed)

func _on_interact_pressed() -> void:
	if action_handler and action_handler.has_method("request_interact"):
		action_handler.request_interact()

func _on_grab_pressed() -> void:
	if action_handler and action_handler.has_method("request_grab"):
		action_handler.request_grab()

func _on_collect_pressed() -> void:
	if action_handler and action_handler.has_method("request_collect"):
		action_handler.request_collect()

func _on_throw_pressed() -> void:
	if action_handler and action_handler.has_method("request_throw"):
		action_handler.request_throw()

func _on_drop_pressed() -> void:
	if action_handler and action_handler.has_method("request_drop"):
		action_handler.request_drop()

func _on_attack_pressed() -> void:
	if action_handler and action_handler.has_method("request_attack"):
		action_handler.request_attack()

func _on_shoot_pressed() -> void:
	if action_handler and action_handler.has_method("request_shoot"):
		action_handler.request_shoot()

func _on_reload_pressed() -> void:
	if action_handler and action_handler.has_method("request_reload"):
		action_handler.request_reload()

func _on_hotbar_pressed(slot_index: int) -> void:
	if action_handler and action_handler.has_method("request_equip_slot"):
		action_handler.request_equip_slot(slot_index)

func _on_pause_pressed() -> void:
	var new_pause := !GameManager.is_paused
	EventBus.pause_toggled.emit(new_pause)

func _on_inventory_toggled() -> void:
	EventBus.action_requested.emit("toggle_inventory", {})

# Called by movement component when it needs the CharacterBody3D
func get_character_body() -> CharacterBody3D:
	return self
