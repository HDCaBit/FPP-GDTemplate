class_name Interactable
extends Node

@export var interaction_prompt: String = "Press [E] to interact"
@export var single_use: bool = false

signal interacted(interactor: Node)

var _used: bool = false

func _ready() -> void:
	# Add parent to interactable group and physics layer
	if parent_is_valid():
		owner.add_to_group("interactable")

func parent_is_valid() -> bool:
	return is_instance_valid(owner) and owner is Node3D

func interact(interactor: Node) -> void:
	if single_use and _used:
		return
	_used = single_use
	emit_signal("interacted", interactor)
	EventBus.interact_pressed.emit(owner)

func get_interaction_prompt() -> String:
	return interaction_prompt
