class_name FootstepSystem
extends Node

@export var step_interval_walk: float = 0.5
@export var step_interval_sprint: float = 0.3

var _step_timer: float = 0.0
var _body: CharacterBody3D = null

func _ready() -> void:
	await owner.ready
	_body = owner as CharacterBody3D

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_body):
		return
	if not _body.is_on_floor():
		_step_timer = 0.0
		return
	var horizontal_speed := Vector2(_body.velocity.x, _body.velocity.z).length()
	if horizontal_speed < 0.5:
		_step_timer = 0.0
		return
	
	var interval := step_interval_walk if horizontal_speed < 7.0 else step_interval_sprint
	_step_timer += delta
	if _step_timer >= interval:
		_step_timer = 0.0
		_play_footstep()

func _play_footstep() -> void:
	if not is_instance_valid(_body):
		return
	# Detect surface
	var surface := _detect_surface()
	EventBus.play_footstep.emit(surface, _body.global_position)

func _detect_surface() -> String:
	# Raycast down to detect physics material
	if not is_instance_valid(_body):
		return "default"
	var space := _body.get_world_3d().direct_space_state
	var from := _body.global_position
	var to := from + Vector3.DOWN * 1.2
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space.intersect_ray(query)
	if result and result.collider:
		# Check for surface tag (group-based surface detection)
		if result.collider.is_in_group("surface_wood"):   return "wood"
		if result.collider.is_in_group("surface_metal"):  return "metal"
		if result.collider.is_in_group("surface_grass"):  return "grass"
		if result.collider.is_in_group("surface_gravel"): return "gravel"
		if result.collider.is_in_group("surface_water"):  return "water"
	return "default"
