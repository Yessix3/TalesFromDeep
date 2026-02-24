class_name GameManager
extends Node

const BATTLE_SCENE := preload("res://levels/BossLevel.tscn")
#const BATTLE_SCENE := preload("res://maptree/dummyFight/dummyFight.tscn")
const BATTLE_REWARD_SCENE := preload("res://maptree/rewardSzene/battle_reward.tscn")
const EVENT_SCENE := preload("res://maptree/Event/event_muster.tscn")
#const MAP_SCENE := preload("res://maptree/mapTree/mapDummy.tscn")
const SHOP_SCENE := preload("res://maptree/shop/shop.tscn")
const RESULT_SCENE := preload("res://maptree/Event/event_result_muster.tscn")

const EVENT_1_DATA:= preload("res://maptree/Event/Events/event_1.tres") as EventData


@export var run_startup: GameManagerStartUp
##
@onready var map: MapTree = $MapTree
##

@onready var current_view: Node = $CurrentView
@onready var shells_ui: ShellsUI = $TopBar/BarItems/ShellsUI
@onready var relic_bar_ui: RelicBarUI = $TopBar/BarItems/RelicBarUI
@onready var relic_desc: RelicMapDescription = $Overlays/RelicMapDescription
@onready var health_ui: HealthUI = $TopBar/BarItems/HealthUI
@onready var battle_over_panel: BattleOverPanel = $Overlays/BattleOverPanel

@onready var protection_timer: Timer = $ProtectionTimer
@onready var poison_timer: Timer = $PoisonTimer

var is_in_battle: bool = false
var status: RunStatus
var frog_poison_bonus: int = 0

func _ready() -> void:
	if not run_startup:
		return
	match run_startup.type:
		GameManagerStartUp.Type.NEW_RUN:
			_start_run()
		GameManagerStartUp.Type.CONTINUED_RUN:
			print("TODO: load previous Run")
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
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()

	map.show_map()
	##########
	map.enable_scroll()
	########
	map.unlock_next_rooms()

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


func _on_battle_won() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_status = status

	# temporary
	reward_scene.add_shells_reward(500)

func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.FIGHT:
			is_in_battle = true
			relic_desc.set_is_in_battle(is_in_battle)
			var fight_view := _change_view(BATTLE_SCENE)
			_bind_player_health(fight_view)
			_bind_enemy_death(fight_view)
		Room.Type.EVENT:
			is_in_battle = false
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
			relic_desc.set_is_in_battle(is_in_battle)
			_change_view(BATTLE_SCENE) #### change later

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

func _bind_enemy_death(_fight_view: Node) -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss == null:
		push_error("Boss not found (group 'boss').")
		return

	if not boss.enemy_died.is_connected(_on_enemy_died):
		boss.enemy_died.connect(_on_enemy_died)
	if not status.outgoing_damage_mult_changed.is_connected(_on_outgoing_mult_changed):
		status.outgoing_damage_mult_changed.connect(_on_outgoing_mult_changed)

	# initial push beim Battle-Start
	_on_outgoing_mult_changed(status.outgoing_damage_mult)

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
	#EventManager.fight_lost.emit()

func _on_enemy_died() -> void:
	if not is_in_battle:
		return
	battle_over_panel.show_screen("Victorious", BattleOverPanel.Type.WIN)


func _on_battle_over_closed(type: int) -> void:
	get_tree().paused = false
	_clear_battle_effects()

	if type == BattleOverPanel.Type.WIN:
		_show_battle_reward()
	else:
		get_tree().change_scene_to_file("res://maptree/mapTree/main_menu.tscn")


func _show_battle_reward() -> void:
	is_in_battle = false
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_status = status
	reward_scene.add_shells_reward(500)

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
	protection_timer.start(duration)

	print("[Protection] USED", relic.display_name, "percent=", percent, "duration=", duration)
	print("[Protection] timer started. time_left=", protection_timer.time_left)

func _on_outgoing_mult_changed(v: int) -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss != null and boss.has_method("set_outgoing_damage_mult"):
		boss.call("set_outgoing_damage_mult", v)
		print("[GM] pushed outgoing mult to boss:", v)
	else:
		print("[GM] boss missing or has no set_outgoing_damage_mult")

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

	poison_timer.start(duration)

	print("[FrogPoison] USED", relic.display_name, " +", percent, "% for ", duration, "s")
	print("[FrogPoison] outgoing_damage_mult now =", status.outgoing_damage_mult, " time_left=", poison_timer.time_left)
