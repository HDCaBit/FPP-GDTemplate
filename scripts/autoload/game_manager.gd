extends Node

enum GameState { MAIN_MENU, LOADING, PLAYING, PAUSED, DEAD, CUTSCENE }

var current_state: GameState = GameState.MAIN_MENU
var current_scene_path: String = ""
var is_paused: bool = false

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.pause_toggled.connect(_on_pause_toggled)

func change_scene(path: String) -> void:
	current_scene_path = path
	_set_state(GameState.LOADING)
	get_tree().change_scene_to_file(path)
	_set_state(GameState.PLAYING)
	EventBus.scene_changed.emit(path)

func _set_state(state: GameState) -> void:
	current_state = state
	EventBus.game_state_changed.emit(GameState.keys()[state])

func _on_pause_toggled(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	InputManager.set_mouse_captured(!paused)
	if paused:
		_set_state(GameState.PAUSED)
	else:
		_set_state(GameState.PLAYING)

func _on_player_died() -> void:
	_set_state(GameState.DEAD)

func restart_current_scene() -> void:
	change_scene(current_scene_path)

func go_to_main_menu() -> void:
	change_scene("res://scenes/ui/main_menu.tscn")
	_set_state(GameState.MAIN_MENU)
