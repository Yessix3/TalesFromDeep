class_name GameManager
extends Node

const BATTLE_REWARD_SCENE := preload("res://maptree/rewardSzene/battle_reward.tscn")
const EVENT_SCENE := preload("res://maptree/Event/event_muster.tscn")
#const MAP_SCENE := preload("res://maptree/mapTree/mapDummy.tscn")
const SHOP_SCENE := preload("res://maptree/shop/shop.tscn")
const RESULT_SCENE := preload("res://maptree/Event/event_result_muster.tscn")

const EVENT_1_DATA:= preload("res://maptree/Event/Events/event_1.tres") as EventData


@export var run_startup: GameManagerStartUp

@onready var map: MapTree = $MapTree
@onready var current_view: Node = $CurrentView
@onready var shells_ui: ShellsUI = $TopBar/BarItems/ShellsUI
@onready var relic_bar_ui: RelicBarUI = $TopBar/BarItems/RelicBarUI
@onready var relic_desc: RelicMapDescription = $Overlays/RelicMapDescription
@onready var health_ui: HealthUI = $TopBar/BarItems/HealthUI
@onready var battle_over_panel: BattleOverPanel = $Overlays/BattleOverPanel
@onready var menu_button: Button = $CanvasLayer/MenuButton

@onready var protection_timer: Timer = $ProtectionTimer
@onready var poison_timer: Timer = $PoisonTimer


var is_in_battle: bool = false
var is_boss_fight: bool = false
var status: RunStatus
var frog_poison_bonus: int = 0
var save_data: SaveGame = null
var current_battle_config: BattleConfig = null

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_button_pressed)
	if not run_startup:
		return
	match run_startup.type:
		GameManagerStartUp.Type.NEW_RUN:
			_start_run()
		GameManagerStartUp.Type.CONTINUED_RUN:
			if SaveGame.load_data() == null:
				_start_run()
			else:
				_load_run()
	relic_bar_ui.relic_ui_requested.connect(_on_relic_ui_requested)
	battle_over_panel.closed.connect(_on_battle_over_closed)

	protection_timer.timeout.connect(_on_protection_timeout)
	poison_timer.timeout.connect(_on_poison_timeout)
	relic_desc.use_requested.connect(_on_relic_use_requested)


func _start_run() -> void:
	status = RunStatus.new()
	status.died.connect(_on_player_died)

	_setup_event_connections()
	_setup_top_bar()

	EventPool.reset()

	map.generate_new_map()
	map.unlock_floor(0)

	save_data = SaveGame.new()
	_save_run(true)

func _save_run(was_on_map: bool) -> void:
	if save_data == null:
		save_data = SaveGame.new()

	save_data.run_status = status

	save_data.map_data = map.map_data.duplicate(true)
	save_data.last_room = map.last_room
	save_data.floors_climbed = map.floors_climbed
	save_data.was_on_map = was_on_map

	save_data.event_pool_state = EventPool.export_state()

	save_data.save_data()

func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data != null, "Couldn't load last save")


	status = save_data.run_status
	status.died.connect(_on_player_died)

	_setup_event_connections()
	_setup_top_bar()

	map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)

	if save_data.last_room != null and not save_data.was_on_map:
		_on_map_exited(save_data.last_room)

func _on_menu_button_pressed() -> void:
	_save_run(true)
	get_tree().change_scene_to_file("res://maptree/mapTree/main_menu.tscn")

func _change_view(scene: PackedScene) -> Node:
	##########
	map.hide_map()
	map.disable_scroll()
	##########
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()

	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)

	return new_view 

func _show_map() -> void:
	menu_button.visible = true
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()

	map.show_map()
	##########
	map.enable_scroll()
	########
	map.unlock_next_rooms()

	_save_run(true)

func _setup_event_connections() -> void:
	#EventManager.battle_over_closed.connect(_on_battle_over_closed)
	#EventManager.fight_won.connect(_on_battle_won)
	EventManager.battle_reward_exited.connect(_show_map)
	EventManager.event_room_exited.connect(_show_map)
	EventManager.map_exited.connect(_on_map_exited)
	EventManager.shop_exited.connect(_show_map)

	EventManager.result_requested.connect(_on_result_requested)

func _setup_top_bar():
	shells_ui.run_status = status
	relic_bar_ui.run_status = status
	health_ui.run_status = status


