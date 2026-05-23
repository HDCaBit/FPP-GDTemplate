# MASTER PROMPT: Godot 4.6.x — First-Person Perspective Game Template (Fully Modular GDScript)

---

## ROLE & OBJECTIVE

You are an expert Godot 4.6 game developer. Your task is to build a **complete, production-ready, first-person game template** using **GDScript** that is **100% modular and fully decoupled**. Every feature must function independently — if a script file is missing or a node is absent, the rest of the project must **not break or throw errors**. All inter-system communication is done exclusively through signals via a central **EventBus**. Do not use direct node references across systems unless they are null-checked.

This template targets **Godot 4.6.x** — all syntax, APIs, and node types must be compatible with that version. Do not use deprecated APIs.

---

## CORE ARCHITECTURE PRINCIPLES (NON-NEGOTIABLE)

1. **EventBus Pattern**: All cross-system communication uses a singleton `EventBus` autoload. Systems emit signals into the bus and listen to signals from it. Systems never hold direct references to each other.
2. **Null-Safe Component Access**: Every time a component or node is accessed, it must be wrapped in `if node_ref != null` or use `is_instance_valid()`. Missing components must be silently ignored, never crash.
3. **No Circular Dependencies**: Scripts never import or depend on each other cyclically.
4. **Component-Based Player**: The player is a root node with child component nodes. Each component is a self-contained script. Removing a child component node from the scene must not break the others.
5. **Resource-Driven Data**: All item, weapon, and gameplay data are defined as `Resource` subclasses (`.tres` files), not hardcoded in scripts.
6. **Autoload-Only Singletons**: Only `GameManager`, `EventBus`, `InputManager`, and `SaveManager` are autoloads. Everything else is instanced normally.
7. **Future Multiplayer-Friendly**: Avoid `Input.get_singleton()` patterns that break with multiplayer. Use `InputManager` autoload as a wrapper. Keep player logic inside the player node (not in globals). Structure player so it could later become a `MultiplayerSynchronizer` target.
8. **Action System is Modular**: Every player action (attack, shoot, throw, drop, grab, collect) is a separate script/component. Removing an action script must not break other actions.

---

## FOLDER TREE (COMPLETE)

Create this exact folder structure inside the Godot project `res://`:

```
res://
│
├── project.godot                         ← Godot project file (configure autoloads here)
│
├── assets/
│   ├── audio/
│   │   ├── ambient/                      ← Looping ambient sounds (.ogg)
│   │   ├── music/                        ← Background music tracks (.ogg)
│   │   └── sfx/
│   │       ├── footsteps/                ← Per-surface footstep sounds
│   │       ├── player/                   ← Hurt, death, breath sounds
│   │       ├── weapons/                  ← Fire, reload, melee sounds
│   │       └── items/                    ← Pick up, drop, throw sounds
│   │
│   ├── animations/
│   │   ├── player/                       ← Player hand/body animations (.anim)
│   │   └── items/                        ← Item-specific animations
│   │
│   ├── fonts/
│   │   └── default_font.ttf              ← UI font
│   │
│   ├── materials/
│   │   ├── environment/                  ← World surface materials
│   │   ├── items/                        ← Item materials
│   │   └── weapons/                      ← Weapon materials
│   │
│   ├── meshes/
│   │   ├── environment/                  ← Static world meshes (.glb / .obj)
│   │   ├── items/                        ← Item meshes
│   │   └── weapons/                      ← Weapon meshes
│   │
│   └── textures/
│       ├── environment/
│       ├── items/
│       ├── ui/                           ← UI icons, crosshairs, HUD elements
│       └── weapons/
│
├── resources/
│   ├── items/                            ← ItemData .tres resource files
│   │   └── example_item.tres
│   └── weapons/                          ← WeaponData .tres resource files
│       └── example_weapon.tres
│
├── scenes/
│   ├── autoload/
│   │   ├── game_manager.tscn             ← GameManager scene (Node)
│   │   ├── event_bus.tscn                ← EventBus scene (Node)
│   │   ├── input_manager.tscn            ← InputManager scene (Node)
│   │   └── save_manager.tscn             ← SaveManager scene (Node)
│   │
│   ├── core/
│   │   └── world.tscn                    ← Root world scene (loads level + player)
│   │
│   ├── player/
│   │   ├── player.tscn                   ← Main player scene (CharacterBody3D root)
│   │   ├── camera_rig.tscn               ← Camera + bob system (Node3D)
│   │   └── hand_rig.tscn                 ← Item/weapon hand display (Node3D)
│   │
│   ├── items/
│   │   ├── base_item.tscn                ← Base world item scene (RigidBody3D)
│   │   ├── pickup_item.tscn              ← Collectible item (inherits base_item)
│   │   ├── throwable_item.tscn           ← Throwable item (inherits base_item)
│   │   └── grabbable_item.tscn           ← Grab-to-hand item (inherits base_item)
│   │
│   ├── weapons/
│   │   ├── weapon_base.tscn              ← Base weapon scene
│   │   ├── weapon_melee.tscn             ← Melee weapon (inherits weapon_base)
│   │   └── weapon_ranged.tscn            ← Ranged weapon (inherits weapon_base)
│   │
│   ├── projectiles/
│   │   └── projectile_base.tscn          ← Base projectile (RigidBody3D or Area3D)
│   │
│   ├── ui/
│   │   ├── hud.tscn                      ← In-game HUD overlay
│   │   ├── inventory_ui.tscn             ← Inventory screen
│   │   ├── pause_menu.tscn               ← Pause overlay
│   │   └── main_menu.tscn                ← Main menu scene
│   │
│   └── world/
│       ├── test_level.tscn               ← Test/sandbox level scene
│       └── sky_environment.tscn          ← WorldEnvironment + DirectionalLight3D
│
└── scripts/
    ├── autoload/
    │   ├── event_bus.gd                  ← Central signal hub
    │   ├── game_manager.gd               ← Game state machine, scene switching
    │   ├── input_manager.gd              ← Input abstraction layer
    │   └── save_manager.gd               ← Save/load game data
    │
    ├── core/
    │   ├── state_machine.gd              ← Reusable generic state machine
    │   └── base_state.gd                 ← Base class for all states
    │
    ├── player/
    │   ├── player_controller.gd          ← Player root orchestrator (null-safe)
    │   ├── player_movement.gd            ← Walk, run, jump, crouch, slide
    │   ├── player_camera.gd              ← Mouse look, FOV, head bob, effects
    │   ├── player_health.gd              ← HP, damage reception, death, regen
    │   ├── player_stamina.gd             ← Stamina for sprint/actions
    │   └── player_interaction.gd         ← Raycast-based world interaction
    │
    ├── actions/
    │   ├── action_handler.gd             ← Routes and validates all action requests
    │   ├── action_attack.gd              ← Melee attack execution
    │   ├── action_shoot.gd               ← Ranged shoot execution
    │   ├── action_throw.gd               ← Throw held item
    │   ├── action_drop.gd                ← Drop held item to world
    │   ├── action_grab.gd                ← Grab world item into hand
    │   └── action_collect.gd             ← Collect world item into inventory
    │
    ├── inventory/
    │   ├── inventory_system.gd           ← Core inventory logic (add/remove/query)
    │   ├── item_data.gd                  ← Resource: item definition
    │   └── item_slot.gd                  ← Resource: single inventory slot state
    │
    ├── weapons/
    │   ├── weapon_base.gd                ← Abstract weapon base (do not instance directly)
    │   ├── weapon_melee.gd               ← Melee weapon logic
    │   ├── weapon_ranged.gd              ← Ranged weapon logic + ammo
    │   └── projectile_base.gd            ← Projectile behavior
    │
    ├── items/
    │   ├── base_item.gd                  ← Base world item behavior
    │   ├── pickup_item.gd                ← Auto-collect or interact-to-collect
    │   ├── throwable_item.gd             ← Thrown physics behavior
    │   └── grabbable_item.gd             ← Grab-to-hand physics behavior
    │
    ├── interaction/
    │   ├── interactable.gd               ← Component: makes any node interactable
    │   └── interaction_detector.gd       ← Raycast scanner (child of camera)
    │
    ├── audio/
    │   ├── audio_manager.gd              ← Pooled 3D/2D audio playback
    │   └── footstep_system.gd            ← Surface-detection footstep player
    │
    ├── ui/
    │   ├── hud_controller.gd             ← Listens to EventBus, updates HUD nodes
    │   ├── inventory_ui_controller.gd    ← Inventory screen logic
    │   └── pause_menu_controller.gd      ← Pause/resume, settings link
    │
    └── utils/
        ├── constants.gd                  ← Global constants (groups, layers, tags)
        ├── debug_overlay.gd              ← In-game debug info (F3 toggle)
        └── math_utils.gd                 ← Reusable math helpers
```

---

## AUTOLOAD CONFIGURATION (project.godot)

Register these autoloads in **Project → Project Settings → Autoload** in this exact order:

| Name            | Path                              |
|-----------------|-----------------------------------|
| `EventBus`      | `res://scripts/autoload/event_bus.gd`      |
| `InputManager`  | `res://scripts/autoload/input_manager.gd`  |
| `GameManager`   | `res://scripts/autoload/game_manager.gd`   |
| `SaveManager`   | `res://scripts/autoload/save_manager.gd`   |

Also configure in project.godot:
- `application/run/main_scene` = `res://scenes/ui/main_menu.tscn`
- Physics layer names (in Project Settings → Layer Names → 3D Physics):
  - Layer 1: `world`
  - Layer 2: `player`
  - Layer 3: `items`
  - Layer 4: `enemies`
  - Layer 5: `projectiles`
  - Layer 6: `interactables`

---

## INPUT MAP (project.godot)

Define these input actions in **Project → Project Settings → Input Map**:

| Action Name         | Default Key/Button         |
|---------------------|----------------------------|
| `move_forward`      | W                          |
| `move_backward`     | S                          |
| `move_left`         | A                          |
| `move_right`        | D                          |
| `jump`              | Space                      |
| `sprint`            | Left Shift                 |
| `crouch`            | Left Ctrl                  |
| `interact`          | E                          |
| `attack`            | Mouse Button Left          |
| `attack_alt`        | Mouse Button Right         |
| `shoot`             | Mouse Button Left          |
| `throw_item`        | G                          |
| `drop_item`         | Q                          |
| `grab_item`         | F                          |
| `collect_item`      | E                          |
| `reload`            | R                          |
| `inventory_toggle`  | Tab                        |
| `pause`             | Escape                     |
| `debug_toggle`      | F3                         |
| `hotbar_1`          | 1                          |
| `hotbar_2`          | 2                          |
| `hotbar_3`          | 3                          |
| `hotbar_4`          | 4                          |
| `hotbar_5`          | 5                          |

---

## PIPELINE EXPLANATION

This section describes exactly how data and events flow through the system at runtime.

### Boot Pipeline
```
Godot launches
  → Autoloads init in order:
      1. EventBus      (signal hub ready, no dependencies)
      2. InputManager  (reads Input Map, wraps input actions)
      3. GameManager   (sets initial state = MAIN_MENU)
      4. SaveManager   (loads save file if exists)
  → main_menu.tscn loads
  → User presses "New Game" or "Continue"
  → GameManager.change_scene("res://scenes/world/test_level.tscn")
  → world.tscn instantiates:
      - sky_environment.tscn
      - test_level.tscn (the physical world)
      - player.tscn (spawned at SpawnPoint marker)
      - hud.tscn (added to CanvasLayer)
```

### Player Initialization Pipeline
```
player.tscn loads
  → player_controller.gd (_ready):
      - Finds child nodes by group or node name (null-safe)
      - Registers player with EventBus signal "player_spawned"
  → Each child component (_ready):
      - Connects to relevant EventBus signals
      - Performs self-initialization
      - Does NOT assume other components exist
```

### Input Pipeline
```
Per physics frame (_physics_process):
  InputManager polls Input singleton
    → Emits InputManager signals (not EventBus)
    → player_controller.gd listens to InputManager
    → Routes to child components:
        movement input  → player_movement.gd
        camera input    → player_camera.gd
        action input    → action_handler.gd

action_handler.gd receives action request:
  → Validates if action is currently possible
  → Emits EventBus.action_requested(action_name, context)
  → Specific action script listens and executes
  → Action result emitted back to EventBus
```

### Interaction Pipeline
```
interaction_detector.gd (every frame):
  → Casts ray from camera forward
  → If hits node in "interactable" group:
      → Emits EventBus.interactable_focused(target_node)
      → hud_controller updates crosshair/prompt
  → If ray clears:
      → Emits EventBus.interactable_cleared()

Player presses "interact" action:
  → action_handler dispatches to appropriate action:
      - Target has "grabbable" group  → action_grab.gd
      - Target has "collectible" group → action_collect.gd
      - Target has "interactable" group → interactable.gd.interact()
```

### Damage Pipeline
```
Any source deals damage to player:
  → Emits EventBus.damage_dealt(target_node, amount, damage_type, source)
  → player_health.gd listens:
      - If target_node == owner player → applies damage
      - Emits EventBus.player_health_changed(current_hp, max_hp)
      - If HP <= 0: emits EventBus.player_died()
  → hud_controller listens to player_health_changed → updates HP bar
  → GameManager listens to player_died → triggers death sequence
```

### Inventory Pipeline
```
action_collect.gd executes:
  → Gets ItemData resource from world item node
  → Emits EventBus.item_collected(item_data, quantity)
  → inventory_system.gd listens → adds to internal storage
  → Emits EventBus.inventory_updated(inventory_snapshot)
  → inventory_ui_controller listens → refreshes UI slots
  → World item node removes itself from scene
```

### Save Pipeline
```
SaveManager.save_game():
  → Emits EventBus.save_requested()
  → All saveable systems listen and return their data:
      inventory_system → provides item array
      player_health → provides current HP
      player_stamina → provides current stamina
      GameManager → provides current scene path
  → SaveManager collects all data into Dictionary
  → Serializes to JSON → writes to user://save.json
```

---

## SCRIPT SPECIFICATIONS

Each script below must be implemented exactly as described. Follow Godot 4.6 GDScript syntax strictly.

---

### `scripts/autoload/event_bus.gd`

**Type:** Autoload Singleton (Node)
**Purpose:** Central signal hub. Every system-to-system communication goes through here.

Declare ALL of the following signals. Do not add logic — this file is signals only.

```gdscript
# --- GAME STATE ---
signal game_state_changed(new_state: String)
signal scene_changed(scene_path: String)
signal pause_toggled(is_paused: bool)
signal save_requested()
signal load_requested()

# --- PLAYER LIFECYCLE ---
signal player_spawned(player_node: Node)
signal player_died()
signal player_respawned()

# --- HEALTH ---
signal damage_dealt(target: Node, amount: float, damage_type: String, source: Node)
signal player_health_changed(current: float, maximum: float)
signal player_healed(amount: float)

# --- STAMINA ---
signal player_stamina_changed(current: float, maximum: float)
signal player_stamina_depleted()
signal player_stamina_recovered()

# --- MOVEMENT ---
signal player_landed(velocity: Vector3)
signal player_jumped()
signal player_started_sprinting()
signal player_stopped_sprinting()
signal player_crouched(is_crouching: bool)

# --- INTERACTION ---
signal interactable_focused(target: Node)
signal interactable_cleared()
signal interact_pressed(target: Node)

# --- ACTIONS ---
signal action_requested(action_name: String, context: Dictionary)
signal action_completed(action_name: String, success: bool)
signal attack_performed(attacker: Node, hit_targets: Array)
signal shot_fired(shooter: Node, origin: Vector3, direction: Vector3)
signal item_thrown(item_node: Node, velocity: Vector3)
signal item_dropped(item_data: Resource, world_position: Vector3)
signal item_grabbed(item_node: Node)
signal item_collected(item_data: Resource, quantity: int)

# --- INVENTORY ---
signal inventory_updated(inventory_data: Array)
signal hotbar_updated(hotbar_data: Array)
signal item_equipped(item_data: Resource, slot_index: int)
signal item_unequipped(slot_index: int)
signal inventory_full()

# --- WEAPONS ---
signal weapon_switched(weapon_data: Resource)
signal weapon_fired(weapon_data: Resource, remaining_ammo: int)
signal weapon_reloaded(weapon_data: Resource)
signal ammo_changed(current: int, reserve: int)

# --- AUDIO ---
signal play_sound_2d(sound_path: String, volume_db: float)
signal play_sound_3d(sound_path: String, position: Vector3, volume_db: float)
signal play_footstep(surface_type: String, position: Vector3)

# --- UI ---
signal hud_message_show(message: String, duration: float)
signal crosshair_changed(crosshair_type: String)
signal interaction_prompt_show(prompt_text: String)
signal interaction_prompt_hide()
```

---

### `scripts/autoload/input_manager.gd`

**Type:** Autoload Singleton (Node)
**Purpose:** Abstracts all input. Emits its own signals. Other systems read from InputManager, not directly from `Input`.

