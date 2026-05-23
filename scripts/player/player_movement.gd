class_name PlayerMovement
extends Node3D

# Must be in this group for player_controller to find it
func _init() -> void:
	add_to_group("player_movement")

# Movement settings (exported for Inspector tuning)
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var crouch_speed: float = 2.5
@export var jump_velocity: float = 5.5
@export var gravity_multiplier: float = 2.0
@export var acceleration: float = 15.0
@export var deceleration: float = 20.0
@export var air_control: float = 0.3
@export var slide_speed: float = 12.0
@export var slide_duration: float = 0.6

# State
var _body: CharacterBody3D = null
var _stamina_node: Node = null
var _is_sprinting: bool = false
var _is_crouching: bool = false
var _is_sliding: bool = false
var _slide_timer: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("player_movement")
	await owner.ready
	_body = owner as CharacterBody3D
	# Find stamina sibling (null-safe)
	_stamina_node = _find_sibling_in_group("player_stamina")
	
	# Connect input signals
	InputManager.sprint_started.connect(_on_sprint_started)
	InputManager.sprint_stopped.connect(_on_sprint_stopped)
	InputManager.jump_pressed.connect(_on_jump_pressed)
	InputManager.crouch_toggled.connect(_on_crouch_toggled)

func _find_sibling_in_group(group: String) -> Node:
	if not is_instance_valid(owner):
		return null
	for child in owner.get_children():
		if child.is_in_group(group):
			return child
	return null

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_body):
		return
	_apply_gravity(delta)
	_apply_slide(delta)
	_apply_movement(delta)
	_body.move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not _body.is_on_floor():
		_body.velocity.y -= _gravity * gravity_multiplier * delta
	else:
		if _body.velocity.y < -5.0:
			EventBus.player_landed.emit(_body.velocity)
		if _body.velocity.y < 0.0:
			_body.velocity.y = 0.0

func _apply_movement(delta: float) -> void:
	var input_dir := InputManager.move_direction
	# Transform input relative to camera/player facing
	var basis := _body.global_transform.basis
	var direction := (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_speed := _get_current_speed()
	var accel := acceleration if _body.is_on_floor() else acceleration * air_control
	var decel := deceleration if _body.is_on_floor() else deceleration * air_control

	if direction.length() > 0.0:
		_body.velocity.x = lerp(_body.velocity.x, direction.x * target_speed, accel * delta)
		_body.velocity.z = lerp(_body.velocity.z, direction.z * target_speed, accel * delta)
	else:
		_body.velocity.x = lerp(_body.velocity.x, 0.0, decel * delta)
		_body.velocity.z = lerp(_body.velocity.z, 0.0, decel * delta)

func _get_current_speed() -> float:
	if _is_sliding:
		return slide_speed
	if _is_crouching:
		return crouch_speed
	if _is_sprinting and _has_stamina():
		return sprint_speed
	return walk_speed

func _has_stamina() -> bool:
	if not is_instance_valid(_stamina_node):
		return true  # No stamina system = unlimited
	if _stamina_node.has_method("has_stamina"):
		return _stamina_node.has_stamina()
	return true

func _apply_slide(delta: float) -> void:
	if _is_sliding:
		_slide_timer -= delta
		if _slide_timer <= 0.0:
			_is_sliding = false

func _on_sprint_started() -> void:
	if _is_crouching and not _is_sliding:
		# Crouch + sprint = slide
		_is_sliding = true
		_slide_timer = slide_duration
		return
	_is_sprinting = true
	EventBus.player_started_sprinting.emit()

func _on_sprint_stopped() -> void:
	_is_sprinting = false
	EventBus.player_stopped_sprinting.emit()

func _on_jump_pressed() -> void:
	if not is_instance_valid(_body):
		return
	if _body.is_on_floor() and not _is_crouching:
		_body.velocity.y = jump_velocity
		EventBus.player_jumped.emit()

func _on_crouch_toggled() -> void:
	_is_crouching = !_is_crouching
	EventBus.player_crouched.emit(_is_crouching)

func is_moving() -> bool:
	if not is_instance_valid(_body):
		return false
	return Vector2(_body.velocity.x, _body.velocity.z).length() > 0.1

func get_velocity() -> Vector3:
	if not is_instance_valid(_body):
		return Vector3.ZERO
	return _body.velocity
