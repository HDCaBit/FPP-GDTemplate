# 🎯 FPS Template — Godot 4.6.3

A modular, production-ready First-Person Shooter template for **Godot 4.6.3** with EventBus architecture and component-based player system.

![Godot](https://img.shields.io/badge/Godot-4.6.3-478CBF?logo=godotengine&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![GDScript](https://img.shields.io/badge/GDScript-4.x-blue)

---

## ✨ Features

| System | Description |
|---|---|
| 🏗️ **EventBus Architecture** | All systems communicate via signals — fully decoupled, no hard dependencies |
| 🧩 **Component-Based Player** | Movement, camera, health, stamina, interaction — each removable without crashing |
| ⚔️ **Action System** | Attack, shoot, throw, drop, grab, collect — modular and extendable |
| 🎒 **Inventory System** | 20 slots + 5 hotbar, stackable items, resource-based `ItemData` |
| 🔫 **Weapon System** | Melee (combo), Ranged (hitscan/projectile), ammo, reload |
| 🔊 **Audio System** | Pooled 3D/2D audio, surface-based footsteps |
| 💾 **Save/Load** | JSON-based, key-value API, auto scene tracking |
| 🖥️ **Full UI** | HUD, pause menu, inventory panel, main menu |
| 🤖 **State Machine** | Generic `StateMachine` + `BaseState` for AI and behaviors |
| 🐛 **Debug Overlay** | FPS, position, velocity, game state (toggle with F3) |

---

## 📁 Project Structure

```
Template_FPP/
├── assets/audio/sfx/        # Sound effects
├── resources/
│   ├── items/               # ItemData resources (.tres)
│   └── weapons/             # Weapon resources (.tres)
├── scenes/
│   ├── core/                # world.tscn (gameplay root)
│   ├── items/               # Item scene templates
│   ├── player/              # player.tscn
│   ├── projectiles/         # Projectile scenes
│   ├── ui/                  # HUD, menus, inventory
│   ├── weapons/             # Weapon scenes
│   └── world/               # Levels + sky environment
├── scripts/
│   ├── actions/             # Action system (7 scripts)
│   ├── audio/               # Audio manager + footsteps
│   ├── autoload/            # EventBus, InputManager, GameManager, SaveManager
│   ├── core/                # StateMachine + BaseState
│   ├── interaction/         # Interactable component
│   ├── inventory/           # ItemData, ItemSlot, InventorySystem
│   ├── items/               # BaseItem + variants
│   ├── player/              # 6 player components
│   ├── ui/                  # UI controllers
│   ├── utils/               # Constants, MathUtils, DebugOverlay
│   └── weapons/             # WeaponBase, Melee, Ranged, Projectile
├── DOCUMENTATION.md         # Full documentation (700+ lines)
└── project.godot
```

---

## 🎮 Controls

| Key | Action | Key | Action |
|---|---|---|---|
| `WASD` | Move | `E` | Interact |
| `Mouse` | Look | `F` | Grab item |
| `Space` | Jump | `G` | Collect item |
| `Shift` | Sprint | `T` | Throw |
| `Ctrl` | Crouch | `Q` | Drop |
| `LMB` | Attack/Shoot | `R` | Reload |
| `RMB` | Alt Attack | `Tab` | Inventory |
| `1-5` | Hotbar | `Esc` | Pause |
| `F3` | Debug overlay | | |

---

## 🚀 Quick Start

1. Clone this repo
2. Open in **Godot 4.6.3**
3. Press **F5** → Main Menu → **New Game**
4. You spawn in `test_level` — move with WASD, look with mouse

---

## 🔌 Architecture Overview

```
┌──────────────────────────────────────────────┐
│                  AUTOLOADS                    │
│  EventBus · InputManager · GameManager · Save │
└──────────────┬───────────────────────────────┘
               │ signals
┌──────────────▼───────────────────────────────┐
│              PLAYER (CharacterBody3D)         │
│  ┌──────────┬──────────┬──────────┬────────┐ │
│  │ Movement │ Camera   │ Health   │Stamina │ │
│  └──────────┴──────────┴──────────┴────────┘ │
│  ┌──────────┬──────────┬──────────────────┐  │
│  │Interact  │Inventory │ ActionHandler    │  │
│  │          │          │ ├ Attack  ├ Grab  │  │
│  │          │          │ ├ Shoot   ├ Drop  │  │
│  │          │          │ ├ Throw   └Collect│  │
│  └──────────┴──────────┴──────────────────┘  │
└──────────────────────────────────────────────┘
               │ signals
┌──────────────▼───────────────────────────────┐
│           WORLD OBJECTS                       │
│  Items · Weapons · Interactables · Enemies    │
└──────────────┬───────────────────────────────┘
               │ signals
┌──────────────▼───────────────────────────────┐
│              UI LAYER                         │
│  HUD · PauseMenu · InventoryUI · MainMenu    │
└──────────────────────────────────────────────┘
```

**Key principle**: Every arrow is an **EventBus signal** — no direct references between systems.

---

## 📖 How to Extend

### Add an Interactable Object

```gdscript
extends StaticBody3D

func _ready() -> void:
    add_to_group("interactable")         # Required
    collision_layer = 32                  # Layer 6

func interact(interactor: Node) -> void:
    print("Interacted!")

func get_interaction_prompt() -> String:
    return "Press [E] to use"
```

### Add a New Item

1. Create `ItemData` resource (`.tres`) in `resources/items/`
2. Set properties: `item_id`, `item_name`, `item_type`, etc.
3. Create a scene using `PickupItem`, `GrabbableItem`, or `ThrowableItem`
4. Assign the resource → place in level

### Add a Player Component

```gdscript
extends Node
func _ready() -> void:
    add_to_group("my_component")  # Discoverable by PlayerController
    EventBus.some_signal.connect(_on_something)
```

### Add a New Action

1. Create script in `scripts/actions/` extending `Node`
2. Add `execute(context: Dictionary)` method
3. Add as child of `ActionHandler` in player scene
4. Wire input in `InputManager` → `PlayerController` → `ActionHandler`

### Listen to Events

```gdscript
EventBus.player_health_changed.connect(func(cur, max): update_bar(cur, max))
EventBus.item_collected.connect(func(data, qty): show_notification(data.item_name))
EventBus.damage_dealt.connect(func(target, amount, type, source): spawn_fx())
```

---

## 🏷️ Physics Layers

| Layer | Name | Bit | Used By |
|---|---|---|---|
| 1 | World | `1` | Floors, walls |
| 2 | Player | `2` | PlayerController |
| 3 | Items | `4` | All items |
| 4 | Enemies | `8` | Enemy characters |
| 5 | Projectiles | `16` | Bullets |
| 6 | Interactables | `32` | Interactive objects |

---

## 📚 Full Documentation

See [**DOCUMENTATION.md**](DOCUMENTATION.md) for comprehensive guides on:
- Creating interactable objects, items, weapons, enemies
- Extending the player with new components
- Adding new actions and input bindings
- Using EventBus signals
- Save/Load system
- Audio system
- State machine for AI
- UI customization
- Troubleshooting

---

## 📄 License

MIT — Free to use for personal and commercial projects.