```gdscript
extends Node

# Movement vectors (normalized)
var move_direction: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO

# State flags
var is_sprinting: bool = false
var is_crouching: bool = false
var is_jumping: bool = false

# Mouse sensitivity (configurable)
var mouse_sensitivity: float = 0.2
var invert_y: bool = false

# Signals for discrete actions (pressed once)
signal jump_pressed()
signal sprint_started()
signal sprint_stopped()
signal crouch_toggled()
signal interact_pressed()
signal attack_pressed()
signal attack_released()
signal attack_alt_pressed()
signal attack_alt_released()
signal shoot_pressed()
signal shoot_released()
signal throw_pressed()
signal drop_pressed()
signal grab_pressed()
signal collect_pressed()
signal reload_pressed()
signal inventory_toggled()
signal pause_pressed()
signal hotbar_pressed(slot_index: int)
signal debug_toggled()

func _ready() -> void:
    # Capture mouse on start — release handled by GameManager/PauseMenu
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
    # Mouse look delta — only when mouse is captured
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        var delta := event.relative
        if invert_y:
            delta.y = -delta.y
        look_delta = delta * mouse_sensitivity

    # Discrete action signals
    if event.is_action_pressed("jump"):         emit_signal("jump_pressed")
    if event.is_action_pressed("sprint"):       emit_signal("sprint_started"); is_sprinting = true
    if event.is_action_released("sprint"):      emit_signal("sprint_stopped"); is_sprinting = false
    if event.is_action_pressed("crouch"):       emit_signal("crouch_toggled"); is_crouching = !is_crouching
    if event.is_action_pressed("interact"):     emit_signal("interact_pressed")
    if event.is_action_pressed("attack"):       emit_signal("attack_pressed")
    if event.is_action_released("attack"):      emit_signal("attack_released")
    if event.is_action_pressed("attack_alt"):   emit_signal("attack_alt_pressed")
    if event.is_action_released("attack_alt"):  emit_signal("attack_alt_released")
    if event.is_action_pressed("shoot"):        emit_signal("shoot_pressed")
    if event.is_action_released("shoot"):       emit_signal("shoot_released")
    if event.is_action_pressed("throw_item"):   emit_signal("throw_pressed")
    if event.is_action_pressed("drop_item"):    emit_signal("drop_pressed")
    if event.is_action_pressed("grab_item"):    emit_signal("grab_pressed")
    if event.is_action_pressed("collect_item"): emit_signal("collect_pressed")
    if event.is_action_pressed("reload"):       emit_signal("reload_pressed")
    if event.is_action_pressed("inventory_toggle"): emit_signal("inventory_toggled")
    if event.is_action_pressed("pause"):        emit_signal("pause_pressed")
    if event.is_action_pressed("debug_toggle"): emit_signal("debug_toggled")

    # Hotbar slots 1-5
    for i in range(1, 6):
        if event.is_action_pressed("hotbar_%d" % i):
            emit_signal("hotbar_pressed", i - 1)

func _physics_process(_delta: float) -> void:
    # Continuous movement vector — updated every physics frame
    move_direction = Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
    ).normalized()
    
    # Reset look_delta each frame (it is set in _input)
    # (look_delta is read by player_camera each frame then reset)

func consume_look_delta() -> Vector2:
    # Call this from player_camera to get and clear the delta
    var d := look_delta
    look_delta = Vector2.ZERO
    return d

func set_mouse_captured(captured: bool) -> void:
    if captured:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
```

---

### `scripts/autoload/game_manager.gd`

**Type:** Autoload Singleton (Node)
**Purpose:** Manages game state and scene transitions.

```gdscript
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
```

---

### `scripts/autoload/save_manager.gd`

**Type:** Autoload Singleton (Node)
**Purpose:** Handles serialization and persistence of game data.

```gdscript
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
```

---

### `scripts/core/base_state.gd`

**Type:** Base Class (Node)
**Purpose:** Base for all state machine states.

```gdscript
class_name BaseState
extends Node

# Reference to the state machine owner (e.g., player_controller)
var owner_node: Node = null

func enter(_previous_state: String) -> void:
    pass

func exit(_next_state: String) -> void:
    pass

func update(_delta: float) -> void:
    pass

func physics_update(_delta: float) -> void:
    pass

func get_state_name() -> String:
    return name
```

---

### `scripts/core/state_machine.gd`

**Type:** Reusable Class (Node)
**Purpose:** Generic hierarchical state machine.

```gdscript
class_name StateMachine
extends Node

var current_state: BaseState = null
var previous_state_name: String = ""

signal state_changed(from_state: String, to_state: String)

func _ready() -> void:
    await owner.ready
    # Initialize with first child state if any
    for child in get_children():
        if child is BaseState:
            child.owner_node = owner
            current_state = child
            current_state.enter("")
            break

func transition_to(state_name: String) -> void:
    var new_state: BaseState = get_node_or_null(state_name)
    if new_state == null:
        push_warning("StateMachine: State '%s' not found." % state_name)
        return
    if new_state == current_state:
        return
    var from_name := ""
    if current_state:
        from_name = current_state.get_state_name()
        current_state.exit(state_name)
    previous_state_name = from_name
    current_state = new_state
    current_state.owner_node = owner
    current_state.enter(from_name)
    emit_signal("state_changed", from_name, state_name)

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)
```

---

### `scripts/player/player_controller.gd`

**Type:** CharacterBody3D root script
**Purpose:** Orchestrates all player components. Null-safe. Connects InputManager signals to components.

```gdscript
class_name PlayerController
extends CharacterBody3D

# Component references — all nullable
var movement: Node = null
var camera_rig: Node = null
var health: Node = null
var stamina: Node = null
var interaction: Node = null
var action_handler: Node = null
var inventory: Node = null

# Cached node paths — components should be in these groups
const GROUP_MOVEMENT    := "player_movement"
const GROUP_CAMERA      := "player_camera"
const GROUP_HEALTH      := "player_health"
const GROUP_STAMINA     := "player_stamina"
const GROUP_INTERACTION := "player_interaction"
const GROUP_ACTIONS     := "player_action_handler"
const GROUP_INVENTORY   := "player_inventory"

func _ready() -> void:
    add_to_group("player")
    _find_components()
    _connect_input_signals()
    EventBus.player_spawned.emit(self)

func _find_components() -> void:
    # Find components by group within this player's subtree
    movement     = _find_in_children(GROUP_MOVEMENT)
    camera_rig   = _find_in_children(GROUP_CAMERA)
    health       = _find_in_children(GROUP_HEALTH)
    stamina      = _find_in_children(GROUP_STAMINA)
    interaction  = _find_in_children(GROUP_INTERACTION)
    action_handler = _find_in_children(GROUP_ACTIONS)
    inventory    = _find_in_children(GROUP_INVENTORY)

func _find_in_children(group: String) -> Node:
    for child in get_children():
        if child.is_in_group(group):
            return child
        # Also search one level deeper
        for grandchild in child.get_children():
            if grandchild.is_in_group(group):
                return grandchild
    return null

func _connect_input_signals() -> void:
    # Connect input signals to components (each connection is null-checked)
    InputManager.interact_pressed.connect(_on_interact_pressed)
    InputManager.pause_pressed.connect(_on_pause_pressed)
    InputManager.inventory_toggled.connect(_on_inventory_toggled)
    InputManager.grab_pressed.connect(_on_grab_pressed)
    InputManager.collect_pressed.connect(_on_collect_pressed)
    InputManager.throw_pressed.connect(_on_throw_pressed)
    InputManager.drop_pressed.connect(_on_drop_pressed)
    InputManager.attack_pressed.connect(_on_attack_pressed)
    InputManager.shoot_pressed.connect(_on_shoot_pressed)
    InputManager.reload_pressed.connect(_on_reload_pressed)
    InputManager.hotbar_pressed.connect(_on_hotbar_pressed)

func _on_interact_pressed() -> void:
    if action_handler and action_handler.has_method("request_interact"):
        action_handler.request_interact()

func _on_grab_pressed() -> void:
    if action_handler and action_handler.has_method("request_grab"):
        action_handler.request_grab()

func _on_collect_pressed() -> void:
    if action_handler and action_handler.has_method("request_collect"):
        action_handler.request_collect()

func _on_throw_pressed() -> void:
    if action_handler and action_handler.has_method("request_throw"):
        action_handler.request_throw()

func _on_drop_pressed() -> void:
    if action_handler and action_handler.has_method("request_drop"):
        action_handler.request_drop()

func _on_attack_pressed() -> void:
    if action_handler and action_handler.has_method("request_attack"):
        action_handler.request_attack()

func _on_shoot_pressed() -> void:
    if action_handler and action_handler.has_method("request_shoot"):
        action_handler.request_shoot()

func _on_reload_pressed() -> void:
    if action_handler and action_handler.has_method("request_reload"):
        action_handler.request_reload()

func _on_hotbar_pressed(slot_index: int) -> void:
    if action_handler and action_handler.has_method("request_equip_slot"):
        action_handler.request_equip_slot(slot_index)

func _on_pause_pressed() -> void:
    var new_pause := !GameManager.is_paused
    EventBus.pause_toggled.emit(new_pause)

func _on_inventory_toggled() -> void:
    EventBus.action_requested.emit("toggle_inventory", {})

# Called by movement component when it needs the CharacterBody3D
func get_character_body() -> CharacterBody3D:
    return self
```

---

### `scripts/player/player_movement.gd`

**Type:** Node3D child of player
**Purpose:** All locomotion — walk, sprint, jump, crouch, slide. Reads from InputManager and player_stamina (null-safe). Moves the CharacterBody3D.

