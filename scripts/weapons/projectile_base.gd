class_name ProjectileBase
extends RigidBody3D

@export var speed: float = 50.0
@export var damage: float = 30.0
@export var lifetime: float = 5.0
@export var damage_type: String = "bullet"

var _shooter: Node = null
var _launched: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func launch(direction: Vector3, shooter: Node = null) -> void:
	_shooter = shooter
	_launched = true
	linear_velocity = direction.normalized() * speed

func _on_body_entered(body: Node) -> void:
	if not _launched:
		return
	if is_instance_valid(_shooter) and body == _shooter:
		return
	EventBus.damage_dealt.emit(body, damage, damage_type, _shooter)
	queue_free()
