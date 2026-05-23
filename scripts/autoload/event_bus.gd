extends Node

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