```gdscript
class_name PlayerMovement
extends Node3D

# Must be in this group for player_controller to find it
func _init() -> void:
    add_to_group("player_movement")

# Movement settings (exported for Inspector tuning)
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var crouch_speed: float = 2.5
@export var jump_velocity: float = 5.5
@export var gravity_multiplier: float = 2.0
@export var acceleration: float = 15.0
@export var deceleration: float = 20.0
@export var air_control: float = 0.3
@export var slide_speed: float = 12.0
@export var slide_duration: float = 0.6

# State
var _body: CharacterBody3D = null
var _stamina_node: Node = null
var _is_sprinting: bool = false
var _is_crouching: bool = false
var _is_sliding: bool = false
var _slide_timer: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    add_to_group("player_movement")
    await owner.ready
    _body = owner as CharacterBody3D
    # Find stamina sibling (null-safe)
    _stamina_node = _find_sibling_in_group("player_stamina")
    
    # Connect input signals
    InputManager.sprint_started.connect(_on_sprint_started)
    InputManager.sprint_stopped.connect(_on_sprint_stopped)
    InputManager.jump_pressed.connect(_on_jump_pressed)
    InputManager.crouch_toggled.connect(_on_crouch_toggled)

func _find_sibling_in_group(group: String) -> Node:
    if not is_instance_valid(owner):
        return null
    for child in owner.get_children():
        if child.is_in_group(group):
            return child
    return null

func _physics_process(delta: float) -> void:
    if not is_instance_valid(_body):
        return
    _apply_gravity(delta)
    _apply_slide(delta)
    _apply_movement(delta)
    _body.move_and_slide()

func _apply_gravity(delta: float) -> void:
    if not _body.is_on_floor():
        _body.velocity.y -= _gravity * gravity_multiplier * delta
    else:
        if _body.velocity.y < -5.0:
            EventBus.player_landed.emit(_body.velocity)
        if _body.velocity.y < 0.0:
            _body.velocity.y = 0.0

func _apply_movement(delta: float) -> void:
    var input_dir := InputManager.move_direction
    # Transform input relative to camera/player facing
    var basis := _body.global_transform.basis
    var direction := (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    var target_speed := _get_current_speed()
    var accel := acceleration if _body.is_on_floor() else acceleration * air_control
    var decel := deceleration if _body.is_on_floor() else deceleration * air_control

    if direction.length() > 0.0:
        _body.velocity.x = lerp(_body.velocity.x, direction.x * target_speed, accel * delta)
        _body.velocity.z = lerp(_body.velocity.z, direction.z * target_speed, accel * delta)
    else:
        _body.velocity.x = lerp(_body.velocity.x, 0.0, decel * delta)
        _body.velocity.z = lerp(_body.velocity.z, 0.0, decel * delta)

func _get_current_speed() -> float:
    if _is_sliding:
        return slide_speed
    if _is_crouching:
        return crouch_speed
    if _is_sprinting and _has_stamina():
        return sprint_speed
    return walk_speed

func _has_stamina() -> bool:
    if not is_instance_valid(_stamina_node):
        return true  # No stamina system = unlimited
    if _stamina_node.has_method("has_stamina"):
        return _stamina_node.has_stamina()
    return true

func _apply_slide(delta: float) -> void:
    if _is_sliding:
        _slide_timer -= delta
        if _slide_timer <= 0.0:
            _is_sliding = false

func _on_sprint_started() -> void:
    if _is_crouching and not _is_sliding:
        # Crouch + sprint = slide
        _is_sliding = true
        _slide_timer = slide_duration
        return
    _is_sprinting = true
    EventBus.player_started_sprinting.emit()

func _on_sprint_stopped() -> void:
    _is_sprinting = false
    EventBus.player_stopped_sprinting.emit()

func _on_jump_pressed() -> void:
    if not is_instance_valid(_body):
        return
    if _body.is_on_floor() and not _is_crouching:
        _body.velocity.y = jump_velocity
        EventBus.player_jumped.emit()

func _on_crouch_toggled() -> void:
    _is_crouching = !_is_crouching
    EventBus.player_crouched.emit(_is_crouching)
    # TODO: Adjust CollisionShape height when crouching

func is_moving() -> bool:
    if not is_instance_valid(_body):
        return false
    return Vector2(_body.velocity.x, _body.velocity.z).length() > 0.1

func get_velocity() -> Vector3:
    if not is_instance_valid(_body):
        return Vector3.ZERO
    return _body.velocity
```

---

### `scripts/player/player_camera.gd`

**Type:** Node3D child of player (wraps Camera3D)
**Purpose:** Mouse look, vertical clamping, head bob, FOV effects, tilt on strafe.

```gdscript
class_name PlayerCamera
extends Node3D

@export var camera_path: NodePath = NodePath("Camera3D")
@export var v_clamp_degrees: float = 85.0
@export var head_bob_enabled: bool = true
@export var head_bob_speed: float = 14.0
@export var head_bob_amplitude: float = 0.03
@export var fov_sprint_delta: float = 5.0
@export var fov_transition_speed: float = 8.0
@export var tilt_amount: float = 0.5

var _camera: Camera3D = null
var _default_fov: float = 75.0
var _bob_time: float = 0.0
var _movement: Node = null
var _target_fov: float = 75.0
# Rotation accumulators
var _pitch: float = 0.0  # Vertical (camera node X rotation)

func _ready() -> void:
    add_to_group("player_camera")
    _camera = get_node_or_null(camera_path)
    if _camera:
        _default_fov = _camera.fov
        _target_fov = _default_fov
    await owner.ready
    _movement = _find_sibling("player_movement")

    EventBus.player_started_sprinting.connect(_on_sprint_start)
    EventBus.player_stopped_sprinting.connect(_on_sprint_stop)
    EventBus.player_crouched.connect(_on_crouch)

func _find_sibling(group: String) -> Node:
    if not is_instance_valid(owner):
        return null
    for child in owner.get_children():
        if child.is_in_group(group):
            return child
    return null

func _process(delta: float) -> void:
    _apply_mouse_look()
    _apply_head_bob(delta)
    _apply_fov(delta)

func _apply_mouse_look() -> void:
    var delta := InputManager.consume_look_delta()
    if delta == Vector2.ZERO:
        return
    # Rotate player body horizontally (yaw)
    if is_instance_valid(owner):
        owner.rotate_y(deg_to_rad(-delta.x))
    # Rotate camera vertically (pitch) — clamped
    _pitch = clampf(_pitch - delta.y, -v_clamp_degrees, v_clamp_degrees)
    rotation_degrees.x = _pitch

func _apply_head_bob(delta: float) -> void:
    if not head_bob_enabled or not is_instance_valid(_camera):
        return
    var is_moving := false
    if is_instance_valid(_movement) and _movement.has_method("is_moving"):
        is_moving = _movement.is_moving()
    if is_moving and owner and (owner as CharacterBody3D).is_on_floor():
        _bob_time += delta * head_bob_speed
        _camera.position.y = lerp(_camera.position.y, sin(_bob_time) * head_bob_amplitude, delta * 10.0)
        _camera.position.x = lerp(_camera.position.x, cos(_bob_time * 0.5) * head_bob_amplitude * 0.5, delta * 10.0)
    else:
        _bob_time = 0.0
        _camera.position.y = lerp(_camera.position.y, 0.0, delta * 10.0)
        _camera.position.x = lerp(_camera.position.x, 0.0, delta * 10.0)

func _apply_fov(delta: float) -> void:
    if not is_instance_valid(_camera):
        return
    _camera.fov = lerp(_camera.fov, _target_fov, fov_transition_speed * delta)

func _on_sprint_start() -> void:
    _target_fov = _default_fov + fov_sprint_delta

func _on_sprint_stop() -> void:
    _target_fov = _default_fov

func _on_crouch(_crouching: bool) -> void:
    pass  # Optional: adjust camera height for crouch

func get_camera() -> Camera3D:
    return _camera

func get_forward_direction() -> Vector3:
    if not is_instance_valid(_camera):
        return Vector3.FORWARD
    return -_camera.global_transform.basis.z
```

---

### `scripts/player/player_health.gd`

**Type:** Node child of player
**Purpose:** Health points, damage, healing, death. Fully standalone.

```gdscript
class_name PlayerHealth
extends Node

@export var max_health: float = 100.0
@export var regen_enabled: bool = false
@export var regen_delay: float = 5.0
@export var regen_rate: float = 2.0

var current_health: float = max_health
var _is_dead: bool = false
var _regen_timer: float = 0.0
var _can_regen: bool = false

func _ready() -> void:
    add_to_group("player_health")
    current_health = max_health
    EventBus.damage_dealt.connect(_on_damage_dealt)
    EventBus.player_healed.connect(_on_healed)

func _process(delta: float) -> void:
    if regen_enabled and not _is_dead:
        _handle_regen(delta)

func _handle_regen(delta: float) -> void:
    if current_health >= max_health:
        _regen_timer = 0.0
        _can_regen = false
        return
    if not _can_regen:
        _regen_timer += delta
        if _regen_timer >= regen_delay:
            _can_regen = true
    else:
        heal(regen_rate * delta)

func _on_damage_dealt(target: Node, amount: float, _damage_type: String, _source: Node) -> void:
    if target != owner:
        return
    take_damage(amount)

func take_damage(amount: float) -> void:
    if _is_dead:
        return
    current_health = maxf(0.0, current_health - amount)
    _regen_timer = 0.0
    _can_regen = false
    EventBus.player_health_changed.emit(current_health, max_health)
    if current_health <= 0.0:
        _die()

func heal(amount: float) -> void:
    if _is_dead:
        return
    current_health = minf(max_health, current_health + amount)
    EventBus.player_health_changed.emit(current_health, max_health)

func _on_healed(amount: float) -> void:
    heal(amount)

func _die() -> void:
    if _is_dead:
        return
    _is_dead = true
    EventBus.player_died.emit()

func get_health_ratio() -> float:
    return current_health / max_health

func is_dead() -> bool:
    return _is_dead

func get_save_data() -> Dictionary:
    return {"current_health": current_health, "max_health": max_health}

func apply_save_data(data: Dictionary) -> void:
    current_health = data.get("current_health", max_health)
    max_health = data.get("max_health", max_health)
    EventBus.player_health_changed.emit(current_health, max_health)
```

