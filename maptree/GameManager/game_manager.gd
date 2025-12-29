class_name GameManager
extends Node

const BATTLE_SCENE := preload("res://maptree/dummyFight/dummyFight.tscn")
const BATTLE_REWARD_SCENE := preload("res://maptree/rewardSzene/reward_dummy.tscn")
const EVENT_SCENE := preload("res://maptree/dummyEvent/event_dummy.tscn")
#const MAP_SCENE := preload("res://maptree/mapTree/mapDummy.tscn")
const SHOP_SCENE := preload("res://maptree/shop/shop_dummy.tscn")

@export var run_startup: GameManagerStartUp
##
@onready var map: MapTree = $MapTree
##

@onready var current_view: Node = $CurrentView
@onready var battle_button: Button = $VBoxContainer/BattleButton
@onready var event_button: Button = $VBoxContainer/EventButton
@onready var map_button: Button = $VBoxContainer/MapButton
@onready var rewards_button: Button = $VBoxContainer/RewardsButton
@onready var shop_button: Button = $VBoxContainer/ShopButton

func _ready() -> void:
	if not run_startup:
		return
	match run_startup.type:
		GameManagerStartUp.Type.NEW_RUN:
			_start_run()
		GameManagerStartUp.Type.CONTINUED_RUN:
			print("TODO: load previous Run")

func _start_run() -> void:
	_setup_event_connections()

	## Wenn ich Top Bar mit Münzen Mache
	#_setup_top_bar
	map.generate_new_map()
	map.unlock_floor(0)

	#return new_view #??


func _change_view(scene: PackedScene) -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()

	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)

func _show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()

	map.show_map()
	map.unlock_next_rooms()

func _setup_event_connections() -> void:
	EventManager.fight_won.connect(_change_view.bind(BATTLE_REWARD_SCENE))
	EventManager.battle_reward_exited.connect(_show_map)
	EventManager.event_room_exited.connect(_show_map)
	EventManager.map_exited.connect(_on_map_exited)
	EventManager.shop_exited.connect(_show_map)

	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	event_button.pressed.connect(_change_view.bind(EVENT_SCENE))
	map_button.pressed.connect(_show_map)
	rewards_button.pressed.connect(_change_view.bind(BATTLE_REWARD_SCENE))
	shop_button.pressed.connect(_change_view.bind(SHOP_SCENE))

func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.FIGHT:
			_change_view(BATTLE_SCENE)
		Room.Type.EVENT:
			_change_view(EVENT_SCENE)
		Room.Type.SHOP:
			_change_view(SHOP_SCENE)
		Room.Type.BOSS:
			_change_view(BATTLE_SCENE) #### change later
