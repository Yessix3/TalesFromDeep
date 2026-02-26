extends CharacterBody2D

signal salmon_hit(int)
signal enemy_knockback(Vector2)
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
var speed = 100
var acceleration = 5
var direction = "left"
var status = "idle"

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@onready var animated_sprite = $AnimatedSprite2D


func _ready():
	damage = int(base_Dmg * ((100.0 + dmg_Mult)/100))
	health = int(base_Health * ((100.0 + health_Mult)/100))
	print(health)
	global_position = spawnPos
	animated_sprite.play("idle")
	self.enemy_knockback.connect(Callable(player, "get_knocked_back"))

func _physics_process(delta):
	if status == "idle":
		face_player()
		pathfinding(delta)
	if status == "attack":
		attack_player()
	move_and_slide()




func pathfinding(delta):
	var vector_player: Vector2 = player.global_position - global_position
	var vector90
	if vector_player.length() <= 150:
		velocity.x = move_toward(velocity.x, vector_player.normalized().x * speed * -1, acceleration)
		velocity.y = move_toward(velocity.y, vector_player.normalized().y * speed * -1, acceleration)
	else:
		velocity.x = move_toward(velocity.x, vector_player.normalized().x * speed, acceleration)
		velocity.y = move_toward(velocity.y, vector_player.normalized().y * speed, acceleration)
	if vector_player.length() >= 50 and vector_player.length() <= 250:
		if direction == "left":
			vector90 = vector_player
			vector90.y = vector90.x * -1
			vector90.x = vector_player.y
			velocity.x = move_toward(velocity.x, vector90.normalized().x * speed, acceleration)
			velocity.y = move_toward(velocity.y, vector90.normalized().y * speed, acceleration)
		else:
			vector90 = vector_player
			vector90.y = vector90.x
			vector90.x = vector_player.y * -1
			velocity.x = move_toward(velocity.x, vector90.normalized().x * speed, acceleration)
			velocity.y = move_toward(velocity.y, vector90.normalized().y * speed, acceleration)
		var i = randi_range(1, 200)
		if i < 2 and status == "idle":
			status = "attack"

func attack_player():
	velocity.x = 0
	velocity.y = 0
	status = "attacking"
	animated_sprite.play("attack_windup")
	

func face_player():
	var vector_player: Vector2 = player.global_position - global_position
	animated_sprite.flip_h = vector_player.x >= 0


#salmon dealing damage
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		salmon_hit.emit(damage)
		enemy_knockback.emit(global_position)
		print(damage)



#salmon taking damage
func _on_area_2d_2_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	health = health - int(10 * ((100.0 + player_Dmg_Mult)/100))
	print(health)
	get_knockback()
	if health <= 0:
		enemy_dead.emit()
		queue_free()

func player_damage_boost(mult: int):
	print("player_dmg_change ", mult)
	player_Dmg_Mult = mult


func get_player_pos() -> Vector2:
	return (player.global_position - global_position).normalized()


func get_knockback():
	velocity.x = get_player_pos().x * -200
	velocity.y = get_player_pos().y * -200


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		animated_sprite.play("idle")
		status = "idle"
		$Area2D/CollisionShape2D.disabled = true
		$Area2D/CollisionShape2D2.disabled = true
	if animated_sprite.animation == "attack_windup":
		animated_sprite.play("attack")
		face_player()
		velocity = get_player_pos() * 300
		if get_player_pos().x >= 0:
			$Area2D/CollisionShape2D.disabled = false
		else:
			$Area2D/CollisionShape2D2.disabled = false
