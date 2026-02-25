extends CharacterBody2D

signal salmon_hit(int)
signal enemy_dead


var variant = 1
var base_Health = 30
var base_Dmg = 20
var spawnPos: Vector2
var health_Mult: int
var dmg_Mult: int
var player_Dmg_Mult: int
var damage: int
var health: int


func _ready():
	damage = int(base_Dmg * ((100.0 + dmg_Mult)/100))
	health = int(base_Health * ((100.0 + health_Mult)/100))
	print(health)
	global_position = spawnPos

func _physics_process(delta):
	move_and_slide()



#salmon dealing damage
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		salmon_hit.emit(damage)
		print(damage)


#salmon taking damage
func _on_area_2d_2_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	health = health - int(10 * ((100.0 + player_Dmg_Mult)/100))
	print(health)
	if health <= 0:
		enemy_dead.emit()
		queue_free()

func player_damage_boost(mult: int):
	print("player_dmg_change ", mult)
	player_Dmg_Mult = mult
