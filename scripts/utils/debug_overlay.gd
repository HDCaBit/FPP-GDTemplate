class_name DebugOverlay
extends CanvasLayer

@onready var label: Label = get_node_or_null("DebugLabel")

var _visible: bool = false
var _player: CharacterBody3D = null

func _ready() -> void:
	layer = 100
	visible = false
	InputManager.debug_toggled.connect(_toggle)
	EventBus.player_spawned.connect(_on_player_spawned)

func _on_player_spawned(player_node: Node) -> void:
	_player = player_node as CharacterBody3D

func _toggle() -> void:
	_visible = !_visible
	visible = _visible

func _process(_delta: float) -> void:
	if not _visible or not label:
		return
	var lines: Array[String] = []
	lines.append("FPS: %d" % Engine.get_frames_per_second())
	if is_instance_valid(_player):
		lines.append("Position: %s" % str(_player.global_position.snapped(Vector3.ONE * 0.01)))
		lines.append("Velocity: %.2f" % Vector2(_player.velocity.x, _player.velocity.z).length())
	lines.append("GameState: %s" % GameManager.GameState.keys()[GameManager.current_state])
	label.text = "\n".join(lines)
