extends CharacterBody2D

signal knockback

var active := false
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



func _on_vision_area_body_entered(_body: Node2D) -> void:
	active = true


func _on_vision_area_body_exited(_body: Node2D) -> void:
	active = false


func attackPlayer():
	animated_sprite.play("Windup")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Recovery":
		animated_sprite.play("Idle")
		attacking = false 
	if animated_sprite.animation == "Attack":
		animated_sprite.play("Recovery")
		$AttackArea/AttackLeft.disabled = true
		$AttackArea/AttackRight.disabled = true
	if animated_sprite.animation == "Windup":
		animated_sprite.play("Attack")
		$AttackArea/AttackLeft.disabled = false
		$AttackArea/AttackRight.disabled = false


func _on_attack_area_body_entered(_body: Node2D) -> void:
	emit_signal("knockback")


func _on_player_player_hit() -> void:
	if not $Timers/GetHitDelay.time_left :
		if animated_sprite.animation == "Recovery":
			velocity.y = -150
		else:
			velocity.y = -50
		$Timers/GetHitDelay.start()
