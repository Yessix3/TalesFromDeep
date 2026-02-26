extends CharacterBody2D

signal tazer_hit
signal enemy_knockback(Vector2)


@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@onready var animated_sprite = $AnimatedSprite2D

var acceleration = 0.2
var speed  = 30
var spawnPos

func _ready() -> void:
	global_position = spawnPos
	animated_sprite.play("default")
	self.enemy_knockback.connect(Callable(player, "get_knocked_back"))


func _physics_process(delta: float) -> void:
	moveToPlayer()
	move_and_slide()



func moveToPlayer():
	var target = get_player_pos()
	velocity.x = move_toward(velocity.x, target.x * speed, acceleration)
	velocity.y = move_toward(velocity.y, target.y * speed, acceleration)


func get_player_pos() -> Vector2:
	return (player.global_position - global_position).normalized()



func _on_hit_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	queue_free()



func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		tazer_hit.emit()
		enemy_knockback.emit(global_position)
		queue_free()
