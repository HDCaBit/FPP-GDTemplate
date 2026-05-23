# 📖 FPS Template — Dokumentasi Lengkap

Template modular First-Person Shooter untuk **Godot 4.6.3** dengan arsitektur EventBus + Component-Based Player.

---

## 📑 Daftar Isi

1. [Struktur Project](#1-struktur-project)
2. [Arsitektur & Konsep Utama](#2-arsitektur--konsep-utama)
3. [Kontrol Default](#3-kontrol-default)
4. [Quick Start — Menjalankan Template](#4-quick-start--menjalankan-template)
5. [Membuat Object Interactable](#5-membuat-object-interactable)
6. [Membuat Item yang Bisa Dipungut (Pickup)](#6-membuat-item-yang-bisa-dipungut-pickup)
7. [Membuat Item yang Bisa Digenggam (Grabbable)](#7-membuat-item-yang-bisa-digenggam-grabbable)
8. [Membuat Item yang Bisa Dilempar (Throwable)](#8-membuat-item-yang-bisa-dilempar-throwable)
9. [Membuat Senjata Baru](#9-membuat-senjata-baru)
10. [Sistem Inventory](#10-sistem-inventory)
11. [Menambah Komponen Player Baru](#11-menambah-komponen-player-baru)
12. [Menambah Action Baru](#12-menambah-action-baru)
13. [Menggunakan EventBus](#13-menggunakan-eventbus)
14. [Sistem Audio](#14-sistem-audio)
15. [Sistem Save & Load](#15-sistem-save--load)
16. [Kustomisasi UI / HUD](#16-kustomisasi-ui--hud)
17. [Membuat Level Baru](#17-membuat-level-baru)
18. [Membuat Enemy Sederhana](#18-membuat-enemy-sederhana)
19. [Menambah State Machine](#19-menambah-state-machine)
20. [Physics Layer Reference](#20-physics-layer-reference)
21. [Tips & Best Practices](#21-tips--best-practices)
22. [Troubleshooting](#22-troubleshooting)

---

## 1. Struktur Project

```
Template_FPP/
├── assets/                      # Audio, textures, models, dll
│   └── audio/sfx/              # Sound effects (buat folder sesuai kebutuhan)
├── resources/                   # File .tres (data item, weapon, dll)
│   ├── items/                  # ItemData resources
│   └── weapons/                # Weapon ItemData resources
├── scenes/                      # File .tscn
│   ├── autoload/               # Scene autoload (opsional)
│   ├── core/                   # world.tscn (scene utama gameplay)
│   ├── items/                  # Scene template item
│   ├── player/                 # player.tscn
│   ├── projectiles/            # Projectile scenes
│   ├── ui/                     # HUD, pause menu, inventory, main menu
│   ├── weapons/                # Weapon scenes
│   └── world/                  # Level scenes + sky environment
├── scripts/                     # Semua GDScript
│   ├── actions/                # Action system (attack, shoot, throw, dll)
│   ├── audio/                  # Audio manager, footstep system
│   ├── autoload/               # Singletons (EventBus, InputManager, dll)
│   ├── core/                   # State machine framework
│   ├── interaction/            # Interactable + Interaction detector
│   ├── inventory/              # Item data, slots, inventory system
│   ├── items/                  # Base item + variants (pickup, grabbable, throwable)
│   ├── player/                 # Player components (movement, camera, health, dll)
│   ├── ui/                     # UI controllers
│   ├── utils/                  # Constants, math utils, debug overlay
│   └── weapons/                # Weapon scripts (base, melee, ranged, projectile)
├── project.godot               # Konfigurasi engine
└── DOCUMENTATION.md            # File ini
```

---

## 2. Arsitektur & Konsep Utama

### 🔌 EventBus Pattern
Semua sistem berkomunikasi melalui **EventBus** (autoload singleton). Tidak ada referensi langsung antar komponen. Ini berarti:
- Menghapus komponen **tidak akan crash** game
- Menambah fitur baru cukup **connect ke signal EventBus**
- Debugging lebih mudah karena semua event terpusat

```
┌──────────┐     signal      ┌──────────┐
│  Health   │ ──────────────► │ EventBus │
└──────────┘                  └────┬─────┘
                                   │ signal
                              ┌────▼─────┐
                              │   HUD    │
                              └──────────┘
```

### 🧩 Component-Based Player
Player (`PlayerController`) tidak hardcode referensi ke komponen. Sebaliknya, ia **mencari komponen berdasarkan group**:

| Group Name | Komponen | Boleh Dihapus? |
|---|---|---|
| `player_movement` | PlayerMovement | ✅ (player diam saja) |
| `player_camera` | PlayerCamera | ❌ (butuh kamera) |
| `player_health` | PlayerHealth | ✅ (invincible) |
| `player_stamina` | PlayerStamina | ✅ (sprint unlimited) |
| `player_interaction` | PlayerInteraction | ✅ (tidak bisa interact) |
| `player_action_handler` | ActionHandler | ✅ (tidak bisa aksi) |
| `player_inventory` | InventorySystem | ✅ (tidak bisa simpan item) |

### 🔄 Autoload Singletons
| Autoload | File | Fungsi |
|---|---|---|
| `EventBus` | `scripts/autoload/event_bus.gd` | Signal hub global |
| `InputManager` | `scripts/autoload/input_manager.gd` | Input terpusat + mouse capture |
| `GameManager` | `scripts/autoload/game_manager.gd` | Game state + scene management |
| `SaveManager` | `scripts/autoload/save_manager.gd` | JSON save/load |

---

## 3. Kontrol Default

| Tombol | Aksi |
|---|---|
| `W A S D` | Gerak |
| `Mouse` | Look around |
| `Space` | Lompat |
| `Shift` | Sprint |
| `Ctrl` | Crouch (toggle) |
| `E` | Interact |
| `F` | Grab (angkat objek) |
| `G` | Collect (masukkan ke inventory) |
| `LMB` (klik kiri) | Attack / Shoot |
| `RMB` (klik kanan) | Alt Attack |
| `T` | Throw (lempar objek di tangan) |
| `Q` | Drop (jatuhkan objek) |
| `R` | Reload |
| `Tab` | Inventory toggle |
| `Esc` | Pause |
| `1-5` | Hotbar slot |
| `F3` | Debug overlay |

---

## 4. Quick Start — Menjalankan Template

1. Buka Godot 4.6.3
2. **Import** → pilih folder `Template_FPP`
3. Tunggu Godot selesai import semua file
4. Tekan **F5** atau klik ▶ Play
5. Di Main Menu, klik **"New Game"**
6. Kamu akan spawn di `test_level` — coba gerak dengan WASD dan lihat sekeliling dengan mouse

---

## 5. Membuat Object Interactable

Object interactable adalah object di dunia yang bisa player lihat dan berinteraksi dengannya (misal: tombol, pintu, NPC, terminal).

### Langkah-langkah:

**Cara 1: Pakai Interactable Component (Recommended)**

1. Buat scene baru (misal `door.tscn`) dengan root `StaticBody3D`
2. Tambahkan `CollisionShape3D` + `MeshInstance3D`
3. Set `collision_layer` ke **Layer 6** (Interactables = bit 32)
4. Tambahkan child node `Node`, assign script `Interactable` (`scripts/interaction/interactable.gd`)
5. Di Inspector, set `Interaction Prompt` = `"Press [E] to open"`

```
Door (StaticBody3D) ← collision_layer = 32
├── CollisionShape3D
├── MeshInstance3D
└── Interactable (Node) ← script: interactable.gd
```

6. Buat script baru di `Door` untuk handle interaksi:

```gdscript
# scripts/world/door.gd
extends StaticBody3D

var _is_open: bool = false
var _interactable: Interactable = null

func _ready() -> void:
    # Cari komponen Interactable di children
    for child in get_children():
        if child is Interactable:
            _interactable = child
            _interactable.interacted.connect(_on_interacted)
            break

func _on_interacted(interactor: Node) -> void:
    _is_open = !_is_open
    if _is_open:
        # Animasi buka pintu (contoh: rotate)
        rotation_degrees.y = 90.0
        print("Pintu dibuka!")
    else:
        rotation_degrees.y = 0.0
        print("Pintu ditutup!")
```

**Cara 2: Langsung di Script (Tanpa Interactable Component)**

```gdscript
# scripts/world/switch.gd
extends StaticBody3D

var _active: bool = false

func _ready() -> void:
    add_to_group("interactable")  # WAJIB agar player bisa detect

func interact(interactor: Node) -> void:
    _active = !_active
    print("Switch toggled: ", _active)
    # Lakukan sesuatu, misal nyalakan lampu
    EventBus.action_completed.emit("switch", true)

func get_interaction_prompt() -> String:
    return "Toggle switch [E]"
```

> ⚠️ **PENTING**: Object interactable HARUS punya:
> 1. Masuk group `"interactable"`
> 2. Collision di **Layer 6** (bit 32) agar raycast player bisa detect
> 3. Method `interact(interactor: Node)` untuk handle aksi
> 4. (Opsional) Method `get_interaction_prompt() -> String` untuk UI prompt

---

## 6. Membuat Item yang Bisa Dipungut (Pickup)

Item pickup masuk ke inventory player saat di-collect.

### Langkah 1: Buat ItemData Resource

1. Di FileSystem, klik kanan folder `resources/items/`
2. **New Resource** → pilih type `ItemData`
3. Atau buat file `.tres` manual:

```
# resources/items/medkit.tres
```

4. Isi property di Inspector:

| Property | Contoh Value |
|---|---|
| `item_id` | `"medkit"` |
| `item_name` | `"Medkit"` |
| `description` | `"Heals 50 HP"` |
| `item_type` | `CONSUMABLE` (3) |
| `max_stack_size` | `3` |
| `weight` | `0.8` |
| `heal_amount` | `50.0` |

### Langkah 2: Buat Scene Item di Dunia

1. Buat scene baru atau duplicate `scenes/items/pickup_item.tscn`
2. Scene tree:

```
MedkitPickup (RigidBody3D)    ← script: pickup_item.gd
├── CollisionShape3D
└── MeshInstance3D             ← ganti mesh sesuai model 3D
```

3. Di Inspector root node, set `Item Data` = drag resource `medkit.tres`
4. Set `collision_layer = 36` (Items + Interactables = 4 + 32)

### Langkah 3: Taruh di Level

1. Instance scene `medkit_pickup.tscn` di level
2. Player mendekat → prompt muncul "Pick up Medkit [E]"
3. Tekan **G** (collect) → item masuk inventory

### Auto-Collect (Opsional)

Untuk item yang langsung ter-pickup saat disentuh player:
1. Di Inspector, centang `Auto Collect On Contact = true`
2. Di RigidBody3D, aktifkan `Contact Monitor = true` dan `Max Contacts Reported = 1`

---

## 7. Membuat Item yang Bisa Digenggam (Grabbable)

Item grabbable bisa diangkat dan dipegang di tangan player.

### Langkah-langkah:

1. Buat scene baru atau duplicate `scenes/items/grabbable_item.tscn`
2. Assign script `grabbable_item.gd`
3. Scene tree:

```
Flashlight (RigidBody3D)      ← script: grabbable_item.gd
├── CollisionShape3D
├── MeshInstance3D
└── (opsional) SpotLight3D    ← untuk senter
```

4. Set `Item Data` = resource `.tres` yang sudah dibuat
5. Taruh di level

**Cara Pakai In-Game:**
- Player mendekat → "[F] Grab Flashlight"
- Tekan **F** → item menempel di tangan (HandRig)
- Tekan **Q** → drop item kembali ke dunia
- Tekan **T** → lempar item ke depan

---

## 8. Membuat Item yang Bisa Dilempar (Throwable)

```
Grenade (RigidBody3D)         ← script: throwable_item.gd
├── CollisionShape3D
├── MeshInstance3D
└── (opsional) Area3D         ← untuk deteksi ledakan
```

Untuk menambah efek ledakan saat menyentuh sesuatu:

```gdscript
# scripts/items/grenade.gd
extends ThrowableItem

@export var explosion_damage: float = 75.0
@export var explosion_radius: float = 5.0
var _has_been_thrown: bool = false

func _ready() -> void:
    super._ready()
    body_entered.connect(_on_body_entered)
    # Enable contact monitoring
    contact_monitor = true
    max_contacts_reported = 1

func _on_body_entered(body: Node) -> void:
    if not _has_been_thrown:
        return
    # Ledakan!
    _explode()

func _explode() -> void:
    # Cari semua node di radius
    var space := get_world_3d().direct_space_state
    var shape := SphereShape3D.new()
    shape.radius = explosion_radius

    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = shape
    query.transform = global_transform
    query.collision_mask = 0b1011  # world + player + enemies

    var results := space.intersect_shape(query)
    for result in results:
        if result.collider:
            EventBus.damage_dealt.emit(
                result.collider,
                explosion_damage,
                "explosion",
                self
            )

    # Efek visual (opsional)
    EventBus.play_sound_3d.emit(
        "res://assets/audio/sfx/weapons/explosion.ogg",
        global_position, 0.0
    )
    queue_free()
```

Lalu connect signal `item_thrown` agar grenade tahu sudah dilempar:

```gdscript
func _ready() -> void:
    super._ready()
    EventBus.item_thrown.connect(_on_thrown)

func _on_thrown(item: Node, _vel: Vector3) -> void:
    if item == self:
        _has_been_thrown = true
```

---

## 9. Membuat Senjata Baru

### Langkah 1: Buat ItemData Resource

```
# resources/weapons/shotgun.tres
item_id = "shotgun"
item_name = "Shotgun"
item_type = WEAPON_RANGED (2)
damage = 15.0           # per pellet
max_ammo = 8
ammo_per_reload = 8
attack_speed = 0.8
is_equippable = true
```

### Langkah 2: Buat Weapon Scene

**Untuk Senjata Ranged:**

1. Buat scene baru, root `Node3D`, assign script `weapon_ranged.gd`
2. Tambahkan child:
   - `MeshInstance3D` — model 3D senjata
   - (opsional) `GPUParticles3D` — muzzle flash

```
Shotgun (Node3D)              ← script: weapon_ranged.gd
├── Model (MeshInstance3D)
├── MuzzleFlash (GPUParticles3D)
└── ShootSound (AudioStreamPlayer3D)
```

3. Di Inspector, set property:

| Property | Value |
|---|---|
| `weapon_data` | `shotgun.tres` |
| `use_hitscan` | `true` |
| `spread_angle` | `5.0` |
| `pellet_count` | `8` |

**Untuk Senjata Melee:**

```
Axe (Node3D)                  ← script: weapon_melee.gd
└── Model (MeshInstance3D)
```

### Langkah 3: Menaruh di Dunia

Bungkus weapon scene di dalam `GrabbableItem`:

```
AxeWorldItem (RigidBody3D)    ← script: grabbable_item.gd, item_data = axe.tres
├── CollisionShape3D
├── MeshInstance3D
└── WeaponMelee (Node3D)      ← script: weapon_melee.gd
```

Player grab → weapon menempel di HandRig → bisa attack/shoot.

---

## 10. Sistem Inventory

### API Utama (`InventorySystem`)

```gdscript
# Menambah item ke inventory
var inv = get_tree().get_first_node_in_group("player_inventory")
inv.add_item(item_data, 1)       # return bool (true = berhasil)

# Mengecek item
inv.has_item("health_potion", 2)  # punya ≥ 2 health potion?

# Menghapus item
inv.remove_item("health_potion", 1)

# Mendapatkan snapshot inventory
var slots: Array = inv.get_inventory_snapshot()
```

### Membuat Item Baru untuk Inventory

1. Buat file `resources/items/nama_item.tres`
2. Set type `ItemData`
3. Isi semua property
4. Item otomatis bisa di-collect ke inventory lewat `PickupItem`

### Mendengarkan Perubahan Inventory

```gdscript
func _ready() -> void:
    EventBus.inventory_updated.connect(_on_inventory_changed)
    EventBus.inventory_full.connect(_on_inventory_full)

func _on_inventory_changed(slots: Array) -> void:
    print("Inventory berubah! Total slot: ", slots.size())

func _on_inventory_full() -> void:
    print("Inventory penuh!")
```

---

## 11. Menambah Komponen Player Baru

Contoh: Menambahkan **sistem armor** ke player.

### Langkah 1: Buat Script

```gdscript
# scripts/player/player_armor.gd
class_name PlayerArmor
extends Node

@export var max_armor: float = 100.0
@export var damage_reduction: float = 0.5  # 50% damage absorbed

var current_armor: float = 0.0

func _ready() -> void:
    add_to_group("player_armor")  # Group unik untuk komponen ini
    EventBus.damage_dealt.connect(_on_damage_dealt)

func _on_damage_dealt(target: Node, amount: float, damage_type: String, source: Node) -> void:
    if target != owner:
        return
    if current_armor <= 0.0:
        return
    # Absorb sebagian damage
    var absorbed := amount * damage_reduction
    absorbed = minf(absorbed, current_armor)
    current_armor -= absorbed
    # Kurangi damage yang diterima health
    # (health akan terima sisa damage yang tidak di-absorb)
    # Note: untuk ini perlu modifikasi health system,
    # atau buat signal baru di EventBus

func add_armor(amount: float) -> void:
    current_armor = minf(max_armor, current_armor + amount)
```

### Langkah 2: Tambahkan ke Player Scene

1. Buka `scenes/player/player.tscn`
2. Tambah child `Node` ke `PlayerController`
3. Assign script `player_armor.gd`

```
PlayerController (CharacterBody3D)
├── CameraRig
├── PlayerMovement
├── PlayerHealth
├── PlayerStamina
├── PlayerArmor          ← BARU
├── ...
```

### Langkah 3: (Opsional) Daftarkan di PlayerController

Jika perlu akses langsung dari controller, tambahkan group lookup:

```gdscript
# Di player_controller.gd, tambahkan:
const GROUP_ARMOR := "player_armor"
var armor: Node = null

# Di _find_components():
armor = _find_in_children(GROUP_ARMOR)
```

> 💡 **Catatan**: Tidak wajib register di controller. Komponen bisa berjalan independen hanya dengan EventBus signals.

---

## 12. Menambah Action Baru

Contoh: Menambahkan aksi **"use item"** (pakai item consumable).

### Langkah 1: Buat Action Script

```gdscript
# scripts/actions/action_use.gd
class_name ActionUse
extends Node

func execute(context: Dictionary) -> void:
    var player: Node = context.get("player")
    var held_item: Node = context.get("held_item")

    if not is_instance_valid(held_item):
        EventBus.action_completed.emit("use", false)
        return

    # Cek apakah item punya heal_amount
    if held_item.has_method("get_item_data"):
        var data: ItemData = held_item.get_item_data()
        if data and data.heal_amount > 0.0:
            EventBus.player_healed.emit(data.heal_amount)
            # Hapus item dari tangan
            held_item.queue_free()
            EventBus.item_dropped.emit(null, Vector3.ZERO)
            EventBus.action_completed.emit("use", true)
            return

    EventBus.action_completed.emit("use", false)
```

### Langkah 2: Tambahkan ke ActionHandler di Player Scene

```
ActionHandler (Node)
├── ActionAttack
├── ActionShoot
├── ActionThrow
├── ActionDrop
├── ActionGrab
├── ActionCollect
└── ActionUse            ← BARU, script: action_use.gd
```

### Langkah 3: Tambah Input Binding

1. Di Godot Editor → **Project → Project Settings → Input Map**
2. Tambah action baru: `use_item` → bind ke tombol `V`

3. Di `input_manager.gd`, tambahkan:

```gdscript
signal use_pressed()

# Di _input():
if event.is_action_pressed("use_item"): emit_signal("use_pressed")
```

### Langkah 4: Connect di ActionHandler

Tambahkan di `action_handler.gd`:

```gdscript
var _action_use: Node = null

# Di _find_action_nodes():
_action_use = get_node_or_null("ActionUse")

func request_use() -> void:
    EventBus.action_requested.emit("use", {"held_item": held_item})
    if is_instance_valid(_action_use) and _action_use.has_method("execute"):
        _action_use.execute({"held_item": held_item, "player": owner})
```

### Langkah 5: Connect di PlayerController

```gdscript
# Di _connect_input_signals():
InputManager.use_pressed.connect(_on_use_pressed)

func _on_use_pressed() -> void:
    if action_handler and action_handler.has_method("request_use"):
        action_handler.request_use()
```

---

## 13. Menggunakan EventBus

EventBus adalah inti komunikasi antar sistem. Berikut signal yang tersedia:

### Game State
```gdscript
EventBus.game_state_changed.connect(func(state: String): print(state))
EventBus.scene_changed.connect(func(path: String): pass)
EventBus.pause_toggled.emit(true)    # Pause game
EventBus.save_requested.emit()       # Trigger save
EventBus.load_requested.emit()       # Trigger load
```

### Player
```gdscript
EventBus.player_spawned.connect(func(player: Node): pass)
EventBus.player_died.connect(func(): get_tree().reload_current_scene())
EventBus.player_health_changed.connect(func(current, max): pass)
EventBus.player_stamina_changed.connect(func(current, max): pass)
EventBus.player_jumped.connect(func(): play_jump_sound())
EventBus.player_landed.connect(func(vel: Vector3): check_fall_damage(vel))
```

### Interaction
```gdscript
EventBus.interactable_focused.connect(func(target): highlight(target))
EventBus.interactable_cleared.connect(func(): clear_highlight())
EventBus.interaction_prompt_show.connect(func(text): show_prompt(text))
EventBus.interaction_prompt_hide.connect(func(): hide_prompt())
```

### Actions & Items
```gdscript
EventBus.attack_performed.connect(func(attacker, targets): screen_shake())
EventBus.shot_fired.connect(func(shooter, origin, dir): spawn_tracer(origin, dir))
EventBus.item_collected.connect(func(data, qty): show_pickup_text(data.item_name))
EventBus.item_thrown.connect(func(item, vel): pass)
EventBus.item_grabbed.connect(func(item): pass)
EventBus.damage_dealt.connect(func(target, amount, type, source): spawn_damage_number())
```

### Inventory & Weapons
```gdscript
EventBus.inventory_updated.connect(func(slots): refresh_ui(slots))
EventBus.inventory_full.connect(func(): show_message("Inventory full!"))
EventBus.weapon_fired.connect(func(data, ammo): update_ammo_display())
EventBus.ammo_changed.connect(func(current, reserve): pass)
```

### Audio
```gdscript
EventBus.play_sound_3d.emit("res://assets/audio/sfx/explosion.ogg", position, 0.0)
EventBus.play_sound_2d.emit("res://assets/audio/sfx/ui_click.ogg", -5.0)
EventBus.play_footstep.emit("wood", player_position)
```

### UI
```gdscript
EventBus.hud_message_show.emit("Quest completed!", 3.0)
EventBus.crosshair_changed.emit("dot")  # Ganti crosshair style
```

### Menambah Signal Baru

Untuk fitur baru, cukup tambahkan signal di `event_bus.gd`:

```gdscript
# --- CUSTOM ---
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal dialog_started(npc_name: String)
signal dialog_ended()
signal level_up(new_level: int)
```

---

## 14. Sistem Audio

### Memutar Sound Effect

```gdscript
# Sound 3D (positional audio)
EventBus.play_sound_3d.emit(
    "res://assets/audio/sfx/weapons/gunshot.ogg",
    global_position,
    0.0  # volume_db (0 = normal, -10 = lebih pelan)
)

# Sound 2D (UI, ambient)
EventBus.play_sound_2d.emit(
    "res://assets/audio/sfx/ui/button_click.ogg",
    -5.0
)
```

### Menambah Audio Files

1. Taruh file `.ogg` atau `.wav` di `assets/audio/sfx/`
2. Organisasi folder:
```
assets/audio/sfx/
├── footsteps/       # Step sounds per surface
│   ├── wood_01.ogg
│   ├── metal_01.ogg
│   └── grass_01.ogg
├── weapons/
│   ├── gunshot.ogg
│   ├── melee_swing.ogg
│   └── reload.ogg
├── items/
│   ├── pickup.ogg
│   ├── drop.ogg
│   └── throw.ogg
└── ui/
    └── button_click.ogg
```

### Footstep per Surface Type

Object di dunia bisa diberi group surface:
```gdscript
# Di script object lantai:
func _ready() -> void:
    add_to_group("surface_wood")
    # Atau: "surface_metal", "surface_grass", "surface_gravel"
```

FootstepSystem otomatis raycast ke bawah player dan memutar sound sesuai surface.

---

## 15. Sistem Save & Load

### Menyimpan Data Custom

```gdscript
# Tulis data sebelum save
SaveManager.write("player_level", 5)
SaveManager.write("unlocked_weapons", ["pistol", "shotgun"])
SaveManager.write("quest_progress", {"main_quest": 3, "side_quest": 1})

# Trigger save
EventBus.save_requested.emit()
```

### Membaca Data Setelah Load

```gdscript
# Trigger load
EventBus.load_requested.emit()

# Baca data (parameter kedua = default value jika key tidak ada)
var level: int = SaveManager.read("player_level", 1)
var weapons: Array = SaveManager.read("unlocked_weapons", [])
var quests: Dictionary = SaveManager.read("quest_progress", {})
```

### Menambah Save Data dari Komponen

Contoh menyimpan posisi player:

```gdscript
# Di player_controller.gd atau komponen lain:
func _ready() -> void:
    EventBus.save_requested.connect(_on_save)
    EventBus.load_requested.connect(_on_load)

func _on_save() -> void:
    SaveManager.write("player_position", {
        "x": global_position.x,
        "y": global_position.y,
        "z": global_position.z
    })

func _on_load() -> void:
    var pos: Dictionary = SaveManager.read("player_position", {})
    if not pos.is_empty():
        global_position = Vector3(pos.x, pos.y, pos.z)
```

### Menghapus Save

```gdscript
SaveManager.delete_save()    # Hapus file save
SaveManager.has_save()       # Cek apakah ada save file
```

---

## 16. Kustomisasi UI / HUD

### Mengubah HUD

1. Buka `scenes/ui/hud.tscn`
2. Semua elemen UI di-control oleh `hud_controller.gd`
3. Elemen yang tersedia:

| Node | Fungsi |
|---|---|
| `HealthBar` | ProgressBar HP |
| `StaminaBar` | ProgressBar Stamina |
| `Crosshair` | TextureRect crosshair |
| `InteractionPrompt` | Label "[E] Interact" |
| `AmmoLabel` | Label "12 / 30" |
| `MessageLabel` | Label pesan sementara |
| `Hotbar` | HBoxContainer 5 slot |

### Menambah Elemen HUD Baru

Contoh: Menambah minimap atau compass:

```gdscript
# Di hud_controller.gd, tambahkan:
@onready var compass: Label = $HUD/Compass

func _process(delta: float) -> void:
    # Update compass berdasarkan rotasi player
    var player := get_tree().get_first_node_in_group("player")
    if player:
        var angle := rad_to_deg(player.rotation.y)
        compass.text = _get_direction(angle)

func _get_direction(angle: float) -> String:
    # Convert angle ke arah mata angin
    if angle > -45 and angle <= 45: return "N"
    if angle > 45 and angle <= 135: return "W"
    if angle > -135 and angle <= -45: return "E"
    return "S"
```

### Menampilkan Pesan di HUD

```gdscript
# Dari script mana saja:
EventBus.hud_message_show.emit("Item acquired!", 2.0)
EventBus.hud_message_show.emit("Door locked. Find the key.", 4.0)
```

---

## 17. Membuat Level Baru

### Langkah 1: Buat Scene Level

1. **Scene → New Scene** → root `Node3D`
2. Tambahkan komponen:

```
NewLevel (Node3D)
├── SkyEnvironment (instance scenes/world/sky_environment.tscn)
├── Floor (StaticBody3D)
│   ├── CollisionShape3D
│   └── MeshInstance3D
├── SpawnPoint (Marker3D) ← HARUS masuk group "spawn_point"
├── AudioManager (Node) ← script: audio_manager.gd
├── DebugOverlay (CanvasLayer) ← script: debug_overlay.gd
│   └── DebugLabel (Label)
├── HUD (instance scenes/ui/hud.tscn)
├── PauseMenu (instance scenes/ui/pause_menu.tscn)
└── InventoryUI (instance scenes/ui/inventory_ui.tscn)
```

> ⚠️ **PENTING**: SpawnPoint HARUS masuk group `"spawn_point"`:
> Klik SpawnPoint → Inspector → Node → Groups → tambah `spawn_point`

### Langkah 2: Buat World Scene

1. Buat scene baru `scenes/core/my_world.tscn`:

```
MyWorld (Node3D) ← script: world.gd
└── NewLevel (instance dari scene level baru)
```

### Langkah 3: Load Level

```gdscript
GameManager.change_scene("res://scenes/core/my_world.tscn")
```

---

## 18. Membuat Enemy Sederhana

Contoh enemy yang bisa menerima damage:

```gdscript
# scripts/enemies/basic_enemy.gd
class_name BasicEnemy
extends CharacterBody3D

@export var max_health: float = 50.0
@export var move_speed: float = 3.0
@export var damage: float = 10.0
@export var attack_range: float = 2.0

var current_health: float = max_health
var _player: Node = null

func _ready() -> void:
    add_to_group("enemy")
    collision_layer = 8        # Layer 4 = enemies
    collision_mask = 1 | 2     # Collide with world + player
    EventBus.damage_dealt.connect(_on_damage_dealt)
    EventBus.player_spawned.connect(func(p): _player = p)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(_player):
        return
    # Sederhana: jalan ke arah player
    var dir := (_player.global_position - global_position).normalized()
    dir.y = 0
    velocity = dir * move_speed
    move_and_slide()

    # Cek jarak untuk attack
    var dist := global_position.distance_to(_player.global_position)
    if dist < attack_range:
        _attack()

func _on_damage_dealt(target: Node, amount: float, type: String, source: Node) -> void:
    if target != self:
        return
    current_health -= amount
    print("Enemy took ", amount, " damage! HP: ", current_health)
    if current_health <= 0.0:
        _die()

func _attack() -> void:
    EventBus.damage_dealt.emit(_player, damage, "melee", self)

func _die() -> void:
    # Drop item (opsional)
    # EventBus.item_dropped.emit(loot_data, global_position)
    queue_free()
```

Scene setup:
```
BasicEnemy (CharacterBody3D) ← script: basic_enemy.gd
├── CollisionShape3D (CapsuleShape3D)
├── MeshInstance3D           ← model atau placeholder
└── NavigationAgent3D        ← untuk pathfinding (opsional)
```

---

## 19. Menambah State Machine

Template menyediakan framework `StateMachine` + `BaseState` untuk AI atau behavior apapun.

### Contoh: Enemy AI States

```gdscript
# scripts/enemies/states/patrol_state.gd
class_name PatrolState
extends BaseState

var _patrol_points: Array[Vector3] = []
var _current_point: int = 0

func enter(_prev: String) -> void:
    print("Enemy: mulai patrol")

func physics_update(delta: float) -> void:
    # Patrol logic
    if _patrol_points.is_empty():
        return
    var target := _patrol_points[_current_point]
    var body: CharacterBody3D = owner_node as CharacterBody3D
    var dir := (target - body.global_position).normalized()
    body.velocity = dir * 3.0
    body.move_and_slide()

    if body.global_position.distance_to(target) < 0.5:
        _current_point = (_current_point + 1) % _patrol_points.size()

    # Cek apakah lihat player
    var player := owner_node.get_tree().get_first_node_in_group("player")
    if player and owner_node.global_position.distance_to(player.global_position) < 10.0:
        # Transition ke chase!
        get_parent().transition_to("ChaseState")
```

```gdscript
# scripts/enemies/states/chase_state.gd
class_name ChaseState
extends BaseState

func enter(_prev: String) -> void:
    print("Enemy: mengejar player!")

func physics_update(delta: float) -> void:
    var player := owner_node.get_tree().get_first_node_in_group("player")
    if not player:
        get_parent().transition_to("PatrolState")
        return

    var body: CharacterBody3D = owner_node as CharacterBody3D
    var dir := (player.global_position - body.global_position).normalized()
    body.velocity = dir * 5.0
    body.move_and_slide()

    if body.global_position.distance_to(player.global_position) > 15.0:
        get_parent().transition_to("PatrolState")
```

Scene setup:
```
EnemyAI (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
└── StateMachine (Node)       ← script: state_machine.gd
    ├── PatrolState (Node)    ← script: patrol_state.gd
    └── ChaseState (Node)     ← script: chase_state.gd
```

StateMachine otomatis mulai dari child pertama (`PatrolState`).

---

## 20. Physics Layer Reference

| Layer | Nama | Bitmask | Digunakan Oleh |
|---|---|---|---|
| 1 | World | `1` | Lantai, dinding, static objects |
| 2 | Player | `2` | PlayerController |
| 3 | Items | `4` | BaseItem dan turunannya |
| 4 | Enemies | `8` | Enemy characters |
| 5 | Projectiles | `16` | Peluru, projectile |
| 6 | Interactables | `32` | Object yang bisa di-interact |

### Kombinasi Umum
| Tujuan | collision_layer | collision_mask |
|---|---|---|
| Player | `2` | `37` (1+4+32) |
| Enemy | `8` | `3` (1+2) |
| Item di dunia | `4` | `1` |
| Item interactable | `36` (4+32) | `1` |
| Projectile | `16` | `9` (1+8) |
| Dinding/lantai | `1` | `0` |

---

## 21. Tips & Best Practices

### ✅ DO (Lakukan)
- **Gunakan EventBus** untuk komunikasi antar sistem — jangan reference langsung
- **Gunakan groups** untuk menemukan node — jangan hardcode NodePath
- **Buat ItemData resource** untuk setiap item — jangan hardcode stats di script
- **Test satu komponen** secara terisolasi — hapus komponen lain, pastikan game tetap jalan
- **Organisasi folder** — taruh script di folder yang sesuai

### ❌ DON'T (Jangan)
- **Jangan modifikasi EventBus signals** yang sudah ada — tambahkan yang baru di bawah
- **Jangan reference player langsung** dari enemy — gunakan `EventBus.player_spawned` atau `get_tree().get_first_node_in_group("player")`
- **Jangan taruh logic di player_controller.gd** — buat komponen terpisah
- **Jangan lupa `add_to_group()`** — tanpa group, PlayerController tidak akan menemukan komponen

### 🏗️ Workflow Menambah Fitur Baru

```
1. Butuh data?        → Buat Resource (.tres)
2. Butuh behavior?    → Buat Script (.gd) + Group
3. Butuh visual?      → Buat Scene (.tscn)
4. Butuh komunikasi?  → Tambah signal di EventBus
5. Butuh input?       → Tambah action di Input Map + InputManager
6. Butuh persistence? → Tambah di SaveManager write/read
7. Butuh UI?          → Tambah di HUD + connect ke EventBus
```

---

## 22. Troubleshooting

### Kamera tidak bisa bergerak
- Pastikan `InputManager` autoload aktif di Project Settings → Autoload
- Pastikan mouse ter-capture: `Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED`

### Player tidak spawn
- Pastikan ada `Marker3D` dengan group `"spawn_point"` di level
- Pastikan `world.gd` di-assign ke root scene

### Interact tidak jalan
- Object HARUS masuk group `"interactable"`
- Object HARUS punya collision di **Layer 6** (interactables)
- Object HARUS punya method `interact(interactor: Node)`

### Item tidak bisa di-collect
- Item HARUS masuk group `"collectible"`
- Item HARUS punya `item_data` resource yang ter-assign
- Player HARUS punya `InventorySystem` di scene tree

### Script error "Cannot find autoload"
- Cek **Project → Project Settings → Autoload** — pastikan path benar
- Urutan autoload: EventBus → InputManager → GameManager → SaveManager

### Scene .tscn error saat import
- Godot mungkin regenerate UID — ini normal
- Jika scene corrupt, recreate manual di editor pakai struktur node yang sama

---

> 📝 **Dokumentasi ini dibuat otomatis. Update sesuai kebutuhan project kamu.**
>
> Template Version: 1.0
> Godot Version: 4.6.3
> Architecture: EventBus + Component-Based Player