---

### `scripts/player/player_stamina.gd`

**Type:** Node child of player
**Purpose:** Stamina resource for sprinting and actions. Optional — if absent, unlimited stamina assumed.

```gdscript
class_name PlayerStamina
extends Node

@export var max_stamina: float = 100.0
@export var sprint_drain_rate: float = 20.0
@export var recovery_rate: float = 15.0
@export var recovery_delay: float = 1.5
@export var minimum_to_sprint: float = 10.0

var current_stamina: float = max_stamina
var _draining: bool = false
var _recovery_timer: float = 0.0
var _depleted: bool = false

func _ready() -> void:
    add_to_group("player_stamina")
    current_stamina = max_stamina
    EventBus.player_started_sprinting.connect(_on_sprint_start)
    EventBus.player_stopped_sprinting.connect(_on_sprint_stop)

func _process(delta: float) -> void:
    if _draining:
        _drain(delta)
    else:
        _recover(delta)

func _drain(delta: float) -> void:
    current_stamina = maxf(0.0, current_stamina - sprint_drain_rate * delta)
    _recovery_timer = 0.0
    EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
    if current_stamina <= 0.0 and not _depleted:
        _depleted = true
        EventBus.player_stamina_depleted.emit()

func _recover(delta: float) -> void:
    if current_stamina >= max_stamina:
        return
    _recovery_timer += delta
    if _recovery_timer < recovery_delay:
        return
    current_stamina = minf(max_stamina, current_stamina + recovery_rate * delta)
    EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
    if _depleted and current_stamina >= minimum_to_sprint:
        _depleted = false
        EventBus.player_stamina_recovered.emit()

func _on_sprint_start() -> void:
    if has_stamina():
        _draining = true

func _on_sprint_stop() -> void:
    _draining = false

func has_stamina() -> bool:
    return current_stamina >= minimum_to_sprint and not _depleted

func consume_stamina(amount: float) -> bool:
    if current_stamina < amount:
        return false
    current_stamina -= amount
    EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
    return true
```

---

### `scripts/player/player_interaction.gd`

**Type:** Node child of player (contains RayCast3D)
**Purpose:** Detects interactable objects in front of player and notifies EventBus.

```gdscript
class_name PlayerInteraction
extends Node3D

@export var ray_length: float = 3.0
@export var interaction_layer: int = 0b100000  # Layer 6 = interactables

var _ray: RayCast3D = null
var _current_target: Node = null

func _ready() -> void:
    add_to_group("player_interaction")
    _ray = RayCast3D.new()
    _ray.enabled = true
    _ray.target_position = Vector3(0, 0, -ray_length)
    _ray.collision_mask = interaction_layer
    add_child(_ray)

func _physics_process(_delta: float) -> void:
    _ray.force_raycast_update()
    var collider := _ray.get_collider()
    if collider and collider.is_in_group("interactable"):
        if collider != _current_target:
            _current_target = collider
            EventBus.interactable_focused.emit(_current_target)
            # Show prompt
            var prompt := ""
            if collider.has_method("get_interaction_prompt"):
                prompt = collider.get_interaction_prompt()
            EventBus.interaction_prompt_show.emit(prompt)
    else:
        if _current_target != null:
            _current_target = null
            EventBus.interactable_cleared.emit()
            EventBus.interaction_prompt_hide.emit()

func get_current_target() -> Node:
    return _current_target

func try_interact() -> void:
    if is_instance_valid(_current_target):
        EventBus.interact_pressed.emit(_current_target)
        if _current_target.has_method("interact"):
            _current_target.interact(owner)
```

---

### `scripts/actions/action_handler.gd`

**Type:** Node child of player
**Purpose:** Central router for all player actions. Validates conditions and delegates to action nodes.

```gdscript
class_name ActionHandler
extends Node

# References to action sub-nodes (all nullable)
var _action_attack: Node = null
var _action_shoot: Node = null
var _action_throw: Node = null
var _action_drop: Node = null
var _action_grab: Node = null
var _action_collect: Node = null
var _interaction: Node = null

# Currently held item
var held_item: Node = null
var equipped_slot: int = -1

func _ready() -> void:
    add_to_group("player_action_handler")
    _find_action_nodes()
    EventBus.item_grabbed.connect(_on_item_grabbed)
    EventBus.item_dropped.connect(_on_item_dropped)

func _find_action_nodes() -> void:
    _action_attack  = get_node_or_null("ActionAttack")
    _action_shoot   = get_node_or_null("ActionShoot")
    _action_throw   = get_node_or_null("ActionThrow")
    _action_drop    = get_node_or_null("ActionDrop")
    _action_grab    = get_node_or_null("ActionGrab")
    _action_collect = get_node_or_null("ActionCollect")
    # Find interaction in parent's children
    if is_instance_valid(owner):
        for child in owner.get_children():
            if child.is_in_group("player_interaction"):
                _interaction = child
                break

func request_attack() -> void:
    EventBus.action_requested.emit("attack", {"held_item": held_item})
    if is_instance_valid(_action_attack) and _action_attack.has_method("execute"):
        _action_attack.execute({"held_item": held_item, "player": owner})

func request_shoot() -> void:
    EventBus.action_requested.emit("shoot", {"held_item": held_item})
    if is_instance_valid(_action_shoot) and _action_shoot.has_method("execute"):
        _action_shoot.execute({"held_item": held_item, "player": owner})

func request_throw() -> void:
    if not is_instance_valid(held_item):
        return
    EventBus.action_requested.emit("throw", {"held_item": held_item})
    if is_instance_valid(_action_throw) and _action_throw.has_method("execute"):
        _action_throw.execute({"held_item": held_item, "player": owner})

func request_drop() -> void:
    if not is_instance_valid(held_item):
        return
    EventBus.action_requested.emit("drop", {"held_item": held_item})
    if is_instance_valid(_action_drop) and _action_drop.has_method("execute"):
        _action_drop.execute({"held_item": held_item, "player": owner})

func request_grab() -> void:
    if not is_instance_valid(_interaction):
        return
    var target := _interaction.get_current_target() if _interaction.has_method("get_current_target") else null
    if not is_instance_valid(target):
        return
    if not target.is_in_group("grabbable"):
        return
    EventBus.action_requested.emit("grab", {"target": target})
    if is_instance_valid(_action_grab) and _action_grab.has_method("execute"):
        _action_grab.execute({"target": target, "player": owner})

func request_collect() -> void:
    if not is_instance_valid(_interaction):
        return
    var target := _interaction.get_current_target() if _interaction.has_method("get_current_target") else null
    if not is_instance_valid(target):
        return
    if not target.is_in_group("collectible"):
        return
    EventBus.action_requested.emit("collect", {"target": target})
    if is_instance_valid(_action_collect) and _action_collect.has_method("execute"):
        _action_collect.execute({"target": target, "player": owner})

func request_interact() -> void:
    if is_instance_valid(_interaction) and _interaction.has_method("try_interact"):
        _interaction.try_interact()

func request_reload() -> void:
    if is_instance_valid(held_item) and held_item.has_method("reload"):
        held_item.reload()

func request_equip_slot(slot_index: int) -> void:
    equipped_slot = slot_index
    EventBus.action_requested.emit("equip_slot", {"slot": slot_index})

func _on_item_grabbed(item_node: Node) -> void:
    held_item = item_node

func _on_item_dropped(_item_data, _pos) -> void:
    held_item = null
```

---

### `scripts/actions/action_attack.gd`

**Type:** Node child of ActionHandler
**Purpose:** Executes melee attack logic.

