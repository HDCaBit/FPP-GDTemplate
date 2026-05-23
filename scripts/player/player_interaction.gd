class_name PlayerInteraction
extends Node3D

@export var ray_length: float = 3.0
@export var interaction_layer: int = 0b100000  # Layer 6 = interactables

var _ray: RayCast3D = null
var _current_target: Node = null

func _ready() -> void:
	add_to_group("player_interaction")
	_ray = RayCast3D.new()
	_ray.enabled = true
	_ray.target_position = Vector3(0, 0, -ray_length)
	_ray.collision_mask = interaction_layer
	add_child(_ray)

func _physics_process(_delta: float) -> void:
	_ray.force_raycast_update()
	var collider := _ray.get_collider()
	if collider and collider.is_in_group("interactable"):
		if collider != _current_target:
			_current_target = collider
			EventBus.interactable_focused.emit(_current_target)
			# Show prompt
			var prompt := ""
			if collider.has_method("get_interaction_prompt"):
				prompt = collider.get_interaction_prompt()
			EventBus.interaction_prompt_show.emit(prompt)
	else:
		if _current_target != null:
			_current_target = null
			EventBus.interactable_cleared.emit()
			EventBus.interaction_prompt_hide.emit()

func get_current_target() -> Node:
	return _current_target

func try_interact() -> void:
	if is_instance_valid(_current_target):
		EventBus.interact_pressed.emit(_current_target)
		if _current_target.has_method("interact"):
			_current_target.interact(owner)
