extends Node3D

@export var player_scene: PackedScene = preload("res://scenes/player/player.tscn")
@export var spawn_point_group: String = "spawn_point"

func _ready() -> void:
	_spawn_player()

func _spawn_player() -> void:
	if not player_scene:
		push_error("World: player_scene not set!")
		return
	var spawn := _find_spawn_point()
	var player := player_scene.instantiate()
	add_child(player)
	if spawn:
		player.global_position = spawn.global_position
		player.global_rotation = spawn.global_rotation

func _find_spawn_point() -> Node3D:
	var points := get_tree().get_nodes_in_group(spawn_point_group)
	if points.is_empty():
		return null
	return points[0] as Node3D