```gdscript
class_name ActionAttack
extends Node

@export var attack_range: float = 2.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.5
@export var attack_layer: int = 0b1001  # world + enemies

var _cooldown_timer: float = 0.0
var _can_attack: bool = true

func _process(delta: float) -> void:
    if not _can_attack:
        _cooldown_timer += delta
        if _cooldown_timer >= attack_cooldown:
            _can_attack = true
            _cooldown_timer = 0.0

func execute(context: Dictionary) -> void:
    if not _can_attack:
        return
    _can_attack = false
    _cooldown_timer = 0.0
    
    var player: Node = context.get("player")
    var held_item: Node = context.get("held_item")
    
    # Use weapon data if item has override values
    var damage := attack_damage
    var range_val := attack_range
    if is_instance_valid(held_item) and held_item.has_method("get_weapon_data"):
        var wd := held_item.get_weapon_data()
        if wd and wd.get("damage"):
            damage = wd.damage
    
    # Raycast for hit detection
    var camera := _get_camera(player)
    if not is_instance_valid(camera):
        EventBus.action_completed.emit("attack", false)
        return
    
    var space := player.get_world_3d().direct_space_state
    var from := camera.global_position
    var to := from - camera.global_transform.basis.z * range_val
    var query := PhysicsRayQueryParameters3D.create(from, to, attack_layer)
    query.exclude = [player]
    var result := space.intersect_ray(query)
    
    var hit_targets: Array = []
    if result and result.collider:
        hit_targets.append(result.collider)
        EventBus.damage_dealt.emit(result.collider, damage, "melee", player)
    
    EventBus.attack_performed.emit(player, hit_targets)
    EventBus.action_completed.emit("attack", true)
    EventBus.play_sound_3d.emit("res://assets/audio/sfx/weapons/melee_swing.ogg", player.global_position, 0.0)

func _get_camera(player: Node) -> Camera3D:
    if not is_instance_valid(player):
        return null
    for child in player.get_children():
        if child is Camera3D:
            return child
        for gc in child.get_children():
            if gc is Camera3D:
                return gc
    return null
```

---

### `scripts/actions/action_shoot.gd`

**Type:** Node child of ActionHandler
**Purpose:** Executes ranged shoot — spawns projectile or uses hitscan.

```gdscript
class_name ActionShoot
extends Node

@export var use_hitscan: bool = true
@export var hitscan_damage: float = 30.0
@export var hitscan_range: float = 200.0
@export var shoot_cooldown: float = 0.2
@export var projectile_scene: PackedScene = null
@export var shoot_layer: int = 0b1001

var _cooldown_timer: float = 0.0
var _can_shoot: bool = true

func _process(delta: float) -> void:
    if not _can_shoot:
        _cooldown_timer += delta
        if _cooldown_timer >= shoot_cooldown:
            _can_shoot = true
            _cooldown_timer = 0.0

func execute(context: Dictionary) -> void:
    if not _can_shoot:
        return
    var held_item: Node = context.get("held_item")
    # Check weapon ammo if available
    if is_instance_valid(held_item) and held_item.has_method("consume_ammo"):
        if not held_item.consume_ammo():
            EventBus.action_completed.emit("shoot", false)
            return
    _can_shoot = false
    _cooldown_timer = 0.0
    
    var player: Node = context.get("player")
    var camera := _get_camera(player)
    if not is_instance_valid(camera):
        EventBus.action_completed.emit("shoot", false)
        return
    
    var origin := camera.global_position
    var direction := -camera.global_transform.basis.z
    EventBus.shot_fired.emit(player, origin, direction)
    EventBus.play_sound_3d.emit("res://assets/audio/sfx/weapons/gunshot.ogg", origin, 0.0)

    if use_hitscan:
        _hitscan(player, camera, origin, direction)
    else:
        _spawn_projectile(origin, direction)
    
    EventBus.action_completed.emit("shoot", true)

func _hitscan(player: Node, _camera: Camera3D, from: Vector3, direction: Vector3) -> void:
    var to := from + direction * hitscan_range
    var space := player.get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(from, to, shoot_layer)
    query.exclude = [player]
    var result := space.intersect_ray(query)
    if result and result.collider:
        EventBus.damage_dealt.emit(result.collider, hitscan_damage, "bullet", player)

func _spawn_projectile(origin: Vector3, direction: Vector3) -> void:
    if not projectile_scene:
        return
    var proj: Node = projectile_scene.instantiate()
    get_tree().current_scene.add_child(proj)
    proj.global_position = origin
    if proj.has_method("launch"):
        proj.launch(direction)

func _get_camera(player: Node) -> Camera3D:
    if not is_instance_valid(player):
        return null
    for child in player.get_children():
        if child is Camera3D:
            return child
        for gc in child.get_children():
            if gc is Camera3D:
                return gc
    return null
```

---

### `scripts/actions/action_throw.gd`

```gdscript
class_name ActionThrow
extends Node

@export var throw_force: float = 15.0

func execute(context: Dictionary) -> void:
    var held: Node = context.get("held_item")
    var player: Node = context.get("player")
    if not is_instance_valid(held) or not is_instance_valid(player):
        EventBus.action_completed.emit("throw", false)
        return
    
    var camera := _get_camera(player)
    var direction := Vector3.FORWARD
    if is_instance_valid(camera):
        direction = -camera.global_transform.basis.z
    
    # Detach from hand and apply physics impulse
    if held.get_parent():
        held.reparent(get_tree().current_scene)
    held.global_position = player.global_position + direction * 1.0 + Vector3.UP * 0.5
    if held is RigidBody3D:
        held.freeze = false
        held.apply_central_impulse(direction * throw_force)
    
    EventBus.item_thrown.emit(held, direction * throw_force)
    EventBus.action_completed.emit("throw", true)
    EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/throw.ogg", player.global_position, 0.0)

func _get_camera(player: Node) -> Camera3D:
    if not is_instance_valid(player): return null
    for child in player.get_children():
        if child is Camera3D: return child
        for gc in child.get_children():
            if gc is Camera3D: return gc
    return null
```

---

### `scripts/actions/action_drop.gd`

```gdscript
class_name ActionDrop
extends Node

@export var drop_offset: Vector3 = Vector3(0, 0.5, -1.0)

func execute(context: Dictionary) -> void:
    var held: Node = context.get("held_item")
    var player: Node = context.get("player")
    if not is_instance_valid(held) or not is_instance_valid(player):
        EventBus.action_completed.emit("drop", false)
        return
    
    var drop_pos := player.global_position + player.global_transform.basis * drop_offset
    
    if held.get_parent():
        held.reparent(get_tree().current_scene)
    held.global_position = drop_pos
    
    if held is RigidBody3D:
        held.freeze = false
    
    var item_data: Resource = null
    if held.has_method("get_item_data"):
        item_data = held.get_item_data()
    
    EventBus.item_dropped.emit(item_data, drop_pos)
    EventBus.action_completed.emit("drop", true)
    EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/drop.ogg", drop_pos, 0.0)
```

---

### `scripts/actions/action_grab.gd`

```gdscript
class_name ActionGrab
extends Node

func execute(context: Dictionary) -> void:
    var target: Node = context.get("target")
    var player: Node = context.get("player")
    if not is_instance_valid(target) or not is_instance_valid(player):
        EventBus.action_completed.emit("grab", false)
        return
    
    # Find hand rig in player subtree
    var hand_rig := _find_hand_rig(player)
    if not is_instance_valid(hand_rig):
        # Fallback: just parent to player camera
        hand_rig = player
    
    # Detach from world and attach to hand
    if target.get_parent():
        target.reparent(hand_rig)
    target.position = Vector3.ZERO
    if target is RigidBody3D:
        target.freeze = true
    
    EventBus.item_grabbed.emit(target)
    EventBus.action_completed.emit("grab", true)
    EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/pickup.ogg", player.global_position, 0.0)

func _find_hand_rig(player: Node) -> Node:
    for child in player.get_children():
        if child.is_in_group("hand_rig"):
            return child
        for gc in child.get_children():
            if gc.is_in_group("hand_rig"):
                return gc
    return null
```

---

### `scripts/actions/action_collect.gd`

```gdscript
class_name ActionCollect
extends Node

func execute(context: Dictionary) -> void:
    var target: Node = context.get("target")
    var player: Node = context.get("player")
    if not is_instance_valid(target):
        EventBus.action_completed.emit("collect", false)
        return
    
    var item_data: Resource = null
    var quantity: int = 1
    
    if target.has_method("get_item_data"):
        item_data = target.get_item_data()
    if target.has_method("get_quantity"):
        quantity = target.get_quantity()
    
    if item_data == null:
        EventBus.action_completed.emit("collect", false)
        return
    
    EventBus.item_collected.emit(item_data, quantity)
    EventBus.action_completed.emit("collect", true)
    EventBus.play_sound_3d.emit("res://assets/audio/sfx/items/pickup.ogg",
        target.global_position if target is Node3D else Vector3.ZERO, 0.0)
    target.queue_free()
```

---

### `scripts/inventory/item_data.gd`

**Type:** Resource (`.tres`)
**Purpose:** Data definition for every item in the game.

```gdscript
class_name ItemData
extends Resource

enum ItemType { MISC, WEAPON_MELEE, WEAPON_RANGED, CONSUMABLE, THROWABLE, KEY_ITEM }

@export var item_id: String = ""
@export var item_name: String = "Unknown Item"
@export var description: String = ""
@export var item_type: ItemType = ItemType.MISC
@export var icon: Texture2D = null
@export var world_scene: PackedScene = null       # Scene to spawn in world when dropped
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
```

---

### `scripts/inventory/item_slot.gd`

