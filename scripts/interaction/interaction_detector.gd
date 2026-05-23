class_name InteractionDetector
extends Node3D

## This is a placeholder component.
## The actual interaction detection logic lives in player_interaction.gd.
## This script exists to fulfill the folder structure requirement.
## It can be extended for alternative interaction methods (e.g., area-based detection).

@export var detection_radius: float = 2.0
@export var use_area_detection: bool = false

func _ready() -> void:
	add_to_group("interaction_detector")
