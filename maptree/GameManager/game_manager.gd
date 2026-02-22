class_name GameManager
extends Node

const BATTLE_SCENE := preload("res://maptree/dummyFight/dummyFight.tscn")
const BATTLE_REWARD_SCENE := preload("res://maptree/rewardSzene/battle_reward.tscn")
const EVENT_SCENE := preload("res://maptree/Event/event_muster.tscn")
#const MAP_SCENE := preload("res://maptree/mapTree/mapDummy.tscn")
const SHOP_SCENE := preload("res://maptree/shop/shop_dummy.tscn")
const RESULT_SCENE := preload("res://maptree/Event/event_result_muster.tscn")

const EVENT_1_DATA:= preload("res://maptree/Event/Events/event_1.tres") as EventData

@export var run_startup: GameManagerStartUp
##
@onready var map: MapTree = $MapTree
##

@onready var current_view: Node = $CurrentView
@onready var shells_ui: ShellsUI = $TopBar/BarItems/ShellsUI

var status: RunStatus

func _ready() -> void:
	if not run_startup:
		return
	match run_startup.type:
		GameManagerStartUp.Type.NEW_RUN:
			_start_run()
		GameManagerStartUp.Type.CONTINUED_RUN:
			print("TODO: load previous Run")

func _start_run() -> void:
	status = RunStatus.new()
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
	EventManager.fight_won.connect(_on_battle_won)
	EventManager.battle_reward_exited.connect(_show_map)
	EventManager.event_room_exited.connect(_show_map)
	EventManager.map_exited.connect(_on_map_exited)
	EventManager.shop_exited.connect(_show_map)

	EventManager.result_requested.connect(_on_result_requested)

func _setup_top_bar():
	shells_ui.run_status = status

func _on_battle_won() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_status = status

	# temporary
	reward_scene.add_shells_reward(77)

func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.FIGHT:
			_change_view(BATTLE_SCENE)
		Room.Type.EVENT:
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
			_change_view(SHOP_SCENE)
		Room.Type.BOSS:
			_change_view(BATTLE_SCENE) #### change later

func _on_result_requested(result: EventResultData) -> void:
	var view := _change_view(RESULT_SCENE)
	# ResultScreen sollte eine Methode set_result haben
	if view.has_method("set_result"):
		view.call("set_result", result)
	else:
		push_error("Result view has no set_result(result).")
