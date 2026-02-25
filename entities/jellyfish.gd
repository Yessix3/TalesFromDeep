extends CharacterBody2D

signal jelly_hit(int)
signal enemy_dead


var variant = 1
var base_Health = 40
var base_Dmg = 20
var spawnPos: Vector2
var health_Mult: int
var dmg_Mult: int
var player_Dmg_Mult: int
var damage: int
var health: int
var speed = 100
var status = "startup"
var friction = 0.3

@onready var entities: Node = get_tree().get_first_node_in_group("entities")
@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var movement_timer = $MoveTimer
@onready var tazer = load("res://entities/jelly_tazer.tscn")

func _ready():
	damage = int(base_Dmg * ((100.0 + dmg_Mult)/100))
	health = int(base_Health * ((100.0 + health_Mult)/100))
	print(health)
	global_position = spawnPos
	animated_sprite.play("idle")




func _physics_process(delta: float) -> void:
	if status == "startup" and randi_range(1,200) <= 2:
		attackPlayer()
	if status == "idle":
		drift()
	if status == "attack":
		attackPlayer()
	move_and_slide()


func player_damage_boost(mult: int):
	print("player_dmg_change ", mult)
	player_Dmg_Mult = mult


func get_player_pos() -> Vector2:
	return (player.global_position - global_position).normalized()


func drift():
	velocity.x = move_toward(velocity.x, 0, friction)
	velocity.y = move_toward(velocity.y, 0, friction)




func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	health = health - int(10 * ((100.0 + player_Dmg_Mult)/100))
	print(health)
	if health <= 0:
		enemy_dead.emit()
		queue_free()


func attackPlayer():
	animated_sprite.play("attack")
	var target = player.global_position
	if get_player_pos().x <= 0:
		target.x = target.x + 100
		target.y = target.y -100
		dashTo(target)
	else:
		target.x = target.x - 100
		target.y = target.y -100
		dashTo(target)
	status = "idle"
	movement_timer.start()



func dashTo(target: Vector2):
	velocity = (target-global_position).normalized() * speed

func _on_move_timer_timeout() -> void:
	status = "attack"
	

func spawnTazer():
	var instance = tazer.instantiate()
	var spawn_position = global_position
	instance.spawnPos = spawn_position
	instance.tazer_hit.connect(Callable(self, "on_tazer_hit"))
	entities.add_child.call_deferred(instance)


func on_tazer_hit():
	jelly_hit.emit(damage)
	print(damage)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		animated_sprite.play("idle")
		spawnTazer()