#func _on_battle_won() -> void:
#	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
#	reward_scene.run_status = status
#
#	# temporary
#	reward_scene.add_shells_reward(500)

func _on_map_exited(room: Room) -> void:
	_save_run(false)
	menu_button.visible = false
	match room.type:
		Room.Type.FIGHT:
			is_in_battle = true
			is_boss_fight = false
			relic_desc.set_is_in_battle(is_in_battle)

			var floor_1_based := room.row + 1  
			var battle_scene := BattlePool.pick_battle_for_floor(floor_1_based)

			var fight_view := _change_view(battle_scene)

			var cfg := _build_battle_config(floor_1_based)
			_push_config_to_battle(cfg)
			current_battle_config = cfg

			_bind_player_health(fight_view)
			_bind_win_condition(fight_view)
			_bind_enemy_control(fight_view)

		Room.Type.EVENT:
			is_in_battle = false
			is_boss_fight = false

			relic_desc.set_is_in_battle(is_in_battle)
			var view := _change_view(EVENT_SCENE)
			var data := EventPool.draw_random()
			if data == null:
				push_error("No event left to draw.")
				_show_map()
				return
			if view.has_method("show_event"):
				view.call("show_event", data)
			else:
				push_error("EVENT_SCENE root has no show_event(EventData).")
		Room.Type.SHOP:
			is_in_battle = false
			is_boss_fight = false

			relic_desc.set_is_in_battle(is_in_battle)
			var view := _change_view(SHOP_SCENE) as Shop
			view.run_status = status

			var all := RelicDatabase.get_all_relics().duplicate()
			var filtered: Array[RelicData] = []
			for r in all:
				if r == null:
					continue
				# Weapon komplett entfernen, wenn schon gekauft
				if r.type == RelicData.Type.WEAPON and status.get_relic_count(r.id) > 0:
					continue
				filtered.append(r)

			view.stock = filtered
		Room.Type.BOSS:
			is_in_battle = true
			is_boss_fight = true
			relic_desc.set_is_in_battle(is_in_battle)

			var fight_view := _change_view(BattlePool.pick_boss())

			var floor_1_based := room.row + 1
			var cfg := _build_battle_config(floor_1_based)
			current_battle_config = cfg
			_push_config_to_battle(cfg)

			_bind_player_health(fight_view)
			_bind_win_condition(fight_view)

func _on_result_requested(result: EventResultData) -> void:
	var view := _change_view(RESULT_SCENE)
	# ResultScreen sollte eine Methode set_result haben
	if view.has_method("set_result"):
		view.call("set_result", result)
	else:
		push_error("Result view has no set_result(result).")

func _on_relic_ui_requested(relic: RelicData) -> void:
	if battle_over_panel.visible:
		return
	relic_desc.show_modal(status, relic)

func _bind_player_health(_fight_view: Node) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node
	if player == null:
		push_error("Player node not found in fight scene.")
		return

	if not player.health_damage.is_connected(_on_player_health_damage):
		player.health_damage.connect(_on_player_health_damage)
	#player.run_status = status


func _bind_win_condition(_fight_view: Node) -> void:
	# 1) Boss-Level: win kommt vom Boss
	var boss := get_tree().get_first_node_in_group("boss")
	if boss != null:
		if boss.has_signal("enemy_died") and not boss.enemy_died.is_connected(_on_enemy_died):
			boss.enemy_died.connect(_on_enemy_died)
		if not status.outgoing_damage_mult_changed.is_connected(_on_outgoing_mult_changed):
			status.outgoing_damage_mult_changed.connect(_on_outgoing_mult_changed)
		_on_outgoing_mult_changed(status.outgoing_damage_mult)
		return

	# 2) Normaler Fight: win kommt von EnemyControl
	var ec := get_tree().get_first_node_in_group("enemy_control")
	if ec == null:
		push_error("[GM] WinCondition: neither boss nor enemy_control found.")
		return

	if ec.has_signal("all_enemies_dead") and not ec.all_enemies_dead.is_connected(_on_enemy_died):
		ec.all_enemies_dead.connect(_on_enemy_died)
	
	if not status.outgoing_damage_mult_changed.is_connected(_on_outgoing_mult_changed):
		status.outgoing_damage_mult_changed.connect(_on_outgoing_mult_changed)
	_on_outgoing_mult_changed(status.outgoing_damage_mult)

