extends Area2D

@export var speed := 400.0
var direction := Vector2.ZERO

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	queue_free()
