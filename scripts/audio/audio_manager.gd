class_name AudioManager
extends Node

const POOL_SIZE_2D := 8
const POOL_SIZE_3D := 16

var _pool_2d: Array[AudioStreamPlayer] = []
var _pool_3d: Array[AudioStreamPlayer3D] = []

func _ready() -> void:
	_build_pool()
	EventBus.play_sound_2d.connect(_on_play_2d)
	EventBus.play_sound_3d.connect(_on_play_3d)
	EventBus.play_footstep.connect(_on_play_footstep)

func _build_pool() -> void:
	for i in range(POOL_SIZE_2D):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool_2d.append(p)
	for i in range(POOL_SIZE_3D):
		var p := AudioStreamPlayer3D.new()
		add_child(p)
		_pool_3d.append(p)

func _on_play_2d(sound_path: String, volume_db: float) -> void:
	if sound_path.is_empty():
		return
	var player := _get_free_2d()
	if not player:
		return
	var stream := load(sound_path) as AudioStream
	if not stream:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func _on_play_3d(sound_path: String, position: Vector3, volume_db: float) -> void:
	if sound_path.is_empty():
		return
	var player := _get_free_3d()
	if not player:
		return
	var stream := load(sound_path) as AudioStream
	if not stream:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.global_position = position
	player.play()

func _on_play_footstep(surface_type: String, position: Vector3) -> void:
	var path := "res://assets/audio/sfx/footsteps/%s_step.ogg" % surface_type
	_on_play_3d(path, position, -5.0)

func _get_free_2d() -> AudioStreamPlayer:
	for p in _pool_2d:
		if not p.playing:
			return p
	return _pool_2d[0]  # Steal oldest

func _get_free_3d() -> AudioStreamPlayer3D:
	for p in _pool_3d:
		if not p.playing:
			return p
	return _pool_3d[0]
