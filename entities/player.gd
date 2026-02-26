extends CharacterBody2D

signal player_hit
signal hit(damage: int)
####################
signal health_damage(value: int)

@export_group('move')
@export var speed: int = 200
@export var acceleration: int = 800
@export var friction: int = 900
var direction := Vector2.ZERO
var can_move := true
var isAttacking := false
var dummy_strength := 500

# beide Variablen werden nicht
@export var max_health: int = 5
@export var current_health: int = 5


@export_group('jump')
@export var jump_height: int = 300
@export var gravity := 600
@export var terminal_velocity := 500
@export var wall_cling_velocity := 20
var jump := false
var short_jump := false
var face_right := true

@onready var animated_sprite = $AnimatedSprite2D


func _process(delta):
	apply_gravity(delta)
	apply_animation()
	if can_move:
		get_input()
		apply_movement(delta)
		

func get_input():
	#horizontal movement
	direction.x = Input.get_axis("left", "right")
	
	#jump input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or $Timers/jump_delay.time_left:
			jump = true
		if velocity.y > 0 and not is_on_floor():
			$Timers/jump_buffer.start()
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		short_jump = true
		

func apply_movement(delta):
	#left right with acceleration
	if direction.x:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	else: 
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	
	#jumping
	if jump or $Timers/jump_buffer.time_left and (is_on_floor() or is_on_wall()):
		velocity.y = -jump_height
		if is_on_wall():
			velocity.x = direction.x / -2 * jump_height
		jump = false
		short_jump = false
	
	
	
	#delayed jump check
	var on_floor = is_on_floor()
	move_and_slide()
	if on_floor and not is_on_floor() and velocity.y >= 0:
		$Timers/jump_delay.start()
	
	
	#gethit
	


func apply_gravity(delta):
	velocity.y += gravity*delta
	if short_jump and velocity.y < 0:
		velocity.y = velocity.y/2
		short_jump = false
	if is_on_wall_only():
		velocity.y = min(velocity.y, wall_cling_velocity)
	else:
		velocity.y = min(velocity.y, terminal_velocity)
	
	

func apply_animation():
	face_right = direction.x >= 0 and face_right
	face_right = direction.x > 0 or face_right
	
	if Input.is_action_pressed("attack") and not $Timers/attack_delay.time_left:
		animated_sprite.play("Attack")
		$Timers/attack_delay.start()
		if face_right:
			$AttackHitbox/CollisionShape2D_right.disabled = false
		else:
			$AttackHitbox/CollisionShape2D_left.disabled = false
		isAttacking = true
	else:
		if not isAttacking:
			if is_on_floor() and velocity.x == 0:
				animated_sprite.play("Idle")
			if is_on_floor() and velocity.x != 0:
				animated_sprite.play("Walk")
			if not is_on_floor() and velocity.y < 0:
				animated_sprite.play("Jump")
			if not is_on_floor() and velocity.y > 0:
				animated_sprite.play("Fall")
			animated_sprite.flip_h = not face_right
	



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Attack":
		$AttackHitbox/CollisionShape2D_left.disabled = true
		$AttackHitbox/CollisionShape2D_right.disabled = true
		isAttacking = false



func _on_dummy_knockback() -> void:
	velocity.x = ((position - get_parent().get_node("Dummy").position).normalized()*dummy_strength).x
	velocity.y = -dummy_strength/2



func _on_attack_hitbox_body_entered(_body: Node2D) -> void:
		emit_signal("player_hit")
		hit.emit(10)


#####################################
func _on_boss_enemy_hit(damage: int) -> void:
	#var health_compare: int = current_health
	#current_health = current_health - damage
	#
	health_damage.emit(damage)
	print("Player Health: ", current_health)
	


func get_knocked_back(enemyPos: Vector2):
	var knockback = (global_position - enemyPos).normalized() * 300
	if abs(velocity.x) < abs(knockback.x):
		velocity.x = knockback.x
	velocity.y = min(knockback.y, -100, velocity.y + knockback.y, velocity.y - 100)
