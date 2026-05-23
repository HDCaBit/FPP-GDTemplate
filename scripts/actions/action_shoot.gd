class_name ActionShoot
extends Node

@export var use_hitscan: bool = true
@export var hitscan_damage: float = 30.0
@export var hitscan_range: float = 200.0
@export var shoot_cooldown: float = 0.2
@export var projectile_scene: PackedScene = null
@export var shoot_layer: int = 0b1001

var _cooldown_timer: float = 0.0
var _can_shoot: bool = true

func _process(delta: float) -> void:
	if not _can_shoot:
		_cooldown_timer += delta
		if _cooldown_timer >= shoot_cooldown:
			_can_shoot = true
			_cooldown_timer = 0.0

func execute(context: Dictionary) -> void:
	if not _can_shoot:
		return
	var held_item: Node = context.get("held_item")
	# Check weapon ammo if available
	if is_instance_valid(held_item) and held_item.has_method("consume_ammo"):
		if not held_item.consume_ammo():
			EventBus.action_completed.emit("shoot", false)
			return
	_can_shoot = false
	_cooldown_timer = 0.0
	
	var player: Node = context.get("player")
	var camera := _get_camera(player)
	if not is_instance_valid(camera):
		EventBus.action_completed.emit("shoot", false)
		return
	
	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	EventBus.shot_fired.emit(player, origin, direction)
	EventBus.play_sound_3d.emit("res://assets/audio/sfx/weapons/gunshot.ogg", origin, 0.0)

	if use_hitscan:
		_hitscan(player, camera, origin, direction)
	else:
		_spawn_projectile(origin, direction)
	
	EventBus.action_completed.emit("shoot", true)

func _hitscan(player: Node, _camera: Camera3D, from: Vector3, direction: Vector3) -> void:
	var to := from + direction * hitscan_range
	var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to, shoot_layer)
	query.exclude = [player]
	var result: Dictionary = space.intersect_ray(query)
	if result and result.collider:
		EventBus.damage_dealt.emit(result.collider, hitscan_damage, "bullet", player)

func _spawn_projectile(origin: Vector3, direction: Vector3) -> void:
	if not projectile_scene:
		return
	var proj: Node = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = origin
	if proj.has_method("launch"):
		proj.launch(direction)

func _get_camera(player: Node) -> Camera3D:
	if not is_instance_valid(player):
		return null
	for child in player.get_children():
		if child is Camera3D:
			return child
		for gc in child.get_children():
			if gc is Camera3D:
				return gc
	return null
