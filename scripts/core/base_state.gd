class_name BaseState
extends Node

# Reference to the state machine owner (e.g., player_controller)
var owner_node: Node = null

func enter(_previous_state: String) -> void:
	pass

func exit(_next_state: String) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func get_state_name() -> String:
	return name
