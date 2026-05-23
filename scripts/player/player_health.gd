class_name PlayerHealth
extends Node

@export var max_health: float = 100.0
@export var regen_enabled: bool = false
@export var regen_delay: float = 5.0
@export var regen_rate: float = 2.0

var current_health: float = max_health
var _is_dead: bool = false
var _regen_timer: float = 0.0
var _can_regen: bool = false

func _ready() -> void:
	add_to_group("player_health")
	current_health = max_health
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.player_healed.connect(_on_healed)

func _process(delta: float) -> void:
	if regen_enabled and not _is_dead:
		_handle_regen(delta)

func _handle_regen(delta: float) -> void:
	if current_health >= max_health:
		_regen_timer = 0.0
		_can_regen = false
		return
	if not _can_regen:
		_regen_timer += delta
		if _regen_timer >= regen_delay:
			_can_regen = true
	else:
		heal(regen_rate * delta)

func _on_damage_dealt(target: Node, amount: float, _damage_type: String, _source: Node) -> void:
	if target != owner:
		return
	take_damage(amount)

func take_damage(amount: float) -> void:
	if _is_dead:
		return
	current_health = maxf(0.0, current_health - amount)
	_regen_timer = 0.0
	_can_regen = false
	EventBus.player_health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		_die()

func heal(amount: float) -> void:
	if _is_dead:
		return
	current_health = minf(max_health, current_health + amount)
	EventBus.player_health_changed.emit(current_health, max_health)

func _on_healed(amount: float) -> void:
	heal(amount)

func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	EventBus.player_died.emit()

func get_health_ratio() -> float:
	return current_health / max_health

func is_dead() -> bool:
	return _is_dead

func get_save_data() -> Dictionary:
	return {"current_health": current_health, "max_health": max_health}

func apply_save_data(data: Dictionary) -> void:
	current_health = data.get("current_health", max_health)
	max_health = data.get("max_health", max_health)
	EventBus.player_health_changed.emit(current_health, max_health)