```gdscript
class_name ItemSlot
extends Resource

@export var item_data: ItemData = null
@export var quantity: int = 0

func is_empty() -> bool:
    return item_data == null or quantity <= 0

func clear() -> void:
    item_data = null
    quantity = 0

func can_stack(other_data: ItemData) -> bool:
    if item_data == null or other_data == null:
        return false
    return item_data.item_id == other_data.item_id and quantity < item_data.max_stack_size
```

---

### `scripts/inventory/inventory_system.gd`

**Type:** Node child of player
**Purpose:** Core inventory management — add, remove, query, hotbar.

```gdscript
class_name InventorySystem
extends Node

@export var inventory_size: int = 20
@export var hotbar_size: int = 5

var slots: Array[ItemSlot] = []
var hotbar: Array[ItemSlot] = []

func _ready() -> void:
    add_to_group("player_inventory")
    _initialize_slots()
    EventBus.item_collected.connect(_on_item_collected)

func _initialize_slots() -> void:
    slots.clear()
    for i in range(inventory_size):
        slots.append(ItemSlot.new())
    hotbar.clear()
    for i in range(hotbar_size):
        hotbar.append(ItemSlot.new())

func add_item(item_data: ItemData, quantity: int = 1) -> bool:
    # Try stack first
    for slot in slots:
        if slot.can_stack(item_data):
            slot.quantity += quantity
            _broadcast_update()
            return true
    # Find empty slot
    for slot in slots:
        if slot.is_empty():
            slot.item_data = item_data
            slot.quantity = quantity
            _broadcast_update()
            return true
    EventBus.inventory_full.emit()
    return false

func remove_item(item_id: String, quantity: int = 1) -> bool:
    for slot in slots:
        if not slot.is_empty() and slot.item_data.item_id == item_id:
            if slot.quantity >= quantity:
                slot.quantity -= quantity
                if slot.quantity <= 0:
                    slot.clear()
                _broadcast_update()
                return true
    return false

func has_item(item_id: String, quantity: int = 1) -> bool:
    var total := 0
    for slot in slots:
        if not slot.is_empty() and slot.item_data.item_id == item_id:
            total += slot.quantity
    return total >= quantity

func get_inventory_snapshot() -> Array:
    return slots.duplicate()

func _broadcast_update() -> void:
    EventBus.inventory_updated.emit(get_inventory_snapshot())

func _on_item_collected(item_data: ItemData, quantity: int) -> void:
    add_item(item_data, quantity)

func get_save_data() -> Array:
    var data := []
    for slot in slots:
        if slot.is_empty():
            data.append({"id": "", "qty": 0})
        else:
            data.append({"id": slot.item_data.item_id, "qty": slot.quantity})
    return data
```

---

### `scripts/interaction/interactable.gd`

**Type:** Node — attach to any object that should be interactable
**Purpose:** Makes parent node interactable. Emits a signal when interacted.

```gdscript
class_name Interactable
extends Node

@export var interaction_prompt: String = "Press [E] to interact"
@export var single_use: bool = false

signal interacted(interactor: Node)

var _used: bool = false

func _ready() -> void:
    # Add parent to interactable group and physics layer
    if parent_is_valid():
        owner.add_to_group("interactable")

func parent_is_valid() -> bool:
    return is_instance_valid(owner) and owner is Node3D

func interact(interactor: Node) -> void:
    if single_use and _used:
        return
    _used = single_use
    emit_signal("interacted", interactor)
    EventBus.interact_pressed.emit(owner)

func get_interaction_prompt() -> String:
    return interaction_prompt
```

---

### `scripts/items/base_item.gd`

**Type:** RigidBody3D script
**Purpose:** Base for all physical world items.

```gdscript
class_name BaseItem
extends RigidBody3D

@export var item_data: ItemData = null
@export var auto_collect_on_contact: bool = false
@export var collect_on_interact: bool = true

func _ready() -> void:
    add_to_group("world_item")
    if collect_on_interact:
        add_to_group("collectible")
    if auto_collect_on_contact:
        body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player") and auto_collect_on_contact:
        if item_data:
            EventBus.item_collected.emit(item_data, 1)
            queue_free()

func get_item_data() -> ItemData:
    return item_data

func get_quantity() -> int:
    return 1

func get_interaction_prompt() -> String:
    if item_data:
        return "Pick up %s" % item_data.item_name
    return "Pick up"
```

---

### `scripts/items/grabbable_item.gd`

**Type:** extends BaseItem
**Purpose:** Item that can be grabbed and held in player's hand.

```gdscript
class_name GrabbableItem
extends BaseItem

func _ready() -> void:
    super._ready()
    add_to_group("grabbable")
    add_to_group("interactable")

func get_interaction_prompt() -> String:
    if item_data:
        return "Grab %s [F]" % item_data.item_name
    return "Grab [F]"

func get_weapon_data() -> ItemData:
    return item_data
```

---

### `scripts/weapons/weapon_base.gd`

**Type:** Node3D — base for all weapon scenes
**Purpose:** Shared weapon state and data interface.

```gdscript
class_name WeaponBase
extends Node3D

@export var weapon_data: ItemData = null

var current_ammo: int = 0
var _is_reloading: bool = false

func _ready() -> void:
    if weapon_data:
        current_ammo = weapon_data.max_ammo

func get_weapon_data() -> ItemData:
    return weapon_data

func consume_ammo() -> bool:
    if weapon_data == null or weapon_data.max_ammo <= 0:
        return true  # Infinite ammo weapon
    if current_ammo <= 0:
        return false
    current_ammo -= 1
    EventBus.ammo_changed.emit(current_ammo, weapon_data.max_ammo)
    return true

func reload() -> void:
    if _is_reloading or weapon_data == null:
        return
    _is_reloading = true
    # Use a timer instead of await so it's cancellable
    var timer := get_tree().create_timer(1.5)
    timer.timeout.connect(_finish_reload)

func _finish_reload() -> void:
    if weapon_data:
        current_ammo = weapon_data.max_ammo
        EventBus.ammo_changed.emit(current_ammo, weapon_data.max_ammo)
        EventBus.weapon_reloaded.emit(weapon_data)
    _is_reloading = false
```

---

### `scripts/projectiles/projectile_base.gd`

**Type:** RigidBody3D or CharacterBody3D
**Purpose:** Projectile that travels and deals damage on collision.

```gdscript
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
```

---

### `scripts/audio/audio_manager.gd`

**Type:** Node (can be autoload or scene child)
**Purpose:** Manages audio playback with pooling.

```gdscript
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
```

---

### `scripts/audio/footstep_system.gd`

**Type:** Node child of player
**Purpose:** Plays footstep sounds based on surface and movement speed.

```gdscript
class_name FootstepSystem
extends Node

@export var step_interval_walk: float = 0.5
@export var step_interval_sprint: float = 0.3

var _step_timer: float = 0.0
var _body: CharacterBody3D = null

func _ready() -> void:
    await owner.ready
    _body = owner as CharacterBody3D

func _physics_process(delta: float) -> void:
    if not is_instance_valid(_body):
        return
    if not _body.is_on_floor():
        _step_timer = 0.0
        return
    var horizontal_speed := Vector2(_body.velocity.x, _body.velocity.z).length()
    if horizontal_speed < 0.5:
        _step_timer = 0.0
        return
    
    var interval := step_interval_walk if horizontal_speed < 7.0 else step_interval_sprint
    _step_timer += delta
    if _step_timer >= interval:
        _step_timer = 0.0
        _play_footstep()

func _play_footstep() -> void:
    if not is_instance_valid(_body):
        return
    # Detect surface
    var surface := _detect_surface()
    EventBus.play_footstep.emit(surface, _body.global_position)

func _detect_surface() -> String:
    # Raycast down to detect physics material
    if not is_instance_valid(_body):
        return "default"
    var space := _body.get_world_3d().direct_space_state
    var from := _body.global_position
    var to := from + Vector3.DOWN * 1.2
    var query := PhysicsRayQueryParameters3D.create(from, to)
    var result := space.intersect_ray(query)
    if result and result.collider:
        # Check for surface tag (group-based surface detection)
        if result.collider.is_in_group("surface_wood"):   return "wood"
        if result.collider.is_in_group("surface_metal"):  return "metal"
        if result.collider.is_in_group("surface_grass"):  return "grass"
        if result.collider.is_in_group("surface_gravel"): return "gravel"
        if result.collider.is_in_group("surface_water"):  return "water"
    return "default"
```

---

### `scripts/ui/hud_controller.gd`

**Type:** Node (root of HUD scene)
**Purpose:** Listens to EventBus, updates all HUD elements. Fully decoupled.

```gdscript
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
```

---

### `scripts/ui/pause_menu_controller.gd`

```gdscript
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
```

---

### `scripts/utils/constants.gd`

```gdscript
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
```

---

### `scripts/utils/debug_overlay.gd`

