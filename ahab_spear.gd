extends CharacterBody2D

@export var speed = 600

signal on_projectile_hit

var direction: float
var spawnPos: Vector2
var spawnRot: float

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	

func _physics_process(delta):
	velocity = Vector2(0, -speed).rotated(direction)
	move_and_slide()
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		on_projectile_hit.emit()
	queue_free()
