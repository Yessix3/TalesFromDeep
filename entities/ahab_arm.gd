extends CharacterBody2D

signal on_projectile_hit
signal enemy_knockback(Vector2)

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D


var raycast_instance = 1

var spawnPos: Vector2

func _ready():
	global_position = spawnPos
	print("ARM")
	animated_sprite.visible = false
	self.enemy_knockback.connect(Callable(player, "get_knocked_back"))


func _physics_process(delta):
	if raycast.is_colliding() and raycast_instance == 1:
		var point: Vector2 = raycast.get_collision_point()
		point.y = point.y -24
		global_position = point
		raycast_instance = 0
		animated_sprite.visible = true
		animated_sprite.play("Ahab_Arm_1")
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	on_projectile_hit.emit()
	enemy_knockback.emit(global_position)
	print("Arm HIT!")



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Ahab_Arm_3":
		queue_free()
	if animated_sprite.animation == "Ahab_Arm_2":
		animated_sprite.play("Ahab_Arm_3")
		$Area2D/CollisionShape2D.disabled = true
	if animated_sprite.animation == "Ahab_Arm_1":
		animated_sprite.play("Ahab_Arm_2")
		$Area2D/CollisionShape2D.disabled = false