```gdscript
class_name DebugOverlay
extends CanvasLayer

@onready var label: Label = get_node_or_null("DebugLabel")

var _visible: bool = false
var _player: CharacterBody3D = null

func _ready() -> void:
    layer = 100
    visible = false
    InputManager.debug_toggled.connect(_toggle)
    EventBus.player_spawned.connect(_on_player_spawned)

func _on_player_spawned(player_node: Node) -> void:
    _player = player_node as CharacterBody3D

func _toggle() -> void:
    _visible = !_visible
    visible = _visible

func _process(_delta: float) -> void:
    if not _visible or not label:
        return
    var lines: Array[String] = []
    lines.append("FPS: %d" % Engine.get_frames_per_second())
    if is_instance_valid(_player):
        lines.append("Position: %s" % str(_player.global_position.snapped(Vector3.ONE * 0.01)))
        lines.append("Velocity: %.2f" % Vector2(_player.velocity.x, _player.velocity.z).length())
    lines.append("GameState: %s" % GameManager.GameState.keys()[GameManager.current_state])
    label.text = "\n".join(lines)
```

---

## SCENE STRUCTURE SPECIFICATIONS

### `scenes/player/player.tscn`

```
PlayerController (CharacterBody3D) [script: player_controller.gd]
├── CollisionShape3D
│   └── CapsuleShape3D (height: 1.8, radius: 0.4)
├── CameraRig (Node3D) [script: player_camera.gd, group: player_camera]
│   └── Camera3D (fov: 75, near: 0.05)
│       └── InteractionDetector (Node3D) [script: player_interaction.gd, group: player_interaction]
├── HandRig (Node3D) [group: hand_rig]
│   └── (Items/weapons are parented here when grabbed/equipped)
├── PlayerMovement (Node3D) [script: player_movement.gd, group: player_movement]
├── PlayerHealth (Node) [script: player_health.gd, group: player_health]
├── PlayerStamina (Node) [script: player_stamina.gd, group: player_stamina]
├── FootstepSystem (Node) [script: footstep_system.gd]
├── InventorySystem (Node) [script: inventory_system.gd, group: player_inventory]
└── ActionHandler (Node) [script: action_handler.gd, group: player_action_handler]
    ├── ActionAttack (Node) [script: action_attack.gd]
    ├── ActionShoot (Node) [script: action_shoot.gd]
    ├── ActionThrow (Node) [script: action_throw.gd]
    ├── ActionDrop (Node) [script: action_drop.gd]
    ├── ActionGrab (Node) [script: action_grab.gd]
    └── ActionCollect (Node) [script: action_collect.gd]
```

**Key Settings on PlayerController (CharacterBody3D):**
- `motion_mode` = Grounded
- `floor_max_angle` = 45°
- `up_direction` = (0, 1, 0)
- Physics Layer: `LAYER_PLAYER` (layer 2)
- Collision Mask: `LAYER_WORLD | LAYER_ITEMS | LAYER_INTERACTABLE`

---

### `scenes/world/test_level.tscn`

```
TestLevel (Node3D)
├── WorldEnvironment [script: none, set sky/fog/ambient here]
├── DirectionalLight3D (sun, shadow enabled)
├── StaticBody3D (floor)
│   ├── CollisionShape3D (BoxShape3D 50x1x50)
│   └── MeshInstance3D (PlaneMesh)
├── SpawnPoint (Marker3D) [group: spawn_point]
├── AudioManager (Node) [script: audio_manager.gd]
├── DebugOverlay (CanvasLayer) [script: debug_overlay.gd]
│   └── DebugLabel (Label)
├── HUD (CanvasLayer — loaded from hud.tscn)
└── PauseMenu (CanvasLayer — loaded from pause_menu.tscn)
```

**Note:** Player is spawned here by world.gd, not placed in editor, to support future multiplayer.

---

### `scenes/core/world.gd`

```gdscript
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
```

---

## GODOT PROJECT SETTINGS CHECKLIST

After creating all files, verify these settings in **Project → Project Settings**:

| Setting | Value |
|---|---|
| `application/run/main_scene` | `res://scenes/ui/main_menu.tscn` |
| `physics/3d/default_gravity` | `9.8` |
| `rendering/renderer/rendering_method` | `forward_plus` (or `mobile` for performance) |
| `input_devices/pointing/emulate_touch_from_mouse` | `false` |
| Autoload: EventBus | `res://scripts/autoload/event_bus.gd` |
| Autoload: InputManager | `res://scripts/autoload/input_manager.gd` |
| Autoload: GameManager | `res://scripts/autoload/game_manager.gd` |
| Autoload: SaveManager | `res://scripts/autoload/save_manager.gd` |

---

## IMPLEMENTATION ORDER (STEP BY STEP)

Follow this exact order to avoid dependency issues:

1. **Create folder tree** — all folders first, empty.
2. **Write `constants.gd`** — no dependencies.
3. **Write `event_bus.gd`** — no dependencies.
4. **Write `input_manager.gd`** — depends on InputMap actions existing.
5. **Write `game_manager.gd`** — depends on EventBus.
6. **Write `save_manager.gd`** — depends on EventBus, GameManager.
7. **Register all 4 autoloads** in Project Settings.
8. **Configure Input Map** — all actions from the table above.
9. **Write `base_state.gd` and `state_machine.gd`** — core utilities.
10. **Write `item_data.gd` and `item_slot.gd`** — Resource classes.
11. **Write `inventory_system.gd`** — depends on ItemData, EventBus.
12. **Write `player_health.gd`** — depends on EventBus.
13. **Write `player_stamina.gd`** — depends on EventBus.
14. **Write `player_movement.gd`** — depends on InputManager, EventBus.
15. **Write `player_camera.gd`** — depends on InputManager, EventBus.
16. **Write `player_interaction.gd`** — depends on EventBus.
17. **Write `interactable.gd`** — depends on EventBus.
18. **Write all action scripts** (attack, shoot, throw, drop, grab, collect).
19. **Write `action_handler.gd`** — depends on all action scripts.
20. **Write `player_controller.gd`** — depends on all player components.
21. **Write `base_item.gd`**, `grabbable_item.gd`, `pickup_item.gd`, `throwable_item.gd`.
22. **Write `weapon_base.gd`**, `weapon_melee.gd`, `weapon_ranged.gd`.
23. **Write `projectile_base.gd`**.
24. **Write `footstep_system.gd`** and `audio_manager.gd`.
25. **Write `hud_controller.gd`**, `pause_menu_controller.gd`.
26. **Write `debug_overlay.gd`** and `math_utils.gd`.
27. **Build `player.tscn`** — follow scene structure above exactly.
28. **Build `test_level.tscn`** and `world.tscn`.
29. **Build HUD, pause menu, main menu scenes**.
30. **Create example `.tres` resources** for at least 2 items and 1 weapon.
31. **Test and validate** — remove one component at a time and verify no crashes.

---

## VALIDATION RULES (TEST THESE AFTER IMPLEMENTATION)

Run these tests to verify modularity:

- [ ] Delete `player_stamina.gd` node from player scene → player still moves, no errors
- [ ] Delete `player_health.gd` node → game still runs, no errors
- [ ] Delete `ActionAttack` node → other actions still work
- [ ] Delete `InventorySystem` node → no crash when collecting items
- [ ] Delete `HUD` scene → game still runs without UI
- [ ] Delete `FootstepSystem` node → no footstep errors
- [ ] Delete `AudioManager` → sounds silently fail, no crash
- [ ] Add a new action node with just `func execute(context):` → works without modifying other scripts
- [ ] All EventBus signals fire correctly (verify with debug prints)
- [ ] Mouse is captured on play, released on pause
- [ ] Save/load round-trip preserves player health and inventory

---

## CODING STANDARDS (ENFORCE THROUGHOUT)

- All `@export` variables have sensible defaults set in the export declaration.
- Every function that accesses a Node must first check `is_instance_valid()` or use `get_node_or_null()`.
- No `await` inside `_ready()` without using `await owner.ready` guard first.
- No direct `get_node("/root/SomeSingleton")` — use autoload names directly.
- Every script file starts with a `class_name` declaration.
- Use `push_warning()` for missing-but-recoverable situations; `push_error()` only for unrecoverable ones.
- Signal connections in `_ready()` must be checked: if the signal source could be null (non-autoload), guard it.
- All exported numeric values use `float` with `f` suffix (e.g., `5.0` not `5`).
- Physics layer masks use named constants from `constants.gd`, not magic numbers.
- Node groups use `Constants.GROUP_*` string constants, not inline string literals.

---

## FUTURE MULTIPLAYER PREPARATION NOTES

When the time comes to add multiplayer, the architecture is already prepared:

- `InputManager` is a wrapper — swap its polling for `MultiplayerInput` without touching any other system.
- `player_controller.gd` already encapsulates all player logic — can become a `MultiplayerSynchronizer` authority.
- `EventBus` signals can be rerouted to RPC calls by subclassing — local signals become `@rpc("any_peer")` calls.
- `SaveManager` can be extended to sync save state with server.
- All physics is in `_physics_process` — safe for network synchronization.
- Avoid using `get_tree().current_scene` directly for adding nodes; use a dedicated `WorldManager` (can later route through server).

---

*End of prompt. Implement all sections completely and in order. Do not skip any script or folder. Do not break modularity. Validate with the checklist.*
