extends Node

# communication to the outside
signal all_enemies_dead
signal enemy_damage(int)

#variables connected from the outside, assigned values for testing
var enemy_health_boost = 10
var enemy_damage_boost = -10
var player_damage_boost = 20
var enemy_variant = 1

#unsure where this should be determined
var number_enemies_spawn = 2

@onready var entities: Node = get_tree().get_first_node_in_group("entities")
@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@onready var salmon = load("res://entities/salmon.tscn")
@onready var jelly = load("res://entities/jellyfish.tscn")
@onready var spawnpoint = load("res://components/spawn_point.tscn")

var number_enemies_current: int
var player_damage_boost_prev: int

signal player_damage_boost_signal(int)

var spawnpoint_list = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	link_spawn_points()
	get_spawn_points()
	for i in number_enemies_spawn:
		spawnEnemy(enemy_health_boost, enemy_damage_boost)
	number_enemies_current = number_enemies_spawn


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	checkBoost()


func spawnEnemy(health: int,damage: int):
	var i = randi_range(1,2)
	if i == 1:
		spawnJelly(health, damage)
	else:
		spawnSalmon(health, damage)


func spawnSalmon(health: int, damage: int):
	var instance = salmon.instantiate()
	#
	#var position = player.global_position
	#position.x = position.x + 100 * randi_range(1,6)
	var position = determine_spawn()
	instance.spawnPos = position
	instance.salmon_hit.connect(Callable(self, "enemy_hit"))
	player_damage_boost_signal.connect(Callable(instance, "player_damage_boost"))
	instance.enemy_dead.connect(Callable(self, "reduceEnemyCount"))
	instance.dmg_Mult = damage
	instance.health_Mult = health
	entities.add_child.call_deferred(instance)

func spawnJelly(health: int, damage: int):
	var instance = jelly.instantiate()
	instance.spawnPos = determine_spawn()
	instance.jelly_hit.connect(Callable(self, "enemy_hit"))
	player_damage_boost_signal.connect(Callable(instance, "player_damage_boost"))
	instance.enemy_dead.connect(Callable(self, "reduceEnemyCount"))
	instance.dmg_Mult = damage
	instance.health_Mult = health
	entities.add_child.call_deferred(instance)

func determine_spawn()-> Vector2:
	var i = randi_range(0,spawnpoint_list.size()-1)
	var position = spawnpoint_list[i]
	if i == spawnpoint_list.size()-1:
		spawnpoint_list[i] = spawnpoint_list[0]
	else:
		spawnpoint_list[i] = spawnpoint_list[i+1]
	if position == null:
		return Vector2(0,0)
	return position


func enemy_hit(damage: int):
	print ("player got hit ", damage)
	enemy_damage.emit(damage)

func checkBoost():
	if player_damage_boost != player_damage_boost_prev:
		player_damage_boost_signal.emit(player_damage_boost)
		player_damage_boost_prev = player_damage_boost

func reduceEnemyCount():
	number_enemies_current = number_enemies_current - 1
	if number_enemies_current <= 0:
		all_enemies_dead.emit()
		print("victory")


func set_player_damage_boost(v: int) -> void:
	print("[Enemy_control] damage boost:", v)
	player_damage_boost = v

func link_spawn_points():
	var spwn = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spwn:
		spawnpoint.coordinate.connect(Callable(self, "listSpawnPoints"))

func get_spawn_points():
	get_tree().call_group("spawnpoints", "giveCoordinates")

func listSpawnPoints(coordinate: Vector2):
	spawnpoint_list.append(coordinate)
	print(spawnpoint_list)


func apply_battle_config(cfg: BattleConfig) -> void:

	enemy_health_boost = cfg.enemy_health_boost
	print("[Enemy_control] health boost:", enemy_health_boost)
	enemy_damage_boost = cfg.enemy_damage_boost
	print("[Enemy_control] damage boost:", enemy_damage_boost)
	player_damage_boost = cfg.player_damage_boost
	print("[Enemy_control] player damage boost:", player_damage_boost)

	enemy_variant = cfg.enemy_variant
	number_enemies_spawn = cfg.number_enemies_spawn
	print("[Enemy_control] number_enemies_spawn:", number_enemies_spawn)
