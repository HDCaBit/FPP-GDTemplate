class_name WeaponBase
extends Node3D

@export var weapon_data: ItemData = null

var current_ammo: int = 0
var _is_reloading: bool = false

func _ready() -> void:
	if weapon_data:
		current_ammo = weapon_data.max_ammo

func get_weapon_data() -> ItemData:
	return weapon_data

func consume_ammo() -> bool:
	if weapon_data == null or weapon_data.max_ammo <= 0:
		return true  # Infinite ammo weapon
	if current_ammo <= 0:
		return false
	current_ammo -= 1
	EventBus.ammo_changed.emit(current_ammo, weapon_data.max_ammo)
	return true

func reload() -> void:
	if _is_reloading or weapon_data == null:
		return
	_is_reloading = true
	# Use a timer instead of await so it's cancellable
	var timer := get_tree().create_timer(1.5)
	timer.timeout.connect(_finish_reload)

func _finish_reload() -> void:
	if weapon_data:
		current_ammo = weapon_data.max_ammo
		EventBus.ammo_changed.emit(current_ammo, weapon_data.max_ammo)
		EventBus.weapon_reloaded.emit(weapon_data)
	_is_reloading = false
