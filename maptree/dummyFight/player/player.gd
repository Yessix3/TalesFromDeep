class_name Player

extends CharacterBody2D

@export var speed: float = 400.0

var movement: float = 0.0

func _physics_process(delta):
    if movement != 0.0: 
        velocity.y = 0

        velocity.x = clamp(movement, -1.0, 1.0) * speed

        move_and_collide(velocity * delta)

