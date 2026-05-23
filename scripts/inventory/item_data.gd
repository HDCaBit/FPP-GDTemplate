class_name ItemData
extends Resource

enum ItemType { MISC, WEAPON_MELEE, WEAPON_RANGED, CONSUMABLE, THROWABLE, KEY_ITEM }

@export var item_id: String = ""
@export var item_name: String = "Unknown Item"
@export var description: String = ""
@export var item_type: ItemType = ItemType.MISC
@export var icon: Texture2D = null
@export var world_scene: PackedScene = null
@export var max_stack_size: int = 1
@export var weight: float = 1.0
@export var is_droppable: bool = true
@export var is_throwable: bool = false
@export var is_equippable: bool = false

# Weapon-specific (only used if type is weapon)
@export var damage: float = 0.0
@export var attack_speed: float = 1.0
@export var range_override: float = 0.0
@export var max_ammo: int = 0
@export var ammo_per_reload: int = 0

# Consumable-specific
@export var heal_amount: float = 0.0
@export var stamina_restore: float = 0.0