func _bind_enemy_control(_fight_view: Node) -> void:
	var ec := get_tree().get_first_node_in_group("enemy_control")
	if ec == null:
		# Nicht jede Szene muss EnemyControl haben (z.B. reine Boss-Szene ohne Spawner)
		return

	# Beispiel: EnemyControl -> meldet Schaden am Player an GM/RunStatus
	if not ec.enemy_damage.is_connected(_on_player_health_damage):
		ec.enemy_damage.connect(_on_player_health_damage)

func _on_player_health_damage(base_damage: int) -> void:
	if base_damage <= 0:
		print("[GM] health_damage ignored (<=0):", base_damage)
		return

	var final_damage := base_damage

	# Wenn Protection aktiv ist -> reduzieren
	if status.incoming_damage_mult != 0:
		final_damage = status.calc_incoming_damage(base_damage)
		print("[GM] protection active -> base=", base_damage, 
			" final=", final_damage, 
			" mult=", status.incoming_damage_mult)
	else:
		print("[GM] no protection -> damage=", base_damage)

	# apply_health_delta erwartet positiven Schadenwert
	status.apply_health_delta(final_damage)
	print("[GM] RunStatus curr_health now =", status.curr_health)

func _on_player_died() -> void:
	if not is_in_battle:
		return
	
	print("PLAYER DIED")
	battle_over_panel.show_screen("Game Over!", BattleOverPanel.Type.LOSE)

func _on_enemy_died() -> void:
	if not is_in_battle:
		return
	battle_over_panel.show_screen("Victorious", BattleOverPanel.Type.WIN)


func _on_battle_over_closed(type: int) -> void:
	get_tree().paused = false
	_clear_battle_effects()

	if type == BattleOverPanel.Type.WIN:
		if is_boss_fight:
			SaveGame.delete_data()
			get_tree().change_scene_to_file("res://maptree/mapTree/main_menu.tscn")
		else:
			_show_battle_reward()
	else:
		SaveGame.delete_data()
		get_tree().change_scene_to_file("res://maptree/mapTree/main_menu.tscn")


func _show_battle_reward() -> void:
	is_in_battle = false
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_status = status

	var shells := 0
	if current_battle_config != null:
		shells = current_battle_config.shells_reward
	reward_scene.add_shells_reward(shells)

func _on_protection_timeout() -> void:
	print("[Protection] timeout -> reset incoming_damage_mult to 0")
	status.incoming_damage_mult = 0

func _on_poison_timeout() -> void:
	print("[FrogPoison] timeout -> removing bonus", frog_poison_bonus)
	if frog_poison_bonus != 0:
		status.add_outgoing_damage_mult(-frog_poison_bonus)
	frog_poison_bonus = 0

func _clear_battle_effects() -> void:
	if protection_timer.time_left > 0.0:
		print("[Battle] stopping protection timer, time_left=", protection_timer.time_left)
		protection_timer.stop()

	if poison_timer.time_left > 0.0:
		print("[Battle] stopping poison timer, time_left=", poison_timer.time_left)
		poison_timer.stop()
	
	if frog_poison_bonus != 0:
		status.add_outgoing_damage_mult(-frog_poison_bonus)
		frog_poison_bonus = 0

	status.incoming_damage_mult = 0
	print("[Battle] cleared damage mults")
	#_notify_player_poison(false, 0)

func _on_relic_use_requested(relic: RelicData) -> void:
	if relic == null:
		return

	# Health-Potion (geht überall)
	if relic.type == RelicData.Type.POTION and relic.subtype == RelicData.Subtype.HEALTH:
		status.try_use_relic(relic)
		relic_desc.refresh() # falls du sowas hast
		return

	# Battle-only Potions
	if not is_in_battle:
		return

	# Protection
	if relic.type == RelicData.Type.POTION and relic.subtype == RelicData.Subtype.PROTECTION:
		_use_protection_potion(relic)
		return

	# Frog Poison
	if relic.type == RelicData.Type.POISON:
		_use_frog_poison(relic)
		return
	
func _safe_start_timer(t: Timer, duration: float) -> void:
	if t == null:
		return
	if t.is_inside_tree():
		t.start(duration)
	else:
		# startet sobald der GM im Tree ist (nächster Frame)
		call_deferred("_deferred_start_timer", t, duration)

func _deferred_start_timer(t: Timer, duration: float) -> void:
	if is_instance_valid(t) and t.is_inside_tree():
		t.start(duration)

