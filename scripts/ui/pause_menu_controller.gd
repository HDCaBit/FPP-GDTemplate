class_name PauseMenuController
extends CanvasLayer

func _ready() -> void:
	visible = false
	EventBus.pause_toggled.connect(_on_pause_toggled)

func _on_pause_toggled(is_paused: bool) -> void:
	visible = is_paused

func _on_resume_pressed() -> void:
	EventBus.pause_toggled.emit(false)

func _on_main_menu_pressed() -> void:
	EventBus.pause_toggled.emit(false)
	GameManager.go_to_main_menu()

func _on_quit_pressed() -> void:
	get_tree().quit()
