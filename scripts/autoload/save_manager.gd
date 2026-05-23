extends Node

const SAVE_PATH := "user://save.json"

var save_data: Dictionary = {}

func _ready() -> void:
	EventBus.save_requested.connect(save_game)
	EventBus.load_requested.connect(load_game)

func save_game() -> void:
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["scene"] = GameManager.current_scene_path
	# Other systems write to save_data via EventBus before this is called
	var json_string := JSON.stringify(save_data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		return false
	save_data = parsed
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	save_data = {}

func write(key: String, value: Variant) -> void:
	save_data[key] = value

func read(key: String, default: Variant = null) -> Variant:
	return save_data.get(key, default)