func _use_protection_potion(relic: RelicData) -> void:
	print("_use_protection_potion")
	if status.get_relic_count(relic.id) <= 0:
		print("[Protection] no relic left:", relic.id)
		return

	# Wenn bereits aktiv: neu starten/überschreiben (einfachste Logik)
	if protection_timer.time_left > 0.0:
		print("[Protection] overwrite existing protection. time_left=", protection_timer.time_left)
		protection_timer.stop()

	var percent := int(relic.power)               # 30 oder 15
	var duration := float(relic.duration_sec)     # 60 oder 30

	if duration <= 0.0:
		# falls duration nicht gesetzt ist
		duration = 60.0
		print("[Protection] WARNING duration_sec not set in relic, fallback to 60s")

	# erst konsumieren, wenn wir wirklich anwenden
	status.consume_relic(relic.id, 1)

	status.incoming_damage_mult = -percent
	_safe_start_timer(protection_timer, duration)

	print("[Protection] USED", relic.display_name, "percent=", percent, "duration=", duration)
	print("[Protection] timer started. time_left=", protection_timer.time_left)

func _on_outgoing_mult_changed(v: int) -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss != null and boss.has_method("set_outgoing_damage_mult"):
		boss.call("set_outgoing_damage_mult", v)
		print("[GM] pushed outgoing mult to boss:", v)
		return

	# Normaler Fight (EnemyControl)
	var ec := get_tree().get_first_node_in_group("enemy_control")
	if ec != null and ec.has_method("set_player_damage_boost"):
		ec.call("set_player_damage_boost", v)
		print("[GM] pushed outgoing mult to enemy_control:", v)

func _use_frog_poison(relic: RelicData) -> void:
	if status.get_relic_count(relic.id) <= 0:
		print("[FrogPoison] no relic left:", relic.id)
		return

	if not is_in_battle:
		print("[FrogPoison] not in battle -> blocked")
		return

	# Wenn schon aktiv: neu starten / überschreiben
	if poison_timer.time_left > 0.0:
		print("[FrogPoison] overwrite existing poison. time_left=", poison_timer.time_left)
		poison_timer.stop()

	var percent := int(relic.power)           # 50
	frog_poison_bonus = percent
	var duration := float(relic.duration_sec) # 60

	if duration <= 0.0:
		duration = 60.0
		print("[FrogPoison] WARNING duration_sec not set, fallback 60s")

	if percent == 0:
		percent = 50
		print("[FrogPoison] WARNING power=0, fallback 50%")

	# erst konsumieren, wenn wir anwenden
	status.consume_relic(relic.id, 1)

	# additiv erhöhen (Weapon +25 bleibt erhalten)
	status.add_outgoing_damage_mult(percent)

	_safe_start_timer(poison_timer, duration)

	print("[FrogPoison] USED", relic.display_name, " +", percent, "% for ", duration, "s")
	print("[FrogPoison] outgoing_damage_mult now =", status.outgoing_damage_mult, " time_left=", poison_timer.time_left)


func _build_battle_config(floor_1_based: int) -> BattleConfig:
	var diff := BattleDefaults.difficulty_from_floor(floor_1_based)
	var cfg := BattleDefaults.make_default_config(diff)

	# --- permanent (Run) ---
	cfg.enemy_health_boost += status.enemy_health_boost
	cfg.enemy_damage_boost += status.enemy_damage_boost
	cfg.player_damage_boost += status.outgoing_damage_mult

	# --- next battle (einmalig) ---
	cfg.enemy_health_boost += status.next_enemy_health_boost
	cfg.enemy_damage_boost += status.next_enemy_damage_boost
	cfg.player_damage_boost += status.next_player_damage_boost
	cfg.number_enemies_spawn += status.next_number_enemies_spawn_delta

	# Variant 
	if status.next_enemy_variant_override != -1:
		cfg.enemy_variant = status.next_enemy_variant_override

	status.clear_next_battle_modifiers()

	return cfg

func _push_config_to_battle(cfg: BattleConfig) -> void:

	var boss := get_tree().get_first_node_in_group("boss")
	if boss != null:
		if boss.has_method("apply_battle_config"):
			boss.apply_battle_config(cfg)
		return


	var ec := get_tree().get_first_node_in_group("enemy_control")
	if ec != null:
		if ec.has_method("apply_battle_config"):
			ec.apply_battle_config(cfg)
