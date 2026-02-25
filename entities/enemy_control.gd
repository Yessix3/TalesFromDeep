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


var number_enemies_current: int

var player_damage_boost_prev: int

signal player_damage_boost_signal(int)

########################################################################
func set_player_damage_boost(v: int) -> void:
	print("[Enemy_control] damage boost:", v)
	player_damage_boost = v
#############################################################################




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in number_enemies_spawn:
		spawnEnemy(enemy_health_boost, enemy_damage_boost)
	number_enemies_current = number_enemies_spawn


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	checkBoost()


func spawnEnemy(health: int,damage: int):
	spawnSalmon(health, damage)


func spawnSalmon(health: int, damage: int):
	var instance = salmon.instantiate()
	var position = player.global_position
	position.x = position.x + 100 * randi_range(1,6)
	var spawn_position = position
	instance.spawnPos = spawn_position
	instance.salmon_hit.connect(Callable(self, "enemy_hit"))
	player_damage_boost_signal.connect(Callable(instance, "player_damage_boost"))
	instance.enemy_dead.connect(Callable(self, "reduceEnemyCount"))
	instance.dmg_Mult = damage
	instance.health_Mult = health
	entities.add_child.call_deferred(instance)


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
