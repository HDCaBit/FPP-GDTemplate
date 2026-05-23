class_name ActionAttack
extends Node

@export var attack_range: float = 2.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.5
@export var attack_layer: int = 0b1001  # world + enemies

var _cooldown_timer: float = 0.0
var _can_attack: bool = true

func _process(delta: float) -> void:
	if not _can_attack:
		_cooldown_timer += delta
		if _cooldown_timer >= attack_cooldown:
			_can_attack = true
			_cooldown_timer = 0.0

func execute(context: Dictionary) -> void:
	if not _can_attack:
		return
	_can_attack = false
	_cooldown_timer = 0.0
	
	var player: Node = context.get("player")
	var held_item: Node = context.get("held_item")
	
	# Use weapon data if item has override values
	var damage := attack_damage
	var range_val := attack_range
	if is_instance_valid(held_item) and held_item.has_method("get_weapon_data"):
		var wd = held_item.get_weapon_data()
		if wd and wd.get("damage"):
			damage = wd.damage
	
	# Raycast for hit detection
	var camera := _get_camera(player)
	if not is_instance_valid(camera):
		EventBus.action_completed.emit("attack", false)
		return
	
	var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	var from := camera.global_position
	var to := from - camera.global_transform.basis.z * range_val
	var query := PhysicsRayQueryParameters3D.create(from, to, attack_layer)
	query.exclude = [player]
	var result: Dictionary = space.intersect_ray(query)
	
	var hit_targets: Array = []
	if result and result.collider:
		hit_targets.append(result.collider)
		EventBus.damage_dealt.emit(result.collider, damage, "melee", player)
	
	EventBus.attack_performed.emit(player, hit_targets)
	EventBus.action_completed.emit("attack", true)
	EventBus.play_sound_3d.emit("res://assets/audio/sfx/weapons/melee_swing.ogg", player.global_position, 0.0)

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
