class_name HudController
extends CanvasLayer

# Node references — all nullable
@onready var health_bar: ProgressBar = get_node_or_null("HUD/HealthBar")
@onready var stamina_bar: ProgressBar = get_node_or_null("HUD/StaminaBar")
@onready var crosshair: TextureRect = get_node_or_null("HUD/Crosshair")
@onready var interaction_prompt: Label = get_node_or_null("HUD/InteractionPrompt")
@onready var ammo_label: Label = get_node_or_null("HUD/AmmoLabel")
@onready var message_label: Label = get_node_or_null("HUD/MessageLabel")
@onready var hotbar_container: HBoxContainer = get_node_or_null("HUD/Hotbar")

var _message_timer: float = 0.0

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_stamina_changed.connect(_on_stamina_changed)
	EventBus.interactable_focused.connect(_on_interactable_focused)
	EventBus.interactable_cleared.connect(_on_interactable_cleared)
	EventBus.interaction_prompt_show.connect(_on_prompt_show)
	EventBus.interaction_prompt_hide.connect(_on_prompt_hide)
	EventBus.ammo_changed.connect(_on_ammo_changed)
	EventBus.hud_message_show.connect(_on_message_show)
	EventBus.crosshair_changed.connect(_on_crosshair_changed)
	
	if interaction_prompt:
		interaction_prompt.visible = false
	if message_label:
		message_label.visible = false

func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0 and message_label:
			message_label.visible = false

func _on_health_changed(current: float, maximum: float) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func _on_stamina_changed(current: float, maximum: float) -> void:
	if stamina_bar:
		stamina_bar.max_value = maximum
		stamina_bar.value = current

func _on_interactable_focused(_target: Node) -> void:
	if crosshair:
		crosshair.modulate = Color.YELLOW

func _on_interactable_cleared() -> void:
	if crosshair:
		crosshair.modulate = Color.WHITE

func _on_prompt_show(text: String) -> void:
	if interaction_prompt:
		interaction_prompt.text = text
		interaction_prompt.visible = true

func _on_prompt_hide() -> void:
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_ammo_changed(current: int, reserve: int) -> void:
	if ammo_label:
		ammo_label.text = "%d / %d" % [current, reserve]

func _on_message_show(message: String, duration: float) -> void:
	if message_label:
		message_label.text = message
		message_label.visible = true
		_message_timer = duration

func _on_crosshair_changed(_type: String) -> void:
	pass  # Swap crosshair texture based on type
