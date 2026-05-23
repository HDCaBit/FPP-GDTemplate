class_name Constants

# Physics Layers (as bitmasks)
const LAYER_WORLD        := 1       # 0b000001
const LAYER_PLAYER       := 2       # 0b000010
const LAYER_ITEMS        := 4       # 0b000100
const LAYER_ENEMIES      := 8       # 0b001000
const LAYER_PROJECTILES  := 16      # 0b010000
const LAYER_INTERACTABLE := 32      # 0b100000

# Node Groups
const GROUP_PLAYER       := "player"
const GROUP_ENEMY        := "enemy"
const GROUP_INTERACTABLE := "interactable"
const GROUP_COLLECTIBLE  := "collectible"
const GROUP_GRABBABLE    := "grabbable"
const GROUP_WORLD_ITEM   := "world_item"
const GROUP_SURFACE_WOOD   := "surface_wood"
const GROUP_SURFACE_METAL  := "surface_metal"
const GROUP_SURFACE_GRASS  := "surface_grass"
const GROUP_SURFACE_GRAVEL := "surface_gravel"

# Damage Types
const DAMAGE_MELEE   := "melee"
const DAMAGE_BULLET  := "bullet"
const DAMAGE_EXPLOSION := "explosion"
const DAMAGE_FALL    := "fall"

# Action Names
const ACTION_ATTACK  := "attack"
const ACTION_SHOOT   := "shoot"
const ACTION_THROW   := "throw"
const ACTION_DROP    := "drop"
const ACTION_GRAB    := "grab"
const ACTION_COLLECT := "collect"
