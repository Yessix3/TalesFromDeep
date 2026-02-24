extends CharacterBody2D

var active := false
signal knockback

@export var gravity := 600
@onready var player = get_tree().get_first_node_in_group('Player')
@onready var animated_sprite = $AnimatedSprite2D
@onready var attacking := false


func _process(delta):
	if active and not attacking:
		attacking = true
		attackPlayer()
	apply_gravity(delta)
	move_and_slide()


func apply_gravity(delta):
	velocity.y += gravity*delta


func attackPlayer():
	animated_sprite.play("attack")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "recovery": 
		animated_sprite.play("idle")
		attacking = false 
	if animated_sprite.animation == "attack":
		animated_sprite.play("recovery")
		$AttackArea/AttackLeft.disabled = true
		$AttackArea/AttackRight.disabled = true
	if animated_sprite.animation == "jump":
		animated_sprite.play("attack")
		$AttackArea/AttackLeft.disabled = false
		$AttackArea/AttackRight.disabled = false


func _on_attack_area_body_entered(_body: Node2D):
	emit_signal("knockback")


func _on_vision_area_body_entered(_body: Node2D):
	active = true


func _on_vision_area_body_exited(_body: Node2D):
	active = false


func _on_player_player_hit() -> void:
	if not $Timers/GetHitDelay.time_left :
		if animated_sprite.animation == "recovery": 
			velocity.y = -150
		else:
			velocity.y = -50
		$Timers/GetHitDelay.start()