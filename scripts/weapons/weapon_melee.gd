class_name WeaponMelee
extends WeaponBase

## Melee weapon — uses attack range and damage from weapon_data.
## Overrides are applied through the ActionAttack system.

@export var swing_speed: float = 1.0
@export var combo_enabled: bool = false
@export var combo_window: float = 0.8

var _combo_count: int = 0
var _combo_timer: float = 0.0

func _process(delta: float) -> void:
	if _combo_count > 0:
		_combo_timer += delta
		if _combo_timer >= combo_window:
			_combo_count = 0
			_combo_timer = 0.0

func get_combo_multiplier() -> float:
	if not combo_enabled:
		return 1.0
	return 1.0 + (_combo_count * 0.25)

func register_hit() -> void:
	if combo_enabled:
		_combo_count = mini(_combo_count + 1, 3)
		_combo_timer = 0.0
