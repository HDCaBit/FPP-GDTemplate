class_name PlayerCamera
extends Node3D

@export var camera_path: NodePath = NodePath("Camera3D")
@export var v_clamp_degrees: float = 85.0
@export var head_bob_enabled: bool = true
@export var head_bob_speed: float = 14.0
@export var head_bob_amplitude: float = 0.03
@export var fov_sprint_delta: float = 5.0
@export var fov_transition_speed: float = 8.0
@export var tilt_amount: float = 0.5

var _camera: Camera3D = null
var _default_fov: float = 75.0
var _bob_time: float = 0.0
var _movement: Node = null
var _target_fov: float = 75.0
# Rotation accumulators
var _pitch: float = 0.0  # Vertical (camera node X rotation)

func _ready() -> void:
	add_to_group("player_camera")
	_camera = get_node_or_null(camera_path)
	if _camera:
		_default_fov = _camera.fov
		_target_fov = _default_fov
	await owner.ready
	_movement = _find_sibling("player_movement")

	EventBus.player_started_sprinting.connect(_on_sprint_start)
	EventBus.player_stopped_sprinting.connect(_on_sprint_stop)
	EventBus.player_crouched.connect(_on_crouch)

func _find_sibling(group: String) -> Node:
	if not is_instance_valid(owner):
		return null
	for child in owner.get_children():
		if child.is_in_group(group):
			return child
	return null

func _process(delta: float) -> void:
	_apply_mouse_look()
	_apply_head_bob(delta)
	_apply_fov(delta)

func _apply_mouse_look() -> void:
	var look: Vector2 = InputManager.consume_look_delta()
	if look.length_squared() < 0.0001:
		return
	# Rotate player body horizontally (yaw)
	if is_instance_valid(owner):
		owner.rotate_y(deg_to_rad(-look.x))
	# Rotate camera vertically (pitch) — clamped
	_pitch = clampf(_pitch - look.y, -v_clamp_degrees, v_clamp_degrees)
	rotation_degrees.x = _pitch

func _apply_head_bob(delta: float) -> void:
	if not head_bob_enabled or not is_instance_valid(_camera):
		return
	var is_moving := false
	if is_instance_valid(_movement) and _movement.has_method("is_moving"):
		is_moving = _movement.is_moving()
	if is_moving and owner and (owner as CharacterBody3D).is_on_floor():
		_bob_time += delta * head_bob_speed
		_camera.position.y = lerp(_camera.position.y, sin(_bob_time) * head_bob_amplitude, delta * 10.0)
		_camera.position.x = lerp(_camera.position.x, cos(_bob_time * 0.5) * head_bob_amplitude * 0.5, delta * 10.0)
	else:
		_bob_time = 0.0
		_camera.position.y = lerp(_camera.position.y, 0.0, delta * 10.0)
		_camera.position.x = lerp(_camera.position.x, 0.0, delta * 10.0)

func _apply_fov(delta: float) -> void:
	if not is_instance_valid(_camera):
		return
	_camera.fov = lerp(_camera.fov, _target_fov, fov_transition_speed * delta)

func _on_sprint_start() -> void:
	_target_fov = _default_fov + fov_sprint_delta

func _on_sprint_stop() -> void:
	_target_fov = _default_fov

func _on_crouch(_crouching: bool) -> void:
	pass  # Optional: adjust camera height for crouch

func get_camera() -> Camera3D:
	return _camera

func get_forward_direction() -> Vector3:
	if not is_instance_valid(_camera):
		return Vector3.FORWARD
	return -_camera.global_transform.basis.z
