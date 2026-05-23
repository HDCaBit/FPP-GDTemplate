class_name PlayerStamina
extends Node

@export var max_stamina: float = 100.0
@export var sprint_drain_rate: float = 20.0
@export var recovery_rate: float = 15.0
@export var recovery_delay: float = 1.5
@export var minimum_to_sprint: float = 10.0

var current_stamina: float = max_stamina
var _draining: bool = false
var _recovery_timer: float = 0.0
var _depleted: bool = false

func _ready() -> void:
	add_to_group("player_stamina")
	current_stamina = max_stamina
	EventBus.player_started_sprinting.connect(_on_sprint_start)
	EventBus.player_stopped_sprinting.connect(_on_sprint_stop)

func _process(delta: float) -> void:
	if _draining:
		_drain(delta)
	else:
		_recover(delta)

func _drain(delta: float) -> void:
	current_stamina = maxf(0.0, current_stamina - sprint_drain_rate * delta)
	_recovery_timer = 0.0
	EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
	if current_stamina <= 0.0 and not _depleted:
		_depleted = true
		EventBus.player_stamina_depleted.emit()

func _recover(delta: float) -> void:
	if current_stamina >= max_stamina:
		return
	_recovery_timer += delta
	if _recovery_timer < recovery_delay:
		return
	current_stamina = minf(max_stamina, current_stamina + recovery_rate * delta)
	EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
	if _depleted and current_stamina >= minimum_to_sprint:
		_depleted = false
		EventBus.player_stamina_recovered.emit()

func _on_sprint_start() -> void:
	if has_stamina():
		_draining = true

func _on_sprint_stop() -> void:
	_draining = false

func has_stamina() -> bool:
	return current_stamina >= minimum_to_sprint and not _depleted

func consume_stamina(amount: float) -> bool:
	if current_stamina < amount:
		return false
	current_stamina -= amount
	EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
	return true
