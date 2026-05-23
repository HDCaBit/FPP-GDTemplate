class_name StateMachine
extends Node

var current_state: BaseState = null
var previous_state_name: String = ""

signal state_changed(from_state: String, to_state: String)

func _ready() -> void:
	await owner.ready
	# Initialize with first child state if any
	for child in get_children():
		if child is BaseState:
			child.owner_node = owner
			current_state = child
			current_state.enter("")
			break

func transition_to(state_name: String) -> void:
	var new_state: BaseState = get_node_or_null(state_name)
	if new_state == null:
		push_warning("StateMachine: State '%s' not found." % state_name)
		return
	if new_state == current_state:
		return
	var from_name := ""
	if current_state:
		from_name = current_state.get_state_name()
		current_state.exit(state_name)
	previous_state_name = from_name
	current_state = new_state
	current_state.owner_node = owner
	current_state.enter(from_name)
	emit_signal("state_changed", from_name, state_name)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
