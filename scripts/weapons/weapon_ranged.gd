class_name WeaponRanged
extends WeaponBase

## Ranged weapon — extends WeaponBase with ranged-specific features.

@export var use_hitscan: bool = true
@export var projectile_scene: PackedScene = null
@export var muzzle_offset: Vector3 = Vector3(0.0, 0.0, -0.5)
@export var recoil_amount: float = 0.1
@export var spread_angle: float = 0.0  # Degrees of inaccuracy

var _current_spread: float = 0.0

func fire() -> Dictionary:
	if not consume_ammo():
		return {"success": false, "reason": "no_ammo"}
	
	_current_spread = minf(_current_spread + spread_angle * 0.1, spread_angle)
	
	if weapon_data:
		EventBus.weapon_fired.emit(weapon_data, current_ammo)
	
	return {"success": true, "use_hitscan": use_hitscan, "spread": _current_spread}

func _process(delta: float) -> void:
	# Spread recovery
	_current_spread = maxf(0.0, _current_spread - spread_angle * delta * 2.0)

func get_muzzle_position() -> Vector3:
	return global_position + global_transform.basis * muzzle_offset
