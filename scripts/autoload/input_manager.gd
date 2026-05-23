extends Node

# Movement vectors (normalized)
var move_direction: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO

# State flags
var is_sprinting: bool = false
var is_crouching: bool = false
var is_jumping: bool = false

# Mouse sensitivity (configurable)
var mouse_sensitivity: float = 0.2
var invert_y: bool = false

# Signals for discrete actions (pressed once)
signal jump_pressed()
signal sprint_started()
signal sprint_stopped()
signal crouch_toggled()
signal interact_pressed()
signal attack_pressed()
signal attack_released()
signal attack_alt_pressed()
signal attack_alt_released()
signal shoot_pressed()
signal shoot_released()
signal throw_pressed()
signal drop_pressed()
signal grab_pressed()
signal collect_pressed()
signal reload_pressed()
signal inventory_toggled()
signal pause_pressed()
signal hotbar_pressed(slot_index: int)
signal debug_toggled()

func _ready() -> void:
	# Capture mouse on start — release handled by GameManager/PauseMenu
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	# Mouse look delta — only when mouse is captured
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		var motion_delta: Vector2 = mouse_event.relative
		if invert_y:
			motion_delta.y = -motion_delta.y
		look_delta = motion_delta * mouse_sensitivity

	# Discrete action signals
	if event.is_action_pressed("jump"):         emit_signal("jump_pressed")
	if event.is_action_pressed("sprint"):       emit_signal("sprint_started"); is_sprinting = true
	if event.is_action_released("sprint"):      emit_signal("sprint_stopped"); is_sprinting = false
	if event.is_action_pressed("crouch"):       emit_signal("crouch_toggled"); is_crouching = !is_crouching
	if event.is_action_pressed("interact"):     emit_signal("interact_pressed")
	if event.is_action_pressed("attack"):       emit_signal("attack_pressed")
	if event.is_action_released("attack"):      emit_signal("attack_released")
	if event.is_action_pressed("attack_alt"):   emit_signal("attack_alt_pressed")
	if event.is_action_released("attack_alt"):  emit_signal("attack_alt_released")
	if event.is_action_pressed("shoot"):        emit_signal("shoot_pressed")
	if event.is_action_released("shoot"):       emit_signal("shoot_released")
	if event.is_action_pressed("throw_item"):   emit_signal("throw_pressed")
	if event.is_action_pressed("drop_item"):    emit_signal("drop_pressed")
	if event.is_action_pressed("grab_item"):    emit_signal("grab_pressed")
	if event.is_action_pressed("collect_item"): emit_signal("collect_pressed")
	if event.is_action_pressed("reload"):       emit_signal("reload_pressed")
	if event.is_action_pressed("inventory_toggle"): emit_signal("inventory_toggled")
	if event.is_action_pressed("pause"):        emit_signal("pause_pressed")
	if event.is_action_pressed("debug_toggle"): emit_signal("debug_toggled")

	# Hotbar slots 1-5
	for i in range(1, 6):
		if event.is_action_pressed("hotbar_%d" % i):
			emit_signal("hotbar_pressed", i - 1)

func _physics_process(_delta: float) -> void:
	# Continuous movement vector — updated every physics frame
	move_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).normalized()

func consume_look_delta() -> Vector2:
	# Call this from player_camera to get and clear the delta
	var d := look_delta
	look_delta = Vector2.ZERO
	return d

func set_mouse_captured(captured: bool) -> void:
	if captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
